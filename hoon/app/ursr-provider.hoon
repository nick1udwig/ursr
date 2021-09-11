/-  ursr, ursr-provider-action
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
    ~&  >  "got poke"
    ?+    mark  (on-poke:def mark vase)
        %ursr-provider-action
      ~&  >>>  !<(provider-action:ursr-provider-action vase)
      =^  cards  state
      (handle-action:hc !<(provider-action:ursr-provider-action vase))
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
:: start helper core
|_  bowl=bowl:gall
++  handle-action
  |=  action=provider-action:ursr-provider-action
  ^-  (quip card _state)
  ?-    -.action
      %start-job
    =/  client-args=args-over-network:ursr  +.action
    ~&  >  "got %start-job request: {<client-args>}"
    =/  receive-tid   `@ta`(cat 3 'thread_r_' (scot %uv (sham eny.bowl)))
    =/  send-tid      `@ta`(cat 3 'thread_s_' (scot %uv (sham eny.bowl)))
    =/  receive-args  [~ `receive-tid %ursr-provider-receive-from-client !>([src.bowl tids.client-args])]
    =/  send-args     [~ `send-tid %ursr-provider-send-to-client !>(~)]
    :_  state
    :~  [%pass /thread/[receive-tid] %agent [our.bowl %spider] %poke %spider-start !>(receive-args)]
        [%pass /thread/[send-tid] %agent [our.bowl %spider] %poke %spider-start !>(send-args)]
        [%give %fact ~[/urth-path] %ursr-provider-action !>([%start-job [options.client-args [receive-tid send-tid]]])]
    ==
    ::
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
  ==
--
