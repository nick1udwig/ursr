/-  spider, ursr-sur=ursr
/+  *strandio, ursr
=,  strand=strand:spider
=>
  |%
  ++  gather-tids
    |=  =tids:ursr-sur
    =/  m  (strand ,tids:ursr-sur)
    (pure:m `tids:ursr-sur`tids)
::   ::
::   ++  pass-through-replies-from-provider
::     |=  [frontend-path=path provider-path=path]
::     =/  m  (strand ,~)
::     ^-  form:m
::     %-  (main-loop ,~)
::     :~  |=  ~
::         ^-  form:m
::         ;<  =cage  bind:m  (take-fact provider-path)
::         ?+  p.cage
::           ;<  ~    bind:m  (flog-text "received unexpected, non-Engine reply from provider")
::           ::
::           %engine-reply
::         ;<  ~      bind:m  (send-raw-card [%give %fact ~[frontend-path] cage])
::         ==
::     ==
  --
^-  thread:spider
|=  args-vase=vase
=/  m  (strand ,vase)
^-  form:m
::
%-  (slog leaf+"ursr-crfp: client receive from provider thread started" ~)
=/  args=args-client-to-client:ursr-sur  !<(args-client-to-client:ursr-sur args-vase)
=/  provider-path=path  /provider-to-client
::
::  Accept subscription from frontend/app.
::
;<  frontend-path=path           bind:m  take-watch
%-  (slog leaf+"ursr-crfp: Got subscription from frontend: {<frontend-path>}" ~)
::  Start threads on provider ship,
::   receive provider tids.
::
;<  ~                            bind:m  (poke [provider.fe.args %ursr-provider] [%ursr-provider-action !>([%start-job [options.fe.args client-tids.args]])])
;<  provider-tids-vase=vase      bind:m  (take-poke %provider-tids)
%-  (slog leaf+"ursr-crfp: Started provider threads: {<provider-tids-vase>}" ~)
::  Subscribe for replies from provider send thread.
::
;<  provider-tids=tids:ursr-sur  bind:m  (gather-tids !<(tids:ursr-sur provider-tids-vase))
;<  ~                            bind:m  (watch provider-path [provider.fe.args %spider] /thread/[send.provider-tids]/updates)
%-  (slog leaf+"ursr-crfp: Subscribed to provider send thread" ~)
::  Pass through Engine reply facts from provider to frontend.
::
;<  ~                            bind:m  (pass-fact-through:ursr frontend-path provider-path %engine-reply)
:: ;<  ~                        bind:m  (pass-through-replies-from-provider frontend-path provider-path)
::  Clean up.
::
;<  ~  bind:m  (take-kick provider-path)
::
(pure:m !>(~))
