/-  spider, ursr
/+  *strandio, ursr-lib=ursr
=,  strand=strand:spider
^-  thread:spider
|=  args-vase=vase
=/  m  (strand ,vase)
^-  form:m
::
%-  (slog leaf+"ursr-crfp: client receive from provider thread started" ~)
=/  provider=ship  !<(ship args-vase)
=/  provider-path=path  /provider-to-client
::
::  Accept subscription from frontend/app.
::
;<  frontend-path=path  bind:m  take-watch
%-  (slog leaf+"ursr-crfp: Got subscription from frontend: {<frontend-path>}" ~)
::  Subscribe for replies from provider app.
::
;<  ~                   bind:m  (watch /from-provider [provider %ursr-provider] provider-path)
%-  (slog leaf+"ursr-crfp: Subscribed to provider app for transcripts" ~)
::  Pass through Engine reply facts from provider to frontend.
::
;<  ~                   bind:m  (pass-fact-through:ursr-lib /from-provider frontend-path)
%-  (slog leaf+"ursr-crfp: Done with loop." ~)
::  Clean up.
::
;<  ~                   bind:m  (take-kick /from-provider)
%-  (slog leaf+"ursr-crfp: Got kick from provider. Exiting." ~)
::
(pure:m !>(~))
