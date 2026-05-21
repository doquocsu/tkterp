#!/bin/bash
set -e

for f in /mnt/extra-addons/*/requirements.txt; do
    [ -f "$f" ] && pip3 install --break-system-packages -r "$f"
done

exec /entrypoint.sh "$@"
