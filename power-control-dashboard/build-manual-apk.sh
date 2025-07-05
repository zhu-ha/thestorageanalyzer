#!/bin/bash

echo "🔧 Manual APK Builder - Creating Android Project from Scratch"

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

if ! command -v gradle &> /dev/null; then
    print_error "Gradle not found. Run: sudo pacman -S gradle"
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

print_info "🏗️ Creating Android project manually..."

# Project setup
PROJECT_NAME="ManualPowerControl"
if [ -d "$PROJECT_NAME" ]; then
    print_warning "Removing existing $PROJECT_NAME directory..."
    rm -rf "$PROJECT_NAME"
fi

mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Create basic Android project structure
print_info "📁 Creating Android project structure..."
mkdir -p android/app/src/main/java/com/powercontrol
mkdir -p android/app/src/main/res/values
mkdir -p android/app/src/main/res/layout
mkdir -p android/app/src/main/assets
mkdir -p android/gradle/wrapper

# Create Android manifest
print_info "📋 Creating AndroidManifest.xml..."
cat > android/app/src/main/AndroidManifest.xml << 'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.powercontrol">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:name=".MainApplication"
        android:label="@string/app_name"
        android:icon="@mipmap/ic_launcher"
        android:theme="@style/AppTheme">
        <activity
            android:name=".MainActivity"
            android:label="@string/app_name"
            android:configChanges="keyboard|keyboardHidden|orientation|screenSize|uiMode"
            android:launchMode="singleTask"
            android:windowSoftInputMode="adjustResize"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# Create strings.xml
cat > android/app/src/main/res/values/strings.xml << 'EOF'
<resources>
    <string name="app_name">Power Control Dashboard</string>
</resources>
EOF

# Create styles.xml
cat > android/app/src/main/res/values/styles.xml << 'EOF'
<resources>
    <style name="AppTheme" parent="Theme.AppCompat.DayNight.NoActionBar">
        <item name="android:textColor">#000000</item>
    </style>
</resources>
EOF

# Create MainActivity.java
cat > android/app/src/main/java/com/powercontrol/MainActivity.java << 'EOF'
package com.powercontrol;

import android.os.Bundle;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebSettings;
import androidx.appcompat.app.AppCompatActivity;

public class MainActivity extends AppCompatActivity {
    private WebView webView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        webView = findViewById(R.id.webview);
        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        
        webView.setWebViewClient(new WebViewClient());
        webView.loadUrl("file:///android_asset/index.html");
    }

    @Override
    public void onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
EOF

# Create MainApplication.java
cat > android/app/src/main/java/com/powercontrol/MainApplication.java << 'EOF'
package com.powercontrol;

import android.app.Application;

public class MainApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
    }
}
EOF

# Create activity_main.xml
cat > android/app/src/main/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical">

    <WebView
        android:id="@+id/webview"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />

</LinearLayout>
EOF

