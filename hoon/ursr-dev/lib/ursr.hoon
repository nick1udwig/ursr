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
  ++  action
    |=  =action:ursr
    ^-  json
    ?-  -.action
        %audio-done
      %-  pairs
      :~  [%audio-done %b +.action]
      ==
      ::
        %client-send-tid
      %-  pairs
      :~  [%client-send-tid %s `cord`+.action]
      ==
      ::
        %client-start-threads
      %-  pairs
      :~  [%client-start-threads (args-frontend-to-client +.action)]
      ==
        %provider-start-job
      %-  pairs
      :~  [%provider-start-job (args-over-network +.action)]
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
      ::
        %stop-threads
      %-  pairs
      :~  [%stop-threads %s `cord`+.action]
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
  ++  action
    |=  jon=json
    ^-  action:ursr
    %.  jon
    %-  of
    :~  [%audio-done bo]
        [%client-send-tid [%tid so]]
        [%client-start-threads args-frontend-to-client]
        [%provider-start-job args-over-network]
        [%relay-audio raw-pcm-ssixteenle-audio]
        [%relay-reply engine-reply]
        [%stop-threads [%tid so]]
    ==
  --
++  pass-fact-through
  |=  [receive-path=path send-path=path]
  =/  m  (strand:spider ,~)
  ^-  form:m
  %-  (slog leaf+"passing through facts from {<receive-path>} to {<send-path>}..." ~)
  %-  (main-loop:strandio ,~)
  :~  |=  ~
      ^-  form:m
      %-  (slog leaf+"iter" ~)
      ;<  =cage  bind:m  (take-fact:strandio receive-path)
      %-  (slog leaf+"got a fact {<cage>}" ~)
      ;<  ~      bind:m  (send-raw-card:strandio [%give %fact ~[send-path] cage])
      %-  (slog leaf+"sent a fact" ~)
      (pure:m ~)
  ==
--
