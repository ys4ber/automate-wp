# SSH Setup Instructions for c

## Server Setup

1. **Create deploy user on server:**
   ```bash
   sudo adduser deployuser
   sudo usermod -aG docker deployuser
   sudo mkdir -p /home/deployuser/c
   sudo chown deployuser:deployuser /home/deployuser/c
   ```

2. **Generate SSH key pair:**
   ```bash
   ssh-keygen -t rsa -b 4096 -f c_deploy_key
   ```

3. **Add public key to server:**
   ```bash
   ssh-copy-id -i c_deploy_key.pub deployuser@192.99.35.79
   ```

## Azure DevOps Setup

1. **Create SSH Service Connection:**
   - Name: `SSH-c`
   - Host: `192.99.35.79`
   - Username: `deployuser`
   - Private Key: Contents of `c_deploy_key` file

2. **Test Connection:**
   ```bash
   ssh -i c_deploy_key deployuser@192.99.35.79 "echo 'Connection successful for c'"
   ```

## Deployment Path
- Application files will be deployed to: `/home/deployuser/c/`
- Make sure this directory exists and has proper permissions.

