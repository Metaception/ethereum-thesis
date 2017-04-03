import ntplib
import os

client =	ntplib.NTPClient()
response =	client.request('pool.ntp.org')

push =		'timeStamper.set(TIME, {from: eth.coinbase, gas: 3000000})'.replace('TIME', str(int(response.tx_time)))

os.system('cd C:/PrivateNet/ & geth --exec "loadScript(\'Contracts.js\'); ' + push + '" attach')
