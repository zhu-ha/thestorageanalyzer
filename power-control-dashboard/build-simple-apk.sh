#!/bin/bash

echo "🚀 Simple APK Builder for Power Control Dashboard"

# Colors
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

if ! command -v node &> /dev/null; then
    print_error "Node.js not found. Run: sudo pacman -S nodejs npm"
    exit 1
fi

if [ ! -d "/opt/android-sdk" ]; then
    print_error "Android SDK not found. Run: ./setup-android-build.sh first"
    exit 1
fi

# Set environment variables
export ANDROID_HOME="/opt/android-sdk"
export ANDROID_SDK_ROOT="/opt/android-sdk"
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"

print_info "🏗️ Creating React Native project manually..."

# Project setup
PROJECT_NAME="PowerControlApp"
if [ -d "$PROJECT_NAME" ]; then
    print_warning "Removing existing $PROJECT_NAME directory..."
    rm -rf "$PROJECT_NAME"
fi

# Create project structure manually
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Initialize package.json
print_info "📦 Creating package.json..."
cat > package.json << 'EOF'
{
  "name": "PowerControlApp",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "android": "react-native run-android",
    "ios": "react-native run-ios",
    "start": "react-native start",
    "test": "jest",
    "lint": "eslint ."
  },
  "dependencies": {
    "react": "18.2.0",
    "react-native": "0.72.6",
    "@react-native-async-storage/async-storage": "^1.19.3",
    "react-native-vector-icons": "^10.0.0"
  },
  "devDependencies": {
    "@babel/core": "^7.20.0",
    "@babel/preset-env": "^7.20.0",
    "@babel/runtime": "^7.20.0",
    "@react-native/eslint-config": "^0.72.2",
    "@react-native/metro-config": "^0.72.11",
    "@tsconfig/react-native": "^3.0.0",
    "@types/react": "^18.0.24",
    "@types/react-test-renderer": "^18.0.0",
    "babel-jest": "^29.2.1",
    "eslint": "^8.19.0",
    "jest": "^29.2.1",
    "metro-react-native-babel-preset": "0.76.8",
    "prettier": "^2.4.1",
    "react-test-renderer": "18.2.0",
    "typescript": "4.8.4"
  },
  "jest": {
    "preset": "react-native"
  }
}
EOF

# Install dependencies
print_info "📥 Installing dependencies..."
npm install

# Create simplified App.js (converted from our complex App.js)
print_info "📱 Creating simplified App.js..."
cat > App.js << 'EOF'
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  TextInput,
  Alert,
  ScrollView,
  RefreshControl,
  StatusBar,
} from 'react-native';

const colors = {
  primary: '#1e1e2e',
  secondary: '#313244',
  surface: '#45475a',
  text: '#cdd6f4',
  textPrimary: '#f2f4f7',
  textSecondary: '#bac2de',
  accentBlue: '#89b4fa',
  accentGreen: '#a6e3a1',
  accentOrange: '#fab387',
  accentRed: '#f38ba8',
  success: '#a6e3a1',
  error: '#f38ba8',
};

