# SSH Setup Instructions for mystore

## Server Setup

1. **Create deploy user on server:**
   ```bash
   sudo adduser liadwordpress
   sudo usermod -aG docker liadwordpress
   sudo mkdir -p /home/liadwordpress/mystore
   sudo chown liadwordpress:liadwordpress /home/liadwordpress/mystore
   ```

2. **Generate SSH key pair:**
   ```bash
   ssh-keygen -t rsa -b 4096 -f mystore_deploy_key
   ```

3. **Add public key to server:**
   ```bash
   ssh-copy-id -i mystore_deploy_key.pub liadwordpress@192.99.35.79
   ```

## Azure DevOps Setup

1. **Create SSH Service Connection:**
   - Name: `SSH-mystore`
   - Host: `192.99.35.79`
   - Username: `liadwordpress`
   - Private Key: Contents of `mystore_deploy_key` file

2. **Test Connection:**
   ```bash
   ssh -i mystore_deploy_key liadwordpress@192.99.35.79 "echo 'Connection successful for mystore'"
   ```

## Deployment Path
- Application files will be deployed to: `/home/liadwordpress/mystore/`
- Make sure this directory exists and has proper permissions.