# Create HTML/CSS/JS app
print_info "🌐 Creating web-based app..."
cat > android/app/src/main/assets/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Power Control Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #1e1e2e 0%, #313244 100%);
            color: #cdd6f4;
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 400px;
            margin: 0 auto;
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
        }

        .header h1 {
            color: #f2f4f7;
            font-size: 24px;
            margin-bottom: 10px;
        }

        .status {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            margin-bottom: 20px;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #f38ba8;
        }

        .status-dot.connected {
            background: #a6e3a1;
        }

        .auth-form {
            background: #45475a;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            color: #bac2de;
            font-size: 14px;
            margin-bottom: 5px;
        }

        .form-group input {
            width: 100%;
            background: #313244;
            border: 1px solid #585b70;
            border-radius: 8px;
            padding: 12px;
            color: #f2f4f7;
            font-size: 16px;
        }

        .form-group input::placeholder {
            color: #6c7086;
        }

        .btn {
            width: 100%;
            background: #89b4fa;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 15px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: opacity 0.2s;
        }

        .btn:disabled {
            opacity: 0.5;
        }

        .error {
            color: #f38ba8;
            text-align: center;
            margin: 10px 0;
            font-size: 14px;
        }

        .dashboard {
            display: none;
        }

        .stat-card {
            background: #45475a;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 15px;
        }

        .stat-title {
            color: #bac2de;
            font-size: 16px;
            margin-bottom: 10px;
        }

        .stat-value {
            color: #f2f4f7;
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .stat-subtitle {
            color: #6c7086;
            font-size: 14px;
        }

        .power-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-top: 20px;
        }

        .power-btn {
            background: #45475a;
            border: 2px solid;
            border-radius: 15px;
            padding: 20px;
            text-align: center;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.2s;
        }

        .power-btn.shutdown { border-color: #f38ba8; color: #f38ba8; }
        .power-btn.reboot { border-color: #fab387; color: #fab387; }
        .power-btn.suspend { border-color: #89b4fa; color: #89b4fa; }
        .power-btn.hibernate { border-color: #a6e3a1; color: #a6e3a1; }

        .power-btn:hover {
            opacity: 0.8;
        }

        .section-title {
            color: #f2f4f7;
            font-size: 18px;
            font-weight: bold;
            margin: 20px 0 15px 0;
        }

        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Power Control Dashboard</h1>
            <div class="status">
                <div class="status-dot" id="statusDot"></div>
                <span id="statusText">Disconnected</span>
            </div>
        </div>

        <div id="authForm" class="auth-form">
            <div class="form-group">
                <label>Server URL</label>
                <input type="text" id="serverUrl" placeholder="http://192.168.1.100:8888">
            </div>
            <div class="form-group">
                <label>Authentication Token</label>
                <input type="password" id="authToken" placeholder="Enter auth token">
            </div>
            <div id="error" class="error hidden"></div>
            <button class="btn" id="connectBtn" onclick="connect()">Connect</button>
        </div>

        <div id="dashboard" class="dashboard">
            <div class="section-title">System Monitor</div>
            
            <div class="stat-card">
                <div class="stat-title">CPU Usage</div>
                <div class="stat-value" id="cpuValue">0%</div>
                <div class="stat-subtitle" id="cpuSubtitle">0 cores</div>
            </div>

            <div class="stat-card">
                <div class="stat-title">Memory</div>
                <div class="stat-value" id="memoryValue">0 GB</div>
                <div class="stat-subtitle" id="memorySubtitle">of 0 GB</div>
            </div>

            <div class="stat-card">
                <div class="stat-title">Temperature</div>
                <div class="stat-value" id="tempValue">0°C</div>
                <div class="stat-subtitle">CPU Temperature</div>
            </div>

            <div class="section-title">Power Control</div>
            <div class="power-grid">
                <div class="power-btn shutdown" onclick="powerAction('shutdown')">SHUTDOWN</div>
                <div class="power-btn reboot" onclick="powerAction('reboot')">REBOOT</div>
                <div class="power-btn suspend" onclick="powerAction('suspend')">SUSPEND</div>
                <div class="power-btn hibernate" onclick="powerAction('hibernate')">HIBERNATE</div>
            </div>
        </div>
    </div>

    <script>
        let serverUrl = '';
        let authToken = '';
        let isConnected = false;

        function showError(message) {
            const errorEl = document.getElementById('error');
            errorEl.textContent = message;
            errorEl.classList.remove('hidden');
        }

        function hideError() {
            document.getElementById('error').classList.add('hidden');
        }

        function updateStatus(connected) {
            isConnected = connected;
            const dot = document.getElementById('statusDot');
            const text = document.getElementById('statusText');
            
            if (connected) {
                dot.classList.add('connected');
                text.textContent = 'Connected';
            } else {
                dot.classList.remove('connected');
                text.textContent = 'Disconnected';
            }
        }

        async function connect() {
            const serverUrlInput = document.getElementById('serverUrl');
            const authTokenInput = document.getElementById('authToken');
            const connectBtn = document.getElementById('connectBtn');

            serverUrl = serverUrlInput.value.trim();
            authToken = authTokenInput.value.trim();

            if (!serverUrl || !authToken) {
                showError('Please enter both server URL and auth token');
                return;
            }

            hideError();
            connectBtn.disabled = true;
            connectBtn.textContent = 'Connecting...';

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
                        updateStatus(true);
                        document.getElementById('authForm').style.display = 'none';
                        document.getElementById('dashboard').style.display = 'block';
                        startMonitoring();
                    } else {
                        showError('Invalid credentials');
                    }
                } else {
                    showError('Server not reachable');
                }
            } catch (error) {
                showError('Connection failed: ' + error.message);
            }

            connectBtn.disabled = false;
            connectBtn.textContent = 'Connect';
        }

        async function fetchSystemData() {
            if (!isConnected) return;

            try {
                const response = await fetch(`${serverUrl}/api/system`, {
                    headers: {
                        'Authorization': `Bearer ${authToken}`,
                    },
                });

                if (response.ok) {
                    const data = await response.json();
                    updateSystemData(data);
                    updateStatus(true);
                } else {
                    updateStatus(false);
                }
            } catch (error) {
                updateStatus(false);
            }
        }

        function updateSystemData(data) {
            // CPU
            document.getElementById('cpuValue').textContent = `${Math.round(data.cpu?.usage_percent || 0)}%`;
            document.getElementById('cpuSubtitle').textContent = `${data.cpu?.count || 0} cores`;

            // Memory
            const memUsed = (data.memory?.used || 0) / (1024**3);
            const memTotal = (data.memory?.total || 0) / (1024**3);
            document.getElementById('memoryValue').textContent = `${memUsed.toFixed(1)} GB`;
            document.getElementById('memorySubtitle').textContent = `of ${memTotal.toFixed(1)} GB`;

            // Temperature
            if (data.temperature) {
                const temps = Object.values(data.temperature).map(t => t.current || 0);
                const maxTemp = Math.max(...temps);
                document.getElementById('tempValue').textContent = `${Math.round(maxTemp)}°C`;
            }
        }

        async function powerAction(action) {
            if (!confirm(`Are you sure you want to ${action} the system?`)) {
                return;
            }

            try {
                const response = await fetch(`${serverUrl}/api/power/${action}`, {
                    method: 'POST',
                    headers: {
                        'Authorization': `Bearer ${authToken}`,
                    },
                });

                if (response.ok) {
                    alert(`${action.charAt(0).toUpperCase() + action.slice(1)} command sent successfully`);
                } else {
                    alert(`Failed to ${action}`);
                }
            } catch (error) {
                alert(`Failed to ${action}: ${error.message}`);
            }
        }

        function startMonitoring() {
            fetchSystemData();
            setInterval(fetchSystemData, 5000);
        }

        // Load saved credentials
        const savedUrl = localStorage.getItem('serverUrl');
        const savedToken = localStorage.getItem('authToken');
        if (savedUrl) document.getElementById('serverUrl').value = savedUrl;
        if (savedToken) document.getElementById('authToken').value = savedToken;

        // Save credentials on connect
        document.getElementById('connectBtn').addEventListener('click', () => {
            localStorage.setItem('serverUrl', document.getElementById('serverUrl').value);
            localStorage.setItem('authToken', document.getElementById('authToken').value);
        });
    </script>
</body>
</html>
EOF

# Create app build.gradle
print_info "📝 Creating Gradle build files..."
cat > android/app/build.gradle << 'EOF'
apply plugin: "com.android.application"

android {
    compileSdkVersion 34
    buildToolsVersion "34.0.0"

    defaultConfig {
        applicationId "com.powercontrol"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
    }

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
            minifyEnabled false
            signingConfig signingConfigs.release
        }
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
}
EOF

