#!/usr/bin/env python3
import os
import sys
import pwd
import subprocess

def is_root():
    """Check if running as root user"""
    return os.geteuid() == 0

def has_read_access(path):
    """Check if we have read access to a directory"""
    try:
        return os.access(path, os.R_OK)
    except Exception:
        return False

def bytes_to_unit(b, unit):
    """Convert bytes to specified unit (GB, MB, KB)"""
    if unit.upper() == "GB":
        return b / (1024 ** 3)
    elif unit.upper() == "MB":
        return b / (1024 ** 2)
    elif unit.upper() == "KB":
        return b / 1024
    else:
        return b

def get_directory_size(path):
    """Recursively calculate directory size"""
    total = 0
    try:
        for entry in os.scandir(path):
            try:
                if entry.is_file(follow_symlinks=False):
                    total += entry.stat().st_size
                elif entry.is_dir(follow_symlinks=False):
                    total += get_directory_size(entry.path)
            except (PermissionError, OSError):
                # Skip directories/files we can't access
                continue
    except (PermissionError, OSError):
        pass
    return total

def list_subdirectories(path):
    """List subdirectories and their sizes"""
    dirs = []
    try:
        for entry in os.scandir(path):
            if entry.is_dir(follow_symlinks=False):
                try:
                    size = get_directory_size(entry.path)
                    dirs.append((entry.name, entry.path, size))
                except (PermissionError, OSError):
                    # Add with size 0 if we can't calculate
                    dirs.append((entry.name, entry.path, 0))
    except (PermissionError, OSError) as e:
        print(f"Error scanning {path}: {e}")
    return dirs

def get_filesystem_info(path):
    """Get filesystem information for the given path"""
    try:
        stat = os.statvfs(path)
        total_space = stat.f_blocks * stat.f_frsize
        free_space = stat.f_available * stat.f_frsize
        used_space = total_space - free_space
        return total_space, used_space, free_space
    except Exception:
        return None, None, None

def interactive_scan(initial_path, unit):
    """Interactive directory scanning with navigation"""
    current_path = initial_path
    history = []
    
    while True:
        print(f"\nCurrent directory: {current_path}")
        
        # Show filesystem info
        total, used, free = get_filesystem_info(current_path)
        if total:
            print(f"Filesystem: {bytes_to_unit(total, unit):.2f} {unit} total, "
                  f"{bytes_to_unit(used, unit):.2f} {unit} used, "
                  f"{bytes_to_unit(free, unit):.2f} {unit} free")
        
        print("Calculating sizes for subdirectories... (this may take a while)")
        subdirs = list_subdirectories(current_path)
        
        # Filter directories above threshold
        filtered_subdirs = []
        for d in subdirs:
            size_conv = bytes_to_unit(d[2], unit)
            if size_conv >= 0.01:
                filtered_subdirs.append((d[0], d[1], d[2]))
        
        if not filtered_subdirs:
            print("No subdirectories found (or none above the display threshold) in this directory.")
        else:
            filtered_subdirs.sort(key=lambda x: x[2], reverse=True)
            print(f"\nDirectories (showing top {len(filtered_subdirs)}):")
            for idx, (name, full_path, size) in enumerate(filtered_subdirs, start=1):
                size_display = bytes_to_unit(size, unit)
                # Add permission indicator
                perm_indicator = "🔒" if not has_read_access(full_path) else ""
                print(f"{idx:2d}. {name}: {size_display:>8.2f} {unit} {perm_indicator}")
        
        print("\nOptions:")
        print("  0. Exit")
        if history:
            print("  b. Go back")
        print("  c. Change starting directory")
        print("  h. Go to home directory")
        print("  r. Go to root directory")
        
        choice = input("Select a directory number to drill down, or an option: ").strip()
        
        if choice == "0":
            print("Exiting...")
            break
        elif choice.lower() == "b":
            if history:
                current_path = history.pop()
            else:
                print("Already at top level.")
        elif choice.lower() == "c":
            new_path = input("Enter new directory path: ").strip()
            if os.path.exists(new_path) and os.path.isdir(new_path):
                history = []
                current_path = os.path.abspath(new_path)
            else:
                print("Invalid directory. Staying in current directory.")
        elif choice.lower() == "h":
            home_dir = os.path.expanduser("~")
            history = []
            current_path = home_dir
        elif choice.lower() == "r":
            history = []
            current_path = "/"
        else:
            try:
                idx = int(choice)
                if 1 <= idx <= len(filtered_subdirs):
                    selected_path = filtered_subdirs[idx - 1][1]
                    if has_read_access(selected_path):
                        history.append(current_path)
                        current_path = selected_path
                    else:
                        print("Permission denied. Cannot access this directory.")
                else:
                    print("Invalid selection number.")
            except ValueError:
                print("Please enter a valid number, 'b' to go back, 'c' to change directory, 'h' for home, or 'r' for root.")

def main():
    """Main function"""
    print("=== Arch Linux Storage Analyzer ===")
    print("Interactive directory size scanner\n")
    
    if not is_root():
        print("INFO: Running as regular user. Some system directories may be inaccessible.")
        print("      Run with 'sudo' for full system access.")
        cont = input("Continue? (Y/n): ").strip().lower()
        if cont == "n":
            print("Exiting. Run with 'sudo python3 thestorageanalyzer_arch.py' for full access.")
            sys.exit(1)
    
    # Unit selection
    print("Choose display unit:")
    print("  1. GB (Gigabytes)")
    print("  2. MB (Megabytes)")
    print("  3. KB (Kilobytes)")
    unit_choice = input("Enter choice (1-3): ").strip()
    
    if unit_choice == "1":
        unit = "GB"
    elif unit_choice == "2":
        unit = "MB"
    elif unit_choice == "3":
        unit = "KB"
    else:
        print("Invalid choice. Defaulting to GB.")
        unit = "GB"
    
    # Starting directory selection
    print("\nStarting directory options:")
    print("  1. Root directory (/)")
    print("  2. Home directory (~)")
    print("  3. Custom path")
    
    start_choice = input("Enter choice (1-3): ").strip()
    
    if start_choice == "1":
        start_dir = "/"
    elif start_choice == "2":
        start_dir = os.path.expanduser("~")
    elif start_choice == "3":
        start_dir = input("Enter starting directory path: ").strip()
        if not start_dir:
            start_dir = os.path.expanduser("~")
    else:
        print("Invalid choice. Using home directory.")
        start_dir = os.path.expanduser("~")
    
    # Validate directory
    if not os.path.exists(start_dir) or not os.path.isdir(start_dir):
        print(f"Invalid directory '{start_dir}', using home directory")
        start_dir = os.path.expanduser("~")
    
    start_dir = os.path.abspath(start_dir)
    print(f"\nStarting analysis from: {start_dir}")
    
    interactive_scan(start_dir, unit)

if __name__ == "__main__":
    main()