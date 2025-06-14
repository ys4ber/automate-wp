# SSH Setup Instructions for b

## Server Setup

1. **Create deploy user on server:**
   ```bash
   sudo adduser deployuser
   sudo usermod -aG docker deployuser
   sudo mkdir -p /home/deployuser/b
   sudo chown deployuser:deployuser /home/deployuser/b
   ```

2. **Generate SSH key pair:**
   ```bash
   ssh-keygen -t rsa -b 4096 -f b_deploy_key
   ```

3. **Add public key to server:**
   ```bash
   ssh-copy-id -i b_deploy_key.pub deployuser@192.99.35.79
   ```

## Azure DevOps Setup

1. **Create SSH Service Connection:**
   - Name: `SSH-b`
   - Host: `192.99.35.79`
   - Username: `deployuser`
   - Private Key: Contents of `b_deploy_key` file

2. **Test Connection:**
   ```bash
   ssh -i b_deploy_key deployuser@192.99.35.79 "echo 'Connection successful for b'"
   ```

## Deployment Path
- Application files will be deployed to: `/home/deployuser/b/`
- Make sure this directory exists and has proper permissions.

