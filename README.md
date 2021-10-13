# UrSR: Urbit Speech Recognition

For some applications, speech is far more natural than text.
UrSR aims to enable calm computing with the power of voice.
It consists of a Gall app and a Golang middleman, and leverages the
[Mod9 ASR Engine](https://mod9.io/)
to make ASR as simple as a poke.


# UrSR Demo Notebook usage example

WARNING: This is ALPHA software.
It shouldn't brick your ship, but
I would STRONGLY advise you to run this on a moon.
You can find instructions on how to boot a moon
[here](https://urbit.org/using/os/basics#moons).

To use the UrSR Demo Notbook voice notes app,
you will need a machine with a mic and to:

1. Know an UrSR provider (currently `~hoster-hosted-labweb` is running a provider node).
1. Get the UrSR Client (which knows how to talk to the provider).
1. Get the UrSR Demo Notebook voice notes app (which is an *aesthetic* JS frontend).

ON A MOON, install the UrSR Client and UrSR Demo Notebook apps:

```
:: Add my software distribution ship as a developer.
:treaty|ally ~dister-hosted-labweb
```

Then, in Grid, search for `~dister-hosted-labweb` and click
to install BOTH UrSR Client and UrSR Demo Notebook.
The UrSR Client will run a Gall app that communicates with
your UrSR Provider of choice, while the Demo Notebook is
an example of a frontend webapp that can take advantage of ASR.

(Alternative install method: `|install ~dister-hosted-labweb %ursr-client`).

For best experience, create a group on your ship and a `Chat`
channel within that group: the UrSR Demo Notebook will post
transcripts to a chat.

Then, open the UrSR Demo Notebook app by clicking the tile in Grid.

For the `Provider` field, fill in

```
~hoster-hosted-labweb
```

which is my UrSR Provider ship.
You will need to enter your `+code`
(another good reason to do this ON A MOON)
so the JS webapp can talk to your ship.
And finally, write in the `Chat` channel name you created a minute ago.
Look in the URL when you are in the `Chat` channel in order to get
the chat name and place ONLY the chat name in this field.
For example, if your URL when you are in the `Chat` channel is

```
http://localhost:8081/apps/landscape/~landscape/ship/~nec/abcdefg/resource/chat/ship/~nec/my-voice-362
```

then you should put

```
my-voice-362
```

into the `Chat` field in the UrSR Demo Notebook webapp.
The `Chat` MUST be hosted on your ship to work!


# Provider set up

It is my intention to make provider set up easier,
but until then, here is a guide.

A provider needs to set up three things:

1. The UrSR Provider Gall app on the provider ship.
1. The Mod9 ASR Engine, a TCP server that will do
   the actual transcription.
1. A golang "wrapper" server that communicates between
   the UrSR Provider Gall app and the Mod9 ASR Engine.

## UrSR Provider Gall app

On your provider ship (recommended to be a moon!)
install the UrSR Provider Gall app from my distribution ship
`~dister-hosted-labweb`.
See
[UrSR Demo usage](#ursr-demo-notebook-usage-example)
above for instructions on how to install.

## Mod9 ASR Engine
I recommend installing the Docker image of the Engine.
To do so, make sure you have installed Docker and then
run

```
docker pull mod9/asr
```

To run the Engine, use
```
docker run -p 9900:9900 mod9/asr engine
```

An important caveat related to the Engine:
the Engine is not free or open source software.
The copy pulled down from Docker, above, is a 45-day trial.
Instructions on getting a licensed copy will appear here shortly.

To run the trial Engine without CPU throttling, start it as follows:

```
docker run -p 9900:9900 mod9/asr engine --accept-license=yes
```

For more information, please consult the
[Engine documentation](https://mod9.io/).

## Golang wrapper
The golang wrapper communicates between
your provider ship and the Engine.
In the future, it will be distributed as an exectuable.
Until then, you will need to run the source.

First, install golang following
[the docs on the golang website](https://golang.org/doc/install).
```bash
# Pull the UrSR source code.
git pull https://github.com/hosted-fornet/ursr.git

# Navigate to the UrSR `go` directory.
cd /path/to/ursr/go

# View usage information.
go run cmd/main.go -h

# Run the golang wrapper with the proper flags for your set up
#  (examples for a fakeship `~wes` below):
go run -code lapwen-fadtun-lagsyl-fadpex -engine localhost:9900 -ship localhost:8080 -ttl 0
```


# Protocol

Coming soon.


# Useful `@p`s to know

```
~hosted-fornet          :: me
~hosted-labweb          :: also me
~dister-hosted-labweb   :: my software distribution ship
~hoster-hosted-labweb   :: my UrSR Provider ship
~wisdem-hosted-labweb   :: my group hosting ship
```


# Questions and Feedback

Hit me up at `~hosted-fornet` or come chat in

```
~wisdem-hosted-labweb/homunculus
```


# Privacy notice

Since you are sending your audio to a provider to transcribe,
you should not send sensitive audio to people you don't trust.
There is nothing stopping a sketchy provider from keeping your
audio and your transcripts.
If you have sensitive audio you wish to transcribe, you should
set up your own provider node and use that.


# Acknowledgements

You can find the grant proposal for this project
[here](https://urbit.org/grants/speech-recognition).
