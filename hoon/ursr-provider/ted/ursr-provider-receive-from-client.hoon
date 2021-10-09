/-  spider, ursr
/+  *strandio, ursr-lib=ursr
=,  strand=strand:spider
^-  thread:spider
|=  args-vase=vase
=/  m  (strand ,vase)
^-  form:m
::
%-  (slog leaf+"ursr-prfc: provider receive from client thread started" ~)
=/  client=ship  !<(ship args-vase)
=/  client-path=path  /client-to-provider
::
::  Receive subscription from Urth,
::
;<  urth-path=path  bind:m  take-watch
%-  (slog leaf+"ursr-prfc: got watch from {<urth-path>}" ~)
::  Subscribe to client app, which will send audio.
::
;<  ~               bind:m  (watch /from-client [client %ursr-client] client-path)
%-  (slog leaf+"ursr-prfc: Subscribed to client app for audio" ~)
::  Pass through Engine reply facts from Urth to client.
::
;<  ~               bind:m  (pass-fact-through:ursr-lib /from-client urth-path)
%-  (slog leaf+"ursr-prfc: Done with loop." ~)
::  Clean up.
::
;<  ~               bind:m  (take-kick /from-client)
%-  (slog leaf+"ursr-prfc: Got kick from client. Exiting." ~)
::
(pure:m !>(~))
