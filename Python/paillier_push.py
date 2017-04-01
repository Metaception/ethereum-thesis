import sys
import subprocess as sub
from paillier.paillier import *

# Constants
pub =       PublicKey.from_n(266347742502914264358755889401488281971031604507585381386547337356193)
directory = '/home/leon/'
ipc =       'ipc://home/leon/dev/geth.ipc'
password =  ''

# Web3 Code
unlock =    'personal.unlockAccount(eth.coinbase, \'{}\')'.format(password)
script =    'loadScript(\'{}.js\')'.format('paillierBalance')
trans =     'paillierBalance.homomorphicAdd(CIPHER, {from: eth.coinbase, gas: 4000000})'

# Check input
x = sys.argv[1]
try:
    x = int(x)
    print('Converted!')
    if x < 0:
        raise ValueError('Input must be a positive!')
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
sub.run('cd {} && ./geth --exec "{}; {}; {}" attach {}'.format(directory, unlock, script, trans, ipc), shell='true')
