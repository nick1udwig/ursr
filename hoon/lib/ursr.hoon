/-  spider, ursr
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
  ++  args-over-network
    |=  =args-over-network:ursr
    ^-  json
    %-  pairs
    :~  [%options (options options.args-over-network)]
        [%tid %s `cord`tid.args-over-network]
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
    |=  action=client-action:ursr
    ^-  json
    ?-  -.action
        %start-threads
      %-  pairs
      :~  [%start-threads (args-frontend-to-client +.action)]
      ==
      ::
        %send-tid
      %-  pairs
      :~  [%send-tid %s `cord`+.action]
      ==
      ::
        %relay-audio
      %-  pairs
      :~  [%relay-audio (raw-pcm-ssixteenle-audio +.action)]
      ==
      ::
        %audio-done
      %-  pairs
      :~  [%audio-done %b +.action]
      ==
    ==
  ::
  ++  provider-action
    |=  action=provider-action:ursr
    ^-  json
    ?-  -.action
        %start-job
      %-  pairs
      :~  [%start-job (args-over-network +.action)]
      ==
      ::
        %relay-audio
      %-  pairs
      :~  [%relay-audio (raw-pcm-ssixteenle-audio +.action)]
      ==
      ::
        %relay-reply
      %-  pairs
      :~  [%relay-reply (engine-reply +.action)]
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
  ++  args-over-network
    |=  jon=json
    ^-  args-over-network:ursr
    %.  jon
    %-  ot
    :~  [%options options]
        [%tid so]
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
    ^-  client-action:ursr
    %.  jon
    %-  of
    :~  [%start-threads args-frontend-to-client]
        [%send-tid [%tid so]]
        [%relay-audio raw-pcm-ssixteenle-audio]
        [%audio-done bo]
    ==
  ::
  ++  provider-action
    |=  jon=json
    ^-  provider-action:ursr
    %.  jon
    %-  of
    :~  [%start-job args-over-network]
        [%relay-audio raw-pcm-ssixteenle-audio]
        [%relay-reply engine-reply]
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
      :: %-  (slog leaf+"ursr-ted: relaying {<p.cage>}" ~)
      ;<  ~      bind:m  (send-raw-card:strandio [%give %fact ~[send-path] cage])
      :: ==
      (pure:m ~)
  ==
--
