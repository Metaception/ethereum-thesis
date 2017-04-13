import sys
import subprocess as subp
from paillier.paillier import *

# Constants
priv =  SpecialPrivateKey(54342586964678706221820581148616306896723877899286354747923159264560520272640, 3488334253972664926922939256419141150691053220179142401932457824642021944425)
pub =   PublicKey.from_n(54342586964678706221820581148616306897192691369301044177089628805327284099513)
directory = '/home/leon/'
ipc =       'ipc://home/leon/dev/geth.ipc'
password =  ''

# Web3 code
unlock =    'personal.unlockAccount(eth.coinbase, \'{}\')'.format(password)
abi =   'loadScript(\'{}.js\')'.format('paillierTally')
trans = 'paillierTally.getTally()'

# Retrieve encrypted tally
tally =   subp.run('cd {} && ./geth --exec "{} && {}" attach {}'.format(directory, abi, trans, ipc), shell='true', stdout=subp.PIPE).stdout.decode('utf-8')

# Strip unwanted characters
tally =   tally.replace('.', '').replace('+', '').replace('[', '').replace(']', '')
tally =   tally.strip().split(', ')

# Convert from scientific notation
for n in range(len(tally)):
    e =           tally[n].index('e')
    exp =         tally[n][e+1:]
    tally[n] =    tally[n][:e]

    # Check for trailing zeros
    if len(tally[n]) < int(exp) + 1:
        tally[n] = int(tally[n]) * 10**(int(exp) + 1 - len(tally[n]))
    else:
        tally[n] = int(tally[n])

# Convert from little endian
cipher = ''
for part in tally:
    cipher = str(hex(part)[2:]) + cipher
cipher = int('0x'+cipher, 16)

cipher = decrypt(priv, pub, cipher)
print('Tally is', cipher)

# Check if reseting balance
if len(sys.argv) > 1:
    reset = sys.argv[1]
    if (bool(reset) == True):
        trans = 'paillierTally.resetTally({from: eth.coinbase, gas: 4000000})'
        subp.run('cd {} && ./geth --exec "{}; {}; {}" attach {}'.format(directory, unlock, abi, trans, ipc), shell='true')

