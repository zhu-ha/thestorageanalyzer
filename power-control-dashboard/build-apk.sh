#!/bin/bash

echo "🚀 Building Power Control Dashboard APK..."

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

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ Error: npm is not installed!"
    echo "Please install Node.js and npm first"
    exit 1
fi

# Check if expo CLI is installed globally
if ! command -v expo &> /dev/null; then
    echo "📦 Installing Expo CLI globally..."
    npm install -g @expo/cli
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Check if EAS CLI is available (recommended for building)
if command -v eas &> /dev/null; then
    echo "🔧 Using EAS Build (recommended)..."
    echo "🔑 Make sure you're logged in to Expo:"
    echo "   expo login"
    echo ""
    echo "🏗️ Building APK with EAS..."
    eas build --platform android --profile preview
else
    echo "⚠️  EAS CLI not found, using classic build..."
    echo "📦 Installing EAS CLI..."
    npm install -g eas-cli
    
    echo "🔑 Please login to Expo account:"
    expo login
    
    echo "🔧 Configuring EAS..."
    eas build:configure
    
    echo "🏗️ Building APK..."
    eas build --platform android --profile preview
fi

echo ""
echo "✅ APK build started!"
echo "📱 The APK will be available for download when build completes"
echo "🔗 Check build status at: https://expo.dev/accounts/[username]/projects/power-control-dashboard/builds"
echo ""
echo "📋 Quick Setup Reminder:"
echo "1. Download and install the APK on your Android device"
echo "2. Start the server on your Arch laptop: python3 power_control_server.py"
echo "3. Note the auth token displayed by the server"
echo "4. Open the app and enter your laptop's IP and the auth token"
echo "5. Enjoy remote control of your Arch Linux system! 🏔️"