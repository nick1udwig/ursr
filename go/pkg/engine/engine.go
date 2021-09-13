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
type Reply struct {
	AsrModel            string        `json:"asr_model,omitempty"`
	Engine              EngineVersion `json:"engine,omitempty"`
	Final               bool          `json:"final,omitempty"`
	ResultIndex         uint          `json:"result_index,omitempty"`
	Status              string        `json:"status"`
	Transcript          string        `json:"transcript,omitempty"`
	TranscriptFormatted string        `json:"transcript_formatted,omitempty"`
	Uuid                string        `json:"uuid,omitempty"`
	Warning             string        `json:"warning,omitempty"`
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

func (e *Job) NextReply() (reply *Reply, err error) {
	replyBytes, err := e.NextReplyBytes()
	if err == nil {
		reply = &Reply{}
		err = json.Unmarshal(replyBytes, reply)
	}
	return
}
