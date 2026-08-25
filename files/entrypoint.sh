#!/bin/sh

. /lib.subr

set -eu

DEBUG=${DEBUG:-}
if [ "$DEBUG" = 'true' ]; then
    set -x
fi
UPLOAD_MAX_SIZE=${UPLOAD_MAX_SIZE:-25M}
MEMORY_LIMIT=${MEMORY_LIMIT:-128M}
SECURE_COOKIES=${SECURE_COOKIES:-true}

# Set attachment size limit
gsed -i "s/<UPLOAD_MAX_SIZE>/$UPLOAD_MAX_SIZE/g" /usr/local/etc/php-fpm.d/php-fpm.conf /usr/local/etc/nginx/nginx.conf
gsed -i "s/<MEMORY_LIMIT>/$MEMORY_LIMIT/g" /usr/local/etc/php-fpm.d/php-fpm.conf

# Secure cookies
if [ "${SECURE_COOKIES}" = 'true' ]; then
    echo "[INFO] Secure cookies activated"
        {
        	echo 'session.cookie_httponly = On';
        	echo 'session.cookie_secure = On';
        	echo 'session.use_only_cookies = On';
        } > /usr/local/etc/php/cookies.ini;
fi

echo "[INFO] Snappymail version: $( ls /usr/local/www/snappymail/snappymail/v )"

# Set permissions on snappymail data
echo "[INFO] Setting permissions on /data"
chown -R www:www /data
chmod 550 /data
find /data -type d -exec chmod 750 {} \;

# Create snappymail default config if absent
SNAPPYMAIL_CONFIG_FILE=/data/_data_/_default_/configs/application.ini
if [ ! -f "$SNAPPYMAIL_CONFIG_FILE" ]; then
    echo "[INFO] Creating default Snappymail configuration: $SNAPPYMAIL_CONFIG_FILE"
    # Run snappymail and exit. This populates the snappymail data directory and generates the config file
    # On error, print php exception and exit
    EXITCODE=
    su-exec www /bin/sh -c 'php /usr/local/www/snappymail/index.php' > /tmp/out || EXITCODE=$?
    if [ -n "$EXITCODE" ]; then
        cat /tmp/out
        exit "$EXITCODE"
    fi
fi

echo "[INFO] Overriding values in snappymail configuration: $SNAPPYMAIL_CONFIG_FILE"
# Enable output of snappymail logs
gsed '/^\; Enable logging/{
N
s/enable = Off/enable = On/
}' -i $SNAPPYMAIL_CONFIG_FILE
# Redirect snappymail logs to stderr /stdout
gsed 's/^filename = .*/filename = "stderr"/' -i $SNAPPYMAIL_CONFIG_FILE
gsed 's/^write_on_error_only = .*/write_on_error_only = Off/' -i $SNAPPYMAIL_CONFIG_FILE
gsed 's/^write_on_php_error_only = .*/write_on_php_error_only = On/' -i $SNAPPYMAIL_CONFIG_FILE
# Always enable snappymail Auth logging
gsed 's/^auth_logging = .*/auth_logging = On/' -i $SNAPPYMAIL_CONFIG_FILE
gsed 's/^auth_logging_filename = .*/auth_logging_filename = "auth.log"/' -i $SNAPPYMAIL_CONFIG_FILE
gsed 's/^auth_logging_format = .*/auth_logging_format = "[{date:Y-m-d H:i:s}] Auth failed: ip={request:ip} user={imap:login} host={imap:host} port={imap:port}"/' -i $SNAPPYMAIL_CONFIG_FILE
gsed 's/^auth_syslog = .*/auth_syslog = Off/' -i $SNAPPYMAIL_CONFIG_FILE

(
    default_interface=$(route -n4 get default 2> /dev/null | grep 'interface:' | cut -d' ' -f4-)
    current_ipv4=$(ifconfig -- "${default_interface}" inet | \
        grep -m 1 -o 'inet.*' | cut -d ' ' -f 2)
    current_ipv4="${current_ipv4:-127.0.0.1}"

    until nc -vz -w 1 127.0.0.1 8888 > /dev/null 2>&1; do echo "[INFO] Checking whether nginx is alive"; sleep 1 || exit $?; done
    until test -S /var/run/php-fpm.sock; do echo "[INFO] Checking whether php-fpm is alive"; sleep 1 || exit $?; done
    # Create snappymail admin password if absent
    SNAPPYMAIL_ADMIN_PASSWORD_FILE=/data/_data_/_default_/admin_password.txt
    if [ ! -f "$SNAPPYMAIL_ADMIN_PASSWORD_FILE" ]; then
        echo "[INFO] Creating Snappymail admin password file: $SNAPPYMAIL_ADMIN_PASSWORD_FILE"
        fetch -qo - 'http://127.0.0.1:8888/?/AdminAppData/0/12345/' > /dev/null
        echo "[INFO] Snappymail Admin Panel ready at http://${current_ipv4}:8888/?admin. Login using password in $SNAPPYMAIL_ADMIN_PASSWORD_FILE"
    fi

    fetch -qo - 'http://127.0.0.1:8888/' > /dev/null
    echo "[INFO] Snappymail ready at http://${current_ipv4}:8888/"
) &

# RUN !
exec /usr/local/bin/supervisord -c /supervisor.conf --pidfile /var/run/supervisor/supervisord.pid
