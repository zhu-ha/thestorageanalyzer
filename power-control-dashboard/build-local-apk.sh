#!/bin/bash

echo "🏗️ Local APK Build Script for Arch Linux"
echo "Building Power Control Dashboard APK using Gradle..."

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "power_control_server.py" ]; then
    print_error "Please run this script from the power-control-dashboard directory"
    exit 1
fi

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    print_warning "This script is optimized for Arch Linux"
fi

print_status "🏔️ Setting up Android development environment..."

# Install Android development dependencies
print_status "📦 Installing Android SDK and build tools..."
sudo pacman -S --needed android-tools android-sdk android-sdk-build-tools android-sdk-platform-tools jdk-openjdk gradle

# Set up Android SDK environment variables
export ANDROID_HOME="/opt/android-sdk"
export ANDROID_SDK_ROOT="/opt/android-sdk"
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"

# Add to shell profiles for persistence
if ! grep -q "ANDROID_HOME" ~/.bashrc; then
    print_status "📝 Adding Android SDK paths to ~/.bashrc"
    echo 'export ANDROID_HOME="/opt/android-sdk"' >> ~/.bashrc
    echo 'export ANDROID_SDK_ROOT="/opt/android-sdk"' >> ~/.bashrc
    echo 'export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"' >> ~/.bashrc
fi

# Install Node.js if not present
if ! command -v node &> /dev/null; then
    print_status "📦 Installing Node.js..."
    sudo pacman -S --needed nodejs npm
fi

# Set up npm for local installation
npm config set prefix ~/.local
export PATH="$HOME/.local/bin:$PATH"

# Navigate to mobile app directory
cd mobile-app || { print_error "mobile-app directory not found"; exit 1; }

print_status "📱 Setting up React Native project for local build..."

# Install dependencies
print_status "📦 Installing npm dependencies..."
npm install

# Install React Native CLI locally
print_status "📦 Installing React Native CLI..."
npm install -g react-native-cli @react-native-community/cli

# Create Android project structure if it doesn't exist
if [ ! -d "android" ]; then
    print_status "🏗️ Initializing React Native Android project..."
    npx react-native init PowerControlDashboard --template react-native-template-typescript
    
    # Copy our App.js to the new project
    cp App.js PowerControlDashboard/
    cp package.json PowerControlDashboard/
    cp app.json PowerControlDashboard/
    
    cd PowerControlDashboard
    
    # Install our dependencies
    npm install
else
    print_status "✅ Android project structure already exists"
fi

# Check for Android SDK platforms
print_status "🔧 Installing Android SDK platforms and build tools..."
if [ -d "$ANDROID_HOME" ]; then
    # Install required Android SDK components
    sudo mkdir -p $ANDROID_HOME/licenses
    echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" | sudo tee $ANDROID_HOME/licenses/android-sdk-license > /dev/null
    
    # Install SDK platforms
    if command -v sdkmanager &> /dev/null; then
        print_status "📦 Installing Android SDK platforms..."
        sudo sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" "platforms;android-33"
    else
        print_warning "sdkmanager not found, you may need to install SDK components manually"
    fi
else
    print_error "Android SDK not found at $ANDROID_HOME"
    print_status "Installing Android SDK via AUR..."
    
    # Install from AUR if available
    if command -v yay &> /dev/null; then
        yay -S android-sdk-platform-tools android-sdk-build-tools
    elif command -v paru &> /dev/null; then
        paru -S android-sdk-platform-tools android-sdk-build-tools
    else
        print_error "Please install an AUR helper (yay or paru) or manually install Android SDK"
        exit 1
    fi
fi

# Create keystore for signing APK
KEYSTORE_PATH="../power-control-dashboard.keystore"
if [ ! -f "$KEYSTORE_PATH" ]; then
    print_status "🔐 Creating keystore for APK signing..."
    keytool -genkeypair -v -storetype PKCS12 -keystore $KEYSTORE_PATH -alias power-control-dashboard \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -dname "CN=Power Control Dashboard, OU=Development, O=Arch Linux, L=Local, S=Local, C=US" \
        -storepass android -keypass android
    print_success "Keystore created at $KEYSTORE_PATH"
