/-  ursr
/+  default-agent
|%
+$  versioned-state
    $%  state-zero
        state-one
    ==
::
+$  state-zero
    $:  [%0 active=(set @ud)]
    ==
::
+$  state-one
    $:  [%1 active=(set @ud) verbose=?]
    ==
::
+$  card  card:agent:gall
::
--
=|  state-one
=*  state  -
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this      .
      def   ~(. (default-agent this %|) bowl)
      hc    ~(. +> bowl)
  ::
  ++  on-init
    ^-  (quip card _this)
    ~&  >>  "ursr-client: initialized successfully"
    =.  state  [%1 ~ %.n]
    `this
  ++  on-save
    ^-  vase
    !>(state)
  ++  on-load
    |=  old-state=vase
    ^-  (quip card _this)
    =/  old  !<(versioned-state old-state)
    |-
    ?-    -.old
        %1
      ~&  >>  "ursr-client: recompiled successfully"
      `this(state old)
      ::
        %0
      $(old [%1 active.old %.n])
    ==
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
          [%set-verbose ?]
        =/  new-verbose=?  +.q.vase
        ~&  >>  "ursr-client: %set-verbose to {<new-verbose>}"
        `this(verbose.state new-verbose)
        ::
          %print-state
        ~&  >  state
        ~&  >  bowl  `this
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
        [%frontend-path @ ~]
      =/  job-id=@ud  (slav %ud -.+.path)
      ?:  (~(has in active.state) job-id)
        ~&  >>  "ursr-client: got duplicate subscription with job-id {<job-id>}; kicking"
        :_  this
        :~  [%give %kick ~ `src.bowl]
        ==
      `this(active.state (~(put in active.state) job-id))
      ::
        [%client-to-provider @ ~]
      =^  cards  state
        %:  return-and-maybe-log
            verbose.state
            "ursr-client: got subscription from provider {<-.+.path>}"
            `state
        ==
      [cards this]
    ==
  ++  on-leave
    |=  =path
    =^  cards  state
      %:  return-and-maybe-log
          verbose.state
          "ursr-client: got subscription leave request on path {<path>}"
          `state
      ==
    [cards this]
  ++  on-peek   on-peek:def
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+    wire  (on-agent:def wire sign)
        [%from-provider @ ~]
      ?+  -.sign  (on-agent:def wire sign)
          %fact
        =/  p=payload:ursr  !<(payload:ursr q.cage.sign)
        =/  job-id-ta=@ta  (scot %ud job-id.p)
        ?.  =(%job-done -.action.p)
          :_  this
          :~  [%give %fact ~[/frontend-path/[job-id-ta]] cage.sign]
          ==
        :_  this(active.state (~(del in active.state) job-id.p))
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
    %:  return-and-maybe-log
        verbose.state
        "ursr-client: got %audio-done"
        :_  state
        :~  [%give %fact ~[/client-to-provider/(scot %ud job-id.payload)] %ursr-payload !>(payload)]
        ==
    ==
    ::
      %client-start-job
    =/  client-args=args-frontend-to-client:ursr  +.action.payload


    %:  return-and-maybe-log
        verbose.state
        "ursr-client: got %client-start-threads request: {<client-args>}"
        :_  state
        :~  [%pass /poke-wire %agent [provider.client-args %ursr-provider] %poke %ursr-payload !>([job-id.payload %relay-options options.client-args])]
            [%pass /from-provider/(scot %ud job-id.payload) %agent [provider.client-args %ursr-provider] %watch /provider-to-client/(scot %ud job-id.payload)]
        ==
    ==
    ::
      %relay-audio
    :_  state
    :~  [%give %fact ~[/client-to-provider/(scot %ud job-id.payload)] %ursr-payload !>(payload)]
    ==
    ::
      %job-done
    ~&  >>>  "ursr-client: unexpectedly received %job-done; ignoring"  `state
    ::
      %relay-options
    ~&  >>>  "ursr-client: unexpectedly received %relay-options; ignoring"  `state
    ::
      %relay-reply
    ~&  >>>  "ursr-client: unexpectedly received %relay-reply; ignoring"  `state
  ==
::
++  return-and-maybe-log
  |=  [verbose=? maybe-log=tape return-val=(quip card _state)]
  ^-  _return-val
  ?.  verbose  return-val
  ~&  >  maybe-log  return-val
--
