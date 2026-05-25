#!/bin/bash
set -e

echo "TKTErp worktree setup: creating data dirs and linking Quadlets..."
cd "$REPO_PATH"

mkdir -p tkterp-data tkterp-db-data

mkdir -p ~/.config/containers/systemd
ln -sf "$(pwd)"/*.container ~/.config/containers/systemd/
ln -sf "$(pwd)"/*.network ~/.config/containers/systemd/
systemctl --user daemon-reload
