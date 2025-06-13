#!/bin/bash
# Database operations

create_backup() {
    local app_name="$1"
    local backup_dir="$2"
    
    mkdir -p "$backup_dir"
    local backup_file="$backup_dir/${app_name}_$(date +%Y%m%d_%H%M%S).sql"
    
    echo "💾 Creating database backup..."
    docker compose exec -T database mysqldump \
        -u root \
        -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d'=' -f2) \
        $(grep MYSQL_DATABASE .env | cut -d'=' -f2) > "$backup_file"
    
    echo "✅ Backup created: $backup_file"
}

restore_backup() {
    local backup_file="$1"
    
    if [ ! -f "$backup_file" ]; then
        echo "❌ Backup file not found: $backup_file"
        return 1
    fi
    
    echo "🔄 Restoring database from $backup_file..."
    docker compose exec -T database mysql \
        -u root \
        -p$(grep MYSQL_ROOT_PASSWORD .env | cut -d'=' -f2) \
        $(grep MYSQL_DATABASE .env | cut -d'=' -f2) < "$backup_file"
    
    echo "✅ Database restored successfully"
}