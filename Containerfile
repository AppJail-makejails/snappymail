ARG FREEBSD_RELEASE
ARG PHPVER

FROM ghcr.io/appjail-makejails/php:${FREEBSD_RELEASE}-${PHPVER}

ARG PHPVER
ARG PYVER
ARG NO_PKGCLEAN

LABEL org.opencontainers.image.title="SnappyMail" \
    org.opencontainers.image.description="Simple, modern, lightweight & fast web-based email client" \
    org.opencontainers.image.source="https://github.com/AppJail-makejails/snappymail" \
    org.opencontainers.image.url="https://github.com/AppJail-makejails/snappymail" \
    org.opencontainers.image.vendor="DtxdF" \
    org.opencontainers.image.authors="Jesús Daniel Colmenares Oviedo <dtxdf@disroot.org>"

RUN set -xe; \
    \
    umask 0022; \
    \
    pkg update; \
    pkg install -y snappymail-php${PHPVER} nginx py${PYVER}-supervisor gsed; \
    \
    if [ -z "${NO_PKGCLEAN}" ]; then \
        pkg clean -a; \
        rm -rf /var/cache/pkg/*; \
    fi; \
    rm -rf /var/db/pkg/repos/*

RUN mv -v /usr/local/www/snappymail/data /data;
# Setup configs
COPY --chown=root:wheel files /
RUN set -eux; \
    chown www:www /usr/local/www/snappymail/include.php; \
    chmod 440 /usr/local/www/snappymail/include.php; \
    chmod +x /entrypoint.sh; \
    # Disable the built-in php-fpm configs, since we're using our own config
    mv -v /usr/local/etc/php-fpm.d/appjail.conf /usr/local/etc/php-fpm.d/appjail.conf.disabled; \
    mv -v /usr/local/etc/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf.disabled; \
    mv -v /usr/local/etc/php-fpm.d/zz-appjail.conf /usr/local/etc/php-fpm.d/zz-appjail.conf.disabled;

USER root
WORKDIR /usr/local/www/snappymail
VOLUME /data

EXPOSE 8888
EXPOSE 9000
ENTRYPOINT []
CMD ["/entrypoint.sh"]