# Create project build.gradle
cat > android/build.gradle << 'EOF'
buildscript {
    ext {
        buildToolsVersion = "34.0.0"
        minSdkVersion = 21
        compileSdkVersion = 34
        targetSdkVersion = 34
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.0.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

# Create settings.gradle
cat > android/settings.gradle << 'EOF'
rootProject.name = 'PowerControlDashboard'
include ':app'
EOF

# Create gradle.properties
cat > android/gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m
org.gradle.parallel=true
org.gradle.daemon=true
android.useAndroidX=true
android.enableJetifier=true
EOF

# Create gradle wrapper
cat > android/gradle/wrapper/gradle-wrapper.properties << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

# Create gradlew
cat > android/gradlew << 'EOF'
#!/usr/bin/env sh

##############################################################################
##
##  Gradle start up script for UN*X
##
##############################################################################

# Resolve links: $0 may be a link
PRG="$0"
# Need this for relative symlinks.
while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`"/$link"
    fi
done
SAVED="`pwd`"
cd "`dirname \"$PRG\"`/" >/dev/null
APP_HOME="`pwd -P`"
cd "$SAVED" >/dev/null

APP_NAME="Gradle"
APP_BASE_NAME=`basename "$0"`

# Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
DEFAULT_JVM_OPTS='"-Xmx64m" "-Xms64m"'

# Use the maximum available, or set MAX_FD != -1 to use that value.
MAX_FD="maximum"

warn () {
    echo "$*"
}

die () {
    echo
    echo "$*"
    echo
    exit 1
}

# OS specific support (must be 'true' or 'false').
cygwin=false
msys=false
darwin=false
nonstop=false
case "`uname`" in
  CYGWIN* )
    cygwin=true
    ;;
  Darwin* )
    darwin=true
    ;;
  MINGW* )
    msys=true
    ;;
  NONSTOP* )
    nonstop=true
    ;;
esac

CLASSPATH=$APP_HOME/gradle/wrapper/gradle-wrapper.jar

# Determine the Java command to use to start the JVM.
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        # IBM's JDK on AIX uses strange locations for the executables
        JAVACMD="$JAVA_HOME/jre/sh/java"
    else
        JAVACMD="$JAVA_HOME/bin/java"
    fi
    if [ ! -x "$JAVACMD" ] ; then
        die "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
    fi
else
    JAVACMD="java"
    which java >/dev/null 2>&1 || die "ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
fi

