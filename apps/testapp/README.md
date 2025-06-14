# testapp WordPress Application

## 🚀 Quick Start

```bash
# Start the application
make start

# Setup WordPress
make setup

# View logs
make logs
```

## 🌐 Access Points

- **Frontend**: http://192.99.35.79:4030
- **Admin**: http://192.99.35.79:4030/wp-admin
- **phpMyAdmin**: http://192.99.35.79:4031

## 🔑 Credentials

- **WordPress Admin**: admin / evFA6r59J1dwEXcC
- **Database**: testapp_user / 2mHYSGPWtHt9HEcj
- **Database Root**: root / W387VAZxq10NWhwd

## 🛠️ Management Commands

```bash
make start          # Start containers
make stop           # Stop containers  
make restart        # Restart containers
make logs           # View logs
make setup          # Initial WordPress setup
make status         # Show container status
```

## 🚀 Deployment

Pipeline file: `pipelines/testapp-pipeline.yml`
Deploy path: `/home/deployuser/testapp`
SSH endpoint: `SSH-testapp`
