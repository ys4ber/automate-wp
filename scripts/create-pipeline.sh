#!/bin/bash
# Create Azure DevOps Pipeline for WordPress Application

APP_NAME="$1"
DEPLOY_USER="${2:-deployuser}"  # Default deploy user, can be overridden

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

if [ -z "$APP_NAME" ]; then
    print_error "Usage: $0 <app-name> [deploy-user]"
    echo "Example: $0 mystore deployuser"
    echo ""
    echo "Arguments:"
    echo "  app-name     - Name of the WordPress application"
    echo "  deploy-user  - Username for deployment (default: deployuser)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPS_DIR="$SCRIPT_DIR/../apps"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"
PIPELINES_DIR="$SCRIPT_DIR/../pipelines"
APP_DIR="$APPS_DIR/$APP_NAME"

# Check if app exists
if [ ! -d "$APP_DIR" ]; then
    print_error "App '$APP_NAME' not found!"
    echo "Available apps:"
    if [ -d "$APPS_DIR" ]; then
        for app in "$APPS_DIR"/*; do
            if [ -d "$app" ]; then
                echo "  📱 $(basename "$app")"
            fi
        done
    fi
    exit 1
fi

# Check if pipeline template exists
if [ ! -f "$TEMPLATES_DIR/pipeline.template.yml" ]; then
    print_error "Pipeline template not found: $TEMPLATES_DIR/pipeline.template.yml"
    exit 1
fi

print_status "Creating Azure DevOps pipeline for: $APP_NAME"

# Create pipelines directory if it doesn't exist
mkdir -p "$PIPELINES_DIR"

# Get app configuration from .env file
if [ -f "$APP_DIR/.env" ]; then
    WP_URL=$(grep "WP_URL=" "$APP_DIR/.env" | cut -d'=' -f2)
    WP_TITLE=$(grep "WP_TITLE=" "$APP_DIR/.env" | cut -d'=' -f2 | sed 's/ WordPress Site//')
else
    print_warning ".env file not found, using default values"
    WP_URL="http://192.99.35.79:4000"
    WP_TITLE="$APP_NAME"
fi

# Define pipeline file path
PIPELINE_FILE="$PIPELINES_DIR/${APP_NAME}-pipeline.yml"

print_status "Generating pipeline file..."

# Copy template and replace placeholders
cp "$TEMPLATES_DIR/pipeline.template.yml" "$PIPELINE_FILE"

# Replace all placeholders
sed -i "s/{{APP_NAME}}/$APP_NAME/g" "$PIPELINE_FILE"
sed -i "s/{{DEPLOY_USER}}/$DEPLOY_USER/g" "$PIPELINE_FILE"
sed -i "s|{{WP_URL}}|$WP_URL|g" "$PIPELINE_FILE"

# Add current date for reference
sed -i "1i# Generated on: $(date)" "$PIPELINE_FILE"
sed -i "2i# App: $APP_NAME" "$PIPELINE_FILE"
sed -i "3i# Deploy User: $DEPLOY_USER" "$PIPELINE_FILE"
sed -i "4i" "$PIPELINE_FILE"

print_success "✅ Pipeline file created: $PIPELINE_FILE"

# Display pipeline summary
echo ""
echo "📋 Pipeline Configuration Summary:"
echo "=================================="
echo "📱 Application: $APP_NAME"
echo "📁 Pipeline File: pipelines/${APP_NAME}-pipeline.yml"
echo "🔗 SSH Endpoint: SSH-${APP_NAME}"
echo "📂 Deploy Path: /home/${DEPLOY_USER}/${APP_NAME}"
echo "🌐 Test URL: $WP_URL"
echo "👤 Deploy User: $DEPLOY_USER"
echo ""

# Show trigger paths
echo "🎯 Pipeline Triggers:"
echo "  - Changes in: apps/${APP_NAME}/*"
echo "  - Branch: master, development"
echo ""

# Display next steps
echo "🚀 Next Steps to Complete Setup:"
echo "================================"
echo ""
echo "1️⃣  Add Pipeline to Azure DevOps:"
echo "   - Go to Azure DevOps → Pipelines → New Pipeline"
echo "   - Choose 'Existing Azure Pipelines YAML file'"
echo "   - Select: /pipelines/${APP_NAME}-pipeline.yml"
echo ""
echo "2️⃣  Create SSH Service Connection:"
echo "   - Go to Project Settings → Service Connections"
echo "   - Create new SSH connection named: SSH-${APP_NAME}"
echo "   - Host: 192.99.35.79 (or your server IP)"
echo "   - Username: ${DEPLOY_USER}"
echo "   - Add your SSH private key"
echo ""
echo "3️⃣  Create Variable Group (Optional):"
echo "   - Go to Pipelines → Library → Variable Groups"  
echo "   - Create group: Secret-Variables-${APP_NAME}"
echo "   - Add any secret variables needed"
echo ""
echo "4️⃣  Test the Pipeline:"
echo "   - Make a small change in apps/${APP_NAME}/"
echo "   - Commit and push to trigger deployment"
echo "   - Check deployment at: $WP_URL"
echo ""

# Offer to show the pipeline content
read -p "📖 Would you like to see the generated pipeline content? (y/n): " show_content
if [[ $show_content =~ ^[Yy]$ ]]; then
    echo ""
    echo "📄 Generated Pipeline Content:"
    echo "=============================="
    cat "$PIPELINE_FILE"
    echo ""
fi

# Offer to create SSH setup instructions
read -p "📝 Generate SSH setup instructions? (y/n): " create_ssh_instructions
if [[ $create_ssh_instructions =~ ^[Yy]$ ]]; then
    SSH_INSTRUCTIONS_FILE="$PIPELINES_DIR/${APP_NAME}-ssh-setup.md"
    
    cat > "$SSH_INSTRUCTIONS_FILE" << EOF
# SSH Setup Instructions for ${APP_NAME}

## Server Setup

1. **Create deploy user on server:**
   \`\`\`bash
   sudo adduser ${DEPLOY_USER}
   sudo usermod -aG docker ${DEPLOY_USER}
   sudo mkdir -p /home/${DEPLOY_USER}/${APP_NAME}
   sudo chown ${DEPLOY_USER}:${DEPLOY_USER} /home/${DEPLOY_USER}/${APP_NAME}
   \`\`\`

2. **Generate SSH key pair:**
   \`\`\`bash
   ssh-keygen -t rsa -b 4096 -f ${APP_NAME}_deploy_key
   \`\`\`

3. **Add public key to server:**
   \`\`\`bash
   ssh-copy-id -i ${APP_NAME}_deploy_key.pub ${DEPLOY_USER}@192.99.35.79
   \`\`\`

## Azure DevOps Setup

1. **Create SSH Service Connection:**
   - Name: \`SSH-${APP_NAME}\`
   - Host: \`192.99.35.79\`
   - Username: \`${DEPLOY_USER}\`
   - Private Key: Contents of \`${APP_NAME}_deploy_key\` file

2. **Test Connection:**
   \`\`\`bash
   ssh -i ${APP_NAME}_deploy_key ${DEPLOY_USER}@192.99.35.79 "echo 'Connection successful for ${APP_NAME}'"
   \`\`\`

## Deployment Path
- Application files will be deployed to: \`/home/${DEPLOY_USER}/${APP_NAME}/\`
- Make sure this directory exists and has proper permissions.

EOF

    print_success "✅ SSH setup instructions created: $SSH_INSTRUCTIONS_FILE"
fi

print_success "🎉 Pipeline generation completed successfully!"
print_status "Pipeline ready for Azure DevOps integration."