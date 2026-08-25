# SnappyMail

SnappyMail is a simple, modern and fast web-based email client, fork of Rainloop that aims to apply hardening, modernization and a more lightweight experience.

github.com/the-djmaze/snappymail

<img src="https://github.com/the-djmaze/snappymail/blob/master/snappymail/v/0.0.0/static/logo-512.png?raw=true" width="30%" height="auto" alt="SnappyMail logo">

## How to use this Makejail

```console
$ mkdir -p /var/appjail-volumes/snappymail/data
$ appjail oci run -Pd \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    -o template=template.conf \ # optional, see below
    -o fstab="/var/appjail-volumes/snappymail/data /data" \
    ghcr.io/appjail-makejails/snappymail snappymail
```

**template.conf**:

```
exec.start: "/bin/sh /etc/rc"
exec.stop: "/bin/sh /etc/rc.shutdown jail"
mount.devfs
persist
# Optional, but recommended to suppress “gpg: Warning: using insecure memory!”,
# a warning you should suppress to prevent memory that should not be swapped
# from memory.
allow.mlock
```

### Arguments (stage: build)

* `snappymail_from` (default: `ghcr.io/appjail-makejails/snappymail`): Location of OCI image. See also [OCI Configuration](#oci-configuration).
* `snappymail_tag` (default: `latest`): OCI image tag. See also [OCI Configuration](#oci-configuration).


### Volumes

| Name | Owner | Group | Perm | Type | Mountpoint |
| --- | --- | --- | --- | --- | --- |
| appjail-263aca83a3-data | `${PUID}` | `${PGID}` | - | - | /data |

## OCI Configuration

```yaml
build:
  variants:
    - tag: 15.1
      containerfile: Containerfile
      aliases: ["latest"]
      default: true
      args:
        FREEBSD_RELEASE: "15.1"
        APACHEVER: "24"
        PHPVER: "84"
        PYVER: "312"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
```

## Notes

1. The ideas present in the Docker image of SnappyMail are taken into account for users who are familiar with it.
