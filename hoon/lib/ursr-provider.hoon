/-  ursr=ursr-provider
|%
++  enjs
  =,  enjs:format
  |%
  ++  ping
    |=  =ping:ursr
    ^-  json
    %-  pairs
    :: :~  [%ship (ship:enjs:format ship.ping)]
    :~  [%ship %s (scot %p ship.ping)]
    ==
  --
::
++  dejs
  =,  dejs:format
  |%
  ++  ping
    |=  jon=json
    ^-  ping:ursr
    :-  %ship
    %.  jon
    %-  ot
    :~  [%ship (su ;~(pfix sig fed:ag))]
    ==
  --
--
