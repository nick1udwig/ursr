package main

import (
	"bytes"
	"encoding/binary"
	"encoding/json"
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
	err = subscription.Wait()
	if err != nil {
		sugar.Errorw(
			"Failed to subscribe.",
			"appName", appName,
			"path", subscriptionPath,
			"subscriptionId", subscription.ID,
			"subscriptionErr", err,
		)
	}
	return
}

func unsubscribe(ship *urbit.Client, subscriptionId uint64) (err error) {
	unsubscribeResult := ship.Unsubscribe(subscriptionId)
	err = unsubscribeResult.Wait()
	if err != nil {
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
	jobIdsToJobs := map[uint64]engine.Job{}
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
					payload := &ursr.Payload{}
					err = json.Unmarshal(event.Data, payload)
					if err != nil {
						sugar.Errorw(
							"Trouble reading in app subscription JSON.",
							"subscriptionId", event.ID,
							"err", err,
						)
						return
					}
					if _, ok := jobIdsToJobs[payload.JobId]; ok {
						go relayAudio(payload, jobIdsToJobs)
					} else {
						go startNewJob(ship, payload, jobIdsToJobs)
					}
				} else {
					sugar.Errorw(
						"Unexpected subscription ID.",
						"event", event,
						"expectedAppSubscriptionId", appSubscription.ID,
					)
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

func startNewJob(ship *urbit.Client, payload *ursr.Payload, jobIdsToJobs map[uint64]engine.Job) (err error) {
	newJob := &engine.Job{JobId: payload.JobId}
	err = newJob.DialEngine(config.DefaultEngineUri)
	if err != nil {
		sugar.Errorw(
			"Trouble dialing Engine.",
			"jobId", payload.JobId,
			"err", err,
		)
		return
	}

	err = newJob.SendOptions(payload.Action.RelayOptions)
	if err != nil {
		sugar.Errorw(
			"Trouble sending options to Engine.",
			"jobId", payload.JobId,
			"err", err,
		)
		return
	}

	jobIdsToJobs[payload.JobId] = *newJob
	go relayReplies(ship, newJob, payload.JobId)
	return
}

func relayAudio(payload *ursr.Payload, jobIdsToJobs map[uint64]engine.Job) (err error) {
	job := jobIdsToJobs[payload.JobId]
	if payload.Action.AudioDone {
		sugar.Debugw(
			"Got audio done signal for job.",
			"jobId", payload.JobId,
		)
		delete(jobIdsToJobs, payload.JobId)
		err = job.SendAudioBytes([]byte(config.AudioDoneSignal))
		if err != nil {
			sugar.Errorw(
				"Trouble sending Engine EOF.",
				"jobId", payload.JobId,
				"job", job,
				"err", err,
			)
		}
		return
	}

	samples := payload.Action.RelayAudio

	// https://stackoverflow.com/a/27815101
	buf := new(bytes.Buffer)
	err = binary.Write(buf, binary.LittleEndian, samples.Audio)
	if err != nil {
		sugar.Errorw(
			"Trouble converting audio int16s to bytes.",
			"jobId", payload.JobId,
			"job", job,
			"err", err,
		)
		return
	}

	err = job.SendAudioBytes(buf.Bytes())
	if err != nil {
		sugar.Errorw(
			"Trouble sending audio bytes for job.",
			"jobId", payload.JobId,
			"job", job,
			"err", err,
		)
	}
	return
}

func relayReplies(ship *urbit.Client, job *engine.Job, jobId uint64) (err error) {
	reply, err := job.NextReply()
	if err != nil {
		sugar.Errorw(
			"Trouble reading/parsing reply from Engine.",
			"jobId", jobId,
			"err", err,
		)
	} else {
		for reply.Status != "completed" && reply.Status != "failed" {
			sugar.Debugw(
				"Got Engine reply.",
				"jobId", jobId,
				"reply", *reply,
			)
			if reply.Transcript != "" {
				// TODO: remove this hack
				if reply.TranscriptFormatted != "" {
					type ReplyAction struct {
						RelayReply engine.ReplyUrbitFormat `json:"relay-reply"`
					}
					replyPayload := &struct {
						JobId  uint64      `json:"job-id"`
						Action ReplyAction `json:"action"`
					}{
						JobId: jobId,
						Action: ReplyAction{
							RelayReply: engine.ReplyToUrbitFormat(reply),
						},
					}

					// // replyAction := &ursr.Action{RelayReply: *reply}
					// replyAction := &struct {
					// 	RelayReply engine.ReplyUrbitFormat `json:"relay-reply"`
					// }{RelayReply: engine.ReplyToUrbitFormat(reply)}

					// replyBytes, err := json.Marshal(replyAction)
					replyBytes, err := json.Marshal(replyPayload)
					if err == nil {
						pokeResult := ship.PokeShipMark(
							ship.Name(),
							config.UrSrProviderAppName,
							// "ursr-action",
							"ursr-payload",
							replyBytes,
						)
						err = pokeResult.Wait()
						if err != nil {
							sugar.Errorw(
								"Failed to relay Engine reply to ship.",
								"jobId", jobId,
								"err", err,
								"ship", ship.Name(),
								"app", config.UrSrProviderAppName,
								"mark", "ursr-action",
								// "replyAction", replyAction,
								"replyPayload", replyPayload,
								"replyBytes", replyBytes,
							)
						} else {
							sugar.Debugw(
								"Sent poke to relay Engine reply to ship.",
								"jobId", jobId,
								"ship", ship.Name(),
								"app", config.UrSrProviderAppName,
								"mark", "ursr-action",
								// "replyAction", replyAction,
								"replyPayload", replyPayload,
								"replyBytes", replyBytes,
							)
						}
					} else {
						sugar.Errorw(
							"Failed to marshal reply to ship.",
							"jobId", jobId,
							"err", err,
							"ship", ship.Name(),
							"app", config.UrSrProviderAppName,
							"mark", "ursr-action",
							// "replyAction", replyAction,
							"replyPayload", replyPayload,
						)
					}
				}
			}
			reply, err = job.NextReply()
			if err != nil {
				sugar.Errorw(
					"Failed to get next Engine reply.",
					"jobId", jobId,
					"err", err,
				)
			}
		}
		err = job.Close()
		if err != nil {
			sugar.Errorw(
				"Trouble closing Engine connection.",
				"jobId", jobId,
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
		"name", ship.Name(),
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
