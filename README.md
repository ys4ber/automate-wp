# 🚀 WordPress Multi-Application Manager

A comprehensive solution for managing multiple WordPress applications with Docker, featuring automated deployment, backup/restore, and CI/CD pipeline support.

## 📁 Project Structure

```
wordpress-deployment-manager/
├── apps/                    # Individual WordPress applications
├── templates/               # Template files for new apps
├── scripts/                 # Management scripts
│   └── shared/             # Shared utility scripts
├── pipelines/              # CI/CD pipeline files
├── config/                 # Configuration files
│   └── app-configs/        # App-specific configurations
├── Makefile                # Main management interface
└── README.md
```

## 🚀 Quick Start

### 1. Setup
```bash
# Run the setup script to create directory structure
./setup-structure.sh

# Make scripts executable
chmod +x scripts/*.sh scripts/shared/*.sh
```

### 2. Create Your First WordPress App
```bash
# Create an e-commerce site on port 4000
make create-app NAME=ecommerce PORT=4000

# Create a blog site on port 4010
make create-app NAME=blog PORT=4010

# Create a corporate site on port 4020
make create-app NAME=corporate PORT=4020
```

### 3. Start and Setup WordPress
```bash
# Start a specific app
make start-app NAME=ecommerce

# Or start all apps
make start-all

# Setup WordPress (run this after starting)
cd apps/ecommerce
make setup
```

## 🛠️ Management Commands

### App Management
```bash
make list-apps              # List all WordPress applications
make create-app NAME=myapp PORT=4000  # Create new app
make start-app NAME=myapp   # Start specific app
make stop-app NAME=myapp    # Stop specific app
make start-all              # Start all apps
make stop-all               # Stop all apps
make status-all             # Show status of all apps
```

### Backup & Restore
```bash
make backup-app NAME=myapp  # Backup specific app
./scripts/restore-app.sh myapp backup.sql  # Restore from backup
```

### Deployment
```bash
make deploy-app NAME=myapp  # Deploy specific app
```

## 🌐 Port Allocation

Each WordPress application uses 3 consecutive ports:
- **4000-4002**: App 1 (nginx, phpMyAdmin, database)
- **4010-4012**: App 2 (nginx, phpMyAdmin, database)
- **4020-4022**: App 3 (nginx, phpMyAdmin, database)

## 🔑 Default Credentials

Each app gets randomly generated passwords during creation. Check the app's README.md for specific credentials.

## 📱 Application Structure

Each WordPress application includes:
- `docker-compose.yml` - Docker services configuration
- `.env` - Environment variables with auto-generated passwords
- `nginx.conf` - Nginx web server configuration
- `plugins.txt` - WordPress plugins to install
- `wp-content/` - WordPress content directory
- `backups/` - Database and file backups
- `Makefile` - App-specific management commands
- `README.md` - App-specific documentation

## 🔄 CI/CD Integration

Each app can have its own Azure DevOps pipeline:
- Pipeline templates are automatically created
- Supports SSH deployment
- Includes validation steps

## 🏗️ Creating Custom Apps

1. **Using Templates**: All apps are created from templates in the `templates/` directory
2. **Customization**: Modify templates to fit your specific needs
3. **Automation**: The creation process handles all placeholder replacements automatically

## 🔧 Per-App Commands

Once inside an app directory (`cd apps/myapp`):
```bash
make start       # Start this app
make stop        # Stop this app
make setup       # Setup WordPress
make logs        # View logs
make shell       # Access WordPress container
make wp-shell    # Access WP-CLI
make db-shell    # Access database
make backup      # Create backup
make status      # Show container status
```

## 🎯 Use Cases

- **Development**: Run multiple WordPress sites locally
- **Staging**: Test different configurations simultaneously  
- **Production**: Deploy multiple client sites with isolation
- **Testing**: Quickly spin up WordPress instances for testing

## 🔒 Security Features

- Isolated Docker networks per application
- Random password generation
- Nginx security headers
- PHP upload limits configuration
- Database SSL disabled for compatibility

## 📊 Monitoring

- Container status monitoring
- Log aggregation per application
- Health check capabilities
- Resource usage tracking

## 🆘 Troubleshooting

### Common Issues
1. **Port conflicts**: Ensure ports are not already in use
2. **Permission issues**: Run `chmod +x` on all scripts
3. **Docker issues**: Ensure Docker and Docker Compose are installed

### Getting Help
```bash
make help           # Show all available commands
./scripts/manage-app.sh  # Show script usage
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Test your changes with multiple apps
4. Submit a pull request

## 📝 License

This project is open source. Feel free to use and modify as needed.


---

the port thst is opened in the server:


4000, 4001, 4002, 4011, 4012 , 4021 , 4022

---

**Happy WordPress Management! 🎉**