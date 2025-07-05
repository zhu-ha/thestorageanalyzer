#!/bin/bash

echo "📱 Setting up Node.js for Power Control Dashboard Mobile App..."

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    echo "❌ This script is designed for Arch Linux"
    echo "💡 For other distributions, install Node.js from: https://nodejs.org"
    exit 1
fi

# Install Node.js and npm
echo "📦 Installing Node.js and npm via pacman..."
sudo pacman -S --needed nodejs npm

# Set up npm to install global packages in user directory (avoid permission issues)
echo "🔧 Configuring npm for user installation..."
mkdir -p ~/.local/bin
npm config set prefix ~/.local

# Add to PATH if not already there
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
    export PATH="$HOME/.local/bin:$PATH"
    echo "✅ Added ~/.local/bin to PATH"
fi

echo "📱 Installing Expo CLI and EAS CLI..."
npm install -g @expo/cli eas-cli

echo ""
echo "✅ Node.js setup complete!"
echo ""
echo "📱 Next steps for mobile app:"
echo "1. 🚀 Run: ./build-apk.sh"
echo "2. 📱 Choose Option 1 for quick testing with Expo Go app"
echo "3. 🏗️  Choose Option 2 to build actual APK (requires Expo account)"
echo ""
echo "💡 Tip: For immediate testing, install 'Expo Go' from Google Play Store"