# Increase the maximum file descriptors if we can.
if [ "$cygwin" = "false" -a "$darwin" = "false" -a "$nonstop" = "false" ] ; then
    MAX_FD_LIMIT=`ulimit -H -n`
    if [ $? -eq 0 ] ; then
        if [ "$MAX_FD" = "maximum" -o "$MAX_FD" = "max" ] ; then
            MAX_FD="$MAX_FD_LIMIT"
        fi
        ulimit -n $MAX_FD
        if [ $? -ne 0 ] ; then
            warn "Could not set maximum file descriptor limit: $MAX_FD"
        fi
    else
        warn "Could not query maximum file descriptor limit: $MAX_FD_LIMIT"
    fi
fi

# For Darwin, add options to specify how the application appears in the dock
if [ "$darwin" = "true" ]; then
    GRADLE_OPTS="$GRADLE_OPTS \"-Xdock:name=$APP_NAME\" \"-Xdock:icon=$APP_HOME/media/gradle.icns\""
fi

# For Cygwin or MSYS, switch paths to Windows format before running java
if [ "$cygwin" = "true" -o "$msys" = "true" ] ; then
    APP_HOME=`cygpath --path --mixed "$APP_HOME"`
    CLASSPATH=`cygpath --path --mixed "$CLASSPATH"`
    JAVACMD=`cygpath --unix "$JAVACMD"`

    # We build the pattern for arguments to be converted via cygpath
    ROOTDIRSRAW=`find -L / -maxdepth 1 -mindepth 1 -type d 2>/dev/null`
    SEP=""
    for dir in $ROOTDIRSRAW ; do
        ROOTDIRS="$ROOTDIRS$SEP$dir"
        SEP="|"
    done
    OURCYGPATTERN="(^($ROOTDIRS))"
    # Add a user-defined pattern to the cygpath arguments
    if [ "$GRADLE_CYGPATTERN" != "" ] ; then
        OURCYGPATTERN="$OURCYGPATTERN|($GRADLE_CYGPATTERN)"
    fi
    # Now convert the arguments - kludge to limit ourselves to /bin/sh
    i=0
    for arg in "$@" ; do
        CHECK=`echo "$arg"|egrep -c "$OURCYGPATTERN" -`
        CHECK2=`echo "$arg"|egrep -c "^-"`                                 ### Determine if an option

        if [ $CHECK -ne 0 ] && [ $CHECK2 -eq 0 ] ; then                    ### Added a condition
            eval `echo args$i`=`cygpath --path --ignore --mixed "$arg"`
        else
            eval `echo args$i`="\"$arg\""
        fi
        i=$((i+1))
    done
    case $i in
        (0) set -- ;;
        (1) set -- "$args0" ;;
        (2) set -- "$args0" "$args1" ;;
        (3) set -- "$args0" "$args1" "$args2" ;;
        (4) set -- "$args0" "$args1" "$args2" "$args3" ;;
        (5) set -- "$args0" "$args1" "$args2" "$args3" "$args4" ;;
        (6) set -- "$args0" "$args1" "$args2" "$args3" "$args4" "$args5" ;;
        (7) set -- "$args0" "$args1" "$args2" "$args3" "$args4" "$args5" "$args6" ;;
        (8) set -- "$args0" "$args1" "$args2" "$args3" "$args4" "$args5" "$args6" "$args7" ;;
        (9) set -- "$args0" "$args1" "$args2" "$args3" "$args4" "$args5" "$args6" "$args7" "$args8" ;;
    esac
fi

# Escape application args
save () {
    for i do printf %s\\n "$i" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/' \\\\/" ; done
    echo " "
}
APP_ARGS=$(save "$@")

# Collect all arguments for the java command
eval set -- $DEFAULT_JVM_OPTS $JAVA_OPTS $GRADLE_OPTS "\"-Dorg.gradle.appname=$APP_BASE_NAME\"" -classpath "\"$CLASSPATH\"" org.gradle.wrapper.GradleWrapperMain "$APP_ARGS"

exec "$JAVACMD" "$@"
EOF

chmod +x android/gradlew

# Create keystore
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

# Build the APK
print_info "🏗️ Building release APK..."
print_info "This will take 5-10 minutes..."

cd android
./gradlew clean
./gradlew assembleRelease

# Check if build succeeded
APK_PATH="app/build/outputs/apk/release/app-release.apk"
if [ -f "$APK_PATH" ]; then
    TIMESTAMP=$(date +%Y%m%d-%H%M)
    FINAL_APK="../../power-control-dashboard-manual-$TIMESTAMP.apk"
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
    print_info "💡 App Features:"
    echo "• Web-based UI with Hyprland-style design"
    echo "• Real-time system monitoring"
    echo "• CPU, memory, temperature display"
    echo "• Power control buttons"
    echo "• Credential storage"
    
else
    print_error "❌ APK build failed!"
    print_info "Check the Gradle output above for errors"
    exit 1
fi