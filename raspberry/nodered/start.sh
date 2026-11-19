#!/bin/sh
# Escribe las credenciales del broker MQTT para Node-RED desde raspberry/.env
# y despues arranca Node-RED normalmente. flows_cred.json no se versiona.
set -e

: "${MQTT_NODERED_PASS:?Falta MQTT_NODERED_PASS: copia raspberry/.env.example como raspberry/.env}"

node -e '
const fs = require("fs");
const cred = { br_main: { user: "nodealert", password: process.env.MQTT_NODERED_PASS } };
fs.writeFileSync("/data/flows_cred.json", JSON.stringify(cred, null, 2));
'
echo "Credenciales MQTT de Node-RED escritas en /data/flows_cred.json"

exec ./entrypoint.sh "$@"
