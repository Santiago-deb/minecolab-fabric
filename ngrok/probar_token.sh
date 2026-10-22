#!/usr/bin/env bash
# Prueba un authtoken de ngrok en tu PC: abre un túnel TCP de prueba y se conecta a través de él.
# Uso: ./probar_token.sh archivo_con_el_token [region]    (o NGROK_TOKEN=... ./probar_token.sh)
set -euo pipefail
TOKEN=${NGROK_TOKEN:-$(tr -d '[:space:]' < "${1:?Pasá el archivo con el token o seteá NGROK_TOKEN}")}
REGION=${2:-sa}
TMP=$(mktemp -d); trap 'kill $(jobs -p) 2>/dev/null; rm -rf "$TMP"' EXIT
curl -sSL https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz | tar -xz -C "$TMP"
printf 'version: "3"\n' > "$TMP/ngrok.yml"
python3 -c "import socket;s=socket.socket();s.setsockopt(1,2,1);s.bind(('127.0.0.1',25599));s.listen()
while 1: c,_=s.accept();c.sendall(b'ok-ngrok\n');c.close()" &
NGROK_AUTHTOKEN=$TOKEN "$TMP/ngrok" tcp 25599 --region "$REGION" --config "$TMP/ngrok.yml" --log stdout --log-format logfmt > "$TMP/log" 2>&1 &
for _ in $(seq 20); do grep -q 'url=tcp://\|lvl=eror\|ERR_NGROK' "$TMP/log" && break; sleep 1; done
URL=$(grep -o 'url=tcp://[^ ]*' "$TMP/log" | head -1 | cut -d/ -f3)
if [ -z "$URL" ]; then
  echo "ngrok no abrió el túnel:"; grep -E 'lvl=eror|ERR_NGROK|ERROR' "$TMP/log" | sed "s/$TOKEN/***/g"
  echo "(ERR_NGROK_8013 = la cuenta no tiene la tarjeta verificada)"; exit 1
fi
echo "Túnel: $URL"
H=${URL%:*}; P=${URL##*:}
timeout 5 bash -c "exec 3<>/dev/tcp/$H/$P; head -1 <&3" | grep -q ok-ngrok && echo "OK: el token sirve para túneles TCP." || { echo "El túnel abrió pero no respondió."; exit 1; }
ping -c3 "$H" | tail -1
