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
        %client-start-job
      %-  pairs
      :~  [%client-start-threads (args-frontend-to-client +.action)]
      ==
      ::
        %job-done
      %-  pairs
      :~  [%job-done %b +.action]
      ==
      ::
        %relay-audio
      %-  pairs
      :~  [%relay-audio (raw-pcm-ssixteenle-audio +.action)]
      ==
      ::
        %relay-options
      %-  pairs
      :~  [%relay-options (options +.action)]
      ==
      ::
        %relay-reply
      %-  pairs
      :~  [%relay-reply (engine-reply +.action)]
      ==
    ==
  ::
  ++  payload
    |=  =payload:ursr
    ^-  json
    %-  pairs
    :~  [%job-id (numb job-id.payload)]
        [%action (action action.payload)]
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
        [%client-start-job args-frontend-to-client]
        [%job-done bo]
        [%relay-audio raw-pcm-ssixteenle-audio]
        [%relay-options options]
        [%relay-reply engine-reply]
    ==
  ::
  ++  payload
    |=  jon=json
    ^-  payload:ursr
    %.  jon
    %-  ot
    :~  [%job-id ni]
        [%action action]
    ==
  --
--
