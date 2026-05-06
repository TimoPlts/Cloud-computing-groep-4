#!/usr/bin/env sh
set -eu

DEPLOY_REF="${DEPLOY_REF:-origin/main}"
HEALTH_RETRIES="${HEALTH_RETRIES:-24}"
HEALTH_SLEEP_SECONDS="${HEALTH_SLEEP_SECONDS:-5}"
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"

log() {
  printf '%s\n' "$1"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "Missing required command: $1"
    exit 1
  fi
}

check_compose_health() {
  container_ids="$(docker compose ps -q)"

  if [ -z "$container_ids" ]; then
    log "No containers found for this compose project."
    return 1
  fi

  for container_id in $container_ids; do
    state="$(docker inspect -f '{{.State.Status}}' "$container_id")"
    health="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$container_id")"

    if [ "$state" != "running" ]; then
      log "Container $container_id is not running (state: $state)."
      return 1
    fi

    if [ "$health" = "unhealthy" ]; then
      log "Container $container_id is unhealthy."
      return 1
    fi
  done

  curl --fail --silent --show-error http://127.0.0.1:1880/ >/dev/null
  curl --fail --silent --show-error http://127.0.0.1:3000/login >/dev/null
  curl --fail --silent --show-error http://127.0.0.1:8086/health >/dev/null
  curl --fail --silent --show-error http://127.0.0.1:9000/api/status >/dev/null
}

wait_for_stack() {
  attempt=1

  while [ "$attempt" -le "$HEALTH_RETRIES" ]; do
    if check_compose_health; then
      log "Health checks passed."
      return 0
    fi

    log "Health check attempt $attempt/$HEALTH_RETRIES failed. Waiting ${HEALTH_SLEEP_SECONDS}s..."
    sleep "$HEALTH_SLEEP_SECONDS"
    attempt=$((attempt + 1))
  done

  return 1
}

deploy_commit() {
  commit="$1"

  log "Checking out commit $commit"
  git checkout --detach "$commit"

  log "Building and starting the updated stack"
  docker compose up -d --build --remove-orphans
}

main() {
  require_cmd git
  require_cmd docker
  require_cmd curl

  cd "$PROJECT_DIR"

  previous_commit="$(git rev-parse HEAD)"
  current_branch="$(git branch --show-current || true)"

  log "Fetching latest changes for $DEPLOY_REF"
  git fetch origin
  target_commit="$(git rev-parse "$DEPLOY_REF")"

  if [ "$previous_commit" = "$target_commit" ]; then
    log "Already on latest commit $target_commit. Re-applying deployment."
  else
    log "Deploying commit $target_commit (previous: $previous_commit)"
  fi

  deploy_commit "$target_commit"

  if wait_for_stack; then
    log "Deployment succeeded on commit $target_commit"
    exit 0
  fi

  log "Deployment failed. Showing recent logs before rollback."
  docker compose logs --tail=100 || true

  log "Rolling back to previous commit $previous_commit"
  deploy_commit "$previous_commit"

  if wait_for_stack; then
    log "Rollback succeeded. Active commit restored to $previous_commit"
  else
    log "Rollback failed. Manual intervention required."
    docker compose logs --tail=100 || true
    exit 1
  fi

  if [ -n "$current_branch" ]; then
    log "Note: deployment checkout is now detached. Original branch was $current_branch."
  fi

  exit 1
}

main "$@"
