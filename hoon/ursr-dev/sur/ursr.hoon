|%
+$  options
  $:  command=cord
      format=cord
      encoding=cord
      rate=@ud
      transcript-formatted=?
  ==
::
+$  engine-reply
  $:  final=?
      result-index=@ud
      transcript=cord
      transcript-formatted=cord
  ==
::
+$  raw-pcm-ssixteenle-audio
  $:  audio=(list cord)
  ==
::
+$  args-frontend-to-client
  $:  =options
      provider=@p
  ==
:: Used for:
:: * Client to provider app (tid is client tid).
:: * Provider app to middleman (tid is provider tid).
::
+$  args-over-network
  $:  =options
      tid=@ta
  ==
::
+$  action
  $%  [%audio-done done=?]
      [%client-send-tid tid=@ta]
      [%client-start-threads =args-frontend-to-client]
      [%provider-start-job =args-over-network]
      [%relay-audio =raw-pcm-ssixteenle-audio]
      [%relay-reply =engine-reply]
      [%stop-threads tid=@ta]
  ==
--
