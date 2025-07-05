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
    echo "📦 Installing required Python packages for Arch Linux..."
    echo "🏔️  Using pacman to install system packages..."
    
    # Install Python packages via pacman (Arch way)
    sudo pacman -S --noconfirm python-flask python-psutil python-flask-cors 2>/dev/null
    
    # If that fails, try creating a virtual environment
    if [ $? -ne 0 ]; then
        echo "📦 Creating virtual environment..."
        if [ ! -d "venv" ]; then
            python3 -m venv venv
        fi
        source venv/bin/activate
        pip install flask flask-cors psutil
        echo "✅ Virtual environment created and activated"
        echo "💡 Note: Server will run in virtual environment"
    fi
fi

# Check sudo permissions for power actions
echo "🔐 Checking sudo permissions for power actions..."
if ! sudo -n systemctl status &>/dev/null; then
    echo "⚠️  Warning: You may need to configure passwordless sudo for power actions"
    echo "   Run: sudo visudo"
    echo "   Add: $USER ALL=(ALL) NOPASSWD: /usr/bin/systemctl poweroff, /usr/bin/systemctl reboot, /usr/bin/systemctl suspend, /usr/bin/systemctl hibernate"
    echo ""
fi

# Get local IP address (use ip command if hostname not available)
if command -v hostname &> /dev/null; then
    LOCAL_IP=$(hostname -I | awk '{print $1}')
else
    LOCAL_IP=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+' 2>/dev/null || echo "localhost")
fi
echo "📡 Local IP Address: $LOCAL_IP"
echo "📱 Mobile URL: http://$LOCAL_IP:8888"
echo ""

# Start the server
echo "🎯 Starting server on all interfaces (0.0.0.0:8888)..."

# Check if we're in a virtual environment and activate it if needed
if [ -d "venv" ] && [ -z "$VIRTUAL_ENV" ]; then
    echo "🔄 Activating virtual environment..."
    source venv/bin/activate
fi

python3 power_control_server.py --host 0.0.0.0 --port 8888