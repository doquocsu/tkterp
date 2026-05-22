#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== TKTErp Database Reset ==="
echo "WARNING: This will delete ALL database data and Odoo filestore!"
read -p "Are you sure? (y/N): " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Cancelled."
    exit 0
fi

# 1. Stop containers
echo "Stopping containers..."
podman-compose down

# 2. Remove data directories (using podman unshare for container-owned files)
echo "Removing database and filestore data..."
podman unshare find tkterp-db-data/ -mindepth 1 -delete 2>/dev/null || true
podman unshare find tkterp-data/ -mindepth 1 -delete 2>/dev/null || true
mkdir -p tkterp-db-data tkterp-data

# 3. Read admin password from .env and regenerate odoo.conf
ADMIN_PASSWORD=$(grep -oP '(?<=^ADMIN_PASSWORD=).*' .env)
echo "Regenerating odoo.conf..."
sed "s|__ADMIN_PASSWORD__|${ADMIN_PASSWORD}|g" odoo.conf.example > odoo.conf

# 4. Start fresh
echo "Starting fresh..."
podman-compose up -d

# 5. Wait for DB to be ready
echo "Waiting for database..."
for i in $(seq 1 30); do
    if podman exec tkterp-db pg_isready -q 2>/dev/null; then
        break
    fi
    sleep 1
done

# 6. Bootstrap database
podman-compose stop tkterp-app
echo "Creating database tkterp..."
podman-compose run --rm tkterp-app odoo -d tkterp -i base,tkterp_base --stop-after-init
echo "Setting admin user password from ADMIN_PASSWORD env..."
podman-compose run --rm --entrypoint python3 tkterp-app /scripts/set_admin_password.py
podman-compose start tkterp-app
podman-compose restart tkterp-proxy

echo "Setting company logo..."
for i in $(seq 1 10); do
    podman exec tkterp-app python3 /scripts/set_company_logo.py 2>/dev/null && break
    echo "Waiting for Odoo container..."
    sleep 2
done

echo ""
echo "Database reset complete."
echo "TKTErp is ready at http://localhost:8080"
echo "Admin password: ${ADMIN_PASSWORD}"
