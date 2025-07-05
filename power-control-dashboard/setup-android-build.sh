#!/bin/bash

echo "📱 Setting up local Android APK build environment..."

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    echo "⚠️  This script is optimized for Arch Linux"
fi

# Install Android development tools
echo "📦 Installing Android development dependencies..."
sudo pacman -S --needed \
    android-tools \
    android-sdk \
    android-sdk-build-tools \
    android-sdk-platform-tools \
    jdk-openjdk \
    gradle \
    nodejs \
    npm

# Set up Android SDK environment
export ANDROID_HOME="/opt/android-sdk"
export ANDROID_SDK_ROOT="/opt/android-sdk"
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"

# Add Android SDK paths to shell configuration
echo "📝 Configuring Android SDK environment..."
if ! grep -q "ANDROID_HOME" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# Android SDK configuration for Power Control Dashboard
export ANDROID_HOME="/opt/android-sdk"
export ANDROID_SDK_ROOT="/opt/android-sdk"
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"
EOF
    echo "✅ Added Android SDK paths to ~/.bashrc"
fi

# Configure npm for local packages
npm config set prefix ~/.local
mkdir -p ~/.local/bin

# Add npm global bin to PATH
if ! grep -q ".local/bin" ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Install React Native CLI
echo "📱 Installing React Native CLI..."
npm install -g @react-native-community/cli react-native-cli

# Set up Android SDK licenses
echo "📋 Setting up Android SDK licenses..."
sudo mkdir -p $ANDROID_HOME/licenses
echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" | sudo tee $ANDROID_HOME/licenses/android-sdk-license > /dev/null
echo "d56f5187479451eabf01fb78af6dfcb131a6481e" | sudo tee $ANDROID_HOME/licenses/android-sdk-preview-license > /dev/null

# Install required Android SDK components
if command -v sdkmanager &> /dev/null; then
    echo "📦 Installing Android SDK platforms..."
    sudo $ANDROID_HOME/tools/bin/sdkmanager "platform-tools"
    sudo $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-34"
    sudo $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-33"
    sudo $ANDROID_HOME/tools/bin/sdkmanager "build-tools;34.0.0"
    sudo $ANDROID_HOME/tools/bin/sdkmanager "build-tools;33.0.1"
else
    echo "⚠️  sdkmanager not found, you may need to install SDK components manually"
fi

echo ""
echo "✅ Android build environment setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Restart your terminal or run: source ~/.bashrc"
echo "2. Run: ./build-local-apk.sh"
echo ""
echo "🔧 Verify installation:"
echo "• Java: java -version"
echo "• Android SDK: ls $ANDROID_HOME"
echo "• React Native: npx react-native --version"