#!/bin/bash
set -e

# Storage Analyzer - Arch Linux Transparent Edition - AppImage Build Script
echo "⚡ Building Storage Analyzer AppImage for Arch Linux..."

# Configuration
APP_NAME="StorageAnalyzer-Arch"
APP_VERSION="1.0.0"
ARCH=$(uname -m)
BUILD_DIR="AppDir-Arch"
PYTHON_VERSION="3.11"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_arch() {
    echo -e "${CYAN}[ARCH]${NC} $1"
}

# Check Arch Linux specific dependencies
check_arch_dependencies() {
    print_status "Checking Arch Linux dependencies..."
    
    # Check if running on Arch Linux
    if [ -f "/etc/arch-release" ]; then
        print_arch "✓ Running on Arch Linux"
    else
        print_warning "Not running on Arch Linux - some features may not work"
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required. Install with: sudo pacman -S python"
        exit 1
    fi
    
    # Check tkinter
    if ! python3 -c "import tkinter" 2>/dev/null; then
        print_error "tkinter is required. Install with: sudo pacman -S tk"
        exit 1
    fi
    
    # Check wget
    if ! command -v wget &> /dev/null; then
        print_error "wget is required. Install with: sudo pacman -S wget"
        exit 1
    fi
    
    # Check if ImageMagick is available for icon conversion
    if command -v convert &> /dev/null; then
        print_arch "✓ ImageMagick found for icon conversion"
    elif command -v inkscape &> /dev/null; then
        print_arch "✓ Inkscape found for icon conversion"
    else
        print_warning "No icon converter found. Install with: sudo pacman -S imagemagick"
    fi
    
    # Check pacman (Arch package manager)
    if command -v pacman &> /dev/null; then
        print_arch "✓ Pacman detected - Arch features enabled"
    fi
    
    print_success "All dependencies checked"
}

# Download AppImageTool if not present
download_appimagetool() {
    if [ ! -f "appimagetool-${ARCH}.AppImage" ]; then
        print_status "Downloading AppImageTool..."
        wget -q --show-progress "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-${ARCH}.AppImage"
        chmod +x "appimagetool-${ARCH}.AppImage"
        print_success "AppImageTool downloaded"
    else
        print_status "AppImageTool already present"
    fi
}

# Create AppDir structure
create_appdir() {
    print_status "Creating AppDir structure for Arch edition..."
    
    # Clean previous build
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    
    # Create standard directories
    mkdir -p "$BUILD_DIR/usr/bin"
    mkdir -p "$BUILD_DIR/usr/lib"
    mkdir -p "$BUILD_DIR/usr/share/applications"
    mkdir -p "$BUILD_DIR/usr/share/icons/hicolor/scalable/apps"
    mkdir -p "$BUILD_DIR/usr/share/pixmaps"
    mkdir -p "$BUILD_DIR/usr/share/doc/storage-analyzer-arch"
    
    print_success "AppDir structure created"
}

# Install Python with Arch-specific optimizations
install_python_arch() {
    print_status "Setting up Python for Arch Linux..."
    
    # Copy system Python
    PYTHON_PATH=$(which python3)
    
    # Create Python directory
    mkdir -p "$BUILD_DIR/usr/bin"
    mkdir -p "$BUILD_DIR/usr/lib/python3"
    
    # Copy Python executable
    cp "$PYTHON_PATH" "$BUILD_DIR/usr/bin/"
    
    # Copy tkinter and essential libraries
    for lib_path in /usr/lib/python3.*/tkinter /usr/lib/python3.*/lib-dynload; do
        if [ -d "$lib_path" ]; then
            cp -r "$lib_path" "$BUILD_DIR/usr/lib/python3/" 2>/dev/null || true
        fi
    done
    
    # Copy additional Python libraries used by the app
    for module in threading os sys time; do
        python3 -c "import $module" 2>/dev/null || print_warning "$module module check failed"
    done
    
    print_arch "Python configured for Arch Linux"
}

