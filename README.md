# TKTErp - ERP Solution for TKTPlastic

This project is a customized Odoo 19 environment for **TKTPlastic**, designed for local development with `podman-compose` and deployment to a VPS via Podman Quadlets + GitHub Actions.

## Quickstart

```bash
./dev-setup.sh
```

Then visit [http://localhost:8080](http://localhost:8080) (admin password: `devadmin`).

## Project Structure

- `tkterp-app.container` / `tkterp-db.container` / `tkterp-proxy.container`: Podman Quadlet definitions (used in production).
- `tkterp-net.network`: Private network for container communication.
- `compose.yaml`: Docker Compose equivalent for local development.
- `tkterp-addons/`: Directory for custom Odoo modules.
- `tkterp-db-data/` & `tkterp-data/`: (Ignored) Local persistence for PostgreSQL and Odoo filestore.
- `odoo.conf.example`: Odoo config template (tracked in git). Actual `odoo.conf` is generated at deploy/dev time.
- `.env`: (Ignored) Secret environment variables.
- `nginx/`: Nginx reverse proxy config for production.

## Local Development

### 1. Prerequisites
- Podman + podman-compose installed.

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your passwords
nano .env
```

### 3. Start

```bash
./dev-setup.sh
```

This will:
- Generate `odoo.conf` from the template (admin password: `devadmin`).
- Start all containers via `podman-compose up -d`.

### 4. Access

Odoo is available at [http://localhost:8080](http://localhost:8080).

| Component | Port |
|-----------|------|
| Odoo (via Nginx) | `8080` |
| PostgreSQL (direct) | `5432` |

### 5. Bootstrap Database (Optional)

Skip the manual DB creation screen:

```bash
podman-compose run --rm tkterp-app odoo -d tkterp -i purchase,sale_management,stock,mrp --stop-after-init
```

### Useful Commands

```bash
podman-compose ps          # Container status
podman-compose logs -f     # Tail logs
podman-compose down        # Stop containers
podman-compose restart     # Restart all
```

## Production Deployment (VPS)

We use **Podman Quadlets** on AlmaLinux for production. This allows Odoo to run as native systemd services.

### Initial Provisioning (One-Time)

```bash
scp vps-setup.sh user@your-vps-ip:~/
ssh user@your-vps-ip
chmod +x ~/vps-setup.sh
./vps-setup.sh
```

### GitHub Actions Deployment

The CI/CD workflow (`.github/workflows/deploy.yml`) runs on every push to `main`.

#### Required Secrets

| Secret | Description |
|:---|---|
| `VPS_HOST` | VPS IP address |
| `VPS_USER` | SSH username |
| `SSH_PRIVATE_KEY` | Private SSH key |
| `POSTGRES_USER` | Database user |
| `POSTGRES_PASSWORD` | Database password |
| `POSTGRES_DB` | Initial DB name |
| `ODOO_ADMIN_PASSWORD` | Odoo master admin password |
| `SMTP_SERVER` | SMTP host |
| `SMTP_PORT` | SMTP port (default 587) |
| `SMTP_USER` | SMTP username |
| `SMTP_PASSWORD` | SMTP password |
| `SMTP_SSL` | `true` or `false` |

## Author

- **Maintainer:** Binh Tran (Trần Đức Bình)
- **Email:** binhtd.dev@gmail.com
- **Project:** TKTErp for TKTPlastic
