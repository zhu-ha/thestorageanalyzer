#!/bin/bash

echo "🚀 Building Native Android APK using React Native CLI + Gradle"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if we're in the project root
if [ ! -f "power_control_server.py" ]; then
    print_error "Run this script from the power-control-dashboard directory"
    exit 1
fi

# Check dependencies
print_info "🔍 Checking dependencies..."

if ! command -v java &> /dev/null; then
    print_error "Java not found. Run: sudo pacman -S jdk-openjdk"
    exit 1
fi

if ! command -v gradle &> /dev/null; then
    print_error "Gradle not found. Run: sudo pacman -S gradle"
    exit 1
fi

if [ ! -d "/opt/android-sdk" ]; then
    print_error "Android SDK not found. Run: ./setup-android-build.sh"
    exit 1
fi

# Set environment variables
export ANDROID_HOME="/opt/android-sdk"
export ANDROID_SDK_ROOT="/opt/android-sdk"
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"

print_info "🏗️ Creating React Native project for native build..."

# Create a clean React Native project
PROJECT_NAME="PowerControlDashboard"
if [ -d "$PROJECT_NAME" ]; then
    print_warning "Removing existing $PROJECT_NAME directory..."
    rm -rf "$PROJECT_NAME"
fi

# Initialize React Native project using the modern CLI
print_info "📱 Initializing React Native project..."
npx @react-native-community/cli@latest init $PROJECT_NAME --version 0.72.6

cd $PROJECT_NAME

# Install our dependencies
print_info "📦 Installing required dependencies..."
npm install @react-native-community/async-storage react-native-vector-icons

# Copy our app code
print_info "📋 Copying app source code..."
cp ../mobile-app/App.js ./App.tsx

# Create a simple index.js that imports our App
cat > index.js << 'EOF'
import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);
EOF

# Update package.json with our app name and version
print_info "⚙️ Configuring project..."
sed -i 's/"name": ".*"/"name": "power-control-dashboard"/' package.json
sed -i 's/"displayName": ".*"/"displayName": "Power Control Dashboard"/' package.json

# Update app.json
cat > app.json << 'EOF'
{
  "name": "PowerControlDashboard",
  "displayName": "Power Control Dashboard"
}
EOF

# Configure Android app
print_info "🤖 Configuring Android build..."

# Update app name in strings.xml
sed -i 's/<string name="app_name">.*<\/string>/<string name="app_name">Power Control Dashboard<\/string>/' android/app/src/main/res/values/strings.xml

# Create keystore for signing
KEYSTORE_PATH="android/app/power-control-dashboard.keystore"
if [ ! -f "$KEYSTORE_PATH" ]; then
    print_info "🔐 Creating keystore for APK signing..."
    keytool -genkeypair -v \
        -storetype PKCS12 \
        -keystore $KEYSTORE_PATH \
        -alias power-control-dashboard \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -dname "CN=Power Control Dashboard, OU=Arch Linux, O=Local, L=Local, S=Local, C=US" \
        -storepass android \
        -keypass android
fi

# Configure Gradle for release signing
print_info "📝 Configuring Gradle build..."

# Add signing config to build.gradle
cat >> android/app/build.gradle << 'EOF'

// APK signing configuration
android {
    signingConfigs {
        release {
            storeFile file('power-control-dashboard.keystore')
            storePassword 'android'
            keyAlias 'power-control-dashboard'
            keyPassword 'android'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
EOF

# Update gradle.properties for better build performance
cat >> android/gradle.properties << 'EOF'

# Build optimization
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
org.gradle.parallel=true
org.gradle.configureondemand=true
org.gradle.daemon=true
android.useAndroidX=true
android.enableJetifier=true
EOF

# Build the APK
print_info "🏗️ Building release APK..."
print_info "This will take 5-15 minutes depending on your system..."

cd android

# Clean and build
./gradlew clean
./gradlew assembleRelease

# Check if build succeeded
APK_PATH="app/build/outputs/apk/release/app-release.apk"
if [ -f "$APK_PATH" ]; then
    # Copy APK to project root with timestamp
    TIMESTAMP=$(date +%Y%m%d-%H%M)
    FINAL_APK="../../power-control-dashboard-$TIMESTAMP.apk"
    cp "$APK_PATH" "$FINAL_APK"
    
    APK_SIZE=$(du -h "$FINAL_APK" | cut -f1)
    
    print_success "🎉 APK built successfully!"
    print_success "📱 APK: $(realpath "$FINAL_APK")"
    print_success "📊 Size: $APK_SIZE"
    
    echo ""
    print_info "📱 Installation Instructions:"
    echo "1. Transfer APK to your Android device"
    echo "2. Enable 'Install from unknown sources' in Settings"
    echo "3. Install the APK"
    echo "4. Start server: ./start-server.sh"
    echo "5. Connect using your laptop's IP address"
    
    echo ""
    print_info "🔧 Development Commands:"
    echo "• Rebuild APK: cd $PROJECT_NAME/android && ./gradlew assembleRelease"
    echo "• Debug build: cd $PROJECT_NAME/android && ./gradlew assembleDebug"
    echo "• Connect device: adb devices"
    echo "• Install APK: adb install $FINAL_APK"
    
else
    print_error "❌ APK build failed!"
    echo ""
    print_info "🔧 Troubleshooting:"
    echo "• Check Android SDK: ls $ANDROID_HOME"
    echo "• Check Java version: java -version"
    echo "• Try debug build: ./gradlew assembleDebug"
    echo "• Check logs: ./gradlew assembleRelease --info"
    
    exit 1
fi