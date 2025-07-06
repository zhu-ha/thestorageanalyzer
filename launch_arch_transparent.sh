#!/bin/bash

# Storage Analyzer Arch Linux Transparent GUI Launcher
# Quick way to test the transparent GUI without building AppImage

echo "⚡ Launching Storage Analyzer - Arch Linux Transparent Edition..."
echo "🎨 Initializing Swift-style transparent interface..."
echo "📍 Current directory: $(pwd)"
echo

# Check if running on Arch Linux
if [ -f "/etc/arch-release" ]; then
    echo "🏔️  Running on Arch Linux - Full features enabled"
else
    echo "⚠️  Not running on Arch Linux - Some features may be limited"
fi

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed"
    echo "📦 Install with: sudo pacman -S python"
    exit 1
fi

# Check if tkinter is available
if ! python3 -c "import tkinter" 2>/dev/null; then
    echo "❌ tkinter is not available"
    echo "📦 Install with: sudo pacman -S tk"
    exit 1
fi

# Check if the GUI file exists
if [ ! -f "storage_analyzer_arch_transparent.py" ]; then
    echo "❌ storage_analyzer_arch_transparent.py not found"
    exit 1
fi

# Check for pacman (Arch package manager)
if command -v pacman &> /dev/null; then
    echo "📦 Pacman detected - Arch Linux integration enabled"
fi

# Set Arch environment variable
export ARCH_STORAGE_ANALYZER=1

echo "✅ All dependencies found"
echo "🔍 Launching transparent interface with glass effects..."
echo "🎯 Features: Arch branding, pacman monitoring, Swift UI"
echo

# Launch the GUI application
python3 storage_analyzer_arch_transparent.py "$@"