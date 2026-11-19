#!/bin/sh
# Crea los usuarios del broker en cada arranque con las claves de raspberry/.env.
# Si falta alguna, el contenedor no arranca (mejor que arrancar con una clave por defecto).
set -e

: "${MQTT_NODERED_PASS:?Falta MQTT_NODERED_PASS: copia raspberry/.env.example como raspberry/.env}"
: "${MQTT_ESP32_PASS:?Falta MQTT_ESP32_PASS: copia raspberry/.env.example como raspberry/.env}"

PASSWORDFILE=/mosquitto/config/passwordfile

mosquitto_passwd -c -b "$PASSWORDFILE" nodealert "$MQTT_NODERED_PASS"
mosquitto_passwd -b "$PASSWORDFILE" nodealert_esp32 "$MQTT_ESP32_PASS"
chown 1883:1883 "$PASSWORDFILE"
chmod 0700 "$PASSWORDFILE"
echo "Usuarios del broker creados: 'nodealert' (Node-RED) y 'nodealert_esp32' (ESP32)"

chown -R 1883:1883 /mosquitto/data 2>/dev/null || true

exec "$@"
