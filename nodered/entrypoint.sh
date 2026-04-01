#!/bin/sh
set -eu

mkdir -p /data/lib

SETTINGS_FILE=/data/settings.js
DEFAULT_SETTINGS_FILE=/usr/src/node-red/node_modules/node-red/settings.js

if [ ! -f /data/flows.json ]; then
  cp /opt/nodered-seed/flows.json /data/flows.json
fi

if [ -d /opt/nodered-seed/lib ]; then
  if [ "$force_seed" = "true" ] || [ ! -e /data/lib/secretKey.js ]; then
    cp -R /opt/nodered-seed/lib/. /data/lib/
  fi
fi

if [ ! -f "$SETTINGS_FILE" ] && [ -f "$DEFAULT_SETTINGS_FILE" ]; then
  cp "$DEFAULT_SETTINGS_FILE" "$SETTINGS_FILE"
fi

if [ -f "$SETTINGS_FILE" ]; then
  if grep -q "credentialSecret: require('./lib/secretKey').key" "$SETTINGS_FILE"; then
    :
  elif grep -q '^[[:space:]]*//credentialSecret: "a-secret-key",' "$SETTINGS_FILE"; then
    sed -i "s|^[[:space:]]*//credentialSecret: \"a-secret-key\",|    credentialSecret: require('./lib/secretKey').key,|" "$SETTINGS_FILE"
  elif grep -q '^[[:space:]]*credentialSecret:' "$SETTINGS_FILE"; then
    sed -i "s|^[[:space:]]*credentialSecret:.*|    credentialSecret: require('./lib/secretKey').key,|" "$SETTINGS_FILE"
  fi
fi

if [ -f /data/.config.runtime.json ]; then
  sed -i '/"_credentialSecret"[[:space:]]*:/d' /data/.config.runtime.json
fi

exec /usr/src/node-red/entrypoint.sh "$@"
