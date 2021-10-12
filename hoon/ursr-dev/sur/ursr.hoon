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
+$  action
  $%  [%audio-done done=?]
      [%client-start-job =args-frontend-to-client]
      [%job-done done=?]
      [%relay-audio =raw-pcm-ssixteenle-audio]
      [%relay-options =options]
      [%relay-reply =engine-reply]
  ==
::
+$  payload
  $:  job-id=@ud
      =action
  ==
--
