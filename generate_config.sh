#!/bin/bash

if [[ -f .env ]]; then
  read -r -p "A config file exists and will be overwritten, are you sure you want to contine? [y/N] " response
  case $response in
    [yY][eE][sS]|[yY])
      mv .env .env_backup
      ;;
    *)
      exit 1
    ;;
  esac
fi

if [ -z "$MAILCOW_HOSTNAME" ]; then
  read -p "Hostname which serves the mailcow UI: " -ei "mail.example.org" MAILCOW_HOSTNAME
fi

if [ -z "$DOMAINNAME" ]; then
  read -p "Domainname which servers mailman3: " -ei "example.org" DOMAINNAME
fi

if [ -z "$HOSTNAME" ]; then
  read -p "Hostname for mailman3 containers (if nothing special, use the mailcow subdomain): " -ei "mail" HOSTNAME
fi

if [[ -a /etc/timezone ]]; then
  TZ=$(cat /etc/timezone)
elif  [[ -a /etc/localtime ]]; then
   TZ=$(readlink /etc/localtime|sed -n 's|^.*zoneinfo/||p')
fi

if [ -z "$TZ" ]; then
  read -p "Timezone: " -ei "Europe/Berlin" TZ
else
  read -p "Timezone: " -ei ${TZ} TZ
fi

cat << EOF > .env
# ------------------------------------
# Main configuration
# ------------------------------------
# example.org is _not_ a valid hostname, use a fqdn here.
# Default admin user is "admin"
# Default password is "moohoo"
MAILCOW_HOSTNAME=${MAILCOW_HOSTNAME}
DOMAINNAME=${DOMAINNAME}
HOSTNAME=${HOSTNAME}

# ------------------------------------
# Mailcow SQL database configuration
# ------------------------------------
MCDBNAME=mailcow
MCDBUSER=mailcow
# Please use long, random alphanumeric strings (A-Za-z0-9)
MCDBPASS=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)
MCDBROOT=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)

# ------------------------------------
# Mailman3 configuration
# ------------------------------------
HKAPIKEY=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)
MMDBPASS=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)
DJSECRET=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)

# ------------------------------------
# HTTP/S Bindings
# ------------------------------------
# You should use HTTPS, but in case of SSL offloaded reverse proxies:
HTTP_PORT=8080
HTTP_BIND=127.0.0.1
HTTPS_PORT=8443
HTTPS_BIND=127.0.0.1

# ------------------------------------
# Other bindings
# ------------------------------------
# You should leave that alone
# Format: 11.22.33.44:25 or 0.0.0.0:465 etc.
# Do _not_ use IP:PORT in HTTP(S)_BIND or HTTP(S)_PORT
SMTP_PORT=25
SMTPS_PORT=465
SUBMISSION_PORT=587
IMAP_PORT=143
IMAPS_PORT=993
POP_PORT=110
POPS_PORT=995
SIEVE_PORT=4190
DOVEADM_PORT=127.0.0.1:19991

# Your timezone
TZ=${TZ}

# Fixed project name
COMPOSE_PROJECT_NAME=mailcow-mailman3-dockerized

# Additional SAN for the certificate
ADDITIONAL_SAN=

# Skip running ACME (acme-mailcow, Let's Encrypt certs) - y/n
SKIP_LETS_ENCRYPT=y

# Skip IPv4 check in ACME container - y/n
SKIP_IP_CHECK=n

# Skip ClamAV (clamd-mailcow) anti-virus (Rspamd will auto-detect a missing ClamAV container) - y/n
SKIP_CLAMD=n

# Enable watchdog (watchdog-mailcow) to restart unhealthy containers (experimental)
USE_WATCHDOG=n

# Send notifications by mail (no DKIM signature, sent from watchdog@MAILCOW_HOSTNAME)
#WATCHDOG_NOTIFY_EMAIL=

# Max log lines per service to keep in Redis logs
LOG_LINES=9999

# ------------------------------------
# Network configuration
# ------------------------------------
# Internal IPv4 /24 subnet, format n.n.n. (expands to n.n.n.0/24)
IPV4_NETWORK=172.19.199

# Internal IPv6 subnet in fd00::/8
IPV6_NETWORK=fd4d:6169:6c63:6f77::/64

# Use this IP for outgoing connections (SNAT)' >> mailcow.conf
#SNAT_TO_SOURCE=" >> .env

# Disable IPv6
# mailcow-network will still be created as IPv6 enabled, all containers will be created
# without IPv6 support.
# Use 1 for disabled, 0 for enabled
SYSCTL_IPV6_DISABLED=0

EOF

echo "Creating needed directories."
mkdir -p ./data/assets/ssl
mkdir -p /opt/mailman/core
mkdir -p /opt/mailman/web

echo "Copying mailman configuration and selfsigned SSL-certificates until new ones are installed."
cp ./templates/mailman/mailman-extra.cfg /opt/mailman/core/mailman-extra.cfg
cp -n ./data/assets/ssl-example/*.pem ./data/assets/ssl/
