FROM nodered/node-red:latest

ARG NODE_RED_CREDENTIAL_SECRET

RUN npm install --unsafe-perm --no-update-notifier --no-fund node-red-contrib-influxdb@0.7.0 \
 && node -e 'const fs=require("fs"); const file="/usr/src/node-red/node_modules/node-red-contrib-influxdb/influxdb.js"; const from="this.credentials.token"; const to="(this.credentials.token || process.env.INFLUXDB_TOKEN)"; const source=fs.readFileSync(file,"utf8"); if (!source.includes(from)) { throw new Error("node-red-contrib-influxdb token lookup not found"); } fs.writeFileSync(file, source.replace(from, to));'

COPY --chown=node-red:node-red flows.json /data/flows.json

RUN cp /usr/src/node-red/node_modules/node-red/settings.js /data/settings.js \
 && sed -i "s|^[[:space:]]*//credentialSecret: \"a-secret-key\",|    credentialSecret: \"${NODE_RED_CREDENTIAL_SECRET}\",|" /data/settings.js \
 && chown node-red:node-red /data/settings.js
