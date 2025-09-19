#!/usr/bin/env bash
# Usage: check-arma.sh <systemd-service-name> [port] [host]
# Example: check-arma.sh arma-reforger.service 2004 127.0.0.1
set -euo pipefail

SERVICE="${1:-}"
PORT="${2:-}"
HOST="${3:-127.0.0.1}"

if [[ -z "$SERVICE" ]]; then
  echo "Usage: $0 <systemd-service-name> [port] [host]" >&2
  exit 2
fi

log() {
  if command -v logger >/dev/null 2>&1; then
    logger -t "check-arma[$SERVICE]" -- "$*"
  fi
  echo "$(date '+%F %T') $*"
}

# Avoid overlapping runs
if command -v flock >/dev/null 2>&1; then
  LOCK="/var/lock/check-arma.${SERVICE}.lock"
  exec 9>"$LOCK"
  flock -n 9 || exit 0
fi

is_service_active() {
  systemctl is-active --quiet "$SERVICE"
}

is_port_ok() {
  [[ -z "${PORT}" ]] && return 0
  if command -v nc >/dev/null 2>&1; then
    nc -z -w 2 "$HOST" "$PORT"
  elif command -v ss >/dev/null 2>&1; then
    # If process bound to port, assume OK
    ss -Htan | awk '{print $4}' | grep -qE "(^|:)$HOST:$PORT$"
  else
    return 0
  fi
}

DOWN_REASON=""
if ! is_service_active; then
  DOWN_REASON="service not active"
elif ! is_port_ok; then
  DOWN_REASON="port check failed (host=${HOST} port=${PORT})"
fi

if [[ -z "$DOWN_REASON" ]]; then
  log "OK: ${SERVICE} healthy$( [[ -n "$PORT" ]] && echo ", port ${PORT} responding" )."
  exit 0
fi

log "DETECTED DOWN: ${SERVICE} — ${DOWN_REASON}. Doing stop → start."
if ! systemctl stop "$SERVICE"; then
  log "WARN: systemctl stop ${SERVICE} returned non-zero."
fi
sleep 3
if ! systemctl start "$SERVICE"; then
  log "ERROR: systemctl start ${SERVICE} failed."
  exit 1
fi

# Post-check
sleep 5
if is_service_active && is_port_ok; then
  log "RECOVERED: ${SERVICE} back up$( [[ -n "$PORT" ]] && echo ", port ${PORT} responding" )."
  exit 0
else
  log "ERROR: ${SERVICE} failed post-recovery checks."
  exit 1
fi
