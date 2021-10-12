package ursr

import (
	"github.com/hosted-fornet/ursr/go/pkg/engine"
)

type Action struct {
	AudioDone    bool                    `json:"audio-done"`
	JobDone      bool                    `json:"job-done"`
	RelayAudio   RawPcm16Le              `json:"relay-audio"`
	RelayOptions engine.Options          `json:"relay-options"`
	RelayReply   engine.ReplyUrbitFormat `json:"relay-reply"`
}

type ArgsOverNetwork struct {
	Options engine.Options `json:"options"`
	Tid     string         `json:"tid"`
}

type Payload struct {
	JobId  uint64 `json:"job-id"`
	Action Action `json:"action"`
}

type RawPcm16Le struct {
	Audio []int16 `json:"audio"`
}

// Specialized actions/payloads for sending.

type JobDoneAction struct {
	JobDone bool `json:"job-done"`
}

type JobDonePayload struct {
	JobId  uint64        `json:"job-id"`
	Action JobDoneAction `json:"action"`
}

type ReplyAction struct {
	RelayReply engine.ReplyUrbitFormat `json:"relay-reply"`
}

type ReplyPayload struct {
	JobId  uint64      `json:"job-id"`
	Action ReplyAction `json:"action"`
}
