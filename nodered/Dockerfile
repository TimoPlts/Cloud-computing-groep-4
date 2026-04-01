FROM nodered/node-red:latest

RUN npm install --unsafe-perm --no-update-notifier --no-fund node-red-contrib-influxdb@0.7.0

COPY --chown=node-red:node-red flows.json /data/flows.json

RUN cp /usr/src/node-red/node_modules/node-red/settings.js /data/settings.js \
 && sed -i 's|^[[:space:]]*//credentialSecret: "a-secret-key",|    credentialSecret: "mF0B9oNC8xw5l1o_yw3asTWLtIhmGmk2WdJHioLG627A1IqmsgXnZuc7GmNgzzMMplAry7O8EzUFVL9EdKyalQ==",|' /data/settings.js \
 && chown node-red:node-red /data/settings.js