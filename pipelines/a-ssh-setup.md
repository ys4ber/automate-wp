# SSH Setup Instructions for a

## Server Setup

1. **Create deploy user on server:**
   ```bash
   sudo adduser deployuser
   sudo usermod -aG docker deployuser
   sudo mkdir -p /home/deployuser/a
   sudo chown deployuser:deployuser /home/deployuser/a
   ```

2. **Generate SSH key pair:**
   ```bash
   ssh-keygen -t rsa -b 4096 -f a_deploy_key
   ```

3. **Add public key to server:**
   ```bash
   ssh-copy-id -i a_deploy_key.pub deployuser@192.99.35.79
   ```

## Azure DevOps Setup

1. **Create SSH Service Connection:**
   - Name: `SSH-wordpress`
   - Host: `192.99.35.79`
   - Username: `deployuser`
   - Private Key: Contents of `a_deploy_key` file

2. **Test Connection:**
   ```bash
   ssh -i a_deploy_key deployuser@192.99.35.79 "echo 'Connection successful for a'"
   ```

## Deployment Path
- Application files will be deployed to: `/home/deployuser/a/`
- Make sure this directory exists and has proper permissions.

