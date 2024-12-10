# SnappyMail

SnappyMail is a simple, modern and fast web-based email client, fork of Rainloop that aims to apply hardening, modernization and a more lightweight experience.

## How to use this Makejail

```sh
appjail makejail \
    -j snappymail \
    -f gh+AppJail-makejails/snappymail \
    -o virtualnet=":<random> default" \
    -o nat \
    -o expose=80
```

### Arguments

* `snappymail_tag` (default: `13.4`): see [#tags](#tags).
* `snappymail_worker_processes` (default: `auto`): see [worker\_processes](https://nginx.org/en/docs/ngx_core_module.html#worker_processes).
* `snappymail_worker_connections` (default: `1024`): see [worker\_connections](https://nginx.org/en/docs/ngx_core_module.html#worker_connections).
* `snappymail_upload_max_size` (default: `25M`): Attachment size limit.
* `snappymail_memory_limit` (default: `128M`): PHP memory limit.
* `snappymail_secure_cookies` (default: `1`): see [session.cookie_httponly](https://www.php.net/manual/en/session.configuration.php#ini.session.cookie-httponly), [session.cookie_secure](https://www.php.net/manual/en/session.configuration.php#ini.session.cookie-secure) and [session.use_only_cookies](https://www.php.net/manual/en/session.configuration.php#ini.session.use-only-cookies).

### Volumes

| Name            | Owner | Group | Perm | Type | Mountpoint                     |
| --------------- | ----- | ----- | ---- | ---- | ------------------------------ |
| snappymail-data |  80   |  80   | 700  |  -   | /usr/local/www/snappymail/data |
| snappymail-log  |  80   |  80   |  -   |  -   | /var/log/snappymail            |

## Tags

| Tag      | Arch    | Version        | Type   |
| -------- | ------- | -------------- | ------ |
| `13.4`   | `amd64` | `13.4-RELEASE` | `thin` |
| `13.4`   | `amd64` | `13.4-RELEASE` | `thin` |
| `14.2`   | `amd64` | `14.2-RELEASE` | `thin` |
