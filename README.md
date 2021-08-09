# UrSR: Urbit Speech Recognition

For some applications, speech is far more natural than text.
UrSR aims to enable calm computing with the power of voice.
It consists of a Gall app and a Golang middleman, and leverages the power of the
[Mod9 ASR Engine](https://mod9.io/)
to make ASR as simple as a poke.

## Under construction.
### 210808
Got pinging working: from client, through provider, to Golang middleman, and back through the provider to the client.

Assuming the provider is running on `~wes`, and the Golang middleman is running,
```
:ursr-client &ursr-client-action [%ping ~wes]
```
