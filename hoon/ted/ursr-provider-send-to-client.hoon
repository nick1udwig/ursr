/-  spider, ursr-sur=ursr
/+  *strandio
=,  strand=strand:spider
=>
  |%
  ++  pass-through-replies-from-urth
    |=  client-path=path
    =/  m  (strand ,~)
    ^-  form:m
    %-  (main-loop ,~)
    :~  |=  ~
        ^-  form:m
        ;<  reply=vase  bind:m  (take-poke %engine-reply)
        :: ?+  p.cage
        ::   ;<  ~    bind:m  (flog-text "received unexpected, non-Engine reply from Urth")
        ::   ::
        ::   %engine-reply
        ;<  ~           bind:m  (send-raw-card [%give %fact ~[client-path] %engine-reply reply])
        :: ==
        (pure:m ~)
    ==
  --
^-  thread:spider
|=  args-vase=vase
=/  m  (strand ,vase)
^-  form:m
::
:: ::  Receive subscription from middleman,
:: ::   signal ready for subscription from client.
:: ::
:: ;<  urth-path=path    bind:m  (take-watch)
:: ;<  ~                 bind:m  (poke-our %ursr-provider %noun !>(`@ta`%send-ready))
::  Receive subscription from client receive thread.
::
;<  client-path=path  bind:m  take-watch
::  Pass through Engine reply facts from Urth to client.
::
;<  ~                 bind:m  (pass-through-replies-from-urth client-path)
::  Clean up.
::
;<  ~  bind:m  (take-kick client-path)
::
(pure:m !>(~))
