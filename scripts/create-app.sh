#!/bin/bash
# Create new WordPress application with automatic pipeline generation

APP_NAME="$1"
PORT_START="$2"
DEPLOY_USER="${3:-deployuser}"  # Optional deploy user parameter

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [ -z "$APP_NAME" ] || [ -z "$PORT_START" ]; then
    print_error "Usage: $0 <app-name> <starting-port> [deploy-user]"
    echo "Example: $0 ecommerce-site 4000 deployuser"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$SCRIPT_DIR/../apps"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
APP_DIR="$APPS_DIR/$APP_NAME"

# Check if app already exists
if [ -d "$APP_DIR" ]; then
    print_error "App '$APP_NAME' already exists!"
    exit 1
fi

print_status "Creating WordPress app: $APP_NAME"

# Create app directory structure
mkdir -p "$APP_DIR"/{wp-content,backups,logs,php-conf}

# Create PHP configuration
cat > "$APP_DIR/php-conf/uploads.ini" << 'EOF'
upload_max_filesize = 2048M
post_max_size = 2048M
memory_limit = 2048M
max_execution_time = 2000
max_input_time = 2000
EOF

# Copy and customize templates
cp "$TEMPLATES_DIR/docker-compose.template.yml" "$APP_DIR/docker-compose.yml"
cp "$TEMPLATES_DIR/.env.template" "$APP_DIR/.env"
cp "$TEMPLATES_DIR/nginx.template.conf" "$APP_DIR/nginx.conf"
cp "$TEMPLATES_DIR/plugins.template.txt" "$APP_DIR/plugins.txt"

# Generate random passwords
DB_ROOT_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-16)
DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-16)
WP_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-16)

# Replace placeholders in docker-compose.yml
sed -i "s/{{APP_NAME}}/$APP_NAME/g" "$APP_DIR/docker-compose.yml"
sed -i "s/{{NGINX_PORT}}/$PORT_START/g" "$APP_DIR/docker-compose.yml"
sed -i "s/{{PHPMYADMIN_PORT}}/$((PORT_START + 1))/g" "$APP_DIR/docker-compose.yml"
sed -i "s/{{DB_PORT}}/$((PORT_START + 20))/g" "$APP_DIR/docker-compose.yml"

# Replace placeholders in .env
sed -i "s/{{APP_NAME}}/$APP_NAME/g" "$APP_DIR/.env"
sed -i "s/{{MYSQL_ROOT_PASSWORD}}/$DB_ROOT_PASSWORD/g" "$APP_DIR/.env"
sed -i "s/{{MYSQL_USER}}/${APP_NAME}_user/g" "$APP_DIR/.env"
sed -i "s/{{MYSQL_PASSWORD}}/$DB_PASSWORD/g" "$APP_DIR/.env"
sed -i "s|{{WP_URL}}|http://192.99.35.79:$PORT_START|g" "$APP_DIR/.env"
sed -i "s/{{WP_TITLE}}/$APP_NAME WordPress Site/g" "$APP_DIR/.env"
sed -i "s/{{WP_ADMIN_USER}}/admin/g" "$APP_DIR/.env"
sed -i "s/{{WP_ADMIN_PASSWORD}}/$WP_PASSWORD/g" "$APP_DIR/.env"
sed -i "s/{{WP_ADMIN_EMAIL}}/admin@$APP_NAME.local/g" "$APP_DIR/.env"

# Replace placeholders in nginx.conf
sed -i "s/{{SERVER_NAME}}/192.99.35.79/g" "$APP_DIR/nginx.conf"

# Create app-specific Makefile
cat > "$APP_DIR/Makefile" << EOF
# Makefile for $APP_NAME
APP_NAME=$APP_NAME

.PHONY: start stop restart logs shell wp-shell db-shell backup setup status

start: ## Start this WordPress app
	docker compose up -d

stop: ## Stop this WordPress app
	docker compose down

restart: ## Restart this WordPress app
	docker compose restart

logs: ## Show logs
	docker compose logs -f

shell: ## Access WordPress container shell
	docker compose exec wordpress bash

wp-shell: ## Access WP-CLI
	docker compose run --rm wpcli bash

db-shell: ## Access database shell
	docker compose exec database mysql -u root -p$DB_ROOT_PASSWORD

backup: ## Create backup
	mkdir -p backups
	docker compose exec -T database mysqldump -u root -p$DB_ROOT_PASSWORD ${APP_NAME}_db > backups/${APP_NAME}_\$(shell date +%Y%m%d_%H%M%S).sql

setup: ## Setup WordPress
	docker compose up -d
	sleep 15
	docker compose run --rm wpcli core download || true
	docker compose run --rm wpcli config create --dbname=${APP_NAME}_db --dbuser=${APP_NAME}_user --dbpass=$DB_PASSWORD --dbhost=database:3306 --force || true
	docker compose run --rm wpcli core install --url=http://192.99.35.79:$PORT_START --title="$APP_NAME WordPress Site" --admin_user=admin --admin_password=$WP_PASSWORD --admin_email=admin@$APP_NAME.local || true

status: ## Show container status
	docker compose ps

help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*\$\$' \$(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", \$\$1, \$\$2}'
EOF

# Create README for the app
cat > "$APP_DIR/README.md" << EOF
# $APP_NAME WordPress Application

## 🚀 Quick Start

\`\`\`bash
# Start the application
make start

# Setup WordPress
make setup

# View logs
make logs
\`\`\`

## 🌐 Access Points

- **Frontend**: http://192.99.35.79:$PORT_START
- **Admin**: http://192.99.35.79:$PORT_START/wp-admin
- **phpMyAdmin**: http://192.99.35.79:$((PORT_START + 1))

## 🔑 Credentials

- **WordPress Admin**: admin / $WP_PASSWORD
- **Database**: ${APP_NAME}_user / $DB_PASSWORD
- **Database Root**: root / $DB_ROOT_PASSWORD

## 🛠️ Management Commands

\`\`\`bash
make start          # Start containers
make stop           # Stop containers  
make restart        # Restart containers
make logs           # View logs
make setup          # Initial WordPress setup
make status         # Show container status
\`\`\`

## 🚀 Deployment

Pipeline file: \`pipelines/${APP_NAME}-pipeline.yml\`
Deploy path: \`/home/${DEPLOY_USER}/${APP_NAME}\`
SSH endpoint: \`SSH-${APP_NAME}\`
EOF

print_success "✅ WordPress app '$APP_NAME' created successfully!"

# Generate pipeline automatically
print_status "🔄 Generating Azure DevOps pipeline..."
if [ -f "$SCRIPT_DIR/create-pipeline.sh" ]; then
    "$SCRIPT_DIR/create-pipeline.sh" "$APP_NAME" "$DEPLOY_USER"
else
    print_error "Pipeline generation script not found: $SCRIPT_DIR/create-pipeline.sh"
    print_status "You can create the pipeline manually later using:"
    echo "  ./scripts/create-pipeline.sh $APP_NAME $DEPLOY_USER"
fi

echo ""
echo "📋 App Details:"
echo "  📁 Location: $APP_DIR"
echo "  🌐 WordPress: http://192.99.35.79:$PORT_START"
echo "  🗄️  phpMyAdmin: http://192.99.35.79:$((PORT_START + 1))"
echo "  🔑 Admin Password: $WP_PASSWORD"
echo "  🚀 Pipeline: pipelines/${APP_NAME}-pipeline.yml"
echo ""
echo "🚀 Next Steps:"
echo "  1. cd apps/$APP_NAME"
echo "  2. make start"
echo "  3. make setup"
echo "  4. Add pipeline to Azure DevOps"
echo ""