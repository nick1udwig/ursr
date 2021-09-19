/-  spider, ursr
/+  *strandio, ursr-lib=ursr
=,  strand=strand:spider
:: =>
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
::   --
^-  thread:spider
|=  args-vase=vase
=/  m  (strand ,vase)
^-  form:m
::
%-  (slog leaf+"ursr-crfp: client receive from provider thread started" ~)
=/  args=args-client-to-client:ursr  !<(args-client-to-client:ursr args-vase)
=/  provider-path=path  /provider-to-client
::
::  Accept subscription from frontend/app.
::
;<  frontend-path=path      bind:m  take-watch
%-  (slog leaf+"ursr-crfp: Got subscription from frontend: {<frontend-path>}" ~)
::  Start threads on provider ship.
::
;<  ~                       bind:m  (poke [provider.fe.args %ursr-provider] [%ursr-provider-action !>([%start-job [options.fe.args client-tid.args]])])
::  Subscribe for replies from provider app.
::
;<  ~                       bind:m  (watch /from-provider [provider.fe.args %ursr-provider] provider-path)
%-  (slog leaf+"ursr-crfp: Subscribed to provider send thread" ~)
::  Pass through Engine reply facts from provider to frontend.
::
;<  ~                       bind:m  (pass-fact-through:ursr-lib /from-provider frontend-path %ursr-provider-action)
:: ;<  ~                        bind:m  (pass-through-replies-from-provider frontend-path provider-path)
::  Clean up.
::
;<  ~  bind:m  (take-kick provider-path)
::
(pure:m !>(~))
