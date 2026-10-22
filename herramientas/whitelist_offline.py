"""Genera whitelist.json con los UUID *offline* (no premium) de los nicks dados.

En online-mode=false el servidor identifica a cada jugador con un UUID calculado a
partir del nick (igual que Java UUID.nameUUIDFromBytes("OfflinePlayer:<nick>")).
`whitelist add` en cambio busca el nick en Mojang y, si existe una cuenta premium
con ese nombre, guarda SU UUID, que no coincide.

Uso: python3 whitelist_offline.py cami descalculadora > whitelist.json
Después copiar whitelist.json a la carpeta del servidor y en la consola: whitelist reload
"""
import hashlib
import json
import sys
import uuid


def uuid_offline(nick):
    h = bytearray(hashlib.md5(f"OfflinePlayer:{nick}".encode()).digest())
    h[6] = (h[6] & 0x0F) | 0x30  # versión 3
    h[8] = (h[8] & 0x3F) | 0x80  # variante IETF
    return str(uuid.UUID(bytes=bytes(h)))


print(json.dumps([{"uuid": uuid_offline(n), "name": n} for n in sys.argv[1:]], indent=2))
