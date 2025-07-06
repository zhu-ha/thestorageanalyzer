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
python3 power_control_server.py
```

The server will display:
- Your auth token
- Server URL for mobile connection
- System information

### 2. Mobile App Setup (Android)

#### Install Dependencies
```bash
cd mobile-app
npm install

# For development
npx expo start

# For APK build
npx expo build:android
# OR using EAS (recommended)
npm install -g @expo/cli
eas build --platform android
```

#### Connect to Your Server
1. Open the app
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

## 🔧 Configuration

### Server Configuration
```python
# Custom host/port
python3 power_control_server.py --host 0.0.0.0 --port 8888

# Custom auth token
python3 power_control_server.py --auth-token "your-custom-token"

# Generate new token
python3 power_control_server.py --generate-token
```

### Mobile App Configuration
- **Auto-save Credentials**: Credentials are saved securely
- **Auto-refresh**: 5-second interval (configurable)
- **Connection Timeout**: 10 seconds
- **Retry Logic**: Automatic reconnection

## 📱 Mobile App Screens

### 🔐 Authentication Screen
- Server URL input
- Token authentication
- Connection status
- Error handling

### 📊 Dashboard Screen
- **System Monitor**: CPU, Memory, Storage with progress rings
- **Hardware Status**: Temperature and battery
- **Power Control**: Shutdown, reboot, suspend, hibernate buttons
- **Process List**: Top 8 processes with CPU/RAM usage
- **System Info**: Uptime, kernel, network stats

### 🎨 UI Features
- **Hyprland Style**: Dark theme with accent colors
- **Smooth Animations**: Loading states and transitions
- **Responsive Design**: Works on all screen sizes
- **Pull-to-Refresh**: Manual refresh capability
- **Confirmation Dialogs**: Safety prompts for power actions

## 🔒 Security

### Authentication
- **Token-based**: 256-bit secure tokens
- **Local Storage**: Encrypted credential storage on mobile
- **Network**: HTTP with token headers (use HTTPS in production)

### Power Actions
- **Sudo Integration**: Passwordless sudo for specific systemctl commands
- **Delayed Execution**: 2-second delay to ensure response delivery
- **Confirmation**: Mobile confirmation dialogs

## 🐛 Troubleshooting

### Server Issues
```bash
# Check if server is running
netstat -tlnp | grep 8888

# Check logs
tail -f power-control.log

# Test connection locally
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8888/api/system
```

### Mobile Issues
- **Connection Failed**: Check IP address and port
- **Authentication Error**: Verify auth token
- **No Data**: Ensure laptop is on same network
- **APK Issues**: Use `expo build:android` or EAS build

### Network Issues
```bash
# Find your IP address
ip addr show
hostname -I

# Check firewall
sudo ufw status
sudo ufw allow 8888/tcp
```

## 📈 API Endpoints

### System Information
```
GET /api/system
Headers: Authorization: Bearer <token>
```

### Power Actions
```
POST /api/power/shutdown
POST /api/power/reboot
POST /api/power/suspend
POST /api/power/hibernate
Headers: Authorization: Bearer <token>
```

### Process List
```
GET /api/processes?limit=20
Headers: Authorization: Bearer <token>
```

### Authentication
```
POST /api/auth/verify
Body: {"token": "<token>"}
```

## 🏆 Performance

- **Server Memory**: ~50MB Python process
- **CPU Usage**: <1% when idle, <5% during monitoring
- **Network**: ~1KB/request, ~5KB/second during monitoring
- **Mobile Battery**: Minimal impact with 5-second refresh

## 🔄 Updates

### Server Updates
```bash
git pull
# Restart server
python3 power_control_server.py
```

### Mobile Updates
```bash
cd mobile-app
npm update
npx expo build:android
```

## 📝 License

MIT License - Feel free to modify and distribute

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Test on HP ProBook 440 G8
4. Submit pull request

## 🆘 Support

- **Issues**: Create GitHub issue
- **Logs**: Check `power-control.log`
- **Network**: Ensure same WiFi network
- **Permissions**: Verify sudo configuration

---

**Built for Arch Linux enthusiasts who want modern remote control of their systems** 🏔️📱
