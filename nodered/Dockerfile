FROM nodered/node-red:latest

RUN npm install --unsafe-perm --no-update-notifier --no-fund node-red-contrib-influxdb@0.7.0

COPY --chown=node-red:node-red flows.json /opt/nodered-seed/flows.json
COPY --chown=node-red:node-red lib /opt/nodered-seed/lib
COPY --chown=node-red:node-red entrypoint.sh /opt/nodered-seed/entrypoint.sh

RUN chmod +x /opt/nodered-seed/entrypoint.sh

ENTRYPOINT ["/opt/nodered-seed/entrypoint.sh"]
