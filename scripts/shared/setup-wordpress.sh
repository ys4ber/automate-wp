#!/bin/bash
# Shared WordPress Setup Functions

setup_wordpress() {
    local app_name="$1"
    local wp_url="$2"
    local admin_user="$3"
    local admin_password="$4"
    local admin_email="$5"
    
    echo "🔧 Setting up WordPress for $app_name..."
    
    # Download WordPress core
    docker compose run --rm wpcli core download || true
    
    # Create wp-config.php
    docker compose run --rm wpcli config create \
        --dbname="${app_name}_db" \
        --dbuser="${app_name}_user" \
        --dbpass="$(grep MYSQL_PASSWORD .env | cut -d'=' -f2)" \
        --dbhost=database:3306 \
        --extra-php \
        --force <<< 'define("MYSQL_SSL_DISABLED", true);'
    
    # Install WordPress
    docker compose run --rm wpcli core install \
        --url="$wp_url" \
        --title="$app_name WordPress Site" \
        --admin_user="$admin_user" \
        --admin_password="$admin_password" \
        --admin_email="$admin_email"
    
    # Set permalinks
    docker compose run --rm wpcli rewrite structure '/%postname%/'
    docker compose run --rm wpcli rewrite flush
    
    echo "✅ WordPress setup completed for $app_name"
}

fix_permissions() {
    echo "📁 Fixing WordPress permissions..."
    docker compose exec wordpress chown -R www-data:www-data /var/www/html
    docker compose exec wordpress chmod -R 755 /var/www/html
    echo "✅ Permissions fixed"
}