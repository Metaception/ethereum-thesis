# Frontend
Frontend UI for pushing and pulling ciphertext onto the Ethereum blockchain.

## Requirements
Requires Python **3.5**

The scripts expect a [Paillier](https://github.com/Metaception/paillier) library.

The library is expected to be in the same path, in a folder called **Pailler**

## Usage
To input a encrypted number:
    python paillier_push.py {input}
    
To retrieve the decrypted result:
    python paillier_pull.py