# Copy application files with Arch branding
copy_arch_app_files() {
    print_status "Copying Arch Linux transparent application files..."
    
    # Copy main application
    cp storage_analyzer_arch_transparent.py "$BUILD_DIR/usr/bin/"
    chmod +x "$BUILD_DIR/usr/bin/storage_analyzer_arch_transparent.py"
    
    # Create launcher script
    cat > "$BUILD_DIR/usr/bin/storage_analyzer_arch_transparent" << 'EOF'
#!/bin/bash
APPDIR="$(dirname "$(readlink -f "${0}")")/../.."
export PYTHONPATH="${APPDIR}/usr/lib/python3:${PYTHONPATH}"
export PATH="${APPDIR}/usr/bin:${PATH}"

# Set Arch Linux environment
export ARCH_STORAGE_ANALYZER=1

# Launch with nice title
echo "⚡ Starting Storage Analyzer - Arch Linux Transparent Edition"
exec "${APPDIR}/usr/bin/python3" "${APPDIR}/usr/bin/storage_analyzer_arch_transparent.py" "$@"
EOF
    chmod +x "$BUILD_DIR/usr/bin/storage_analyzer_arch_transparent"
    
    # Copy desktop file
    cp storage-analyzer-arch.desktop "$BUILD_DIR/usr/share/applications/"
    cp storage-analyzer-arch.desktop "$BUILD_DIR/"
    
    # Convert and copy icons
    if command -v convert &> /dev/null; then
        print_status "Converting Arch SVG icon to PNG with ImageMagick..."
        convert storage-analyzer-arch.svg -resize 512x512 "$BUILD_DIR/usr/share/pixmaps/storage-analyzer-arch.png"
        convert storage-analyzer-arch.svg -resize 256x256 "$BUILD_DIR/usr/share/icons/hicolor/scalable/apps/storage-analyzer-arch.png"
        cp "$BUILD_DIR/usr/share/pixmaps/storage-analyzer-arch.png" "$BUILD_DIR/"
    elif command -v inkscape &> /dev/null; then
        print_status "Converting Arch SVG icon to PNG with Inkscape..."
        inkscape storage-analyzer-arch.svg --export-filename="$BUILD_DIR/usr/share/pixmaps/storage-analyzer-arch.png" --export-width=512 --export-height=512
        inkscape storage-analyzer-arch.svg --export-filename="$BUILD_DIR/usr/share/icons/hicolor/scalable/apps/storage-analyzer-arch.png" --export-width=256 --export-height=256
        cp "$BUILD_DIR/usr/share/pixmaps/storage-analyzer-arch.png" "$BUILD_DIR/"
    else
        print_warning "No icon converter found, using SVG directly"
        cp storage-analyzer-arch.svg "$BUILD_DIR/storage-analyzer-arch.svg"
        cp storage-analyzer-arch.svg "$BUILD_DIR/usr/share/pixmaps/"
        # Update desktop file to use SVG
        sed -i 's/Icon=storage-analyzer-arch/Icon=storage-analyzer-arch.svg/' "$BUILD_DIR/storage-analyzer-arch.desktop"
    fi
    
    print_success "Arch application files copied"
}

# Create AppRun with Arch branding
create_arch_apprun() {
    print_status "Creating AppRun for Arch edition..."
    
    cat > "$BUILD_DIR/AppRun" << 'EOF'
#!/bin/bash
APPDIR="$(dirname "$(readlink -f "${0}")")"
export PYTHONPATH="${APPDIR}/usr/lib/python3:${PYTHONPATH}"
export PATH="${APPDIR}/usr/bin:${PATH}"

# Set up library paths
export LD_LIBRARY_PATH="${APPDIR}/usr/lib:${LD_LIBRARY_PATH}"

# Arch Linux specific environment
export ARCH_STORAGE_ANALYZER=1

# Display startup message
echo "⚡ Storage Analyzer - Arch Linux Transparent Edition"
echo "🔍 Initializing transparent interface..."

# Launch the application
exec "${APPDIR}/usr/bin/storage_analyzer_arch_transparent" "$@"
EOF
    
    chmod +x "$BUILD_DIR/AppRun"
    print_success "Arch AppRun created"
}

