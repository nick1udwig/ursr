package ursr

import (
	"math"
	"strconv"
	"strings"

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

func OffsetToIndex(bytes []byte, delimiter byte, offset int) (index int) {
	for i, c := range bytes {
		if c == delimiter {
			if i == offset {
				break
			}
			index += 1
		}
	}
	return
}

func jsonValueToInt64(jsonValue string) (jsonInt64 int64) {
	jsonValues := strings.Split(jsonValue, " ")
	jsonInt64, _ = strconv.ParseInt(jsonValues[1], 10, 64)
	return
}

func JsonValueToClippedInt16(jsonValue string) (clippedInt16 int16) {
	jsonInt64 := jsonValueToInt64(jsonValue)
	switch {
	case jsonInt64 < math.MinInt16:
		clippedInt16 = math.MinInt16
	case jsonInt64 > math.MaxInt16:
		clippedInt16 = math.MaxInt16
	default:
		clippedInt16 = int16(jsonInt64)
	}
	return
}
