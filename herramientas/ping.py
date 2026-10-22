"""Consulta el estado de un servidor de Minecraft Java (versión, MOTD, jugadores).

Uso: python3 ping.py bore.pub:12345
"""
import json
import socket
import struct
import sys


def varint(n):
    out = b""
    while True:
        b = n & 0x7F
        n >>= 7
        out += bytes([b | (0x80 if n else 0)])
        if not n:
            return out


def leer_varint(s):
    n = shift = 0
    while True:
        b = s.recv(1)[0]
        n |= (b & 0x7F) << shift
        shift += 7
        if not b & 0x80:
            return n


host, port = sys.argv[1].rsplit(":", 1)
port = int(port)
s = socket.create_connection((host, port), timeout=10)
# Handshake (estado = 1) + pedido de status
hs = varint(0) + varint(770) + varint(len(host)) + host.encode() + struct.pack(">H", port) + varint(1)
s.sendall(varint(len(hs)) + hs + varint(1) + varint(0))
leer_varint(s)  # largo del paquete
leer_varint(s)  # id del paquete
n = leer_varint(s)
data = b""
while len(data) < n:
    data += s.recv(n - len(data))
print(json.dumps(json.loads(data), ensure_ascii=False, indent=2))
