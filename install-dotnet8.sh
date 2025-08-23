#!/bin/bash

# Script to install .NET 8.0 SDK on Jenkins server
# Run this on your Jenkins server as root or with sudo privileges

set -e

echo "🚀 Installing .NET 8.0 SDK on Jenkins server..."

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root or with sudo privileges"
    echo "Usage: sudo ./install-dotnet8.sh"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo "❌ Cannot detect OS version"
    exit 1
fi

echo "📋 Detected OS: $OS $VER"

# Install .NET 8.0 SDK based on OS
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    echo "📦 Installing .NET 8.0 SDK for Ubuntu/Debian..."
    
    # Download Microsoft package repository
    wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    
    # Update and install .NET SDK
    apt-get update
    apt-get install -y dotnet-sdk-8.0
    
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]]; then
    echo "📦 Installing .NET 8.0 SDK for CentOS/RHEL/Rocky..."
    
    # Install EPEL and Microsoft repository
    dnf install -y epel-release
    rpm -Uvh https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
    
    # Install .NET SDK
    dnf install -y dotnet-sdk-8.0
    
else
    echo "❌ Unsupported OS: $OS"
    echo "Please install .NET 8.0 SDK manually for your OS"
    exit 1
fi

# Verify installation
echo "✅ Verifying .NET 8.0 SDK installation..."
dotnet --version

# Add Jenkins user to necessary groups if needed
if id "jenkins" &>/dev/null; then
    echo "👤 Adding Jenkins user to docker group..."
    usermod -aG docker jenkins
    
    echo "🔄 Restarting Jenkins service..."
    systemctl restart jenkins
    
    echo "✅ Jenkins user added to docker group and service restarted"
fi

echo "🎉 .NET 8.0 SDK installation completed!"
echo "📋 Next steps:"
echo "1. Restart your Jenkins pipeline"
echo "2. The pipeline should now detect .NET 8.0 and proceed with build"
echo "3. If Docker issues persist, ensure Docker is installed and Jenkins has access"
