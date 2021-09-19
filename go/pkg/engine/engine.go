package engine

import (
	"bufio"
	"encoding/json"
	"net"

	"github.com/hosted-fornet/ursr/go/pkg/config"
)

type Options struct {
	Command             string `json:"command"`
	Format              string `json:"format"`
	Encoding            string `json:"encoding"`
	Rate                uint   `json:"rate"`
	TranscriptFormatted bool   `json:"transcript-formatted"`
}

// Union of fields in replies:
//  not every reply has these fields.
type ReplyEngineFormat struct {
	AsrModel            string        `json:"asr_model,omitempty"`
	Engine              EngineVersion `json:"engine,omitempty"`
	Final               bool          `json:"final"`
	ResultIndex         uint          `json:"result_index"`
	Status              string        `json:"status"`
	Transcript          string        `json:"transcript,omitempty"`
	TranscriptFormatted string        `json:"transcript_formatted,omitempty"`
	Uuid                string        `json:"uuid,omitempty"`
	Warning             string        `json:"warning,omitempty"`
}

// Union of fields in replies:
//  not every reply has these fields.
type ReplyUrbitFormat struct {
	Final               bool   `json:"final"`
	ResultIndex         uint   `json:"result-index"`
	Status              string `json:"status"`
	Transcript          string `json:"transcript,omitempty"`
	TranscriptFormatted string `json:"transcript-formatted,omitempty"`
}

type EngineVersion struct {
	Hostname string `json:"hostname,omitempty"`
	Version  string `json:"version,omitempty"`
}

type Job struct {
	conn       net.Conn
	sockReader *bufio.Reader

	ProviderShipTid string
}

func (e *Job) DialEngine(uri string) (err error) {
	if uri == "" {
		uri = config.DefaultEngineUri
	}

	e.conn, err = net.Dial("tcp", uri)
	if err == nil {
		e.sockReader = bufio.NewReader(e.conn)
	}
	return
}

func (e *Job) SendOptions(options Options) (err error) {
	jsonBytes, err := json.Marshal(&options)
	if err == nil {
		jsonBytes = append(jsonBytes, '\n')
		_, err = e.conn.Write(jsonBytes)
	}
	return
}

func (e *Job) SendAudioBytes(audio []byte) (err error) {
	_, err = e.conn.Write(audio)
	return
}

func (e *Job) NextReplyBytes() ([]byte, error) {
	return e.sockReader.ReadSlice('\n')
}

func (e *Job) NextReply() (reply *ReplyEngineFormat, err error) {
	replyBytes, err := e.NextReplyBytes()
	if err == nil {
		reply = &ReplyEngineFormat{}
		err = json.Unmarshal(replyBytes, reply)
	}
	return
}

func (e *Job) Close() error {
	return e.conn.Close()
}

func ReplyToUrbitFormat(r *ReplyEngineFormat) (replyUrbit ReplyUrbitFormat) {
	replyUrbit = ReplyUrbitFormat{
		Final:               r.Final,
		ResultIndex:         r.ResultIndex,
		Status:              r.Status,
		Transcript:          r.Transcript,
		TranscriptFormatted: r.TranscriptFormatted,
	}
	return
}
