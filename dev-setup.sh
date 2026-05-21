#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== TKTErp Dev Setup ==="

# 1. Check prerequisites
if ! command -v podman &> /dev/null; then
    echo "ERROR: podman not found. Install it first."
    exit 1
fi
if ! command -v podman-compose &> /dev/null; then
    echo "ERROR: podman-compose not found. Install it first."
    exit 1
fi
if ! command -v uv &> /dev/null; then
    echo "ERROR: uv not found. Install it first (https://docs.astral.sh/uv/)."
    exit 1
fi

# 2. Check .env
if [ ! -f .env ]; then
    cp .env.example .env
    echo ".env file created from .env.example"
    echo "Please edit .env with your passwords, then re-run this script."
    exit 0
fi

# 3. Create Python venv for editor LSP (skips if exists)
if [ ! -d .venv ]; then
    echo "Creating Python venv for LSP support..."
    uv venv .venv
    echo "  Installing Odoo requirements (line-by-line, skipping build failures)..."
    while IFS= read -r pkg; do
        pkg="${pkg%%#*}"
        pkg="${pkg%"${pkg##*[![:space:]]}"}"
        [ -z "$pkg" ] && continue
        uv pip install "$pkg" 2>/dev/null || true
    done < refs/odoo/requirements.txt
    uv run python3 -c "import psycopg2" 2>/dev/null || uv pip install psycopg2-binary 2>/dev/null || true
    for f in tkterp_addons/*/requirements.txt; do
        [ -f "$f" ] && while IFS= read -r pkg; do
            pkg="${pkg%%#*}"
            pkg="${pkg%"${pkg##*[![:space:]]}"}"
            [ -z "$pkg" ] && continue
            uv pip install "$pkg" 2>/dev/null || true
        done < "$f"
    done
fi

# 4. Read admin password from .env and generate odoo.conf
ADMIN_PASSWORD=$(grep -oP '(?<=^ADMIN_PASSWORD=).*' .env)
sed "s|__ADMIN_PASSWORD__|${ADMIN_PASSWORD}|g" odoo.conf.example > odoo.conf
echo "odoo.conf generated (admin password: ${ADMIN_PASSWORD})"

# 5. Start containers
echo "Starting containers..."
podman-compose up -d

# 6. Wait for DB to be ready
echo "Waiting for database..."
for i in $(seq 1 30); do
    if podman exec tkterp-db pg_isready -q 2>/dev/null; then
        break
    fi
    sleep 1
done

# 7. Bootstrap database if it doesn't exist
podman-compose stop tkterp-app
if ! podman exec tkterp-db psql -U odoo -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='tkterp'" | grep -q 1 2>/dev/null; then
    echo "Creating database tkterp..."
    podman-compose run --rm tkterp-app odoo -d tkterp -i base,tkterp_base --stop-after-init
fi
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

# 8. Show status
echo ""
echo "=== Status ==="
podman-compose ps
echo ""
echo "TKTErp is ready at http://localhost:8080"
echo "Admin password: ${ADMIN_PASSWORD}"
echo ""
echo "To stop: podman-compose down"
echo "To view logs: podman-compose logs -f"
