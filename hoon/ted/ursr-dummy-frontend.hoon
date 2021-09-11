/-  spider, ursr-sur=ursr
/+  *strandio, ursr
=,  strand=strand:spider
=>
  |%
  ++  gather-tids
    |=  [receive=tid send=tid]
    =/  m  (strand ,tids:ursr-sur)
    (pure:m `tids:ursr-sur`[receive=receive send=send])
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
|=  =vase
=/  m  (strand ,vase)
^-  form:m
::
=/  args=args-frontend-to-client:ursr-sur  !<(args-frontend-to-client:ursr-sur vase)
=/  provider-path=path  /provider-to-client
::
::  Accept subscription from frontend/app.
::
;<  frontend-path=path       bind:m  (take-watch)
::  Start client send thread to send bytes,
::   store client tids to be sent to provider and frontend.
::
;<  client-send-tid=@ta      bind:m  (start-thread %ursr-client-send-to-provider)
;<  bowl                     bind:m  (get-bowl)
;<  client-tids=tids         bind:m  (gather-tids [receive=tid.bowl send=client-send-tid])
::  Start threads on provider ship,
::   receive provider tids.
::
;<  ~                        bind:m  (poke [provider.args %ursr-provider] [%noun !>([%start-provider-threads [options.args client-tids]])])
;<  provider-tids-vase=vase  bind:m  (take-poke %provider-tids)
::  Inform client send thread of provider tids,
::   then inform frontend of the send thread tid.
::   Ordering is important: client send thread
::   is expecting tids first, then audio byts,
::   so wait to inform frontend until send
::   thread is ready.
::
;<  ~                        bind:m  (poke-our %spider %spider-input !>([send.client-tids %provider-tids provider-tids-vase]))
;<  ~                        bind:m  (send-raw-card [%give %fact ~[frontend-path] %client-tids !>(client-tids)])
::  Subscribe for replies from provider send thread.
::
;<  provider-tids=tids       bind:m  (gather-tids !<(tids provider-tids-vase))
;<  ~                        bind:m  (watch [provider.args provider-path] %spider /thread/[send.provider-tids])
::  Pass through Engine reply facts from provider to frontend.
::
;<  ~                        bind:m  (pass-fact-through frontend-path provider-path %engine-reply)
:: ;<  ~                        bind:m  (pass-through-replies-from-provider frontend-path provider-path)
::  Clean up.
::
;<  ~  bind:m  (take-kick provider-path)
::
(pure:m !>(~))
