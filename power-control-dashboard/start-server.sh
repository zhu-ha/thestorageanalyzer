#!/bin/bash

echo "🚀 Starting Power Control Dashboard Server..."
echo "🏔️  Arch Linux - HP ProBook 440 G8 Edition"
echo ""

# Check if Python3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python3 is not installed!"
    exit 1
fi

# Check if required Python packages are installed
echo "🔍 Checking dependencies..."
python3 -c "import flask, psutil" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "📦 Installing required Python packages..."
    pip3 install flask flask-cors psutil
fi

# Check sudo permissions for power actions
echo "🔐 Checking sudo permissions for power actions..."
if ! sudo -n systemctl status &>/dev/null; then
    echo "⚠️  Warning: You may need to configure passwordless sudo for power actions"
    echo "   Run: sudo visudo"
    echo "   Add: $USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot, /usr/bin/systemctl suspend, /usr/bin/systemctl hibernate"
    echo ""
fi

# Get local IP address
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "📡 Local IP Address: $LOCAL_IP"
echo "📱 Mobile URL: http://$LOCAL_IP:8888"
echo ""

# Start the server
echo "🎯 Starting server on all interfaces (0.0.0.0:8888)..."
python3 power_control_server.py --host 0.0.0.0 --port 8888