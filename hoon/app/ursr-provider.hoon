/-  ursr
/+  default-agent, ursr-lib=ursr
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
        %ursr-provider-action
      ~&  >>>  !<(provider-action:ursr vase)
      =^  cards  state
      (handle-action:hc !<(provider-action:ursr vase))
      [cards this]
    ::
        %noun
      ?+    q.vase  (on-poke:def mark vase)
          %print-state
        ~&  >  state
        ~&  >>  bowl  `this
        ::
          %print-subs
        ~&  >  &2.bowl  `this
      ==
    ==
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ?+     path  (on-watch:def path)
        [%provider-to-client ~]
        ~&  >  "got subscription from client"  `this
        ::
        [%urth-path ~]
        ~&  >  "got subscription from urth backend"  `this
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
:: start helper core
|_  bowl=bowl:gall
++  handle-action
  |=  action=provider-action:ursr
  ^-  (quip card _state)
  ?-    -.action
      %start-job
    =/  client-args=args-over-network:ursr  +.action
    ~&  >  "got %start-job request: {<client-args>}"
    =/  receive-tid   `@ta`(cat 3 'thread_' (scot %uv (sham eny.bowl)))
    =/  receive-args  [~ `receive-tid %ursr-provider-receive-from-client !>([src.bowl tid.client-args])]
    :_  state
    :~  [%pass /thread/[receive-tid] %agent [our.bowl %spider] %poke %spider-start !>(receive-args)]
        [%give %fact ~[/urth-path] %ursr-provider-action !>([%start-job [options.client-args receive-tid]])]
    ==
    ::
      %relay-reply
    ~&  >  "got %relay-reply request: {<+.action>}"
    :_  state
    :~  [%give %fact ~[/provider-to-client] %ursr-provider-action !>(action)]
    ==
    ::
      %relay-audio
    ~&  >  "got unexpected case %relay-audio"  `state
    ::
  ==
--
