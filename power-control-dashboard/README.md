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
# Install Python dependencies
pip install flask flask-cors psutil

# Ensure sudo access for power actions
sudo visudo
# Add this line: yourusername ALL=(ALL) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot, /usr/bin/systemctl suspend, /usr/bin/systemctl hibernate
```

#### Run the Server
```bash
./start-server.sh
```

### 2. Mobile App Setup (Android)

#### Build APK
```bash
./build-apk.sh
```

#### Connect to Your Server
1. Install the APK on your Android device
2. Enter your laptop's IP address and port (e.g., `http://192.168.1.100:8888`)
3. Enter the auth token displayed by the server
4. Tap "Connect"

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

```bash
# Start the server
./start-server.sh

# Build mobile app APK
./build-apk.sh
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