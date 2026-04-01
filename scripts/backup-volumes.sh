#!/usr/bin/env sh
set -eu

OUTPUT_DIR="backups"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --output-dir)
      if [ "$#" -lt 2 ]; then
        echo "Ontbrekende waarde voor --output-dir" >&2
        exit 1
      fi
      OUTPUT_DIR="$2"
      shift 2
      ;;
    *)
      echo "Onbekend argument: $1" >&2
      echo "Gebruik: ./scripts/backup-volumes.sh [--output-dir <map>]" >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
cd "$REPO_ROOT"

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_ROOT="$REPO_ROOT/$OUTPUT_DIR"
mkdir -p "$BACKUP_ROOT"

PROJECT_NAME=$(docker compose config --format json | tr -d '\r' | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
if [ -z "$PROJECT_NAME" ]; then
  echo "Kon de Compose-projectnaam niet bepalen." >&2
  exit 1
fi

LOGICAL_VOLUMES="influxdb-data nodered-data portainer_data"
COMPOSE_VOLUMES=$(docker volume ls --filter "label=com.docker.compose.project=$PROJECT_NAME" --format '{{.Name}}')
if [ -z "$COMPOSE_VOLUMES" ]; then
  echo "Geen compose-volumes gevonden voor project: $PROJECT_NAME" >&2
  exit 1
fi

echo "Compose-project: $PROJECT_NAME"
echo "Backupmap: $BACKUP_ROOT"

for LOGICAL_VOLUME in $LOGICAL_VOLUMES; do
  DOCKER_VOLUME=$(printf '%s\n' "$COMPOSE_VOLUMES" | awk -v p="$PROJECT_NAME" -v v="$LOGICAL_VOLUME" '$0 == p"_"v || $0 == p"-"v { print; exit }')

  if [ -z "$DOCKER_VOLUME" ]; then
    echo "Waarschuwing: volume niet gevonden, wordt overgeslagen: $LOGICAL_VOLUME" >&2
    continue
  fi

  ARCHIVE_NAME="$DOCKER_VOLUME-$TIMESTAMP.tar.gz"
  ARCHIVE_PATH="$BACKUP_ROOT/$ARCHIVE_NAME"

  echo "Backup bezig: $DOCKER_VOLUME"

  TEMP_CONTAINER=$(docker create -v "$DOCKER_VOLUME:/volume:ro" alpine sh -c 'tar -czf /tmp/backup.tar.gz -C /volume .')
  if [ -z "$TEMP_CONTAINER" ]; then
    echo "Kon geen tijdelijke container maken voor: $DOCKER_VOLUME" >&2
    exit 1
  fi

  docker start -a "$TEMP_CONTAINER" >/dev/null
  docker cp "$TEMP_CONTAINER:/tmp/backup.tar.gz" "$ARCHIVE_PATH" >/dev/null
  docker rm -f "$TEMP_CONTAINER" >/dev/null

  echo "Backup klaar: $ARCHIVE_PATH"
done

echo "Alle beschikbare volume-backups zijn voltooid."
