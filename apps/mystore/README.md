# mystore WordPress Application

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

- **Frontend**: http://192.99.35.79:4000
- **Admin**: http://192.99.35.79:4000/wp-admin
- **phpMyAdmin**: http://192.99.35.79:4001

## 🔑 Credentials

- **WordPress Admin**: admin / ADUanuJseYMLL3Kj
- **Database**: mystore_user / vuGl9Ku4l3tvnqIb
- **Database Root**: root / Jni6hFS66htc5fVR

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

Pipeline file: `pipelines/mystore-pipeline.yml`
Deploy path: `/home/deployuser/mystore`
SSH endpoint: `SSH-mystore`
