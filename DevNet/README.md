# Private Network
Private network for testing.

The JavaScript code checks if there is a transaction, starting/stopping the miner as needed.

## Start Network
    geth --dev --nodiscover --rpc --rpccorsdomain "*" --datadir /home/leon/dev js /home/leon/gethdev.js

## Attach to Node
    geth attach ipc://home/leon/dev/geth.ipc
