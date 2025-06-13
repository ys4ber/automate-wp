#!/bin/bash
# Install WordPress plugins from plugins.txt

install_plugins() {
    local plugins_file="$1"
    
    if [ ! -f "$plugins_file" ]; then
        echo "❌ Plugins file not found: $plugins_file"
        return 1
    fi
    
    echo "🔌 Installing plugins from $plugins_file..."
    
    # Read plugins from file
    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ ! "$line" =~ ^[[:space:]]*# ]] && [[ -n "${line// }" ]]; then
            plugin=$(echo "$line" | xargs)
            if [ -n "$plugin" ]; then
                echo "  Installing: $plugin"
                docker compose run --rm wpcli plugin install "$plugin" --activate || echo "  ❌ Failed to install $plugin"
            fi
        fi
    done < "$plugins_file"
    
    echo "✅ Plugin installation completed"
}