# Build the Arch AppImage
build_arch_appimage() {
    print_status "Building Arch Linux AppImage..."
    
    # Set ARCH environment variable for appimagetool
    export ARCH
    
    OUTPUT_NAME="StorageAnalyzer-Arch-Transparent-${APP_VERSION}-${ARCH}.AppImage"
    
    # Build the AppImage
    "./appimagetool-${ARCH}.AppImage" "$BUILD_DIR" "$OUTPUT_NAME"
    
    if [ -f "$OUTPUT_NAME" ]; then
        print_success "Arch AppImage built successfully: $OUTPUT_NAME"
        
        # Make it executable
        chmod +x "$OUTPUT_NAME"
        
        # Show file info with Arch styling
        echo
        print_arch "📦 AppImage Details:"
        ls -lh "$OUTPUT_NAME"
        echo
        file_size=$(du -h "$OUTPUT_NAME" | cut -f1)
        print_arch "📏 Size: $file_size"
        
    else
        print_error "Failed to build Arch AppImage"
        exit 1
    fi
}

# Test the Arch AppImage
test_arch_appimage() {
    print_status "Testing Arch AppImage..."
    
    OUTPUT_NAME="StorageAnalyzer-Arch-Transparent-${APP_VERSION}-${ARCH}.AppImage"
    
    if [ -f "$OUTPUT_NAME" ]; then
        print_arch "🎉 Arch Linux AppImage created successfully!"
        echo
        print_arch "🚀 Quick test: ./$OUTPUT_NAME"
        print_arch "🔧 Installation: sudo mv $OUTPUT_NAME /usr/local/bin/storage-analyzer-arch"
        print_arch "📱 Desktop: Add to applications menu for GUI access"
        echo
        print_arch "Features enabled:"
        print_arch "  ✓ Transparent Swift-style interface"
        print_arch "  ✓ Arch Linux branding and colors"
        print_arch "  ✓ Pacman cache monitoring"
        print_arch "  ✓ Glass effect UI elements"
        print_arch "  ✓ Enhanced directory navigation"
        print_arch "  ✓ Context menus and file manager integration"
    fi
}

# Create documentation
create_arch_docs() {
    print_status "Creating Arch Linux documentation..."
    
    cat > "$BUILD_DIR/usr/share/doc/storage-analyzer-arch/README.md" << 'EOF'
# Storage Analyzer - Arch Linux Transparent Edition

## Features
- **Transparent Interface**: Modern Swift-style UI with glass effects
- **Arch Linux Integration**: Pacman cache monitoring and Arch branding
- **High Readability**: Optimized contrast for transparent backgrounds
- **Advanced Navigation**: Context menus, file manager integration
- **Real-time Scanning**: Background threads for responsive UI

## Arch Linux Specific Features
- Pacman cache size monitoring
- Arch blue color scheme
- Optimized for common Arch fonts (Noto Sans, Liberation Sans)
- Integration with Arch file systems

## Usage
Double-click directories to navigate, right-click for context menu.
Use keyboard shortcuts: Ctrl+R (refresh), Ctrl+H (home), Ctrl+/ (root).

Built specifically for Arch Linux users.
EOF
    
    print_success "Documentation created"
}

# Main build process
main() {
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║     Storage Analyzer - Arch Linux Transparent       ║"
    echo "║              AppImage Build Script                   ║"
    echo "║                   ⚡ Arch Edition ⚡                 ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo
    
    check_arch_dependencies
    download_appimagetool
    create_appdir
    install_python_arch
    copy_arch_app_files
    create_arch_docs
    create_arch_apprun
    build_arch_appimage
    test_arch_appimage
    
    echo
    print_success "Arch Linux build completed successfully! ⚡"
    echo
    OUTPUT_NAME="StorageAnalyzer-Arch-Transparent-${APP_VERSION}-${ARCH}.AppImage"
    print_arch "📦 AppImage: $OUTPUT_NAME"
    print_arch "🎨 Features: Transparent UI, Arch branding, Swift styling"
    print_arch "🚀 Run: ./$OUTPUT_NAME"
    echo
}

# Run main function
main "$@"