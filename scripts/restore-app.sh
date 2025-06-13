#!/bin/bash
# Restore WordPress Application

APP_NAME="$1"
BACKUP_FILE="$2"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [ -z "$APP_NAME" ] || [ -z "$BACKUP_FILE" ]; then
    print_error "Usage: $0 <app-name> <backup-file>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$SCRIPT_DIR/../apps"
APP_DIR="$APPS_DIR/$APP_NAME"

if [ ! -d "$APP_DIR" ]; then
    print_error "App '$APP_NAME' not found!"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    print_error "Backup file '$BACKUP_FILE' not found!"
    exit 1
fi

print_status "Restoring $APP_NAME from $BACKUP_FILE..."

cd "$APP_DIR"

# Get database credentials from .env
DB_ROOT_PASSWORD=$(grep MYSQL_ROOT_PASSWORD .env | cut -d'=' -f2)
DB_NAME=$(grep MYSQL_DATABASE .env | cut -d'=' -f2)

# Restore database
if [[ "$BACKUP_FILE" == *.sql ]]; then
    print_status "Restoring database..."
    docker compose exec -T database mysql -u root -p$DB_ROOT_PASSWORD $DB_NAME < "$BACKUP_FILE"
    print_success "Database restored successfully!"
elif [[ "$BACKUP_FILE" == *.tar.gz ]]; then
    print_status "Restoring files..."
    tar -xzf "$BACKUP_FILE"
    print_success "Files restored successfully!"
else
    print_error "Unknown backup file format. Use .sql for database or .tar.gz for files"
    exit 1
fi

print_success "Restore completed for $APP_NAME"