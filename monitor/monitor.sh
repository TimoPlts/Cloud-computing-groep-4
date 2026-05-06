#!/usr/bin/env sh
set -eu

: "${DISCORD_WEBHOOK_URL:?DISCORD_WEBHOOK_URL is required}"

MONITOR_INTERVAL="${MONITOR_INTERVAL:-60}"
MONITOR_STARTUP_DELAY="${MONITOR_STARTUP_DELAY:-60}"
MONITOR_TARGETS="${MONITOR_TARGETS:-influxdb grafana portainer nodered mosquitto sensor-sim}"
STATE_DIR="${STATE_DIR:-/state}"

mkdir -p "$STATE_DIR"

send_discord_message() {
  message=$1

  jq -n --arg content "$message" '{content: $content}' \
    | curl -fsS -H 'Content-Type: application/json' -d @- "$DISCORD_WEBHOOK_URL" >/dev/null
}

check_influxdb() {
  curl -fsS http://influxdb:8086/health >/dev/null
}

check_grafana() {
  curl -fsS http://grafana:3000/api/health >/dev/null
}

check_portainer() {
  curl -fsS http://portainer:9000/api/status >/dev/null
}

check_nodered() {
  curl -fsS http://nodered:1880/ >/dev/null
}

check_mosquitto() {
  nc -z -w 2 mosquitto 1883 >/dev/null 2>&1
}

check_sensor_sim() {
  [ "$(docker inspect -f '{{.State.Running}}' sensor-sim 2>/dev/null || printf 'false')" = "true" ]
}

is_service_up() {
  service_name=$1

  case "$service_name" in
    influxdb)
      check_influxdb
      ;;
    grafana)
      check_grafana
      ;;
    portainer)
      check_portainer
      ;;
    nodered)
      check_nodered
      ;;
    mosquitto)
      check_mosquitto
      ;;
    sensor-sim)
      check_sensor_sim
      ;;
    *)
      echo "Onbekende service in MONITOR_TARGETS: $service_name" >&2
      return 1
      ;;
  esac
}

record_state() {
  service_name=$1
  state_value=$2
  printf '%s' "$state_value" > "$STATE_DIR/$service_name.state"
}

previous_state() {
  service_name=$1
  if [ -f "$STATE_DIR/$service_name.state" ]; then
    cat "$STATE_DIR/$service_name.state"
  else
    printf ''
  fi
}

sleep "$MONITOR_STARTUP_DELAY"

while :; do
  for service_name in $MONITOR_TARGETS; do
    current_state="up"
    if ! is_service_up "$service_name"; then
      current_state="down"
    fi

    last_state=$(previous_state "$service_name")

    if [ "$current_state" != "$last_state" ]; then
      if [ "$current_state" = "down" ]; then
        send_discord_message "Alert: $service_name heeft een probleem. Controleer de Docker-container."
      else
        send_discord_message "Herstel: $service_name draait weer normaal."
      fi

      record_state "$service_name" "$current_state"
    fi
  done

  sleep "$MONITOR_INTERVAL"
done