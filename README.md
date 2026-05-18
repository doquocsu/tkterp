# TKTErp - ERP Solution for TKTPlastic

This project is a customized Odoo 19 environment for **TKTPlastic**, designed for local development and seamless deployment to a VPS using Podman Quadlets.

## Project Structure

- `tkterp-app.container`: Podman Quadlet definition for the Odoo application.
- `tkterp-db.container`: Podman Quadlet definition for the PostgreSQL database.
- `tkterp-net.network`: Private network for container communication.
- `tkterp-addons/`: Directory for custom Odoo modules.
- `tkterp-db-data/`: (Ignored) Local persistence for PostgreSQL.
- `tkterp-data/`: (Ignored) Local persistence for Odoo filestore.
- `odoo.conf`: Odoo configuration file.
- `.env`: (Ignored) Secret environment variables.

## Local Setup

### 1. Prerequisites
- Podman installed on your system.
- `systemd` (standard on most Linux distributions).

### 2. Configure Environment
Copy the example environment file and update the passwords:
```bash
cp .env.example .env
# Edit .env with your preferred passwords
nano .env
```

### 3. Initialize Quadlets
Link the project files to your user's systemd directory to enable Quadlet management:
```bash
mkdir -p ~/.config/containers/systemd
ln -s $(pwd)/*.container ~/.config/containers/systemd/
ln -s $(pwd)/*.network ~/.config/containers/systemd/
```

### 4. Start the Application
Reload systemd to detect the new Quadlets and start the service:
```bash
systemctl --user daemon-reload
systemctl --user start tkterp-app.service
```

Odoo will be available at [http://localhost:8069](http://localhost:8069).

### 5. Managing the Service
- **Check status:** `systemctl --user status tkterp-app.service`
- **View logs:** `journalctl --user -u tkterp-app.service -f`
- **Stop:** `systemctl --user stop tkterp-app.service`
- **Restart:** `systemctl --user restart tkterp-app.service`

## Database Access

The PostgreSQL database is exposed on port **5432**. You can connect using tools like DBeaver, pgAdmin, or `psql` using the credentials defined in your `.env` file.

- **Host:** `localhost`
- **Port:** `5432`
- **User:** (from .env)
- **Password:** (from .env)

## VPS Setup (AlmaLinux)

### 1. Install Podman
AlmaLinux (RHEL-based) comes with excellent Podman support. Install it using:
```bash
sudo dnf update -y
sudo dnf install podman -y
```

### 2. Enable Linger
For rootless containers to stay running after you logout, enable lingering for your user:
```bash
loginctl enable-linger $USER
```

## GitHub Actions Deployment

The CI/CD workflow is defined in `.github/workflows/deploy.yml`.

### 1. Configure GitHub Secrets
Go to your GitHub Repository **Settings > Secrets and variables > Actions** and add the following secrets:

| Secret Name | Description |
| :--- | :--- |
| `VPS_HOST` | The IP address of your AlmaLinux VPS |
| `VPS_USER` | The SSH username |
| `SSH_PRIVATE_KEY` | Your private SSH key |
| `POSTGRES_USER` | Database username (e.g., odoo) |
| `POSTGRES_PASSWORD`| Database password |
| `POSTGRES_DB` | Initial DB name |
| `ODOO_ADMIN_PASSWORD`| Odoo Master Password |
| `SMTP_SERVER` | SMTP host |
| `SMTP_PORT` | SMTP port |
| `SMTP_USER` | SMTP username |
| `SMTP_PASSWORD`| SMTP password |
| `SMTP_SSL` | true/false |

### 2. How it works
On every push to the `main` branch, GitHub will:
1. Connect to your VPS via SSH.
2. Pull the latest code and custom addons.
3. Sync your secrets to a `.env` file on the server.
4. Refresh the Podman Quadlet services.

## Initial VPS Provisioning (One-Time)

Before the GitHub Action can work, you must prepare the server. We have provided a script to automate this:

1. **Upload the script to your VPS:**
   ```bash
   scp vps-setup.sh user@your-vps-ip:~/
   ```
2. **Run the script on the VPS:**
   ```bash
   chmod +x ~/vps-setup.sh
   ./vps-setup.sh
   ```

This script will install Podman, enable user lingering, open the firewall (8069), and create the necessary folder structure.

