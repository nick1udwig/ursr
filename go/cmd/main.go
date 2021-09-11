package main

import (
	"time"

	"github.com/hosted-fornet/ursr/go/pkg/config"

	"github.com/hosted-fornet/go-urbit"
	"go.uber.org/zap"
)

var (
	sugar *zap.SugaredLogger
)

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

func monitorShipEvents(
	ship *urbit.Client,
	subscription urbit.Result,
	timeout <-chan time.Time,
) (err error) {
	for {
		select {
		case event := <-ship.Events():
			sugar.Debugw(
				"Got event from ship.",
				"event", event,
			)
			switch event.Type {
			case "diff":
				if subscription.ID == event.ID {
					// ship.Poke(config.UrSrProviderAppName, event.Data) // pong
				}
			default:
			}

		case <-timeout:
			sugar.Infow(
				"Shutdown timeout reached.",
				"timeoutSeconds", config.ShutdownTimeout.Seconds(),
			)
			return
		}
	}
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

	subscription := ship.Subscribe(
		config.UrSrProviderAppName,
		config.UrSrProviderPath,
	)
	if subscription.Err != nil {
		sugar.Errorw(
			"Failed to subscribe to provider app.",
			"appName", config.UrSrProviderAppName,
			"path", config.UrSrProviderPath,
			"subscriptionId", subscription.ID,
			"subscriptionErr", subscription.Err,
		)
		closeConnection(ship)
		return
	}
	sugar.Debugw(
		"Connected to provider app.",
		"appName", config.UrSrProviderAppName,
		"path", config.UrSrProviderPath,
		"subscriptionId", subscription.ID,
	)

	timeout := time.After(config.ShutdownTimeout)
	sugar.Debugw(
		"Monitoring events until timeout reached.",
		"timeoutSeconds", config.ShutdownTimeout.Seconds(),
	)

	err = monitorShipEvents(ship, subscription, timeout)
	if err != nil {
		sugar.Errorw(
			"Problem while monitoring ship events.",
			"err", err,
		)
		err = unsubscribe(ship, subscription.ID)
		if err == nil {
			sugar.Debugw("Unsubscribed successfully.")
		}
		closeConnection(ship)
		return
	}

	sugar.Debugw("Closing connection.")
	err = unsubscribe(ship, subscription.ID)
	if err == nil {
		sugar.Debugw("Unsubscribed successfully.")
	}
	err = closeConnection(ship)
	if err == nil {
		sugar.Debugw("Exiting successfully.")
	}
	return
}
