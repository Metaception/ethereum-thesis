import sys
import subprocess as subp
from paillier.paillier import *

# Constants
pub =       PublicKey.from_n(54342586964678706221820581148616306897192691369301044177089628805327284099513)
directory = '/home/leon/'
ipc =       'ipc://home/leon/dev/geth.ipc'
password =  ''

# Web3 Code
unlock =    'personal.unlockAccount(eth.coinbase, \'{}\')'.format(password)
abi =       'loadScript(\'{}.js\')'.format('paillierTally')
trans =     'paillierTally.homomorphicAdd(CIPHER, {from: eth.coinbase, gas: 4000000})'

# Check input
x = sys.argv[1]
try:
    x = int(x)
    print('Converted!')
    if x < 0:
        print('Negative!')
        x = 54342586964678706221820581148616306897192691369301044177089628805327284099513 + x
except:
    raise TypeError('That is not an integer!')

# Encrypt Input
print("x =      ", x)
cx = encrypt(pub, x)
print("cx =     ", cx)
hex_cx = hex(cx)
print("hex_cx = ", hex_cx)
ciphertext = str(['0x'+hex_cx[-64:], hex_cx[:-64]])

# Send value into blockchain
trans = trans.replace('CIPHER', ciphertext)
subp.run('cd {} && ./geth --exec "{}; {}; {}" attach {}'.format(directory, unlock, abi, trans, ipc), shell='true')

