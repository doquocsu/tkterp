# AGENTS.md - Project Instructions for TKTErp (TKTPlastic)

## Project Overview
**TKTErp** is the dedicated ERP solution for **TKTPlastic**, built on Odoo 19.

- **Author:** Binh Tran (binhtd.dev@gmail.com)
- **Core Technologies:** Odoo 19 (Community), PostgreSQL 15, Podman, systemd (Quadlets).

- **Architecture:** Rootless Podman containers managed as systemd services via Quadlet files (`.container`, `.network`).
- **Environment Management:** Uses a `.env` file for secrets (ignored by Git) and an `.env.example` for templating.

## Project Structure
- `tkterp-app.container`: Odoo application definition.
- `tkterp-db.container`: PostgreSQL database definition.
- `tkterp-net.network`: Private bridge network.
- `tkterp_addons/`: Root directory for all custom Odoo modules.
- `odoo.conf.example`: Odoo configuration template (tracked in git). Actual `odoo.conf` is generated at deploy time.
- `tkterp-db-data/` & `tkterp-data/`: Local host-path volumes for persistence (ignored by Git).

## Building and Running

### Local Development
1. **Initialize:** Link Quadlet files to `~/.config/containers/systemd/`.
2. **Reload:** `systemctl --user daemon-reload`.
3. **Start:** `systemctl --user start tkterp-app.service`.
4. **Logs:** `journalctl --user -u tkterp-app.service -f`.

### Deployment (Future)
- **Target:** Vinahost VPS with Podman installed.
- **Method:** GitHub Actions via SSH.
- **Workflow:** `git pull` -> `systemctl --user daemon-reload` -> `systemctl --user restart tkterp-app.service`.

## Development Conventions

### 1. Portability
- **NEVER** use absolute host paths in `.container` files. Always use the `%d` specifier to refer to the current directory.
- Use `EnvironmentFile=%d/.env` to manage secrets.

### 2. Custom Modules
- All new features must be implemented as Odoo modules within the `tkterp_addons/` directory.
- Follow standard Odoo coding conventions (Python for logic, XML for views).

### 3. Database Management
- The database is exposed on port `5432` for local development tools (DBeaver, etc.).
- Direct database edits are allowed for debugging but should be formalized via Odoo `data` or `migration` scripts for permanent changes.

### 4. Config Generation
- `odoo.conf` is generated from `odoo.conf.example` on deploy (CI replaces placeholders).
- Never commit `odoo.conf` directly — it's in `.gitignore`.

### 5. Commit Workflow
- **ALWAYS ask before committing.** Propose the commit title and wait for approval.
- Never commit without explicit user confirmation first.

### 6. Security
- Never commit the `.env` file.
- Use the `:Z` suffix on all volume mounts to handle SELinux/permission labeling correctly.
