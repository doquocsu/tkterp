#!/bin/bash
set -e

ACTION="${1:-start}"

case "$ACTION" in
  start)
    echo "Starting TKTErp containers..."
    podman-compose up -d
    ;;
  stop)
    echo "Stopping TKTErp containers..."
    podman-compose down
    ;;
  status)
    podman-compose ps
    ;;
  *)
    echo "Usage: $0 {start|stop|status}"
    exit 1
    ;;
esac
