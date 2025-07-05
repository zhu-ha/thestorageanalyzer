#!/bin/bash
set -e

# Storage Analyzer AppImage Build Script
echo "🔨 Building Storage Analyzer AppImage..."

# Configuration
APP_NAME="StorageAnalyzer"
APP_VERSION="1.0.0"
ARCH=$(uname -m)
BUILD_DIR="AppDir"
PYTHON_VERSION="3.11"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
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

# Check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed"
        exit 1
    fi
    
    if ! command -v wget &> /dev/null; then
        print_error "wget is required but not installed"
        exit 1
    fi
    
    # Check if we have tkinter
    if ! python3 -c "import tkinter" 2>/dev/null; then
        print_error "tkinter is required. Install with: sudo apt install python3-tk"
        exit 1
    fi
    
    print_success "All dependencies found"
}

# Download AppImageTool if not present
download_appimagetool() {
    if [ ! -f "appimagetool-${ARCH}.AppImage" ]; then
        print_status "Downloading AppImageTool..."
        wget -q "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-${ARCH}.AppImage"
        chmod +x "appimagetool-${ARCH}.AppImage"
        print_success "AppImageTool downloaded"
    else
        print_status "AppImageTool already present"
    fi
}

# Create AppDir structure
create_appdir() {
    print_status "Creating AppDir structure..."
    
    # Clean previous build
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    
    # Create standard directories
    mkdir -p "$BUILD_DIR/usr/bin"
    mkdir -p "$BUILD_DIR/usr/lib"
    mkdir -p "$BUILD_DIR/usr/share/applications"
    mkdir -p "$BUILD_DIR/usr/share/icons/hicolor/scalable/apps"
    mkdir -p "$BUILD_DIR/usr/share/pixmaps"
    
    print_success "AppDir structure created"
}

# Install Python portable
install_python_portable() {
    print_status "Setting up portable Python..."
    
    # Copy system Python (simplified approach)
    PYTHON_PATH=$(which python3)
    PYTHON_LIB_PATH=$(python3 -c "import sys; print(sys.path[1])")
    
    # Create Python directory
    mkdir -p "$BUILD_DIR/usr/bin"
    mkdir -p "$BUILD_DIR/usr/lib/python3"
    
    # Copy Python executable
    cp "$PYTHON_PATH" "$BUILD_DIR/usr/bin/"
    
    # Copy essential Python libraries
    if [ -d "/usr/lib/python3.*/tkinter" ]; then
        cp -r /usr/lib/python3.*/tkinter "$BUILD_DIR/usr/lib/python3/" 2>/dev/null || true
    fi
    
    print_success "Python setup completed"
}

# Copy application files
copy_app_files() {
    print_status "Copying application files..."
    
    # Copy main application
    cp storage_analyzer_gui.py "$BUILD_DIR/usr/bin/"
    chmod +x "$BUILD_DIR/usr/bin/storage_analyzer_gui.py"
    
    # Create launcher script
    cat > "$BUILD_DIR/usr/bin/storage_analyzer_gui" << 'EOF'
#!/bin/bash
APPDIR="$(dirname "$(readlink -f "${0}")")/../.."
export PYTHONPATH="${APPDIR}/usr/lib/python3:${PYTHONPATH}"
export PATH="${APPDIR}/usr/bin:${PATH}"
exec "${APPDIR}/usr/bin/python3" "${APPDIR}/usr/bin/storage_analyzer_gui.py" "$@"
EOF
    chmod +x "$BUILD_DIR/usr/bin/storage_analyzer_gui"
    
    # Copy desktop file
    cp storage-analyzer.desktop "$BUILD_DIR/usr/share/applications/"
    cp storage-analyzer.desktop "$BUILD_DIR/"
    
    # Convert SVG to PNG for icon (if available)
    if command -v convert &> /dev/null; then
        print_status "Converting SVG icon to PNG..."
        convert storage-analyzer.svg -resize 512x512 "$BUILD_DIR/usr/share/pixmaps/storage-analyzer.png"
        convert storage-analyzer.svg -resize 256x256 "$BUILD_DIR/usr/share/icons/hicolor/scalable/apps/storage-analyzer.png"
        cp "$BUILD_DIR/usr/share/pixmaps/storage-analyzer.png" "$BUILD_DIR/"
    elif command -v inkscape &> /dev/null; then
        print_status "Converting SVG icon to PNG with Inkscape..."
        inkscape storage-analyzer.svg --export-filename="$BUILD_DIR/usr/share/pixmaps/storage-analyzer.png" --export-width=512 --export-height=512
        inkscape storage-analyzer.svg --export-filename="$BUILD_DIR/usr/share/icons/hicolor/scalable/apps/storage-analyzer.png" --export-width=256 --export-height=256
        cp "$BUILD_DIR/usr/share/pixmaps/storage-analyzer.png" "$BUILD_DIR/"
    else
        print_warning "ImageMagick or Inkscape not found, copying SVG as icon"
        cp storage-analyzer.svg "$BUILD_DIR/storage-analyzer.svg"
        cp storage-analyzer.svg "$BUILD_DIR/usr/share/pixmaps/"
        # Update desktop file to use SVG
        sed -i 's/Icon=storage-analyzer/Icon=storage-analyzer.svg/' "$BUILD_DIR/storage-analyzer.desktop"
    fi
    
    print_success "Application files copied"
}

