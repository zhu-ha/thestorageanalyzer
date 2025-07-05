#!/bin/bash

echo "🏔️  Installing Power Control Dashboard Dependencies for Arch Linux..."

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    echo "❌ This script is designed for Arch Linux"
    echo "💡 For other distributions, use: pip install flask flask-cors psutil"
    exit 1
fi

# Install Python packages via pacman
echo "📦 Installing Python packages via pacman..."
sudo pacman -S --needed python python-pip python-psutil

# Check if flask is available in repos
if pacman -Ss python-flask | grep -q "python-flask"; then
    echo "📦 Installing Flask from official repos..."
    sudo pacman -S --needed python-flask
else
    echo "📦 Flask not in repos, will use pip..."
    pip install --user flask flask-cors
fi

# Install flask-cors if available
if pacman -Ss python-flask-cors | grep -q "python-flask-cors"; then
    sudo pacman -S --needed python-flask-cors
else
    echo "📦 Installing flask-cors via pip..."
    pip install --user flask-cors
fi

# Install iproute2 for network commands
echo "📦 Installing network utilities..."
sudo pacman -S --needed iproute2 net-tools

# Set up sudo permissions for power actions
echo ""
echo "🔐 Setting up sudo permissions for power actions..."
echo "💡 You'll need to add this line to sudoers file:"
echo "   $USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot, /usr/bin/systemctl suspend, /usr/bin/systemctl hibernate"
echo ""
read -p "Would you like me to add this automatically? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Adding sudo permissions..."
    echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot, /usr/bin/systemctl suspend, /usr/bin/systemctl hibernate" | sudo tee /etc/sudoers.d/power-control-dashboard
    sudo chmod 440 /etc/sudoers.d/power-control-dashboard
    echo "✅ Sudo permissions configured"
fi

echo ""
echo "✅ Dependencies installed successfully!"
echo "🚀 You can now run: ./start-server.sh"