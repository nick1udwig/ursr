/-  ursr
/+  default-agent
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
    ~&  >  '%ursr-client initialized successfully'
    =.  state  [%0 ~]
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
    ?>  (team:title our.bowl src.bowl)
    ?+    mark  (on-poke:def mark vase)
        %ursr-payload
      =^  cards  state
      (handle-payload:hc !<(payload:ursr vase))
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
        [%frontend-path @ ~]
      =/  job-id=@ud  (slav %ud -.+.path)
      ~&  >>  "got subscription from urth frontend {<job-id>}"
      ?:  (~(has in active.state) job-id)
        :: TODO: warn frontend this job-id is occupied.
        ~&  >>  "already have this job-id; kicking"
        :_  this
        :~  [%give %kick ~ src.bowl]
        ==
      `this(state [%0 (~(put in active.state) job-id)])
      ::
        [%client-to-provider @ ~]
      ~&  >>  "got subscription from provider {<-.+.path>}"  `this
    ==
  ++  on-leave
    |=  =path
    ~&  "got subscription leave request on path {<path>}"  `this
  ++  on-peek   on-peek:def
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+    wire  (on-agent:def wire sign)
        [%from-provider @ ~]
      ?+  -.sign  (on-agent:def wire sign)
          %fact
        ~&  >>  "got reply cage from provider {<cage.sign>}"
        =/  p=payload:ursr  !<(payload:ursr q.cage.sign)
        =/  job-id-ta=@ta  (scot %ud job-id.p)
        :_  this
        ?.  =(%job-done -.action.p)
          :~  [%give %fact ~[/frontend-path/[job-id-ta]] cage.sign]
          ==
        :~  [%give %fact ~[/frontend-path/[job-id-ta]] cage.sign]
            [%pass /from-provider/[job-id-ta] %agent [src.bowl %ursr-provider] %leave ~]
        ==
      ==
    ==
  ++  on-arvo   on-arvo:def
  ++  on-fail   on-fail:def
  --
::  start helper core
|_  bowl=bowl:gall
++  handle-payload
  |=  =payload:ursr
  ^-  (quip card _state)
  ?-    -.action.payload
      %audio-done
    ~&  >  "got %audio-done"
    :_  state
    :~  [%give %fact ~[/client-to-provider/(scot %ud job-id.payload)] %ursr-payload !>(payload)]
    ==
    ::
      %client-start-job
    =/  client-args=args-frontend-to-client:ursr  +.action.payload
    ~&  >  "got %client-start-threads request: {<client-args>}"
    :_  state
    :~  [%pass /poke-wire %agent [provider.client-args %ursr-provider] %poke %ursr-payload !>([job-id.payload %relay-options options.client-args])]
        [%pass /from-provider/(scot %ud job-id.payload) %agent [provider.client-args %ursr-provider] %watch /provider-to-client/(scot %ud job-id.payload)]
        :: TODO: notify frontend ready to accept audio?
    ==
    ::
      %relay-audio
    :_  state
    :~  [%give %fact ~[/client-to-provider/(scot %ud job-id.payload)] %ursr-payload !>(payload)]
    ==
    ::
      %job-done
    ~&  >  "unexpectedly received %job-done; ignoring"  `state
    ::
      %relay-options
    ~&  >>>  "unexpectedly received %relay-options; ignoring"  `state
    ::
      %relay-reply
    ~&  >>>  "unexpectedly received %relay-reply; ignoring"  `state
  ==
--