# Create AppRun
create_apprun() {
    print_status "Creating AppRun..."
    
    cat > "$BUILD_DIR/AppRun" << 'EOF'
#!/bin/bash
APPDIR="$(dirname "$(readlink -f "${0}")")"
export PYTHONPATH="${APPDIR}/usr/lib/python3:${PYTHONPATH}"
export PATH="${APPDIR}/usr/bin:${PATH}"

# Set up library paths
export LD_LIBRARY_PATH="${APPDIR}/usr/lib:${LD_LIBRARY_PATH}"

# Launch the application
exec "${APPDIR}/usr/bin/storage_analyzer_gui" "$@"
EOF
    
    chmod +x "$BUILD_DIR/AppRun"
    print_success "AppRun created"
}

# Build AppImage
build_appimage() {
    print_status "Building AppImage..."
    
    # Set ARCH environment variable for appimagetool
    export ARCH
    
    # Build the AppImage
    "./appimagetool-${ARCH}.AppImage" "$BUILD_DIR" "StorageAnalyzer-${APP_VERSION}-${ARCH}.AppImage"
    
    if [ -f "StorageAnalyzer-${APP_VERSION}-${ARCH}.AppImage" ]; then
        print_success "AppImage built successfully: StorageAnalyzer-${APP_VERSION}-${ARCH}.AppImage"
        
        # Make it executable
        chmod +x "StorageAnalyzer-${APP_VERSION}-${ARCH}.AppImage"
        
        # Show file info
        ls -lh "StorageAnalyzer-${APP_VERSION}-${ARCH}.AppImage"
    else
        print_error "Failed to build AppImage"
        exit 1
    fi
}

# Test the AppImage
test_appimage() {
    print_status "Testing AppImage..."
    
    if [ -f "StorageAnalyzer-${APP_VERSION}-${ARCH}.AppImage" ]; then
        print_status "AppImage created successfully!"
        print_status "You can now run: ./StorageAnalyzer-${APP_VERSION}-${ARCH}.AppImage"
        print_status "Or install it system-wide by moving it to /usr/local/bin/"
    fi
}

# Main build process
main() {
    echo "╔══════════════════════════════════════════╗"
    echo "║         Storage Analyzer AppImage        ║"
    echo "║              Build Script                ║"
    echo "╚══════════════════════════════════════════╝"
    echo
    
    check_dependencies
    download_appimagetool
    create_appdir
    install_python_portable
    copy_app_files
    create_apprun
    build_appimage
    test_appimage
    
    echo
    print_success "Build completed successfully! 🎉"
    echo
    echo "📦 AppImage: StorageAnalyzer-${APP_VERSION}-${ARCH}.AppImage"
    echo "🚀 Run with: ./StorageAnalyzer-${APP_VERSION}-${ARCH}.AppImage"
    echo
}

# Run main function
main "$@"