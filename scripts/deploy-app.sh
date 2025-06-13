#!/bin/bash
# Deploy WordPress Application

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

print_status "Deploying $APP_NAME..."

cd "$APP_DIR"

# Stop existing containers
print_status "Stopping existing containers..."
docker compose down --remove-orphans

# Pull latest images
print_status "Pulling latest images..."
docker compose pull

# Start containers
print_status "Starting containers..."
docker compose up -d

# Wait for services
print_status "Waiting for services to be ready..."
sleep 15

# Check if WordPress is accessible
WP_URL=$(grep WP_URL .env | cut -d'=' -f2)
if curl -s "$WP_URL" > /dev/null; then
    print_success "Deployment successful! $APP_NAME is accessible at $WP_URL"
else
    print_error "Deployment may have issues. Check logs with: docker compose logs"
fi