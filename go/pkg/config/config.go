package config

import (
	"time"
)

const (
	AudioDoneSignal = "END-OF-FILE"

	DefaultEngineUri string = "localhost:9900"
	DefaultPasscode  string = "lapwen-fadtun-lagsyl-fadpex" // wes
	DefaultShipUri   string = "http://localhost:8080"

	UrSrProviderAppName string = "ursr-provider"
	UrSrProviderPath    string = "/urth-path"
)

var (
	ShipUri  string = DefaultShipUri
	Passcode string = DefaultPasscode

	EngineUri string = DefaultEngineUri

	// EngineDialTimeout      time.Duration = 60 * time.Second
	ShipSubShutdownTimeout time.Duration = 60 * time.Second
)
