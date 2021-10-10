/-  ursr
/+  default-agent
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
=<
  |_  =bowl:gall
  +*  this      .
      def   ~(. (default-agent this %|) bowl)
      hc    ~(. +> bowl)
  ::
  ++  on-init
    ^-  (quip card _this)
    ~&  >  '%ursr-client initialized successfully'
    =.  state  [%0 0]
    `this
  ++  on-save
    ^-  vase
    !>(state)
  ++  on-load
    |=  old-state=vase
    ^-  (quip card _this)
    ~&  >  '%ursr-client recompiled successfully'
    `this(state !<(versioned-state old-state))
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?+    mark  (on-poke:def mark vase)
        %ursr-action
      =^  cards  state
      (handle-action:hc !<(action:ursr vase))
      [cards this]
    ::
        %noun
      ?+    q.vase  (on-poke:def mark vase)
          %print-state
        ~&  >>  state
        ~&  >>>  bowl  `this
      ::
          %print-subs
        ~&  >>  &2.bowl  `this
      ==
    ==
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ?+     path  (on-watch:def path)
        [%client-to-provider ~]
        ~&  >>  "got subscription from provider"  `this
        ::
        [%frontend-path ~]
        ~&  >>  "got subscription from urth frontend"  `this
    ==
  ++  on-leave
    |=  =path
    ~&  "got subscription leave request on path {<path>}"  `this
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
|_  bowl=bowl:gall
++  handle-action
  |=  =action:ursr
  ^-  (quip card _state)
  ?-    -.action
      %audio-done
    ~&  >  "got %audio-done"
    :_  state
    :~  [%give %fact ~[/client-to-provider] %ursr-action !>(action)]
    ==
    ::
      %client-start-threads
    =/  client-args=args-frontend-to-client:ursr  +.action
    ~&  >  "got %client-start-threads request: {<client-args>}"
    =/  receive-tid   `@ta`(cat 3 'thread_' (scot %uv (sham eny.bowl)))
    =/  receive-args  [~ `receive-tid [our.bowl %ursr-client da+now.bowl] %ursr-client-receive-from-provider !>([provider.client-args])]
    ~&  >  "starting receive thread {<receive-tid>}"
    :_  state
    :~  [%pass /poke-wire %agent [provider.client-args %ursr-provider] %poke %ursr-action !>([%provider-start-job [options.client-args receive-tid]])]
        [%pass /thread/[receive-tid] %agent [our.bowl %spider] %poke %spider-start !>(receive-args)]
        [%give %fact ~[/frontend-path] %ursr-action !>([%client-send-tid receive-tid])]
    ==
    ::
      %relay-audio
    =/  samples=raw-pcm-ssixteenle-audio:ursr  +.action
    ~&  >  "relaying audio {<samples>}"
    :_  state
    :~  [%give %fact ~[/client-to-provider] %ursr-action !>([%relay-audio samples])]
    ==
    ::
      %stop-threads
    =/  receive-tid=@ta  +.action
    ~&  >  "stopping receive thread {<receive-tid>}"
    :_  state
    :~  [%pass /thread/[receive-tid] %agent [our.bowl %spider] %poke %spider-stop !>([receive-tid %.y])]
    ==
    ::
      %client-send-tid
    ~&  >>>  "unexpectedly received %client-send-tid; ignoring"  `state
    ::
      %provider-start-job
    ~&  >>>  "unexpectedly received %provider-start-job; ignoring"  `state
    ::
      %relay-reply
    ~&  >>>  "unexpectedly received %relay-reply; ignoring"  `state
  ==
--
