# Jenkins Pipeline Troubleshooting Guide

## Current Issue: .NET SDK Version Mismatch

### Problem
Your Jenkins server has .NET SDK 6.0 installed, but your project requires .NET 8.0.

### Error Message
```
error NETSDK1045: The current .NET SDK does not support targeting .NET 8.0. Either target .NET 6.0 or lower, or use a version of the .NET SDK that supports .NET 8.0.
```

## Quick Fix Options

### Option 1: Install .NET 8.0 SDK on Jenkins Server (Recommended)

1. **SSH into your Jenkins server**
2. **Run the installation script:**
   ```bash
   cd /path/to/your/project/DiaryApp
   chmod +x install-dotnet8.sh
   sudo ./install-dotnet8.sh
   ```

3. **Or install manually:**
   ```bash
   # For Ubuntu/Debian
   wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
   sudo dpkg -i packages-microsoft-prod.deb
   sudo apt-get update
   sudo apt-get install -y dotnet-sdk-8.0
   
   # For CentOS/RHEL/Rocky
   sudo dnf install -y epel-release
   sudo rpm -Uvh https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
   sudo dnf install -y dotnet-sdk-8.0
   ```

4. **Verify installation:**
   ```bash
   dotnet --version
   # Should show 8.x.x
   ```

5. **Restart Jenkins:**
   ```bash
   sudo systemctl restart jenkins
   ```

### Option 2: Downgrade Project to .NET 6.0 (Not Recommended)

If you can't install .NET 8.0, you can temporarily downgrade your project:

1. **Edit `DiaryApp.csproj`:**
   ```xml
   <TargetFramework>net6.0</TargetFramework>
   ```

2. **Update Entity Framework packages to 6.0 versions**
3. **Rebuild and test locally**

## What I Fixed in the Jenkinsfile

1. **Added prerequisite checking** - Pipeline now checks for .NET 8.0 and Docker before proceeding
2. **Added conditional stages** - Build stages only run when prerequisites are met
3. **Added automatic .NET 8.0 installation** - Pipeline can install .NET 8.0 if missing
4. **Fixed Docker network variable** - Added missing `DOCKER_NETWORK` environment variable
5. **Added proper directory navigation** - Pipeline now runs commands from the correct `DiaryApp` directory
6. **Improved error handling** - Better error messages and troubleshooting tips

## Pipeline Stages Now

1. **Checkout** - Gets code from Git
2. **Check Prerequisites** - Verifies .NET and Docker availability
3. **Install .NET 8.0 SDK** - Automatically installs if missing (conditional)
4. **Build & Test** - Builds .NET app (only if .NET 8.0 available)
5. **Build Docker Image** - Creates Docker image (only if Docker available)
6. **Deploy** - Deploys container (only if Docker available)

## Next Steps

1. **Install .NET 8.0 SDK on Jenkins server** using the script above
2. **Commit and push the updated Jenkinsfile** to your repository
3. **Restart the Jenkins pipeline**
4. **Monitor the pipeline logs** - it should now proceed past the build stage

## Verification Commands

After installation, verify on Jenkins server:

```bash
# Check .NET version
dotnet --version

# Check Docker
docker --version

# Check Jenkins user groups
groups jenkins

# Check Jenkins service status
sudo systemctl status jenkins
```

## Common Issues

- **Permission denied**: Run installation script with `sudo`
- **Package not found**: Ensure you're using the correct repository for your OS
- **Jenkins can't access Docker**: Add Jenkins user to docker group and restart service
- **Port conflicts**: Change `HOST_PORT` in Jenkinsfile if 8081 is already in use

## Support

If issues persist:
1. Check Jenkins server logs: `sudo tail -f /var/log/jenkins/jenkins.log`
2. Verify all prerequisites are installed
3. Ensure Jenkins has proper permissions
4. Check network connectivity for package downloads
