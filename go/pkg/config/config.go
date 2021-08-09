package config

import (
	"time"
)

const (
	UrSrProviderAppName = "ursr-provider"
	UrSrProviderPath    = "/urth-path"
)

var (
	Address  = "http://localhost:8080"
	Passcode = "lapwen-fadtun-lagsyl-fadpex" // wes

	ShutdownTimeout = 60 * time.Second
)
