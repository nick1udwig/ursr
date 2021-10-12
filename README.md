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
~hoster-hosted-fornet
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
audio and your transcripts, though they would have to write
their own software to do so.
If you have sensitive audio you wish to transcribe, you should
set up your own provider node and use that.


# Acknowledgements

You can find the grant proposal for this project
[here](https://urbit.org/grants/speech-recognition).
