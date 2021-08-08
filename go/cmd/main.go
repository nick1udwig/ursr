package main

import (
	"github.com/hosted-fornet/ursr/go/pkg/config"

	"github.com/hosted-fornet/go-urbit"
	"go.uber.org/zap"
)

var (
	sugar *zap.SugaredLogger
)

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

	sugar.Debugw("Exiting successfully.")
	ship.Close()
	return
}
