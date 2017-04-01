#!/usr/bin/env python
from paillier.paillier import *


print("Generating keypair...")
priv, pub =	generate_keypair(228)
print(priv)
print(pub)
hex_n_sq =	hex(pub.n_sq)
print(['0x'+hex_n_sq[-64:], hex_n_sq[:-64]], '\n')

x = 3
print("x =", x)
print("Encrypting x...")
cx = encrypt(pub, x)
print("cx =", cx)
hex_cx = hex(cx)
print(['0x'+hex_cx[-64:], hex_cx[:-64]], '\n')

y = 5
print("y =", y)
print("Encrypting y...")
cy = encrypt(pub, y)
print("cy =", cy)
hex_cy = hex(cy)
print(['0x'+hex_cy[-64:], hex_cy[:-64]], '\n')

print("Computing cx + cy...")
cz = e_add(pub, cx, cy)
print("cz =", cz)
hex_cz = hex(cz)
print([int('0x'+hex_cz[-64:], 16), int(hex_cz[:-64], 16)], '\n')

# print('\n', ['0x'+hex_cx[-64:], hex_cx[:-64]], ',', ['0x'+hex_cy[-64:], hex_cy[:-64]], ',', ['0x'+hex_n_sq[-64:], hex_n_sq[:-64]], '\n')

print("Decrypting cz...")
z = decrypt(priv, pub, cz)
print("z =", z)

print("Computing decrypt((cz + 2) * 3) ...")
print("result =", decrypt(priv, pub, e_mul_const(pub, e_add_const(pub, cz, 2), 3)))