export default function App() {
  const [serverUrl, setServerUrl] = useState('');
  const [authToken, setAuthToken] = useState('');
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [systemData, setSystemData] = useState({});
  const [refreshing, setRefreshing] = useState(false);
  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    let interval;
    if (isAuthenticated) {
      fetchSystemData();
      interval = setInterval(fetchSystemData, 5000);
    }
    return () => clearInterval(interval);
  }, [isAuthenticated]);

  const fetchSystemData = async () => {
    if (!serverUrl || !authToken) return;

    try {
      const response = await fetch(`${serverUrl}/api/system`, {
        headers: {
          'Authorization': `Bearer ${authToken}`,
        },
        timeout: 10000,
      });

      if (response.ok) {
        const data = await response.json();
        setSystemData(data);
        setIsConnected(true);
        setError('');
      } else {
        throw new Error('Failed to fetch system data');
      }
    } catch (error) {
      console.log('Error fetching system data:', error);
      setIsConnected(false);
      setError('Connection failed');
    }
  };

  const executePowerAction = async (action) => {
    Alert.alert(
      `Confirm ${action.charAt(0).toUpperCase() + action.slice(1)}`,
      `Are you sure you want to ${action} the system?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Confirm',
          style: 'destructive',
          onPress: async () => {
            try {
              setIsLoading(true);
              const response = await fetch(`${serverUrl}/api/power/${action}`, {
                method: 'POST',
                headers: {
                  'Authorization': `Bearer ${authToken}`,
                },
              });

              if (response.ok) {
                Alert.alert('Success', `${action.charAt(0).toUpperCase() + action.slice(1)} command sent successfully`);
              } else {
                throw new Error(`Failed to ${action}`);
              }
            } catch (error) {
              Alert.alert('Error', `Failed to ${action}: ${error.message}`);
            } finally {
              setIsLoading(false);
            }
          },
        },
      ]
    );
  };

  const handleConnect = async () => {
    if (!serverUrl || !authToken) {
      setError('Please enter both server URL and auth token');
      return;
    }

    setIsLoading(true);
    setError('');

    try {
      const response = await fetch(`${serverUrl}/api/auth/verify`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ token: authToken }),
      });

      if (response.ok) {
        const data = await response.json();
        if (data.valid) {
          setIsAuthenticated(true);
          setIsConnected(true);
        } else {
          setError('Invalid credentials');
        }
      } else {
        setError('Server not reachable');
      }
    } catch (error) {
      setError('Connection failed: ' + error.message);
    } finally {
      setIsLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchSystemData();
    setRefreshing(false);
  };

  const formatBytes = (bytes, unit = 'GB') => {
    if (!bytes) return '0';
    const divisor = unit === 'MB' ? 1024 * 1024 : 1024 * 1024 * 1024;
    return (bytes / divisor).toFixed(1);
  };

  if (!isAuthenticated) {
    return (
      <View style={styles.container}>
        <StatusBar backgroundColor={colors.primary} barStyle="light-content" />
        <View style={styles.authContainer}>
          <View style={styles.authCard}>
            <Text style={styles.authTitle}>Power Control Dashboard</Text>
            <Text style={styles.authSubtitle}>Connect to your Arch Linux system</Text>

            <Text style={styles.inputLabel}>Server URL</Text>
            <TextInput
              style={styles.textInput}
              placeholder="http://192.168.1.100:8888"
              placeholderTextColor={colors.textSecondary}
              value={serverUrl}
              onChangeText={setServerUrl}
              autoCapitalize="none"
              autoCorrect={false}
            />

            <Text style={styles.inputLabel}>Authentication Token</Text>
            <TextInput
              style={styles.textInput}
              placeholder="Enter auth token"
              placeholderTextColor={colors.textSecondary}
              value={authToken}
              onChangeText={setAuthToken}
              secureTextEntry
              autoCapitalize="none"
              autoCorrect={false}
            />

            {error ? <Text style={styles.errorText}>{error}</Text> : null}

            <TouchableOpacity
              style={[styles.connectButton, isLoading && styles.connectButtonDisabled]}
              onPress={handleConnect}
              disabled={isLoading}
            >
              <Text style={styles.connectButtonText}>
                {isLoading ? 'Connecting...' : 'Connect'}
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <StatusBar backgroundColor={colors.primary} barStyle="light-content" />
      
      <View style={styles.header}>
        <Text style={styles.headerTitle}>{systemData.hostname || 'Arch System'}</Text>
        <View style={styles.connectionStatus}>
          <View style={[styles.statusDot, { backgroundColor: isConnected ? colors.success : colors.error }]} />
          <Text style={styles.statusText}>{isConnected ? 'Connected' : 'Disconnected'}</Text>
        </View>
      </View>

      <ScrollView
        style={styles.scrollView}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={colors.accentBlue} />
        }
      >
        {/* System Stats */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>System Monitor</Text>
          
          <View style={styles.statCard}>
            <Text style={styles.statTitle}>CPU Usage</Text>
            <Text style={styles.statValue}>{Math.round(systemData.cpu?.usage_percent || 0)}%</Text>
            <Text style={styles.statSubtitle}>{systemData.cpu?.count || 0} cores</Text>
          </View>

          <View style={styles.statCard}>
            <Text style={styles.statTitle}>Memory</Text>
            <Text style={styles.statValue}>{formatBytes(systemData.memory?.used)} GB</Text>
            <Text style={styles.statSubtitle}>of {formatBytes(systemData.memory?.total)} GB</Text>
          </View>

          <View style={styles.statCard}>
            <Text style={styles.statTitle}>Storage</Text>
            <Text style={styles.statValue}>{formatBytes(systemData.disk?.used)} GB</Text>
            <Text style={styles.statSubtitle}>{formatBytes(systemData.disk?.free)} GB free</Text>
          </View>

          {systemData.temperature && (
            <View style={styles.statCard}>
              <Text style={styles.statTitle}>Temperature</Text>
              <Text style={styles.statValue}>
                {Math.round(Math.max(...Object.values(systemData.temperature).map(t => t.current || 0)))}°C
              </Text>
              <Text style={styles.statSubtitle}>CPU Temperature</Text>
            </View>
          )}

          {systemData.processes && systemData.processes.length > 0 && (
            <View style={styles.statCard}>
              <Text style={styles.statTitle}>Top Processes</Text>
              {systemData.processes.slice(0, 5).map((process, index) => (
                <Text key={index} style={styles.processText}>
                  {process.name}: {(process.cpu_percent || 0).toFixed(1)}% CPU
                </Text>
              ))}
            </View>
          )}
        </View>

        {/* Power Control */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Power Control</Text>
          <View style={styles.powerGrid}>
            <TouchableOpacity
              style={[styles.powerButton, { borderColor: colors.accentRed }]}
              onPress={() => executePowerAction('shutdown')}
            >
              <Text style={[styles.powerButtonText, { color: colors.accentRed }]}>SHUTDOWN</Text>
            </TouchableOpacity>
            
            <TouchableOpacity
              style={[styles.powerButton, { borderColor: colors.accentOrange }]}
              onPress={() => executePowerAction('reboot')}
            >
              <Text style={[styles.powerButtonText, { color: colors.accentOrange }]}>REBOOT</Text>
            </TouchableOpacity>
            
            <TouchableOpacity
              style={[styles.powerButton, { borderColor: colors.accentBlue }]}
              onPress={() => executePowerAction('suspend')}
            >
              <Text style={[styles.powerButtonText, { color: colors.accentBlue }]}>SUSPEND</Text>
            </TouchableOpacity>
            
            <TouchableOpacity
              style={[styles.powerButton, { borderColor: colors.accentGreen }]}
              onPress={() => executePowerAction('hibernate')}
            >
              <Text style={[styles.powerButtonText, { color: colors.accentGreen }]}>HIBERNATE</Text>
            </TouchableOpacity>
          </View>
        </View>

        <View style={{ height: 50 }} />
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.primary,
  },
  authContainer: {
    flex: 1,
    justifyContent: 'center',
    padding: 20,
  },
  authCard: {
    backgroundColor: colors.surface,
    borderRadius: 20,
    padding: 30,
    alignItems: 'center',
  },
  authTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: colors.textPrimary,
    marginBottom: 10,
    textAlign: 'center',
  },
  authSubtitle: {
    fontSize: 16,
    color: colors.textSecondary,
    marginBottom: 30,
    textAlign: 'center',
  },
  inputLabel: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.textSecondary,
    marginBottom: 8,
    marginTop: 15,
    alignSelf: 'flex-start',
  },
  textInput: {
    backgroundColor: colors.secondary,
    borderRadius: 12,
    padding: 15,
    fontSize: 16,
    color: colors.textPrimary,
    borderWidth: 1,
    borderColor: colors.surface,
    width: '100%',
    marginBottom: 10,
  },
  errorText: {
    color: colors.error,
    fontSize: 14,
    marginTop: 10,
    textAlign: 'center',
  },
  connectButton: {
    backgroundColor: colors.accentBlue,
    borderRadius: 12,
    padding: 18,
    marginTop: 25,
    alignItems: 'center',
    width: '100%',
  },
  connectButtonDisabled: {
    opacity: 0.5,
  },
  connectButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  header: {
    padding: 20,
    paddingTop: 40,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: colors.primary,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: colors.textPrimary,
  },
  connectionStatus: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 8,
  },
  statusText: {
    fontSize: 12,
    color: colors.textSecondary,
  },
  scrollView: {
    flex: 1,
  },
  section: {
    padding: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: colors.textPrimary,
    marginBottom: 15,
  },
  statCard: {
    backgroundColor: colors.surface,
    borderRadius: 15,
    padding: 20,
    marginBottom: 15,
  },
  statTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: colors.textSecondary,
    marginBottom: 5,
  },
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: colors.textPrimary,
    marginBottom: 5,
  },
  statSubtitle: {
    fontSize: 14,
    color: colors.textSecondary,
  },
  processText: {
    fontSize: 12,
    color: colors.textSecondary,
    marginBottom: 2,
  },
  powerGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 15,
  },
  powerButton: {
    flex: 1,
    minWidth: '45%',
    backgroundColor: colors.surface,
    borderRadius: 15,
    padding: 20,
    alignItems: 'center',
    borderWidth: 2,
    marginBottom: 10,
  },
  powerButtonText: {
    fontSize: 14,
    fontWeight: '600',
  },
});
EOF

# Create index.js
cat > index.js << 'EOF'
import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);
EOF

# Create app.json
cat > app.json << 'EOF'
{
  "name": "PowerControlApp",
  "displayName": "Power Control Dashboard"
}
EOF

# Create babel.config.js
cat > babel.config.js << 'EOF'
module.exports = {
  presets: ['module:metro-react-native-babel-preset'],
};
EOF

# Create metro.config.js
cat > metro.config.js << 'EOF'
const {getDefaultConfig, mergeConfig} = require('@react-native/metro-config');

const config = {};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
EOF

# Initialize React Native project structure
print_info "🏗️ Creating Android project..."
npx @react-native-community/cli@latest init PowerControlTemp --skip-install

# Move the android directory from the created project
if [ -d "PowerControlTemp/android" ]; then
    print_info "📁 Moving Android project structure..."
    mv PowerControlTemp/android ./
    mv PowerControlTemp/ios ./ 2>/dev/null || true
    rm -rf PowerControlTemp
    print_success "✅ Android project structure created"
else
    print_error "Failed to create Android project structure"
    exit 1
fi

# Configure Android app
print_info "🤖 Configuring Android build..."

# Update app name in strings.xml
sed -i 's/<string name="app_name">.*<\/string>/<string name="app_name">Power Control Dashboard<\/string>/' android/app/src/main/res/values/strings.xml

# Create keystore for signing
KEYSTORE_PATH="android/app/power-control-dashboard.keystore"
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

# Configure Gradle signing
print_info "📝 Configuring Gradle for release build..."

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

# Update gradle.properties
cat >> android/gradle.properties << 'EOF'

# Build optimization
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m
org.gradle.parallel=true
org.gradle.daemon=true
android.useAndroidX=true
android.enableJetifier=true
EOF

# Build the APK
print_info "🏗️ Building release APK..."
print_info "This will take 10-15 minutes..."

cd android
./gradlew clean
./gradlew assembleRelease

# Check if build succeeded
APK_PATH="app/build/outputs/apk/release/app-release.apk"
if [ -f "$APK_PATH" ]; then
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
    
else
    print_error "❌ APK build failed!"
    print_info "Check the Gradle output above for errors"
    exit 1
fi