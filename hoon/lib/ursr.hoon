/-  spider, ursr, ursr-client-action, ursr-provider-action
/+  strandio
|%
++  enjs
  =,  enjs:format
  |%
  ++  options
    |=  =options:ursr
    ^-  json
    %-  pairs
    :~  [%command %s command.options]
        [%format %s format.options]
        [%encoding %s encoding.options]
        [%rate (numb rate.options)]
        [%transcript-formatted %b transcript-formatted.options]
    ==
  ::
  ++  engine-reply
    |=  =engine-reply:ursr
    ^-  json
    %-  pairs
    :~  [%final %b final.engine-reply]
        [%result-index (numb result-index.engine-reply)]
        [%transcript %s transcript.engine-reply]
        [%transcript-formatted %s transcript-formatted.engine-reply]
    ==
  ::
  ++  raw-pcm-ssixteenle-audio
    |=  =raw-pcm-ssixteenle-audio:ursr
    ^-  json
    %-  pairs
    :~  [%audio [%a (turn audio.raw-pcm-ssixteenle-audio |=(=cord n+(@ta cord)))]]
    ==
  ::
  ++  tids
    |=  =tids:ursr
    ^-  json
    %-  pairs
    :~  [%receive %s `cord`receive.tids]
        [%send %s `cord`send.tids]
    ==
  ::
  ++  args-over-network
    |=  =args-over-network:ursr
    ^-  json
    %-  pairs
    :~  [%options (options options.args-over-network)]
        [%tids (tids tids.args-over-network)]
    ==
  ::
  ++  args-frontend-to-client
    |=  =args-frontend-to-client:ursr
    ^-  json
    %-  pairs
    :~  [%options (options options.args-frontend-to-client)]
        [%provider %s (scot %p provider.args-frontend-to-client)]
    ==
  ::
  ++  client-action
    |=  action=client-action:ursr-client-action
    ^-  json
    ?-  -.action
        %start-threads
      %-  pairs
      :~  [%start-threads (args-frontend-to-client +.action)]
      ==
    ::
        %send-tids
      %-  pairs
      :~  [%send-tids (tids +.action)]
      ==
    ==
  ::
  ++  provider-action
    |=  action=provider-action:ursr-provider-action
    ^-  json
    ?-  -.action
        %start-job
      %-  pairs
      :~  [%start-job (args-over-network +.action)]
      ==
    ==
  --
::
++  dejs
  =,  dejs:format
  |%
  ++  options
    |=  jon=json
    ^-  options:ursr
    %.  jon
    %-  ot
    :~  [%command so]
        [%format so]
        [%encoding so]
        [%rate ni]
        [%transcript-formatted bo]
    ==
  ::
  ++  engine-reply
    |=  jon=json
    ^-  engine-reply:ursr
    %.  jon
    %-  ot
    :~  [%final bo]
        [%result-index ni]
        [%transcript so]
        [%transcript-formatted so]
    ==
  ::
  ++  raw-pcm-ssixteenle-audio
    |=  jon=json
    ^-  raw-pcm-ssixteenle-audio:ursr
    %.  jon
    %-  ot
    :~  [%audio (ar no)]
    ==
  ::
  ++  tids
    |=  jon=json
    ^-  tids:ursr
    %.  jon
    %-  ot
    :~  [%receive so]
        [%send so]
    ==
  ::
  ++  args-over-network
    |=  jon=json
    ^-  args-over-network:ursr
    %.  jon
    %-  ot
    :~  [%options options]
        [%tids tids]
    ==
  ::
  ++  args-frontend-to-client
    |=  jon=json
    ^-  args-frontend-to-client:ursr
    %.  jon
    %-  ot
    :~  [%options options]
        [%provider (su ;~(pfix sig fed:ag))]
    ==
  ::
  ++  client-action
    |=  jon=json
    ^-  client-action:ursr-client-action
    %.  jon
    %-  of
    :~  [%start-threads args-frontend-to-client]
        [%send-tids tids]
    ==
  ::
  ++  provider-action
    |=  jon=json
    ^-  provider-action:ursr-provider-action
    %.  jon
    %-  of
    :~  [%start-job args-over-network]
    ==
  --
++  pass-fact-through
  |=  [receive-path=path send-path=path expected-mark=@tas]
  =/  m  (strand:spider ,~)
  ^-  form:m
  %-  (main-loop:strandio ,~)
  :~  |=  ~
      ^-  form:m
      ;<  =cage  bind:m  (take-fact:strandio receive-path)
      :: ?+  p.cage
      ::   ;<  ~    bind:m  (flog-text "received unexpected fact")
      ::   ::
      ::   expected-mark
      ;<  ~      bind:m  (send-raw-card:strandio [%give %fact ~[send-path] cage])
      :: ==
      (pure:m ~)
  ==
--
