/-  ursr
/+  default-agent, ursr-lib=ursr
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 active=(set @ud)]
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
    =.  state  [%0 ~]
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
        %ursr-payload
      ~&  >>>  !<(payload:ursr vase)
      =^  cards  state
      (handle-payload:hc !<(payload:ursr vase))
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
        [%provider-to-client @ ~]
      =/  job-id-ta=@ta  -.+.path
      =/  job-id=@ud  (slav %ud job-id-ta)
      ~&  >  "got subscription from client; subscribing back {<job-id-ta>}"
      :_  this(state [%0 (~(put in active.state) job-id)])
      :~  [%pass /from-client/[job-id-ta] %agent [src.bowl %ursr-client] %watch /client-to-provider/[job-id-ta]]
      ==
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
        [%from-client @ ~]
      ?+  -.sign  (on-agent:def wire sign)
          %fact
        :: ~&  >>  "got audio cage from client {<cage.sign>}"
        :_  this
        :~  [%give %fact ~[/urth-path] cage.sign]
        ==
      ==
    ==
  ++  on-arvo   on-arvo:def
  ++  on-fail   on-fail:def
  --
:: start helper core
|_  bowl=bowl:gall
++  handle-payload
  |=  =payload:ursr
  ^-  (quip card _state)
  ?-    -.action.payload
      %relay-options
    =/  options=options:ursr  +.action.payload
    ~&  >  "got %provider-start-job request: {<options>}"
    :_  state
    :~  [%give %fact ~[/urth-path] %ursr-payload !>([job-id.payload %relay-options options])]
    ==
    ::
      %relay-reply
    ~&  >  "got %relay-reply request: {<+.action.payload>}"
    :_  state
    :~  [%give %fact ~[/provider-to-client/(scot %ud job-id.payload)] %ursr-payload !>(payload)]
    ==
    ::
      %audio-done
    ~&  >  "unexpectedly received %audio-done; ignoring"  `state
    ::
      %client-start-job
    ~&  >  "unexpectedly received %client-start-job; ignoring"  `state
    ::
      %relay-audio
    ~&  >  "unexpectedly received %relay-audio; ignoring"  `state
  ==
--
