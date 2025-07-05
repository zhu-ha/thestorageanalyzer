#!/bin/bash

# Storage Analyzer GUI Launcher
# Quick way to test the GUI without building AppImage

echo "🚀 Launching Storage Analyzer GUI..."
echo "📍 Current directory: $(pwd)"
echo

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed"
    exit 1
fi

# Check if tkinter is available
if ! python3 -c "import tkinter" 2>/dev/null; then
    echo "❌ tkinter is not available"
    echo "Install with: sudo apt install python3-tk"
    exit 1
fi

# Check if the GUI file exists
if [ ! -f "storage_analyzer_gui.py" ]; then
    echo "❌ storage_analyzer_gui.py not found"
    exit 1
fi

echo "✅ All dependencies found"
echo "🎨 Launching Swift-style GUI..."
echo

# Launch the GUI application
python3 storage_analyzer_gui.py "$@"