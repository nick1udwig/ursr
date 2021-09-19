package ursr

import (
	"github.com/hosted-fornet/ursr/go/pkg/engine"
)

type ProviderAction struct {
	AudioDone  bool                    `json:"audio-done"`
	RelayAudio RawPcm16Le              `json:"relay-audio"`
	RelayReply engine.ReplyUrbitFormat `json:"relay-reply"`
	StartJob   ArgsOverNetwork         `json:"start-job"`
}

type ArgsOverNetwork struct {
	Options engine.Options `json:"options"`
	Tid     string         `json:"tid"`
}

type RawPcm16Le struct {
	Audio []int16 `json:"audio"`
}
