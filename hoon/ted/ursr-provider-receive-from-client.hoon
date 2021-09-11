/-  spider, ursr-sur=ursr
/+  *strandio, ursr
=,  strand=strand:spider
:: =>
::   |%
::   ++  pass-through-replies-from-urth
::     |=  [client-path=path urth-path=path]
::     =/  m  (strand ,~)
::     ^-  form:m
::     %-  (main-loop ,~)
::     :~  |=  ~
::         ^-  form:m
::         ;<  =cage  bind:m  (take-fact urth-path)
::         ?+  p.cage
::           ;<  ~    bind:m  (flog-text "received unexpected, non-Engine reply from provider")
::           ::
::           %engine-reply
::         ;<  ~      bind:m  (send-raw-card [%give %fact ~[provider-path] cage])
::         ==
::     ==
::   --
^-  thread:spider
|=  args-vase=vase
=/  m  (strand ,vase)
^-  form:m
::
=/  args=args-provider-to-provider:ursr-sur  !<(args-provider-to-provider:ursr-sur args-vase)
=/  client-path=path  /client-to-provider
::
::  Receive subscription from Urth,
::
;<  urth-path=path  bind:m  take-watch
::  Subscribe to client send thread.
::
;<  ~               bind:m  (watch client-path [client.args %spider] /thread/[send.client-tids.args]/updates)
::  Pass through Engine reply facts from Urth to client.
::
;<  ~               bind:m  (pass-fact-through:ursr client-path urth-path %raw-pcm-ssixteenle-audio)
:: ;<  ~                 bind:m  (pass-through-replies-from-urth client-path urth-path)
::  Clean up.
::
;<  ~  bind:m  (take-kick client-path)
::
(pure:m !>(~))
