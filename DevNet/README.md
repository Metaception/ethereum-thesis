# Private Network
Private network for testing 

## Start Network
    geth --dev --nodiscover --rpc --rpccorsdomain "*" --datadir /home/leon/dev js /home/leon/gethdev.js

## Attach to Node
    geth attach ipc://home/leon/dev/geth.ipc
