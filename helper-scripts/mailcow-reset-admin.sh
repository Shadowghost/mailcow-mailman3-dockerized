#!/bin/bash
[[ -f .env ]] && source .env
[[ -f ../.env ]] && source ../.env

if [[ -z ${MCDBUSER} ]] || [[ -z ${MCDBPASS} ]] || [[ -z ${MCDBNAME} ]]; then
	echo "Cannot find .env, make sure this script is run from within the correct folder."
	exit 1
fi

echo -n "Checking MySQL service... "
if [[ -z $(docker ps -qf name=mysql-mailcow) ]]; then
	echo "failed"
	echo "MySQL (mysql-mailcow) is not up and running, exiting..."
	exit 1
fi

echo "OK"
read -r -p "Are you sure you want to reset the mailcow administrator account? [y/N] " response
response=${response,,}    # tolower
if [[ "$response" =~ ^(yes|y)$ ]]; then
	echo -e "\nWorking, please wait..."
	docker exec -it $(docker ps -qf name=mysql-mailcow) mysql -u${MCDBUSER} -p${MCDBPASS} ${MCDBNAME} -e "DELETE FROM admin;"
	docker exec -it $(docker ps -qf name=mysql-mailcow) mysql -u${MCDBUSER} -p${MCDBPASS} ${MCDBNAME} -e "INSERT INTO admin (username, password, superadmin, created, modified, active) VALUES ('admin', '{SSHA256}K8eVJ6YsZbQCfuJvSUbaQRLr0HPLz5rC9IAp0PAFl0tmNMCDBkMDc0NDAyOTAxN2Rk', 1, NOW(), NOW(), 1);"
	docker exec -it $(docker ps -qf name=mysql-mailcow) mysql -u${MCDBUSER} -p${MCDBPASS} ${MCDBNAME} -e "DELETE FROM domain_admins WHERE username='admin';"
	docker exec -it $(docker ps -qf name=mysql-mailcow) mysql -u${MCDBUSER} -p${MCDBPASS} ${MCDBNAME} -e "INSERT INTO domain_admins (username, domain, created, active) VALUES ('admin', 'ALL', NOW(), 1);"
	docker exec -it $(docker ps -qf name=mysql-mailcow) mysql -u${MCDBUSER} -p${MCDBPASS} ${MCDBNAME} -e "DELETE FROM tfa WHERE username='admin';"
	echo "
Reset credentials:
---
Username: admin
Password: moohoo
TFA: none
"
else
	echo "Operation canceled."
fi
