# docker-based mailcow installation with integrated mailman3 list-management

This project is based on [mailcow-dockerized](https://github.com/mailcow/mailcow-dockerized) and [docker-mailman](https://github.com/maxking/docker-mailman).

For more information and help on specific parts, please consult the correspoding documentation of **mailcow-dockerized** or **docker-mailman**.

Please do **NOT** post issues over there, since I don't want to spam those project with issues resulting out of this setup. You're free to post issues here.

# Prerequisites
You need **docker**, **docker-compose** and a **proxy-capable** webserver (e.g. apache2 or nginx).


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

3.  Create mailman admin (you need to **manually** create this mail address in the mailcowUI)

```bash
docker exec -it mailman-web python manage.py createsuperuser
```

# Additional notes
This setup is built to run behind a webserver proxying mailcow and mailman3. Within `templates/apache2` are some configurations you might find useful. They are intended to work with apache2 and certificates by [Let's encrypt](https://letsencrypt.org). You'll also need some additional apache2-modules installed:
```
mod_headers, mod_proxy, mod_proxy_html, mod_wsgi, mod_http2
```

Since a lot of distros do not include mod_http2, you might want to checkout [this](https://launchpad.net/~ondrej/+archive/ubuntu/apache2) PPA or just disable the corresponding entry.