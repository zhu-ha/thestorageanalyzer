# Arch Linux Storage Analyzer

An interactive directory size scanner specifically designed for Arch Linux systems.

## Features

- **Interactive Navigation**: Browse directories interactively with drill-down capability
- **Multiple Units**: Display sizes in GB, MB, or KB
- **Filesystem Info**: Shows total, used, and free space for the current filesystem
- **Permission Awareness**: Indicates directories with restricted access (🔒)
- **Linux-Specific**: Optimized for Linux filesystem structure and permissions
- **Navigation Options**: Quick jump to root (`/`) or home directory (`~`)

## Usage

### Basic Usage
```bash
python3 thestorageanalyzer_arch.py
```

### With Full System Access
```bash
sudo python3 thestorageanalyzer_arch.py
```

## Key Differences from Windows Version

- **Root Check**: Uses `os.geteuid()` instead of Windows admin check
- **Default Paths**: Uses Linux paths (`/` for root, `~` for home)
- **Permission Handling**: Proper Linux permission checking with `os.access()`
- **Filesystem Info**: Uses `os.statvfs()` for Linux filesystem statistics
- **Error Handling**: Handles `PermissionError` and `OSError` appropriately

## Interactive Commands

- **0**: Exit the program
- **b**: Go back to previous directory
- **c**: Change to custom directory path
- **h**: Go to home directory
- **r**: Go to root directory
- **1-N**: Enter numbered directory

## Requirements

- Python 3.x
- Standard library only (no external dependencies)

## Installation on Arch Linux

```bash
# Clone or download the script
git clone <repository-url>
cd <repository-directory>

# Make executable
chmod +x thestorageanalyzer_arch.py

# Run directly
./thestorageanalyzer_arch.py

# Or with python3
python3 thestorageanalyzer_arch.py
```

## Tips

- Run with `sudo` for full system access
- Use KB units for detailed analysis of smaller directories
- The 🔒 symbol indicates directories you don't have permission to access
- Large directories (like `/usr` or `/var`) may take time to calculate

## Common Starting Points

- `/` - Analyze entire system
- `~` - Analyze your home directory
- `/var` - Check system logs and data
- `/usr` - Check installed software
- `/home` - Check all user directories (requires sudo)