fi

# Configure Gradle for signing
print_status "⚙️ Configuring Gradle build..."

# Create gradle.properties if it doesn't exist
if [ ! -f "android/gradle.properties" ]; then
    cat > android/gradle.properties << EOF
# APK signing configuration
MYAPP_UPLOAD_STORE_FILE=../../power-control-dashboard.keystore
MYAPP_UPLOAD_KEY_ALIAS=power-control-dashboard
MYAPP_UPLOAD_STORE_PASSWORD=android
MYAPP_UPLOAD_KEY_PASSWORD=android

# Android configuration
android.useAndroidX=true
android.enableJetifier=true
org.gradle.jvmargs=-Xmx2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
EOF
fi

# Update build.gradle for release build
if [ -f "android/app/build.gradle" ]; then
    print_status "📝 Configuring release build settings..."
    
    # Backup original build.gradle
    cp android/app/build.gradle android/app/build.gradle.bak
    
    # Add signing configuration to build.gradle
    if ! grep -q "signingConfigs" android/app/build.gradle; then
        sed -i '/android {/a\
    signingConfigs {\
        release {\
            if (project.hasProperty("MYAPP_UPLOAD_STORE_FILE")) {\
                storeFile file(MYAPP_UPLOAD_STORE_FILE)\
                storePassword MYAPP_UPLOAD_STORE_PASSWORD\
                keyAlias MYAPP_UPLOAD_KEY_ALIAS\
                keyPassword MYAPP_UPLOAD_KEY_PASSWORD\
            }\
        }\
    }' android/app/build.gradle
    fi
    
    # Update buildTypes to use signing config
    if ! grep -q "signingConfig signingConfigs.release" android/app/build.gradle; then
        sed -i '/release {/a\
            signingConfig signingConfigs.release' android/app/build.gradle
    fi
fi

# Clean previous builds
print_status "🧹 Cleaning previous builds..."
cd android
./gradlew clean

# Build the APK
print_status "🏗️ Building release APK with Gradle..."
print_status "This may take 10-15 minutes on first build..."

# Build release APK
./gradlew assembleRelease

# Check if build was successful
APK_PATH="app/build/outputs/apk/release/app-release.apk"
if [ -f "$APK_PATH" ]; then
    # Copy APK to project root with better name
    FINAL_APK_PATH="../../power-control-dashboard-$(date +%Y%m%d-%H%M).apk"
    cp "$APK_PATH" "$FINAL_APK_PATH"
    
    print_success "🎉 APK built successfully!"
    print_success "📱 APK location: $(realpath $FINAL_APK_PATH)"
    
    # Get APK info
    APK_SIZE=$(du -h "$FINAL_APK_PATH" | cut -f1)
    print_status "📊 APK size: $APK_SIZE"
    
    echo ""
    print_status "📱 Installation instructions:"
    echo "1. Transfer APK to your Android device"
    echo "2. Enable 'Install from unknown sources' in Android settings"
    echo "3. Install the APK"
    echo "4. Start the server: ./start-server.sh"
    echo "5. Open the app and connect using your laptop's IP"
    
    echo ""
    print_status "🔧 Development commands:"
    echo "• Rebuild: cd mobile-app/android && ./gradlew assembleRelease"
    echo "• Debug build: cd mobile-app/android && ./gradlew assembleDebug"
    echo "• Clean: cd mobile-app/android && ./gradlew clean"
    
else
    print_error "❌ APK build failed!"
    print_error "Check the Gradle output above for errors"
    print_status "💡 Common issues:"
    echo "• Missing Android SDK components"
    echo "• Java version compatibility"
    echo "• Insufficient memory (try: export GRADLE_OPTS=-Xmx4096m)"
    echo "• Missing dependencies"
    
    echo ""
    print_status "🔧 Debug commands:"
    echo "• Check Java: java -version"
    echo "• Check Android SDK: ls $ANDROID_HOME"
    echo "• Manual build: cd mobile-app/android && ./gradlew assembleRelease --info"
    
    exit 1
fi