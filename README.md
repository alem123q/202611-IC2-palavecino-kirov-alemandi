# NodeAlert IoT — Trabajo Final

**Materia:** Ingeniería en Computación II
**TP:** Trabajo Final
**Universidad:** Universidad Nacional de Rafaela (UNRaf)
**Autores:** Sebastián Palavecino, Eloy Kirov, Francisco Alemandi

## 1. Descripción del proyecto

NodeAlert IoT es un sistema de monitoreo y control de iluminación para aulas y
laboratorios. Un nodo ESP32-C3 (Control Luz) mide presencia (radar LD2420), luz
(BH1750 ×2), temperatura y humedad (SHT30), y controla un relé de iluminación con
lógica local. La telemetría se publica por MQTT hacia una Raspberry Pi, donde
Node-RED la persiste en SQLite y un frontend React la visualiza y permite enviar
comandos.

## 2. Arquitectura

| Componente             | Dónde corre                | Función                          |
| ---------------------- | --------------------------- | --------------------------------- |
| ESP32-C3 (Control Luz) | Nodo físico                | Sensores + lógica + relé + MQTT |
| Mosquitto              | Raspberry Pi (Docker)       | Broker MQTT                       |
| Node-RED               | Raspberry Pi (Docker)       | Flujos, API REST, SQLite          |
| Frontend React         | Raspberry Pi (Docker/nginx) | Dashboard web                     |

## 3. Stack y dependencias

- Firmware: ESP-IDF 6.1, ESP32-C3
- Broker: Eclipse Mosquitto 2.0.20
- Backend: Node-RED 4.1.1, node-red-node-sqlite 2.0.1
- Frontend: React 18.3.1, Vite 5.4.8, nginx 1.27.2
- Base de datos: SQLite
- Simulador: Python 3 + paho-mqtt 2.1.0

## 4. Estructura del repositorio

```
firmware/control-luz/   -> firmware ESP32-C3
raspberry/              -> stack Docker
  docker-compose.yml
  mqtt/                 -> Mosquitto
  nodered/              -> flujos y datos
  frontend/             -> React
  simulator.py          -> simulador ESP32
  .env.example          -> configuración
  README.md             -> backend
docs/                   -> informe PDF
README.md               -> este archivo
```

## 5. Contrato MQTT

Tópicos:

- `nodealert/<device_id>/telemetry` (QoS 1): ESP32 → broker → Node-RED.
- `nodealert/<device_id>/commands` (QoS 1): Node-RED → broker → ESP32.
- `nodealert/<device_id>/status` (QoS 1, retain): LWT online/offline.

Payload telemetría:

```json
{"device_id":"nodealert-luz01","presencia":0/1,"luz_ventana_lx":..,"luz_aula_lx":..,"temp_c":..,"humedad_pct":..,"rele_canal1":0/1}
```

Caso sensor fallido: campos de luz/temp/humedad ausentes.

Comandos (texto plano): `REBOOT`, `RELE_ON`, `RELE_OFF`, `AUTO`, `LED_ON`, `LED_OFF`, `BUZZER_ON`, `BUZZER_OFF`.

## 6. Pinout ESP32-C3

| GPIO | Componente              |
| ---- | ----------------------- |
| 0    | Relé (activo en bajo)  |
| 1    | LED de presencia        |
| 4    | I2C SDA (BH1750, SHT30) |
| 5    | I2C SCL                 |
| 6    | UART TX (LD2420 RX)     |
| 7    | UART RX (LD2420 TX)     |

## 7. Puesta en marcha

### Raspberry Pi / Linux

```bash
git clone <repo>
cd <repo>/raspberry
cp .env.example .env
docker compose up -d --build
```

Verificar:

```bash
docker compose ps
curl http://localhost:1880/api/health
curl http://localhost:3001
```

### Windows

1. Instalar Docker Desktop (WSL2) y Git.
2. Clonar y entrar a `raspberry/`.
3. `docker compose up -d --build`
4. Abrir http://localhost:3001 y http://localhost:1880.

### Firmware

```bash
cd firmware/control-luz
idf.py set-target esp32c3
idf.py build
idf.py -p PUERTO flash monitor
```

Editar `main/config_local.h` con WiFi, broker IP, credenciales y device ID.

### Simulador

```bash
cd raspberry
python3 -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
export MQTT_ESP32_PASS=<clave>
python simulator.py --broker localhost
```

## 8. Limitaciones conocidas

- Sin TLS en MQTT.
- Un solo nodo implementado.
- Umbrales fijos en firmware (60/100 lx).
- Sin deep sleep (monitoreo en tiempo real priorizado).

## 9. Informe

El informe formal se encuentra en `docs/informe.pdf`.

## 10. Autores

Sebastián Palavecino, Eloy Kirov, Francisco Alemandi — Ingeniería en Computación II.
