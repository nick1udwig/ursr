package main

import (
	"bytes"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"time"

	"github.com/hosted-fornet/ursr/go/pkg/config"
	"github.com/hosted-fornet/ursr/go/pkg/engine"
	"github.com/hosted-fornet/ursr/go/pkg/ursr"

	"github.com/hosted-fornet/go-urbit"
	"go.uber.org/zap"
)

var (
	sugar *zap.SugaredLogger
)

func subscribe(
	ship *urbit.Client,
	appName string,
	subscriptionPath string,

) (subscription urbit.Result, err error) {
	subscription = ship.Subscribe(appName, subscriptionPath)
	if subscription.Err != nil {
		sugar.Errorw(
			"Failed to subscribe.",
			"appName", appName,
			"path", subscriptionPath,
			"subscriptionId", subscription.ID,
			"subscriptionErr", subscription.Err,
		)
	}
	return
}

func unsubscribe(ship *urbit.Client, subscriptionId uint64) (err error) {
	unsubscribeResult := ship.Unsubscribe(subscriptionId)
	if unsubscribeResult.Err != nil {
		sugar.Errorw(
			"Problem while unsubscribing.",
			"unsubscribeId", unsubscribeResult.ID,
			"unsubscribeErr", unsubscribeResult.Err,
		)
		err = unsubscribeResult.Err
	}
	return
}

func closeConnection(ship *urbit.Client) (err error) {
	err = ship.Close()
	if err != nil {
		sugar.Errorw(
			"Error closing connection.",
			"err", err,
		)
	}
	return
}

func monitorSubscriptionEvents(
	ship *urbit.Client,
	appSubscription urbit.Result,
	timeout <-chan time.Time,
) (err error) {
	subscriptionsToJobs := map[uint64]engine.Job{}
	for {
		select {
		case event := <-ship.Events():
			// sugar.Debugw(
			// 	"Got event from ship.",
			// 	"event", event,
			// )
			switch event.Type {
			case "diff":
				if event.ID == appSubscription.ID {
					go startNewJob(ship, event, subscriptionsToJobs)
				} else if _, ok := subscriptionsToJobs[event.ID]; ok {
					go relayAudio(event, subscriptionsToJobs)
				}
			default:
			}

		case <-timeout:
			sugar.Infow(
				"Shutdown timeout reached.",
				"timeoutSeconds", config.ShipSubShutdownTimeout.Seconds(),
			)
			return
		}
	}
}

func startNewJob(ship *urbit.Client, event *urbit.Event, subscriptionsToJobs map[uint64]engine.Job) (err error) {
	action := &ursr.Action{}
	err = json.Unmarshal(event.Data, action)
	if err != nil {
		sugar.Errorw(
			"Trouble reading in app subscription JSON.",
			"subscriptionId", event.ID,
			"err", err,
		)
		return
	}
	args := action.StartJob

	newJob := &engine.Job{ProviderShipTid: args.Tid}
	err = newJob.DialEngine(config.DefaultEngineUri)
	if err != nil {
		sugar.Errorw(
			"Trouble dialing Engine.",
			"subscriptionId", event.ID,
			"err", err,
		)
		return
	}

	err = newJob.SendOptions(args.Options)
	if err != nil {
		sugar.Errorw(
			"Trouble sending options to Engine.",
			"subscriptionId", event.ID,
			"err", err,
		)
		return
	}

	newSubscription, err := subscribe(
		ship,
		"spider",
		fmt.Sprintf("/thread/%v/updates", newJob.ProviderShipTid),
	)
	if err != nil {
		// TODO: Send error to Mars.
		sugar.Errorw(
			"Trouble creating new job thread subscription.",
			"subscriptionId", event.ID,
			"err", err,
		)
		return
	}
	sugar.Debugw(
		"Subscribed to thread.",
		"path", fmt.Sprintf("/thread/%v/updates", newJob.ProviderShipTid),
	)
	subscriptionsToJobs[newSubscription.ID] = *newJob
	go relayReplies(ship, newJob, newSubscription.ID)
	return
}

func relayAudio(event *urbit.Event, subscriptionsToJobs map[uint64]engine.Job) (err error) {
	job := subscriptionsToJobs[event.ID]
	action := &ursr.Action{}
	err = json.Unmarshal(event.Data, action)
	if err != nil {
		sugar.Errorw(
			"Trouble reading in job thread subscription JSON.",
			"subscriptionId", event.ID,
			"job", job,
			"err", err,
		)
		return
	}
	if action.AudioDone {
		sugar.Debugw(
			"Got audio done signal for job.",
			"subscriptionId", event.ID,
		)
		delete(subscriptionsToJobs, event.ID)
		err = job.SendAudioBytes([]byte(config.AudioDoneSignal))
		if err != nil {
			sugar.Errorw(
				"Trouble sending Engine EOF.",
				"subscriptionId", event.ID,
				"job", job,
				"err", err,
			)
		}
		return
	}

	samples := action.RelayAudio

	// https://stackoverflow.com/a/27815101
	buf := new(bytes.Buffer)
	err = binary.Write(buf, binary.LittleEndian, samples.Audio)
	if err != nil {
		sugar.Errorw(
			"Trouble converting audio int16s to bytes.",
			"subscriptionId", event.ID,
			"job", job,
			"err", err,
		)
		return
	}

	err = job.SendAudioBytes(buf.Bytes())
	if err != nil {
		sugar.Errorw(
			"Trouble sending audio bytes for job.",
			"subscriptionId", event.ID,
			"job", job,
			"err", err,
		)
	}
	return
}

