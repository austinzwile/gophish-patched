#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
RESET="\033[0m"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "${RED}[*] ${RESET}This script must be run as root. Please use sudo."
  exit 1
fi

# Check if domain name is provided
if [ -z "$1" ]; then
  echo "${RED}[*] ${RESET}Please provide a domain name for certbot to generate the TLS certificates."
  echo "    Usage: $0 domain.com example@google.com"
  exit 1
fi

# Check if email is provided
if [ -z "$2" ]; then
  echo "${RED}[*] ${RESET}Please provide an email for certbot."
  echo "    Usage: $0 domain.com example@google.com"
  exit 2
fi

# Check if the necessary packages are installed
echo "${GREEN}[*] ${RESET}Checking for required packages.\n"
for pkg in certbot golang-go git ufw; do
  if ! command -v $pkg > /dev/null 2>&1; then
    echo "${GREEN}[*] ${RESET}Installing missing package: $pkg"
    sudo apt install $pkg -y
  else
    echo "${GREEN}[*] ${RESET}$pkg is already installed."
  fi
done

# Check if the certificate for the domain already exists
CERT_PATH="/etc/letsencrypt/live/$1/fullchain.pem"
if [ -f "$CERT_PATH" ]; then
  echo "${GREEN}[*] ${RESET}Certificate for $1 already exists. Revoking it..."

  # Revoke the existing certificate
  certbot revoke --cert-path "$CERT_PATH" --non-interactive
  if [ $? -eq 0 ]; then
    echo "${GREEN}[*] ${RESET}Certificate for $1 has been revoked."
  else
    echo "${RED}[*] ${RESET}Failed to revoke the certificate for $1."
    exit 3
  fi

  # Remove the certificate files
  echo "${GREEN}[*] ${RESET}Removing existing certificate files..."
  rm -rf "/etc/letsencrypt/live/$1" "/etc/letsencrypt/archive/$1" "/etc/letsencrypt/renewal/$1.conf"
  echo "${GREEN}[*] ${RESET}Existing certificate files removed."
else
  echo "${GREEN}[*] ${RESET}No existing certificate found for $1."
fi

# Clone the patched Gophish repository
echo "${GREEN}[*] ${RESET}Cloning the patched Gophish repository to /opt/gophish.\n"
git clone https://github.com/austinzwile/gophish-patched /opt/gophish || {
  echo "${RED}[*] ${RESET}Failed to clone Gophish repository."
  exit 4
}

# Build Gophish
echo "${GREEN}[*] ${RESET}Building Gophish.\n"
cd /opt/gophish
go build . || {
  echo "${RED}[*] ${RESET}Gophish build failed."
  exit 5
}

# Request the TLS certificate
echo "${GREEN}[*] ${RESET}Requesting the TLS certificate for $1.\n"
certbot certonly --cert-name "$1" -d "$1" --standalone --email "$2" --agree-tos --non-interactive || {
  echo "${RED}[*] ${RESET}Failed to generate TLS certificate."
  exit 6
}

# Configure Gophish's config.json with the certificates
echo "${GREEN}[*] ${RESET}Configuring Gophish's config.json to use the newly created certificates.\n"
rm -f config.json

mv "/etc/letsencrypt/live/$1/privkey.pem" "/etc/letsencrypt/live/$1/privkey.key"
mv "/etc/letsencrypt/live/$1/fullchain.pem" "/etc/letsencrypt/live/$1/fullchain.crt"

cat <<EOF > config.json
{
	"admin_server": {
		"listen_url": "0.0.0.0:8443",
		"use_tls": true,
		"cert_path": "/etc/letsencrypt/live/$1/fullchain.crt",
		"key_path": "/etc/letsencrypt/live/$1/privkey.key",
		"trusted_origins": []
	},
	"phish_server": {
		"listen_url": "0.0.0.0:443",
		"use_tls": true,
		"cert_path": "/etc/letsencrypt/live/$1/fullchain.crt",
		"key_path": "/etc/letsencrypt/live/$1/privkey.key"
	},
	"db_name": "sqlite3",
	"db_path": "gophish.db",
	"migrations_prefix": "db/db_",
	"contact_address": "",
	"logging": {
		"filename": ".gophish.log",
		"level": ""
	}
}
EOF

# Check if Gophish binary exists
EXEC_PATH="/opt/gophish/gophish"
if [ ! -f "$EXEC_PATH" ]; then
    echo "${RED}[*] ${RESET}Error: Gophish binary not found at $EXEC_PATH.\n"
    exit 7
fi

# Create systemd service file for Gophish
SERVICE_FILE="/etc/systemd/system/gophish.service"
echo "${GREEN}[*] ${RESET}Creating Gophish service file...\n"

cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Gophish Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/gophish
ExecStart=$EXEC_PATH
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon
echo "${GREEN}[*] ${RESET}Reloading systemd daemon.\n"
sudo systemctl daemon-reload

# Enable and start Gophish service
echo "${GREEN}[*] ${RESET}Enabling and starting Gophish service.\n"
sudo systemctl enable gophish
sudo systemctl start gophish

# Check the status of the Gophish service
echo "${GREEN}[*] ${RESET}Checking Gophish service status.\n"
sudo systemctl status gophish --no-pager

# Disable UFW firewall
if command -v ufw > /dev/null 2>&1; then
  echo "${GREEN}[*] ${RESET}Disabling ufw firewall.\n"
  sudo ufw default allow incoming
else
  echo "${RED}[*] ${RESET}ufw not found. Skipping firewall configuration."
fi

# Check Gophish server logs for credentials
CRED_STRING=$(journalctl -u gophish --no-pager | grep "login with the username")

if [[ -z "${CRED_STRING}" ]]; then
	echo "${RED}[*] ${RESET}An error occurred during server startup. Please check the Gophish server's logs."
	exit 8
fi

echo "${GREEN}[*] ${RESET}Gophish server setup complete!!!"
echo "${GREEN}[*] ${RESET}${CRED_STRING}"
echo "${GREEN}[*] ${RESET}Please log in at https://$1:8443/ with the above credentials."

exit 0
