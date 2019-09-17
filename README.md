# docker-based mailcow installation with integrated mailman3 list-management

**This project is a work in *progress*! Bugs are expected to happen while running it. Not all commits are thoroughly tested, please take backups before using.**

This project is based on [mailcow-dockerized](https://github.com/mailcow/mailcow-dockerized) and [docker-mailman](https://github.com/maxking/docker-mailman).

For more information and help on specific parts, please consult the corresponding documentation of **mailcow-dockerized** or **docker-mailman**.

Please do **NOT** post issues over there, since I don't want to spam those project with issues resulting out of this setup. You're free to post issues here.

# Prerequisites
You need **docker**, **docker-compose** and a **proxy-capable** web server (e.g. apache2 or nginx).

# Installation
To create the configuration and create/copy the initial files, just run **generate_config.sh**.

Afterwards you need to run some additional commands:
1.  Pull all images

```bash
docker-compose pull
```

2.  Start all containers

```bash
docker-compose up -d
```

3. Check `mailman-web` logs to make sure the database is initialized and all migrations ran (you need to wait some time)

```bash
docker-compose logs -f mailman-web
```

4.  Create mailman admin user (you need to **manually** create this mail address in the mailcowUI); replace `<project-name>` with your project name (commonly `mailcowdockerized`).

```bash
docker exec -it <project-name>_mailman-web_1 python3 manage.py createsuperuser
```

## Migrating from mailcow-dockerized
**I am not responsible for any damaged data, apocalyptic scenarios or marauding employees.**

To migrate your existing mailcow-dockerized installation to mailcow-mailman3-dockerized, you need to do the following steps:

0.  Create a backup of your current mailcow-dockerized setup!
1.  Clone this repository
2.  Generate .env-file by running `generate_config.sh`
3.  Copy the password-strings and other configuration parameter from your existing mailcow-dockerized install to the newly created .env
4.  To use the existing volumes created by mailcow-dockerized, check if `COMPOSE_PROJECT_NAME` is `mailcowdockerized` and change it if needed.
5.  run `docker-compose pull && docker-compose up -d` to pull the additional mailman3 images and start the whole thing up.
6.  Check your data and settings in the mailcow web-interface.

# Additional notes
This setup is built to run behind a web server proxying mailcow and mailman3. Within `templates/apache2` are some configurations you might find useful. They are intended to work with apache2 and certificates by [Let's encrypt](https://letsencrypt.org). You'll also need some additional apache2-modules installed:
```
mod_headers, mod_proxy, mod_proxy_html, mod_wsgi, mod_http2
```

Since a lot of distros do not include mod_http2, you might want to checkout [this](https://launchpad.net/~ondrej/+archive/ubuntu/apache2) PPA or just disable the corresponding entries in the config files.
