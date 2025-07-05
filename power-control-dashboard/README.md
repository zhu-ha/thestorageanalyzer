# 🚀 Power Control Dashboard
**Remote System Control for Arch Linux - HP ProBook 440 G8**

A modern, Hyprland-style mobile dashboard for monitoring and controlling your Arch Linux laptop remotely. Built specifically for HP ProBook 440 G8 with KDE Plasma 6 on Wayland.

## ✨ Features

### 📱 Mobile App (React Native)
- **Real-time System Monitoring**: CPU, memory, storage, temperature
- **Process Management**: View top processes by CPU/RAM usage
- **Power Control**: Shutdown, reboot, suspend, hibernate
- **Battery Monitoring**: Battery percentage and charging status
- **Network Stats**: Data sent/received tracking
- **Modern UI**: Hyprland-inspired design with Catppuccin colors
- **Secure Authentication**: Token-based authentication
- **Auto-refresh**: Real-time updates every 5 seconds

### 🖥️ Desktop Server (Python/Flask)
- **Background Monitoring**: Continuous system stats collection
- **REST API**: Comprehensive endpoints for system data
- **Power Management**: SystemD integration for power actions
- **Temperature Sensors**: Multiple sensor support
- **KDE Plasma 6 Integration**: Desktop environment detection
- **Logging**: Comprehensive error and activity logging

## 🏗️ Setup Instructions

### 1. Server Setup (Arch Linux Laptop)

#### Install Dependencies
```bash
# Easy installation for Arch Linux
./install-arch-deps.sh

# OR manually install via pacman
sudo pacman -S python python-psutil python-pip iproute2 net-tools

# Install Flask (may need pip if not in repos)
sudo pacman -S python-flask || pip install --user flask flask-cors

# Configure sudo permissions for power actions
sudo visudo
# Add this line: yourusername ALL=(ALL) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot, /usr/bin/systemctl suspend, /usr/bin/systemctl hibernate
```

#### Run the Server
```bash
./start-server.sh
```

### 2. Mobile App Setup (Android)

#### Install Node.js Dependencies
```bash
# Install Node.js and mobile development tools
./setup-nodejs.sh

# Restart terminal or run:
source ~/.bashrc
```

#### Mobile App Options

**Option 1: Local APK Build with Gradle (Recommended)**
```bash
# Set up Android development environment
./setup-android-build.sh

# Build APK locally using React Native + Gradle
./build-native-apk.sh
# Creates: power-control-dashboard-YYYYMMDD-HHMM.apk
```

**Option 2: Quick Testing**
```bash
./build-apk.sh
# Choose option 1 - Development server
# Install "Expo Go" app on your phone
# Scan QR code to test instantly
```

**Option 3: Cloud APK Build**
```bash
./build-apk.sh
# Choose option 2 - Cloud build
# Create free account at expo.dev
# Download APK when build completes
```

#### Connect to Your Server
1. Start the server: `./start-server.sh`
2. Note the auth token and IP address shown
3. Open the mobile app (Expo Go or installed APK)
4. Enter your laptop's IP and the auth token
5. Tap "Connect"

## 📊 System Requirements

### Laptop (Server)
- **OS**: Arch Linux
- **Desktop**: KDE Plasma 6 (Wayland)
- **Hardware**: HP ProBook 440 G8 (optimized for)
- **Python**: 3.8+
- **Network**: WiFi/Ethernet with local network access

### Mobile (Client)
- **OS**: Android 6.0+ / iOS 11+
- **Network**: Same WiFi network as laptop
- **Storage**: ~50MB for APK

### Build Environment (For APK compilation)
- **Android SDK**: Latest platform tools
- **Java**: OpenJDK 8+
- **Gradle**: For APK compilation
- **Node.js**: 16+ for React Native
- **RAM**: 4GB+ recommended for building

## 🎯 Key Features Implemented

### ✅ Complete System Monitoring
- 🌡️ **Temperature Monitoring** - Multiple sensors, real-time CPU temperature
- 💻 **CPU Usage** - Percentage, frequency, core count, load average
- 🔄 **Process List** - Top processes by CPU/RAM usage, tap for full list
- 🧠 **Memory Stats** - RAM, swap, available memory with percentages
- 📁 **Storage Usage** - Disk space, utilization percentages
- 🌐 **Network Activity** - Data sent/received, bandwidth tracking
- ⚡ **Battery Status** - Charge level, charging state, time remaining
- ⚙️ **System Info** - Uptime, kernel, architecture, desktop environment

### 🎛️ Remote Power Control
- 🔌 **Power Actions** - Shutdown, reboot, suspend, hibernate
- 📱 **Mobile Interface** - Touch-friendly controls with confirmations
- 🔐 **Secure Authentication** - Token-based security
- ⚡ **SystemD Integration** - Native Linux power management

## 🚀 Quick Start

### **Local APK Build (Recommended):**
```bash
# 1. Install all dependencies
./install-arch-deps.sh
./setup-android-build.sh

# 2. Build APK locally with Gradle
./build-native-apk.sh
# Creates installable APK file in 10-15 minutes

# 3. Start the server
./start-server.sh

# 4. Install APK on your Android device
```

### **Quick Testing (No APK needed):**
```bash
# 1. Install Node.js dependencies
./setup-nodejs.sh

# 2. Start development server
./build-apk.sh
# Choose option 1, scan QR code with Expo Go app
```

The mobile app displays **everything** in real-time:
- CPU temperature from multiple sensors
- Live CPU usage with frequency and load
- Top running processes with resource usage
- Battery status and charging state
- Network statistics and data usage
- Memory and storage utilization
- Remote power control with confirmation dialogs

---

**Built for Arch Linux enthusiasts who want modern remote control of their systems** 🏔️📱