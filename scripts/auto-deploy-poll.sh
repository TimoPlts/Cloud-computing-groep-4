#!/usr/bin/env sh
set -eu

DEPLOY_REF="${DEPLOY_REF:-origin/main}"
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"
DEPLOY_SCRIPT="${DEPLOY_SCRIPT:-$PROJECT_DIR/scripts/deploy-with-rollback.sh}"

log() {
  printf '%s\n' "$1"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "Missing required command: $1"
    exit 1
  fi
}

main() {
  require_cmd git

  cd "$PROJECT_DIR"

  if [ ! -x "$DEPLOY_SCRIPT" ]; then
    log "Deploy script not found or not executable: $DEPLOY_SCRIPT"
    exit 1
  fi

  current_commit="$(git rev-parse HEAD)"

  log "Checking for updates on $DEPLOY_REF"
  git fetch origin
  target_commit="$(git rev-parse "$DEPLOY_REF")"

  if [ "$current_commit" = "$target_commit" ]; then
    log "No new commit found."
    exit 0
  fi

  log "New commit detected: $target_commit"
  PROJECT_DIR="$PROJECT_DIR" DEPLOY_REF="$DEPLOY_REF" "$DEPLOY_SCRIPT"
}

main "$@"
