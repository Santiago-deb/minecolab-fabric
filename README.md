# MineColab Fabric 26.3

Servidor de Minecraft **Fabric 26.3** en Google Colab, gratis, apto para cuentas **no premium** y sin necesidad de ngrok.

[![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Santiago-deb/minecolab-fabric/blob/main/MineServerColab-Fabric-26.3.ipynb)

## Cómo usarlo

1. Abrí el notebook con el botón de arriba (o subí `MineServerColab-Fabric-26.3.ipynb` a Colab).
2. **Celda 1 · Configuración**: revisá el formulario. Lo de fábrica ya sirve.
3. **Celda 2 · Instalar**: pide permiso para Google Drive (ahí se guarda el mundo) y baja Java 25, Fabric y Fabric API.
4. **Celda 3 · Iniciar**: muestra `==> IP del servidor: bore.pub:XXXXX`. Esa es la dirección para *Multijugador → Añadir servidor*.
5. La salida de la celda 3 es la consola. Escribí comandos ahí (`op TuNick`, `whitelist add Amigo`, `stop`...).
6. Apagá **siempre con `stop`** para que se guarde todo en Drive.

| Opción | Qué hace |
|---|---|
| `VERSION` | Versión de Minecraft (`26.3`). Sirve cualquier versión que soporte Fabric. |
| `CARPETA_DRIVE` | Carpeta en *Mi unidad* donde vive el servidor. |
| `TUNEL` | `bore` (sin cuenta), `playit` (cuenta gratis, IP fija) o `ngrok` (con token). |
| `RAM_GB` | `0` = 75 % de la RAM de la máquina (unos 9 GB en Colab gratis). |
| `ONLINE_MODE` | `False` = entran cuentas no premium. |
| `INSTALAR_FABRIC_API` | Baja la Fabric API de Modrinth para esa versión. |

**Mods:** poné los `.jar` en `Mi unidad/<CARPETA_DRIVE>/mods/` y volvé a correr la celda 2.

## Cómo se hizo (y por qué el MineColab viejo ya no anda)

Partí de un notebook basado en [MineColab](https://github.com/thecoder-001/MineColab) (versión en español de ALEIXMINE17 / SoyMichas). Al revisarlo para 26.3 encontré tres cosas rotas:

1. **serverjars.com cerró.** El notebook bajaba Fabric, Forge, etc. de ahí y ahora esa URL redirige a otra cosa. Ahora el servidor se baja directo de la API oficial de Fabric: `https://meta.fabricmc.net/v2/versions/loader/<mc>/<loader>/<installer>/server/jar`. Esa URL devuelve un *launcher* que, en el primer arranque, descarga el `server.jar` de Mojang y las librerías. El loader se elige solo: el último estable compatible con esa versión.
2. **Java.** El notebook instalaba OpenJDK 17 por apt. Según el manifest de Mojang, Minecraft 26.x pide **Java 25** (`javaVersion.majorVersion = 25`), y el apt de Colab (Ubuntu 22.04) no lo trae. Ahora se baja el JRE de **Temurin 25** de la API de Adoptium y se descomprime en `/content/java25`.
3. **ngrok TCP.** El plan gratis de ngrok ya no da túneles TCP sin verificar una tarjeta. Por defecto se usa **[bore](https://github.com/ekzhang/bore)** contra el servidor público `bore.pub`: no pide cuenta y te da `bore.pub:<puerto>`. ngrok y [playit.gg](https://playit.gg) quedan como alternativas.

Otros cambios:

- **No premium:** `online-mode=false` y además `enforce-secure-profile=false`. Sin lo segundo, las cuentas no premium no pueden chatear en versiones nuevas.
- **Rendimiento:** el servidor ya no corre sobre la carpeta de Drive montada, que es lenta y puede corromper el mundo. Ahora se copia a `/content/server` y corre en el disco local. Cada 10 minutos hace `save-off` → `save-all flush` → `rsync` a Drive → `save-on`, y una vez más al apagar.
- **Consola:** el servidor se lanza con `subprocess` y la celda lee lo que escribís con `input()`, así los comandos le llegan por stdin. Si cortás la celda con ⏹, igual manda `stop` y guarda.

### Cómo se probó

- Primero, en local: la misma lógica del notebook con Drive desactivado. Java 25 → Fabric 0.19.5 + Fabric API 0.164.0 (42 mods cargados). El servidor arranca en ~7 s, el túnel bore queda abierto y `stop` apaga y guarda bien.
- Después, en Colab de verdad: el servidor quedó accesible desde internet por `bore.pub`.
- Para comprobar desde afuera que responde está `herramientas/ping.py`. Hace el *handshake* de estado del protocolo de Minecraft y muestra versión, MOTD y jugadores:

  ```
  $ python3 herramientas/ping.py bore.pub:4226
  {"description": "Servidor Fabric 26.3 en Colab", "players": {"max": 10, "online": 0}, "version": {"name": "26.3", "protocol": 777}}
  ```

## Avisos

- La IP de bore **cambia en cada arranque**. Si querés una fija, usá `playit`.
- Colab gratis corta por inactividad o a las ~12 h, y puede pedirte un captcha. Dejá la pestaña abierta.
- Con `online-mode` apagado **cualquiera puede entrar con cualquier nick**, incluso el tuyo. Si compartís la IP, usá un mod de login como *EasyAuth*.
- La **whitelist viene apagada**. Si la prendés, `whitelist add <nick>` guarda el UUID de la cuenta *premium* con ese nombre (si existe), y el jugador no premium con ese nick queda afuera igual ("You are not white-listed").
- Usar Colab para servidores de juegos va contra el espíritu de sus términos. Úsalo para jugar un rato con amigos, no como hosting permanente.

## Licencia

GPL-3.0, igual que el MineColab original en el que se basa.
