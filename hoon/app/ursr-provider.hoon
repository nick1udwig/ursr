/-  ursr=ursr-provider
/+  default-agent, ursr-lib=ursr-provider
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 counter=@]
    ==
::
+$  card  card:agent:gall
::
--
=|  state=versioned-state
^-  agent:gall
:: =<
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%ursr-provider initialized successfully'
  =.  state  [%0 0]
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%ursr-provider recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        %print-state
      ~&  >  state
      ~&  >>  bowl  `this
      ::
        %print-subs
      ~&  >  &2.bowl  `this
      ::
        %receive-ping
      ~&  >  "got ping from {<src.bowl>}, pinging urth"
      :_  this
      ~[[%give %fact ~[/urth-path] [%ursr-provider-ping !>([%ship src.bowl])]]]
      :: ~[[%pass /poke-wire %agent [src.bowl %ursr-client] %poke %noun !>(%receive-pong)]]
        [%receive-pong ping:ursr]
      =/  ping-source=ping:ursr  !<(ping:ursr vase)
      ~&  >  "got pong from urth, ponging {<ship.ping-source>}"
      :_  this
      :: ~[[%give %fact ~[/urth-path] [%noun !>(%receive-pong)]]]
      ~[[%pass /poke-wire %agent [ship.ping-source %ursr-client] %poke %noun !>(%receive-pong)]]
    ==
      :: %ursr-provider-ping
      %json
    ~&  >  !<(json vase)
    =/  ping-source=ping:ursr  (ping:dejs:ursr-lib !<(json vase))
    :_  this
    ~[[%pass /poke-wire %agent [ship.ping-source %ursr-client] %poke %noun !>(%receive-pong)]]
    :: ::
    ::   %ursr-provider-action
    ::   ~&  >>>  !<(action:ursr-provider vase)
    ::   =^  cards  state
    ::   (handle-action:hc !<(action:ursr-provider vase))
    ::   [cards this]
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+     path  (on-watch:def path)
      [%mars-path ~]
      ~&  >  "got subscription from mars"  `this
      ::
      [%urth-path ~]
      ~&  >  "got subscription from urth"  `this
  ==
++  on-leave
  |=  =path
  ~&  >  "got subscription leave request on path {<path>}"  `this
++  on-peek   on-peek:def
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%counter @ ~]
    ?+  -.sign  (on-agent:def wire sign)
        %fact
      =/  val=@  !<(@ q.cage.sign)
      ~&  >>  "counter val on {<src.bowl>} is {<val>}"
      `this
      ==
      ::
      [%poke-wire ~]
    ?~  +.sign
      ~&  >>  "successful {<-.sign>}"  `this
    (on-agent:def wire sign)
  ==
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
::  start helper core
:: |_  bowl=bowl:gall
:: ++  handle-action
::   |=  =action:ursr-provider
::   ^-  (quip card _state)
::   ?-    -.action
::       %increase-counter
::     =.  counter.state  (add step.action counter.state)
::     :_  state
::     ~[[%give %fact ~[/counter] [%atom !>(counter.state)]]]
::     ::
::       %poke-remote
::     :_  state
::     ~[[%pass /poke-wire %agent [target.action %ursr-provider] %poke %noun !>([%receive-poke 99])]]
::     ::
::       %poke-self
::     :_  state
::     ~[[%pass /poke-wire %agent [target.action %ursr-provider] %poke %noun !>(%poke-self)]]
::     ::
::       %subscribe
::     :_  state
::     ~[[%pass /counter/(scot %p host.action) %agent [host.action %ursr-provider] %watch /counter]]
::     ::
::       %leave
::     :_  state
::     ~[[%pass /counter/(scot %p host.action) %agent [host.action %ursr-provider] %leave ~]]
::     ::
::       %kick
::     :_  state
::     ~[[%give %kick paths.action `subscriber.action]]
::     ::
::       %bad-path
::     :_  state
::     ~[[%pass /bad-path/(scot %p host.action) %agent [host.action %ursr-provider] %watch /bad-path]]
::   ==
:: --
