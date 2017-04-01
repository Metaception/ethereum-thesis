import sys
import subprocess as subp
from paillier.paillier import *

# Constants
priv =  SpecialPrivateKey(266347742502914264358755889401488249325495300671582270713569795357460, 149942662169238178637581093259222659241564344736260065652410101529652)
pub =   PublicKey.from_n(266347742502914264358755889401488281971031604507585381386547337356193)
directory = '/home/leon/'
ipc =       'ipc://home/leon/dev/geth.ipc'

# Web3 code
abi =   'loadScript(\'{}.js\')'.format('paillierBalance')
trans = 'paillierBalance.getBalance()'

balance =   subp.run('cd {} && ./geth --exec "{} && {}" attach {}'.format(directory, abi, trans, ipc), shell='true', stdout=subp.PIPE).stdout.decode('utf-8')

# Strip unwanted characters
balance =   balance.replace('.', '').replace('+', '').replace('[', '').replace(']', '')
balance =   balance.strip().split(', ')

# Convert from scientific notation
for n in range(len(balance)):
    e =             balance[n].index('e')
    exp =           balance[n][e+1:]
    balance[n] =    balance[n][:e]

    # Check for trailing zeros
    if len(balance[n]) < int(exp) + 1:
        balance[n] = int(balance[n]) * 10**(int(exp) + 1 - len(balance[n]))
    else:
        balance[n] = int(balance[n])

# Convert from little endian
cipher = ''
for part in balance:
    cipher = str(hex(part)[2:]) + cipher
cipher = int('0x'+cipher, 16)

cipher = decrypt(priv, pub, cipher)
print('Balance is', cipher)
