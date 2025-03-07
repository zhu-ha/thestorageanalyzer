import os
import ctypes
import sys

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except Exception:
        return False

def bytes_to_unit(b, unit):
    if unit.upper() == "GB":
        return b / (1024 ** 3)
    elif unit.upper() == "MB":
        return b / (1024 ** 2)
    else:
        return b

def get_directory_size(path):
    total = 0
    try:
        for entry in os.scandir(path):
            try:
                if entry.is_file():
                    total += entry.stat().st_size
                elif entry.is_dir(follow_symlinks=False):
                    total += get_directory_size(entry.path)
            except Exception:
                continue
    except Exception:
        pass
    return total

def list_subdirectories(path):
    dirs = []
    try:
        for entry in os.scandir(path):
            if entry.is_dir(follow_symlinks=False):
                size = get_directory_size(entry.path)
                dirs.append((entry.name, entry.path, size))
    except Exception as e:
        print(f"Error scanning {path}: {e}")
    return dirs

def interactive_scan(initial_path, unit):
    current_path = initial_path
    history = []
    while True:
        print(f"\nCurrent directory: {current_path}")
        print("Calculating sizes for subdirectories... (this may take a while)")
        subdirs = list_subdirectories(current_path)
        filtered_subdirs = []
        for d in subdirs:
            size_conv = bytes_to_unit(d[2], unit)
            if size_conv >= 0.01:
                filtered_subdirs.append((d[0], d[1], d[2]))
        if not filtered_subdirs:
            print("No subdirectories found (or none above the display threshold) in this directory.")
        else:
            filtered_subdirs.sort(key=lambda x: x[2], reverse=True)
            for idx, (name, full_path, size) in enumerate(filtered_subdirs, start=1):
                print(f"{idx}. {name}: {bytes_to_unit(size, unit):.2f} {unit}")
        print("\nOptions:")
        print("  0. Exit")
        if history:
            print("  b. Go back")
        print("  c. Change starting directory")
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
                current_path = new_path
            else:
                print("Invalid directory. Staying in current directory.")
        else:
            try:
                idx = int(choice)
                if 1 <= idx <= len(filtered_subdirs):
                    history.append(current_path)
                    current_path = filtered_subdirs[idx - 1][1]
                else:
                    print("Invalid selection number.")
            except ValueError:
                print("Please enter a valid number, 'b' to go back, or 'c' to change directory.")

if __name__ == "__main__":
    if not is_admin():
        print("WARNING: For a deeper scan (and access to restricted folders), please run this script as an administrator.")
        cont = input("Do you want to continue anyway? (y/N): ").strip().lower()
        if cont != "y":
            print("Exiting. Please run as administrator for full functionality.")
            sys.exit(1)
    unit_choice = input("Choose display unit - enter 1 for GB or 2 for MB: ").strip()
    if unit_choice == "1":
        unit = "GB"
    elif unit_choice == "2":
        unit = "MB"
    else:
        print("Invalid choice. Defaulting to GB.")
        unit = "GB"
    start_dir = input("Enter starting directory path (or press Enter for C:\\): ").strip()
    if not start_dir:
        start_dir = "C:\\"
    elif not os.path.exists(start_dir) or not os.path.isdir(start_dir):
        print("Invalid directory, defaulting to C:\\")
        start_dir = "C:\\"
    interactive_scan(start_dir, unit)

