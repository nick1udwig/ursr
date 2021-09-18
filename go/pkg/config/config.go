package config

import (
	"time"
)

const (
	DefaultEngineUri = "localhost:9900"

	UrSrProviderAppName string = "ursr-provider"
	UrSrProviderPath    string = "/urth-path"
)

var (
	Address  string = "http://localhost:8080"
	Passcode string = "lapwen-fadtun-lagsyl-fadpex" // wes

	// EngineDialTimeout      time.Duration = 60 * time.Second
	ShipSubShutdownTimeout time.Duration = 5 * 60 * time.Second
)
