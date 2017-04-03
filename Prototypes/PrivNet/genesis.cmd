cd C:/PrivateNet/

geth --identity node1 --nodiscover --networkid 420 --maxpeers 0 --datadir node1 init /PrivateNet/genesis.json
geth --identity node2 --nodiscover --networkid 420 --maxpeers 0 --datadir node2 init /PrivateNet/genesis.json
geth --identity node3 --nodiscover --networkid 420 --maxpeers 0 --datadir node3 init /PrivateNet/genesis.json
