package ursr

import (
	"github.com/hosted-fornet/ursr/go/pkg/engine"
)

type ProviderAction struct {
	StartJob   ArgsOverNetwork `json:"start-job,omitempty"`
	RelayAudio RawPcm16Le      `json:"relay-audio,omitempty"`
}

type ArgsOverNetwork struct {
	Options engine.Options `json:"options"`
	Tid     string         `json:"tid"`
}

type RawPcm16Le struct {
	Audio []int16 `json:"audio"`
}
