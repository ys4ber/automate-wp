#!/bin/bash
# WordPress Application Manager
# Usage: ./manage-app.sh [create|start|stop|deploy|backup|restore] [app-name]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$SCRIPT_DIR/../apps"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
CONFIG_DIR="$SCRIPT_DIR/../config"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

case "$1" in
    create)
        if [ -z "$2" ] || [ -z "$3" ]; then
            print_error "Usage: $0 create <app-name> <starting-port>"
            exit 1
        fi
        ./create-app.sh "$2" "$3"
        ;;
    start)
        if [ -z "$2" ]; then
            print_error "Usage: $0 start <app-name>"
            exit 1
        fi
        if [ -d "$APPS_DIR/$2" ]; then
            print_status "Starting $2..."
            cd "$APPS_DIR/$2" && docker compose up -d
            print_success "$2 started successfully!"
        else
            print_error "App $2 not found!"
        fi
        ;;
    stop)
        if [ -z "$2" ]; then
            print_error "Usage: $0 stop <app-name>"
            exit 1
        fi
        if [ -d "$APPS_DIR/$2" ]; then
            print_status "Stopping $2..."
            cd "$APPS_DIR/$2" && docker compose down
            print_success "$2 stopped successfully!"
        else
            print_error "App $2 not found!"
        fi
        ;;
    deploy)
        ./deploy-app.sh "$2"
        ;;
    backup)
        ./backup-app.sh "$2"
        ;;
    restore)
        ./restore-app.sh "$2" "$3"
        ;;
    list)
        print_status "Available WordPress applications:"
        if [ -d "$APPS_DIR" ]; then
            for app in "$APPS_DIR"/*; do
                if [ -d "$app" ]; then
                    echo "  📱 $(basename "$app")"
                fi
            done
        else
            print_warning "No apps directory found. Run 'make create-app' first."
        fi
        ;;
    status)
        print_status "WordPress Applications Status:"
        if [ -d "$APPS_DIR" ]; then
            for app in "$APPS_DIR"/*; do
                if [ -d "$app" ]; then
                    echo "=== $(basename "$app") ==="
                    cd "$app" && docker compose ps 2>/dev/null || echo "  Not running"
                    echo ""
                fi
            done
        else
            print_warning "No apps found."
        fi
        ;;
    *)
        echo "Usage: $0 {create|start|stop|deploy|backup|restore|list|status} [app-name] [options]"
        echo ""
        echo "Commands:"
        echo "  create <name> <port>  - Create new WordPress app"
        echo "  start <name>          - Start WordPress app"
        echo "  stop <name>           - Stop WordPress app"
        echo "  deploy <name>         - Deploy WordPress app"
        echo "  backup <name>         - Backup WordPress app"
        echo "  restore <name> <file> - Restore WordPress app"
        echo "  list                  - List all apps"
        echo "  status                - Show status of all apps"
        ;;
esac