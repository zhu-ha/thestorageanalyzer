# Storage Analyzer AppImage - Swift Style GUI

A modern, Swift-style GUI version of the Storage Analyzer packaged as an AppImage for easy distribution on Linux systems.

![Storage Analyzer](storage-analyzer.svg)

## ✨ Features

### 🎨 Modern Swift-Style Interface
- **Clean Design**: Inspired by iOS/macOS interfaces with proper spacing and typography
- **Swift Color Palette**: Uses authentic Swift/iOS colors (#007aff primary, #34c759 accent, etc.)
- **Modern Fonts**: SF Pro Display/Text fonts with Helvetica fallback
- **Hover Effects**: Interactive buttons with smooth color transitions
- **Card-Based Layout**: Clean white cards on light gray background

### 🔍 Advanced Directory Analysis
- **Interactive Navigation**: Click to drill down into directories
- **Real-Time Scanning**: Background threads for responsive UI
- **Multiple Units**: Display sizes in GB, MB, or KB
- **Permission Indicators**: 🔒 icon for restricted directories
- **Filesystem Info**: Shows total, used, and free space
- **Smart Filtering**: Only shows directories above size threshold

### 🚀 Navigation Features
- **Quick Actions**: Home, Root, Parent, and Back buttons
- **Browse Dialog**: Native folder picker
- **Path Display**: Current location with text wrapping
- **History Support**: Navigate backward through visited directories
- **Double-Click**: Navigate into directories with double-click

### 📊 Visual Information
- **Tree View**: Organized directory listing with icons
- **Size Sorting**: Largest directories shown first
- **Type Indicators**: Directory vs Restricted access
- **Loading States**: Progress indicators during scanning

## 🔧 Building the AppImage

### Prerequisites

Install required system packages:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-tk wget imagemagick

# Arch Linux
sudo pacman -S python python-tk wget imagemagick

# Fedora
sudo dnf install python3 python3-tkinter wget ImageMagick
```

### Build Process

1. **Clone and prepare:**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   chmod +x build_appimage.sh
   ```

2. **Build the AppImage:**
   ```bash
   ./build_appimage.sh
   ```

3. **The script will:**
   - ✅ Check all dependencies
   - ⬇️ Download AppImageTool automatically
   - 📁 Create proper AppDir structure
   - 🐍 Set up portable Python environment
   - 🎨 Convert SVG icon to PNG (if ImageMagick available)
   - 📦 Package everything into AppImage
   - 🧪 Verify the build

### Build Output

```
📦 AppImage: StorageAnalyzer-1.0.0-x86_64.AppImage
🚀 Run with: ./StorageAnalyzer-1.0.0-x86_64.AppImage
```

## 🎯 Usage

### Running the AppImage

```bash
# Make executable (if needed)
chmod +x StorageAnalyzer-1.0.0-x86_64.AppImage

# Run directly
./StorageAnalyzer-1.0.0-x86_64.AppImage

# Or install system-wide
sudo mv StorageAnalyzer-1.0.0-x86_64.AppImage /usr/local/bin/storage-analyzer
storage-analyzer
```

### Interface Overview

#### Left Panel - Navigation
- **Current Path**: Shows current directory location
- **🏠 Home**: Jump to user home directory
- **📁 Root**: Navigate to filesystem root
- **⬆️ Parent**: Go to parent directory
- **↩️ Back**: Return to previous directory
- **📂 Browse**: Open folder picker dialog
- **Filesystem Info**: Displays disk usage statistics

#### Right Panel - Directory Listing
- **Directory Tree**: Sortable list of subdirectories
- **Size Column**: Directory sizes in selected unit
- **Type Column**: Shows if directory is accessible
- **🔄 Refresh**: Manually refresh current directory
- **Double-Click**: Navigate into selected directory

#### Header Controls
- **Display Unit**: Switch between GB, MB, KB
- **Title**: Shows current application name

## 🎨 Design Philosophy

### Swift-Style Elements
- **Color System**: Faithful recreation of iOS/macOS color palette
- **Typography**: SF Pro font family with system fallbacks
- **Spacing**: Consistent 20px padding and 10px margins
- **Interactive Elements**: Hover states and visual feedback
- **Card Design**: Elevated white surfaces on gray background

### User Experience
- **Non-Blocking UI**: All directory scanning happens in background threads
- **Visual Feedback**: Loading indicators and disabled states
- **Error Handling**: Graceful permission error messages
- **Responsive Design**: Adapts to different window sizes

## ⚡ Performance

### Optimization Features
- **Background Scanning**: UI remains responsive during large directory scans
- **Smart Caching**: Filesystem info cached per navigation
- **Efficient Filtering**: Only displays directories above size threshold
- **Memory Management**: Proper cleanup of background threads

### System Requirements
- **OS**: Linux (any distribution)
- **Architecture**: x86_64 (amd64)
- **RAM**: 100MB+ (varies with directory size)
- **Python**: 3.8+ (bundled in AppImage)
- **Display**: GUI environment (X11/Wayland)

## 🛠️ Technical Details

### AppImage Structure
```
StorageAnalyzer.AppImage/
├── AppRun                 # Main launcher script
├── storage-analyzer.desktop # Desktop integration
├── storage-analyzer.png   # Application icon
└── usr/
    ├── bin/
    │   ├── python3        # Bundled Python
    │   ├── storage_analyzer_gui.py # Main application
    │   └── storage_analyzer_gui    # Launcher script
    ├── lib/
    │   └── python3/       # Python libraries
    └── share/
        ├── applications/  # Desktop files
        └── pixmaps/      # Icons
```

### Dependencies
- **Runtime**: Self-contained (no external dependencies)
- **Build-time**: Python 3, tkinter, wget, imagemagick (optional)
- **Libraries**: Uses only Python standard library

## 🔍 Troubleshooting

### Common Issues

**"Permission denied" when running:**
```bash
chmod +x StorageAnalyzer-1.0.0-x86_64.AppImage
```

**"tkinter not found" during build:**
```bash
# Ubuntu/Debian
sudo apt install python3-tk

# Arch Linux
sudo pacman -S tk
```

**AppImage won't start:**
- Check if FUSE is installed: `sudo apt install fuse`
- Try running with `--appimage-extract-and-run` flag

**Slow directory scanning:**
- This is normal for large directories
- Use the loading indicator as progress reference
- Consider starting with smaller directories

### Debug Mode

Run with verbose output:
```bash
./StorageAnalyzer-1.0.0-x86_64.AppImage --debug
```

## 📝 Comparison with CLI Version

| Feature | CLI Version | AppImage GUI |
|---------|-------------|--------------|
| Interface | Terminal-based | Modern GUI |
| Navigation | Text menu | Point & click |
| Visualization | Text table | Tree view |
| Performance | Fast startup | Background scanning |
| Distribution | Python script | Self-contained AppImage |
| Dependencies | Python 3 | None (bundled) |

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Test your changes with the GUI
4. Build and test the AppImage: `./build_appimage.sh`
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## 📜 License

This project is licensed under the same license as the main Storage Analyzer project.

## 🙏 Acknowledgments

- **Swift Design**: Inspired by Apple's design language
- **AppImage**: Thanks to the AppImage project for portable Linux apps
- **Python tkinter**: For providing a capable GUI framework
- **Icons**: Custom SVG icon design