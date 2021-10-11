package ursr

import (
	"github.com/hosted-fornet/ursr/go/pkg/engine"
)

type Payload struct {
	JobId  uint64 `json:"job-id"`
	Action Action `json:"action"`
}

type Action struct {
	AudioDone    bool                    `json:"audio-done"`
	RelayAudio   RawPcm16Le              `json:"relay-audio"`
	RelayOptions engine.Options          `json:"relay-options"`
	RelayReply   engine.ReplyUrbitFormat `json:"relay-reply"`
	StartJob     ArgsOverNetwork         `json:"provider-start-job"`
}

type ArgsOverNetwork struct {
	Options engine.Options `json:"options"`
	Tid     string         `json:"tid"`
}

type RawPcm16Le struct {
	Audio []int16 `json:"audio"`
}
