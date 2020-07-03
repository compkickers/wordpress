#!/bin/sh
# Demyx
# https://demyx.sh
set -euo pipefail

# Define variables
WORDPRESS_DB_NAME="${WORDPRESS_DB_NAME:-}"
WORDPRESS_DB_USER="${WORDPRESS_DB_USER:-}"
WORDPRESS_DB_PASSWORD="${WORDPRESS_DB_PASSWORD:-}"
WORDPRESS_DB_HOST="${WORDPRESS_DB_HOST:-}"

if [[ ! -d "$WORDPRESS_ROOT"/wp-content ]]; then
    echo "WordPress is missing, installing now."
    cp -r "$WORDPRESS_CONFIG"/wordpress/* "$WORDPRESS_ROOT"

    if [[ "$WORDPRESS_DB_NAME" && "$WORDPRESS_DB_USER" && "$WORDPRESS_DB_PASSWORD" && "$WORDPRESS_DB_HOST" ]]; then
        mv "$WORDPRESS_ROOT"/wp-config-sample.php "$WORDPRESS_ROOT"/wp-config.php
        sed -i "s/database_name_here/$WORDPRESS_DB_NAME/g" "$WORDPRESS_ROOT"/wp-config.php
        sed -i "s/username_here/$WORDPRESS_DB_USER/g" "$WORDPRESS_ROOT"/wp-config.php
        sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/g" "$WORDPRESS_ROOT"/wp-config.php
        sed -i "s/localhost/$WORDPRESS_DB_HOST/g" "$WORDPRESS_ROOT"/wp-config.php 
        SALT="$(wget -qO- https://api.wordpress.org/secret-key/1.1/salt/)"
        printf '%s\n' "g/put your unique phrase here/d" a "$SALT" . w | ed -s "$WORDPRESS_ROOT"/wp-config.php
        sed -i "s/\$table_prefix = 'wp_';/\$table_prefix = 'wp_';\n\n\/\/ If we're behind a proxy server and using HTTPS, we need to alert Wordpress of that fact\n\/\/ see also http:\/\/codex.wordpress.org\/Administration_Over_SSL#Using_a_Reverse_Proxy\nif (isset($\_SERVER['HTTP_X_FORWARDED_PROTO']) \&\& $\_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {\n\t$\_SERVER['HTTPS'] = 'on';\n}\n/g" "$WORDPRESS_ROOT"/wp-config.php
    else
        echo "One or more environment variables are missing! Exiting ... "
        exit 1
    fi
fi