func relayReplies(ship *urbit.Client, job *engine.Job, subscriptionId uint64) (err error) {
	reply, err := job.NextReply()
	if err != nil {
		sugar.Errorw(
			"Trouble reading/parsing reply from Engine.",
			"subscriptionId", subscriptionId,
			"err", err,
		)
	} else {
		for reply.Status != "completed" && reply.Status != "failed" {
			sugar.Debugw(
				"Got Engine reply.",
				"subscriptionId", subscriptionId,
				"reply", *reply,
			)
			if reply.Transcript != "" {
				// TODO: remove this hack
				if reply.TranscriptFormatted != "" {
					// replyAction := &ursr.Action{RelayReply: *reply}
					replyAction := &struct {
						RelayReply engine.ReplyUrbitFormat `json:"relay-reply"`
					}{RelayReply: engine.ReplyToUrbitFormat(reply)}

					replyBytes, err := json.Marshal(replyAction)
					if err == nil {
						pokeResult := ship.PokeShipMark(
							ship.Name(),
							config.UrSrProviderAppName,
							"ursr-action",
							replyBytes,
						)
						err = pokeResult.Wait()
						if err != nil {
							sugar.Errorw(
								"Failed to relay Engine reply to ship.",
								"subscriptionId", subscriptionId,
								"err", err,
								"ship", ship.Name(),
								"app", config.UrSrProviderAppName,
								"mark", "ursr-action",
								"replyAction", replyAction,
								"replyBytes", replyBytes,
							)
						} else {
							sugar.Debugw(
								"Sent poke to relay Engine reply to ship.",
								"subscriptionId", subscriptionId,
								"ship", ship.Name(),
								"app", config.UrSrProviderAppName,
								"mark", "ursr-action",
								"replyAction", replyAction,
								"replyBytes", replyBytes,
							)
						}
					} else {
						sugar.Errorw(
							"Failed to marshal reply to ship.",
							"subscriptionId", subscriptionId,
							"err", err,
							"ship", ship.Name(),
							"app", config.UrSrProviderAppName,
							"mark", "ursr-action",
							"replyAction", replyAction,
						)
					}
				}
			}
			reply, err = job.NextReply()
			if err != nil {
				sugar.Errorw(
					"Failed to get next Engine reply.",
					"subscriptionId", subscriptionId,
					"err", err,
				)
			}
		}
		err = job.Close()
		if err != nil {
			sugar.Errorw(
				"Trouble closing Engine connection.",
				"subscriptionId", subscriptionId,
				"job", job,
				"err", err,
			)
		}
	}
	return
}

func main() {
	logger, _ := zap.NewDevelopment()
	defer logger.Sync()
	sugar = logger.Sugar()
	sugar.Debugw("Initialized logger.")

	ship, err := urbit.Dial(config.Address, config.Passcode, nil)
	if err != nil {
		sugar.Errorw(
			"Failed to connect with ship.",
			"address", config.Address,
			"err", err,
		)
		return
	}
	sugar.Debugw(
		"Connected to ship.",
		"address", config.Address,
	)

	appSubscription, err := subscribe(
		ship,
		config.UrSrProviderAppName,
		config.UrSrProviderPath,
	)
	if err != nil {
		closeConnection(ship)
		return
	}
	sugar.Debugw(
		"Connected to provider app.",
		"appName", config.UrSrProviderAppName,
		"path", config.UrSrProviderPath,
		"appSubscriptionId", appSubscription.ID,
	)

	timeout := time.After(config.ShipSubShutdownTimeout)
	sugar.Debugw(
		"Monitoring events until timeout reached.",
		"timeoutSeconds", config.ShipSubShutdownTimeout.Seconds(),
	)

	monitorSubscriptionEvents(ship, appSubscription, timeout)

	sugar.Debugw("Closing connection.")
	err = unsubscribe(ship, appSubscription.ID)
	if err == nil {
		sugar.Debugw("Unsubscribed successfully.")
	}
	err = closeConnection(ship)
	if err == nil {
		sugar.Debugw("Exiting successfully.")
	}
	return
}
