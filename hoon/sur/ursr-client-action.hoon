/-  ursr
|%
+$  client-action
  $%  [%start-threads args-frontend-to-client:ursr]
      [%send-tids tids:ursr]
  ::    [%ping target=ship]
  ::    [%poke-remote target=ship]
  ::    [%poke-self target=ship]
  ::    [%subscribe host=ship]
  ::    [%leave host=ship]
  ::    [%kick paths=(list path) subscriber=ship]
  ::    [%bad-path host=ship]
  ==
--
