FROM nodered/node-red:4.1.1

RUN npm install node-red-node-sqlite@2.0.1

# Escribe las credenciales MQTT desde raspberry/.env antes de arrancar Node-RED
COPY start.sh /usr/src/node-red/start.sh
ENTRYPOINT ["/bin/sh", "/usr/src/node-red/start.sh"]
