# Servidor con ngrok

Variante del notebook principal que usa **ngrok** como túnel en vez de bore.pub. Sirve para bajar el lag: con la región `sa` (São Paulo), el tramo jugador → túnel pasa de unos 195 ms (bore.pub está en New Jersey) a unos 90–130 ms desde Argentina. La VM de Colab sigue estando en EE. UU., así que no hace milagros.

[![Abrir en Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Santiago-deb/minecolab-fabric/blob/main/ngrok/MineServerColab-Fabric-26.3-ngrok.ipynb)

## Qué necesitás

- Una cuenta de [ngrok](https://dashboard.ngrok.com) **verificada con tarjeta**. Sin eso, ngrok no da túneles TCP (error `ERR_NGROK_8013`). No cobra nada.
- Tu **authtoken**: <https://dashboard.ngrok.com/get-started/your-authtoken>.

## Cómo usarlo

1. Abrí el notebook con el botón de arriba.
2. En Colab, abrí 🔑 **Secretos** (barra izquierda) → *Agregar secreto nuevo*:
   - Nombre: `NGROK_TOKEN`
   - Valor: tu authtoken
   - Activá **Acceso del notebook**.
3. Celda 1: poné la misma `CARPETA_DRIVE` que tu servidor (si ya tenías uno con bore, usá esa carpeta y sigue el mismo mundo).
4. Celdas 2 y 3, como siempre. La IP sale así: `==> IP del servidor: 0.tcp.sa.ngrok.io:12345`.
5. Apagá siempre con `stop`.

**No pegues el token en el campo `NGROK_TOKEN` del formulario** si vas a guardar o compartir el notebook: queda escrito adentro. El secreto de Colab queda en tu cuenta y no viaja con el archivo.

| Opción | Qué hace |
|---|---|
| `NGROK_REGION` | Dónde está la entrada del túnel. `sa` = São Paulo (lo mejor desde Sudamérica). |
| `NGROK_TOKEN` | Vacío = lo lee del secreto `NGROK_TOKEN`. |
| `MODO_PRUEBA` | Trae el mundo de Drive pero **no escribe nada en Drive**. Para probar el túnel sin arriesgar el mundo; lo que pase en esa partida se pierde. |

El resto de las opciones son las del notebook principal.

## Probar el token antes (en tu PC)

```
./probar_token.sh archivo_con_el_token      # o: NGROK_TOKEN=... ./probar_token.sh
```

Baja ngrok a una carpeta temporal, abre un túnel TCP de prueba y se conecta a través de él. Si dice `OK`, el token sirve para el servidor.

## Cuidado del mundo

- El mundo se copia de Drive a `/content/server` y se vuelve a guardar en Drive cada 10 minutos y al hacer `stop`.
- Antes de guardar, el notebook comprueba que el mundo exista en local (`*/level.dat`). Si no está (por ejemplo, porque la copia desde Drive falló), **no toca Drive**, para no pisar el mundo guardado con uno vacío.
- Con `MODO_PRUEBA` no se escribe nada en Drive.
