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
::
+$  args-client-to-client
  $:  fe=args-frontend-to-client
      client-tids=tids
  ==
:: Used for:
:: * Client to frontend (tids are client tids;
::   really we only need send tid for this).
:: * Provider app to provider receive thread (tids are client tids).
::
+$  tids
  $:  receive=@ta
      send=@ta
  ==
:: Used for:
:: * Client to provider app (tids are client tids).
:: * Provider app to middleman (tids are provider tids).
::
+$  args-over-network
  $:  =options
      =tids
  ==
::
+$  args-provider-to-provider
  $:  client=@p
      client-tids=tids
  ==
--
