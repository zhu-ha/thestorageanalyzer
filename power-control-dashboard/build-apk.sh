#!/bin/bash

echo "🚀 Power Control Dashboard APK Build Setup for Arch Linux..."

# Check if we're in the mobile-app directory
if [ ! -f "package.json" ]; then
    if [ -d "mobile-app" ]; then
        cd mobile-app
        echo "📁 Switched to mobile-app directory"
    else
        echo "❌ Error: mobile-app directory not found!"
        echo "Please run this script from the project root or mobile-app directory"
        exit 1
    fi
fi

# Check if Node.js/npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ Error: npm is not installed!"
    echo "📦 Installing Node.js on Arch Linux:"
    echo "   sudo pacman -S nodejs npm"
    exit 1
fi

echo "🏔️  Setting up for Arch Linux..."

# Install npm packages locally to avoid permission issues
echo "📦 Installing local development dependencies..."
npm install

# Check if npx is available
if ! command -v npx &> /dev/null; then
    echo "❌ npx not found. Installing globally with proper permissions..."
    # Use npm prefix to install in user directory
    npm config set prefix ~/.local
    export PATH="$HOME/.local/bin:$PATH"
    npm install -g @expo/cli eas-cli
else
    echo "✅ npx available, using local packages"
fi

echo ""
echo "📱 APK Build Options:"
echo ""
echo "🔄 Option 1: Local Development Server (Recommended for testing)"
echo "   • Run: npx expo start"
echo "   • Use Expo Go app on your phone to scan QR code"
echo "   • No APK needed, instant testing"
echo ""
echo "🏗️  Option 2: Build APK via Expo Cloud (Requires account)"
echo "   • Create free account at: https://expo.dev"
echo "   • Run: npx expo login"
echo "   • Run: npx eas build --platform android --profile preview"
echo "   • Download APK from Expo dashboard"
echo ""
echo "📱 Option 3: Build APK Locally (Advanced)"
echo "   • Install Android SDK and tools"
echo "   • Run: npx expo run:android"
echo "   • Requires Android development setup"
echo ""
echo "💡 Recommendation: Use Option 1 for immediate testing!"
echo ""

read -p "Which option would you like? (1=dev server, 2=cloud build, 3=local build, q=quit): " choice

case $choice in
    1)
        echo "🚀 Starting development server..."
        echo "� Install 'Expo Go' app on your phone and scan the QR code"
        npx expo start
        ;;
    2)
        echo "🔑 Setting up Expo cloud build..."
        echo "📝 You'll need to create a free account at https://expo.dev"
        echo ""
        
        if ! npx expo whoami &>/dev/null; then
            echo "Please login to your Expo account:"
            npx expo login
        fi
        
        echo "🔧 Configuring build..."
        npx eas build:configure 2>/dev/null || echo "Build already configured"
        
        echo "🏗️ Building APK (this will take 5-15 minutes)..."
        npx eas build --platform android --profile preview
        
        echo ""
        echo "✅ Build started! Check progress at: https://expo.dev"
        echo "📱 You'll receive an email when the APK is ready for download"
        ;;
    3)
        echo "🔧 Local build requires Android SDK setup..."
        echo "📦 Install Android Studio or SDK tools first"
        echo "🚀 Then run: npx expo run:android"
        ;;
    *)
        echo "👋 Exiting..."
        exit 0
        ;;
esac

echo ""
echo "✅ APK build started!"
echo "📱 The APK will be available for download when build completes"
echo "🔗 Check build status at: https://expo.dev/accounts/[username]/projects/power-control-dashboard/builds"
echo ""
echo "📋 Quick Setup Reminder:"
echo "1. Download and install the APK on your Android device"
echo "2. Start the server on your Arch laptop: ./start-server.sh"
echo "3. Note the auth token displayed by the server"
echo "4. Open the app and enter your laptop's IP and the auth token"
echo "5. Enjoy remote control of your Arch Linux system! 🏔️"