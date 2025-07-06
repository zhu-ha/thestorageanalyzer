# Storage Analyzer - Arch Linux Transparent Edition

A modern, transparent Swift-style GUI storage analyzer specifically designed for Arch Linux, featuring glass effects and excellent readability.

![Arch Linux Edition](storage-analyzer-arch.svg)

## 🎨 Design Philosophy

### Transparent Interface with Perfect Readability
- **Glass Effect UI**: Semi-transparent backgrounds with subtle blur effects
- **High Contrast Text**: Black text on light transparent backgrounds for maximum readability
- **Swift Color Palette**: Authentic iOS/macOS colors combined with Arch Linux blue
- **Modern Typography**: Optimized for Arch Linux fonts (Noto Sans, Liberation Sans, JetBrains Mono)

### Arch Linux Integration
- **Pacman Cache Monitoring**: Real-time tracking of package cache size
- **Arch Blue Branding**: Official Arch Linux color scheme (#1793d1)
- **System Integration**: Native file manager and clipboard integration
- **Arch-Specific Optimizations**: Tuned for common Arch Linux configurations

## ✨ Unique Features

### 🪟 Transparent Glass Interface
- **96% Window Transparency**: Subtle transparency for modern appearance
- **Glass Cards**: UI elements with glass-like semi-transparent backgrounds
- **Readability First**: High contrast text (#000000) on light transparent backgrounds
- **Hover Effects**: Interactive elements with smooth transitions
- **Borders & Shadows**: Subtle visual cues for better element definition

### ⚡ Arch Linux Specific
- **Pacman Integration**: Monitors `/var/cache/pacman/pkg` size
- **Arch Branding**: Lightning bolt icon and Arch blue accents
- **Font Detection**: Automatically uses best available fonts on Arch
- **System Optimization**: Leverages Arch Linux file system features

### 🎯 Advanced Navigation
- **Context Menus**: Right-click for "Open in File Manager", "Copy Path", "Analyze"
- **Glass Buttons**: All navigation buttons with glass effect and hover states
- **Quick Actions**: Home, Root, Parent, Back navigation
- **Browse Dialog**: Native Arch Linux file picker integration
- **Keyboard Shortcuts**: Standard shortcuts for power users

### 📊 Enhanced Visualization
- **Tree View**: Clean directory listing with 4 columns (Name, Size, Type, Permission)
- **Visual Indicators**: 📁 for accessible, 🔒 for restricted directories
- **Size Categorization**: Color-coded backgrounds for large/restricted directories
- **Real-time Stats**: Live file and directory counts in footer

## 🔧 Technical Architecture

### Transparency Implementation
```python
# Window transparency with optimal readability
self.root.attributes('-alpha', 0.96)  # 96% opacity

# Glass effect backgrounds
'card_bg_transparent': '#ffffffe6',   # White with transparency
'glass_light': '#ffffff40',           # Light glass effect
'text_primary': '#000000',           # High contrast black text
```

### Color System
```python
# Arch Linux + Swift color palette
colors = {
    'arch_blue': '#1793d1',      # Official Arch blue
    'primary': '#007aff',        # Swift blue
    'accent': '#34c759',         # Swift green
    'warning': '#ff9500',        # Swift orange
    'text_primary': '#000000',   # Maximum readability
}
```

### Font Optimization
- **Priority Order**: SF Pro Display → Roboto → Noto Sans → DejaVu Sans → Liberation Sans
- **Fallback System**: Graceful degradation to available system fonts
- **Monospace**: JetBrains Mono for path display (common on Arch)

## 🛠️ Building the AppImage

### Prerequisites on Arch Linux

```bash
# Install required packages
sudo pacman -S python tk wget imagemagick

# Optional for better icon conversion
sudo pacman -S inkscape
```

### Build Process

1. **Clone and switch to branch:**
   ```bash
   git checkout appimage-arch-transparent
   chmod +x build_arch_appimage.sh launch_arch_transparent.sh
   ```

2. **Build the AppImage:**
   ```bash
   ./build_arch_appimage.sh
   ```

3. **Output:**
   ```
   📦 StorageAnalyzer-Arch-Transparent-1.0.0-x86_64.AppImage
   ```

## 🚀 Usage

### Running the AppImage

```bash
# Direct execution
./StorageAnalyzer-Arch-Transparent-1.0.0-x86_64.AppImage

# System installation
sudo mv StorageAnalyzer-Arch-Transparent-1.0.0-x86_64.AppImage /usr/local/bin/storage-analyzer-arch
storage-analyzer-arch
```

### Development Testing

```bash
# Quick test without building AppImage
./launch_arch_transparent.sh
```

### Interface Guide

#### 🏠 Left Panel - Navigation & System Info
- **Current Location**: Monospace path display with word wrapping
- **Quick Navigation**: 
  - 🏠 Home Directory
  - 📁 Root Filesystem  
  - ⬆️ Parent Directory
  - ↩️ Go Back
  - 📂 Browse Directories
- **System Information**:
  - 💾 Total space
  - 📊 Used space
  - 🆓 Free space
  - 📦 Pacman cache size (Arch-specific)

#### 📊 Right Panel - Directory Analysis
- **Header Controls**: Refresh and Clear Cache buttons
- **Directory Tree**: Sortable columns with icons
- **Loading States**: Animated progress indicators
- **Context Menu**: Right-click for advanced options

#### ⚡ Footer
- **Arch Branding**: "Built for Arch Linux" 
- **Live Statistics**: Current scan results

## 🎨 Visual Design Details

### Glass Effect Implementation
- **Background Opacity**: Semi-transparent whites (#ffffff40-80)
- **Border Highlighting**: Subtle white borders (#ffffff60)
- **Text Contrast**: Pure black (#000000) for maximum readability
- **Hover States**: Increased opacity on interaction

### Color Psychology
- **Arch Blue**: Trust, reliability, Linux heritage
- **Swift Colors**: Modern, approachable, professional
- **High Contrast**: Accessibility and readability first
- **Glass Effects**: Modern, lightweight, premium feel

### Typography Hierarchy
- **Title**: 28px bold (Storage Analyzer)
- **Headings**: 20px bold (Section titles)
- **Body**: 14px regular (Interface text)
- **Captions**: 12px (Metadata, stats)
- **Monospace**: Path display and technical info

## 🔍 Performance Optimizations

### Background Scanning
- **Non-blocking UI**: All directory scans in background threads
- **Progress Feedback**: Loading indicators and button states
- **Responsive Design**: UI remains interactive during scans
- **Memory Management**: Proper thread cleanup

### Arch Linux Optimizations
- **Pacman Cache**: Efficient size calculation
- **Font Detection**: Runtime font availability checking
- **System Integration**: Native file manager launching
- **Path Handling**: Optimized for Linux filesystem structure

## 🐛 Troubleshooting

### Common Issues

**"App won't start" or blank screen:**
```bash
# Check transparency support
xprop -root | grep compositor

# Disable transparency temporarily
sed -i 's/0.96/1.0/' storage_analyzer_arch_transparent.py
```

**Poor text readability:**
- Ensure you're using a light desktop background
- Check monitor brightness and contrast settings
- The app uses black text for maximum contrast

**Pacman cache not detected:**
```bash
# Check permissions
ls -la /var/cache/pacman/pkg
# Should be readable by user or try with sudo
```

**Font rendering issues:**
```bash
# Install better fonts
sudo pacman -S noto-fonts ttf-liberation ttf-jetbrains-mono
```

### Debug Mode

Run with environment variables for debugging:
```bash
export ARCH_STORAGE_ANALYZER_DEBUG=1
./launch_arch_transparent.sh
```

## 📊 Comparison Matrix

| Feature | CLI Version | Standard GUI | Arch Transparent |
|---------|-------------|--------------|------------------|
| Interface | Terminal | Opaque GUI | Transparent Glass |
| Arch Integration | ❌ | ❌ | ✅ Pacman Cache |
| Design Language | Text | Swift | Swift + Arch |
| Transparency | ❌ | ❌ | ✅ 96% with readability |
| Context Menus | ❌ | Basic | Advanced |
| Font Optimization | ❌ | Generic | Arch-specific |
| Performance | Fast | Good | Optimized |

## 🎯 Use Cases

### Perfect For
- **Arch Linux Users**: Native integration and branding
- **Modern Desktop Environments**: Complements transparent themes
- **Power Users**: Advanced navigation and context options
- **System Administrators**: Pacman cache monitoring

### Ideal Desktop Environments
- **KDE Plasma**: Full transparency support
- **GNOME**: Good integration with Activities
- **i3/Sway**: Excellent for tiling window managers
- **Xfce**: Works with compositor enabled

## 🤝 Contributing

### Development Setup
```bash
# Clone and switch to branch
git clone <repo-url>
cd <repo-directory>
git checkout appimage-arch-transparent

# Install development dependencies
sudo pacman -S python tk python-pip
pip install --user black pylint

# Test changes
./launch_arch_transparent.sh
```

### Design Guidelines
- **Maintain high contrast** for text readability
- **Preserve Arch Linux branding** in blue elements
- **Test transparency** on various backgrounds
- **Ensure glass effects** work without compositor

## 📜 License

This project follows the same license as the main Storage Analyzer project.

## 🙏 Acknowledgments

- **Arch Linux Community**: For the amazing distribution
- **Apple Design Team**: Swift/iOS design inspiration  
- **Python tkinter**: For enabling modern GUI development
- **AppImage Project**: For portable Linux app distribution
- **Glass UI Pioneers**: For establishing transparent design patterns

---

*Built with ⚡ for the Arch Linux community*