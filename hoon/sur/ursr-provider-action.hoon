/-  ursr
|%
+$  provider-action
  $%  [%start-job =args-over-network:ursr]
      [%relay-audio =raw-pcm-ssixteenle-audio:ursr]
      [%relay-reply =engine-reply:ursr]
  ::    [%send-tid tid=@ta]
  ::    [%ping target=ship]
  ::    [%poke-remote target=ship]
  ::    [%poke-self target=ship]
  ::    [%subscribe host=ship]
  ::    [%leave host=ship]
  ::    [%kick paths=(list path) subscriber=ship]
  ::    [%bad-path host=ship]
  ==
--
