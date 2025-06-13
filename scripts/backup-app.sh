#!/bin/bash
# Backup WordPress Application

APP_NAME="$1"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [ -z "$APP_NAME" ]; then
    print_error "Usage: $0 <app-name>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$SCRIPT_DIR/../apps"
APP_DIR="$APPS_DIR/$APP_NAME"

if [ ! -d "$APP_DIR" ]; then
    print_error "App '$APP_NAME' not found!"
    exit 1
fi

print_status "Creating backup for $APP_NAME..."

cd "$APP_DIR"

# Create backup directory
mkdir -p backups

# Create database backup
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
DB_BACKUP="backups/${APP_NAME}_db_${BACKUP_DATE}.sql"
FILES_BACKUP="backups/${APP_NAME}_files_${BACKUP_DATE}.tar.gz"

# Get database credentials from .env
DB_ROOT_PASSWORD=$(grep MYSQL_ROOT_PASSWORD .env | cut -d'=' -f2)
DB_NAME=$(grep MYSQL_DATABASE .env | cut -d'=' -f2)

# Database backup
if docker compose exec -T database mysqldump -u root -p$DB_ROOT_PASSWORD $DB_NAME > "$DB_BACKUP" 2>/dev/null; then
    print_success "Database backup created: $DB_BACKUP"
else
    print_error "Database backup failed!"
fi

# Files backup
if tar -czf "$FILES_BACKUP" wp-content/ 2>/dev/null; then
    print_success "Files backup created: $FILES_BACKUP"
else
    print_error "Files backup failed!"
fi

print_success "Backup completed for $APP_NAME"