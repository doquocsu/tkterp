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

# 2. Check .env
if [ ! -f .env ]; then
    cp .env.example .env
    echo ".env file created from .env.example"
    echo "Please edit .env with your passwords, then re-run this script."
    exit 0
fi

# 3. Generate odoo.conf from template
sed 's|__ADMIN_PASSWORD__|devadmin|g' odoo.conf.example > odoo.conf
echo "odoo.conf generated (admin password: devadmin)"

# 4. Start containers
echo "Starting containers..."
podman-compose up -d

# 5. Wait for DB to be ready
echo "Waiting for database..."
for i in $(seq 1 30); do
    if podman exec tkterp-db pg_isready -q 2>/dev/null; then
        break
    fi
    sleep 1
done

# 6. Bootstrap database if it doesn't exist
podman-compose stop tkterp-app
if ! podman exec tkterp-db psql -U odoo -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='tkterp'" | grep -q 1 2>/dev/null; then
    echo "Creating database tkterp..."
    podman-compose run --rm tkterp-app odoo -d tkterp -i base,tkterp_base --stop-after-init
fi
echo "Setting admin user password to devadmin..."
podman-compose run --rm --entrypoint python3 tkterp-app -c "
import psycopg2, os
from passlib.context import CryptContext
ctx = CryptContext(schemes=['pbkdf2_sha512'])
hash = ctx.hash('devadmin')
conn = psycopg2.connect(host='tkterp-db', dbname='tkterp', user='odoo', password=os.environ['PASSWORD'])
cur = conn.cursor()
cur.execute('UPDATE res_users SET password = %s WHERE login = %s', (hash, 'admin'))
conn.commit()
cur.close()
conn.close()
print('Admin password updated to devadmin')
"
echo "Setting company currency to VND..."
podman-compose run --rm --entrypoint python3 tkterp-app -c "
import psycopg2, os
conn = psycopg2.connect(host='tkterp-db', dbname='tkterp', user='odoo', password=os.environ['PASSWORD'])
cur = conn.cursor()
cur.execute(\"UPDATE res_company SET currency_id = (SELECT id FROM res_currency WHERE name = 'VND') WHERE id = 1\")
conn.commit()
cur.close()
conn.close()
print('Currency set to VND')
"
podman-compose start tkterp-app
podman-compose restart tkterp-proxy

echo "Setting company logo..."
for i in $(seq 1 10); do
    podman exec tkterp-app python3 -c "import psycopg2, os; conn = psycopg2.connect(host='tkterp-db', dbname='tkterp', user='odoo', password=os.environ['PASSWORD']); conn.close()" 2>/dev/null && break
    echo "Waiting for Odoo container..."
    sleep 2
done
podman exec tkterp-app python3 -c "
import base64, os, psycopg2
conn = psycopg2.connect(host='tkterp-db', dbname='tkterp', user='odoo', password=os.environ['PASSWORD'])
cur = conn.cursor()
# Get company's partner_id
cur.execute('SELECT partner_id FROM res_company WHERE id = 1')
partner_id = cur.fetchone()[0]
# Read logo file
with open('/mnt/extra-addons/tkterp_base/static/tktplastic-logo.png', 'rb') as f:
    raw = f.read()
    b64 = base64.b64encode(raw).decode()
# Update ir_attachment for res.partner.image_1920
cur.execute(\"UPDATE ir_attachment SET db_datas = %s, mimetype = 'image/png', write_date = NOW() WHERE res_model = 'res.partner' AND res_field = 'image_1920' AND res_id = %s\",
    (psycopg2.Binary(raw), partner_id))
# Also update logo_web (attachment=False, stored as base64 text in column)
cur.execute('UPDATE res_company SET logo_web = %s WHERE id = 1', (b64,))
conn.commit()
cur.close()
conn.close()
print('Company logo set')
"

# 7. Show status
echo ""
echo "=== Status ==="
podman-compose ps
echo ""
echo "TKTErp is ready at http://localhost:8080"
echo "Admin password: devadmin"
echo ""
echo "To stop: podman-compose down"
echo "To view logs: podman-compose logs -f"
