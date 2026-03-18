FROM nodered/node-red:latest

RUN npm install --unsafe-perm --no-update-notifier --no-fund node-red-contrib-influxdb@0.7.0

COPY --chown=node-red:node-red lib/secretKey.js /data/lib/secretKey.js
