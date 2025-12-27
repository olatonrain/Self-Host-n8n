# 🚀 n8n-traefik-installer (Official Lanre Edition)

A production-ready Bash script to deploy **n8n** with **Traefik** reverse proxy and automatic **Let's Encrypt SSL** on any Linux VPS. Designed for speed, stability, and resource management.

## 🌟 Features

* **Zero Dependencies:** Automatically checks for Docker and installs it if missing.
* **Automated SSL:** Uses Traefik to handle Let's Encrypt certificates (HTTPS) automatically.
* **Resource Management:** Prompts for CPU and RAM limits to protect your server from OOM (Out of Memory) crashes.
* **Network Stability:** Includes DNS fixes (`8.8.8.8`) to prevent container connection issues on Ubuntu/Debian.
* **Port Conflict Cleaning:** Automatically detects and stops interfering services (Apache/Nginx) on Port 80.
* **Persistence:** Data is saved in local folders for easy backup and migration.

## 🛠 Prerequisites

1.  **A VPS** (Ubuntu 20.04+, Debian, or CentOS).
2.  **A Domain Name** managed via Cloudflare (recommended).
3.  **DNS A Record** pointing to your server's IP.

## ⚡ Quick Start

### 1. Download & Prepare
SSH into your server and create the file:

```bash
nano install_n8n.sh
2. Copy the Script
Copy the code from install_n8n_official.sh in this repository and paste it into the file. Save with Ctrl+X, Y, Enter.

3. Run
Make it executable and launch:

Bash

chmod +x install_n8n.sh
./install_n8n.sh
⚙️ Configuration Prompts
The script will interactively ask for the following:

Prompt	Description	Example
Main Domain	Your root domain name	lanreenlight.com
Subdomain	The prefix for n8n	n8n
Email	Email for SSL expiry notifications	admin@example.com
CPU Limit	Max CPU usage (default: 1.0)	1.0
RAM Limit	Max Memory usage (default: 1G)	1G

🌐 Cloudflare Configuration (Important)
To avoid "Too Many Redirects" or "522" errors, ensure your Cloudflare settings are correct:

DNS: Set the Proxy status (Orange Cloud) to Grey (DNS Only) during installation. You can switch it to Orange (Proxied) after the SSL certificate is generated.

SSL/TLS: Set encryption mode to Full (Strict).

📂 Directory Structure
The installation creates the following structure at ~/n8n-compose:

~/n8n-compose/
├── .env                # Stores your domain and timezone vars
├── compose.yaml        # The Docker Compose configuration
├── local-files/        # Volume for n8n file storage
├── n8n_data/           # (Docker Volume) n8n database & flows
└── traefik_data/       # (Docker Volume) SSL certificates
🚨 Troubleshooting
"Port 80 is in use" The script attempts to stop Nginx/Apache automatically. If it fails, run:

Bash

systemctl stop nginx apache2
"Connection Refused" / SSL Generation Failed Ensure your firewall allows traffic on ports 80 and 443:

Bash

ufw allow 80/tcp
ufw allow 443/tcp
ufw reload

Maintained by: Lanre (Lanreenlight) Speed. Precision. Profitability.
