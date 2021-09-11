/-  spider, ursr-sur=ursr
/+  *strandio, ursr
=,  strand=strand:spider
=>
  |%
  ++  pass-through-audio-from-frontend
    |=  provider-path=path
    =/  m  (strand ,~)
    ^-  form:m
    %-  (main-loop ,~)
    :~  |=  ~
        ^-  form:m
        ;<  samples=vase  bind:m  (take-poke %raw-pcm-ssixteenle-audio)
        :: ?+  p.cage
        ::   ;<  ~  bind:m  (flog-text "received unexpected, non-Engine reply from provider")
        ::   ::
        ::   %raw-pcm-ssixteenle-audio
        ;<  ~             bind:m  (send-raw-card [%give %fact ~[provider-path] %raw-pcm-ssixteenle-audio samples])
        :: ==
        (pure:m ~)
    ==
  --
^-  thread:spider
|=  args-vase=vase
=/  m  (strand ,vase)
^-  form:m
::
%-  (slog leaf+"ursr-cstp: client send to provider thread started" ~)
::  Receive subscription from provider receive thread.
::
;<  provider-path=path  bind:m  take-watch
%-  (slog leaf+"ursr-cstp: Got subscription from provider: {<provider-path>}" ~)
::  Pass through audio bytes pokes from frontend to provider.
::
;<  ~                   bind:m  (pass-through-audio-from-frontend provider-path)
::  Clean up.
::
;<  ~  bind:m  (take-kick provider-path)
::
(pure:m !>(~))
