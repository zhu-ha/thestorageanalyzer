#!/usr/bin/env python3
"""
Storage Analyzer - Arch Linux Transparent GUI
Swift-style interface with transparent background and excellent readability
"""

import os
import sys
import threading
import time
from tkinter import *
from tkinter import ttk, messagebox, filedialog
import tkinter.font as tkfont

class ArchTransparentStorageAnalyzer:
    def __init__(self):
        self.root = Tk()
        self.root.title("Storage Analyzer - Arch Linux")
        self.root.geometry("1300x900")
        
        # Enable transparency and modern styling
        self.setup_transparent_window()
        
        # Modern font setup
        self.setup_fonts()
        
        # Arch Linux + Swift-style colors with transparency
        self.colors = {
            # Transparent backgrounds
            'bg_transparent': '#f5f5f7e6',  # Light gray with transparency
            'card_bg_transparent': '#ffffffe6',  # White with transparency
            'dark_bg_transparent': '#1d1d1fe6',  # Dark with transparency
            
            # Swift colors
            'primary': '#007aff',
            'secondary': '#8e8e93',
            'accent': '#34c759',
            'warning': '#ff9500',
            'danger': '#ff3b30',
            
            # Arch Linux blue
            'arch_blue': '#1793d1',
            'arch_dark': '#0f2835',
            
            # Text colors with high contrast
            'text_primary': '#000000',  # Black for readability
            'text_secondary': '#4d4d4d',  # Dark gray
            'text_light': '#ffffff',  # White text
            'text_shadow': '#00000080',  # Shadow for text
            
            # Glass effect colors
            'glass_light': '#ffffff40',  # Light glass
            'glass_dark': '#00000020',   # Dark glass
            'border_glass': '#ffffff60',  # Glass border
        }
        
        # Data storage
        self.current_path = os.path.expanduser("~")
        self.history = []
        self.current_unit = "GB"
        self.scanning = False
        
        self.setup_ui()
        self.refresh_data()
    
    def setup_transparent_window(self):
        """Setup transparent window with modern effects"""
        # Set window attributes for transparency
        self.root.configure(bg='#f5f5f7')
        self.root.attributes('-alpha', 0.96)  # Slight transparency
        
        # Try to enable blur on supported systems
        try:
            # Linux window manager hints
            self.root.attributes('-type', 'dialog')
        except:
            pass
        
        # Remove window decorations for modern look (optional)
        # self.root.overrideredirect(True)
    
    def setup_fonts(self):
        """Setup modern font families with Arch Linux preferences"""
        # Arch Linux commonly has these fonts
        font_families = ['SF Pro Display', 'Roboto', 'Noto Sans', 'DejaVu Sans', 'Liberation Sans']
        
        available_font = 'Liberation Sans'  # Fallback
        for font in font_families:
            try:
                test_font = tkfont.Font(family=font, size=12)
                test_font.configure()
                available_font = font
                break
            except:
                continue
        
        self.fonts = {
            'title': tkfont.Font(family=available_font, size=28, weight='bold'),
            'heading': tkfont.Font(family=available_font, size=20, weight='bold'),
            'body': tkfont.Font(family=available_font, size=14),
            'body_medium': tkfont.Font(family=available_font, size=14, weight='bold'),
            'caption': tkfont.Font(family=available_font, size=12),
            'small': tkfont.Font(family=available_font, size=10),
            'mono': tkfont.Font(family='JetBrains Mono', size=12) if self.font_exists('JetBrains Mono') else tkfont.Font(family='monospace', size=12)
        }
    
    def font_exists(self, font_name):
        """Check if a font exists on the system"""
        try:
            test_font = tkfont.Font(family=font_name, size=12)
            test_font.configure()
            return True
        except:
            return False
    
    def setup_ui(self):
        """Create the transparent Swift-style interface"""
        # Main container with transparent background
        main_frame = Frame(self.root, bg='#f5f5f7')
        main_frame.pack(fill=BOTH, expand=True, padx=0, pady=0)
        
        # Header section with glass effect
        self.create_header(main_frame)
        
        # Content area with transparency
        content_frame = Frame(main_frame, bg='#f5f5f7')
        content_frame.pack(fill=BOTH, expand=True, padx=20, pady=10)
        
        # Left panel (navigation and controls)
        self.create_left_panel(content_frame)
        
        # Right panel (directory listing)
        self.create_right_panel(content_frame)
        
        # Footer with Arch Linux branding
        self.create_footer(main_frame)
    
    def create_glass_frame(self, parent, bg_color='#ffffff40'):
        """Create a frame with glass/blur effect"""
        frame = Frame(parent, bg=bg_color, relief=FLAT, bd=0)
        # Add subtle border for glass effect
        frame.configure(highlightbackground='#ffffff60', highlightthickness=1)
        return frame
    
    def create_header(self, parent):
        """Create the header with glass effect and Arch branding"""
        header_frame = self.create_glass_frame(parent, '#ffffff50')
        header_frame.pack(fill=X, padx=20, pady=20)
        
        # Header content with padding
        header_content = Frame(header_frame, bg='#ffffff50')
        header_content.pack(fill=X, padx=25, pady=20)
        
        # Arch Linux logo and title
        title_frame = Frame(header_content, bg='#ffffff50')
        title_frame.pack(side=LEFT)
        
        # Arch logo (text-based)
        arch_label = Label(title_frame, text="⚡", font=self.fonts['title'], 
                          fg=self.colors['arch_blue'], bg='#ffffff50')
        arch_label.pack(side=LEFT, padx=(0, 10))
        
        # Title with shadow effect
        title_label = Label(title_frame, text="Storage Analyzer", 
                           font=self.fonts['title'], fg=self.colors['text_primary'],
                           bg='#ffffff50')
        title_label.pack(side=LEFT)
        
        # Subtitle
        subtitle_label = Label(title_frame, text="Arch Linux Edition", 
                              font=self.fonts['caption'], fg=self.colors['arch_blue'],
                              bg='#ffffff50')
        subtitle_label.pack(side=LEFT, padx=(10, 0))
        
        # Controls on the right
        controls_frame = Frame(header_content, bg='#ffffff50')
        controls_frame.pack(side=RIGHT)
        
        # Unit selector with glass effect
        unit_frame = self.create_glass_frame(controls_frame, '#ffffff70')
        unit_frame.pack(side=RIGHT)
        
        Label(unit_frame, text="Display unit:", font=self.fonts['body'],
              fg=self.colors['text_primary'], bg='#ffffff70').pack(side=LEFT, padx=(15, 10), pady=10)
        
        self.unit_var = StringVar(value=self.current_unit)
        unit_menu = ttk.Combobox(unit_frame, textvariable=self.unit_var, 
                                values=["GB", "MB", "KB"], state="readonly", width=6,
                                font=self.fonts['body'])
        unit_menu.pack(side=RIGHT, padx=15, pady=10)
        unit_menu.bind('<<ComboboxSelected>>', self.on_unit_changed)
        
        # Style the combobox for transparency
        style = ttk.Style()
        style.configure('TCombobox', fieldbackground='#ffffff90', borderwidth=0)
    
    def create_left_panel(self, parent):
        """Create the left navigation panel with glass effect"""
        left_frame = self.create_glass_frame(parent, '#ffffff45')
        left_frame.configure(width=320)
        left_frame.pack(side=LEFT, fill=Y, padx=(0, 15))
        left_frame.pack_propagate(False)
        
        # Path section with enhanced visibility
        path_section = Frame(left_frame, bg='#ffffff45')
        path_section.pack(fill=X, padx=20, pady=20)
        
        # Section title with Arch blue
        path_title = Label(path_section, text="📍 Current Location", 
                          font=self.fonts['heading'], fg=self.colors['arch_blue'],
                          bg='#ffffff45')
        path_title.pack(anchor=W)
        
        # Path display with high contrast background
        path_frame = self.create_glass_frame(path_section, '#ffffff80')
        path_frame.pack(fill=X, pady=(15, 0))
        
        self.path_label = Label(path_frame, text=self.current_path, 
                               font=self.fonts['mono'], fg=self.colors['text_primary'],
                               bg='#ffffff80', wraplength=280, justify=LEFT, anchor=W)
        self.path_label.pack(padx=15, pady=12, anchor=W)
        
        # Navigation buttons with Arch styling
        nav_section = Frame(left_frame, bg='#ffffff45')
        nav_section.pack(fill=X, padx=20, pady=(15, 20))
        
        Label(nav_section, text="🚀 Quick Navigation", 
              font=self.fonts['heading'], fg=self.colors['arch_blue'],
              bg='#ffffff45').pack(anchor=W, pady=(0, 15))
        
        nav_buttons = [
            ("🏠 Home Directory", self.go_home, self.colors['primary']),
            ("📁 Root Filesystem", self.go_root, self.colors['arch_blue']),
            ("⬆️ Parent Directory", self.go_up, self.colors['secondary']),
            ("↩️ Go Back", self.go_back, self.colors['secondary'])
        ]
        
        for text, command, color in nav_buttons:
            btn = self.create_glass_button(nav_section, text, command, color)
            btn.pack(fill=X, pady=3)
        
        # Browse button with special styling
        browse_btn = self.create_glass_button(nav_section, "📂 Browse Directories", 
                                            self.browse_folder, self.colors['accent'])
        browse_btn.pack(fill=X, pady=(15, 0))
        
        # Arch system info section
        self.create_arch_system_info(left_frame)
    
    def create_right_panel(self, parent):
        """Create the right panel with directory listing"""
        right_frame = self.create_glass_frame(parent, '#ffffff40')
        right_frame.pack(side=RIGHT, fill=BOTH, expand=True)
        
        # Header with controls
        list_header = Frame(right_frame, bg='#ffffff40')
        list_header.pack(fill=X, padx=25, pady=(25, 15))
        
        # Title with icon
        title_frame = Frame(list_header, bg='#ffffff40')
        title_frame.pack(side=LEFT)
        
        Label(title_frame, text="📊 Directory Analysis", 
              font=self.fonts['heading'], fg=self.colors['arch_blue'],
              bg='#ffffff40').pack(side=LEFT)
        
        # Control buttons
        controls_frame = Frame(list_header, bg='#ffffff40')
        controls_frame.pack(side=RIGHT)
        
        self.refresh_btn = self.create_glass_button(controls_frame, "🔄 Refresh", 
                                                   self.refresh_data, self.colors['primary'])
        self.refresh_btn.pack(side=RIGHT, padx=(10, 0))
        
        # Clear cache button
        clear_btn = self.create_glass_button(controls_frame, "🗑️ Clear Cache", 
                                           self.clear_cache, self.colors['warning'])
        clear_btn.pack(side=RIGHT)
        
        # Loading indicator
        self.loading_frame = Frame(right_frame, bg='#ffffff40')
        self.loading_label = Label(self.loading_frame, text="⚡ Scanning directories...", 
                                  font=self.fonts['body'], fg=self.colors['arch_blue'],
                                  bg='#ffffff40')
        self.loading_label.pack(pady=25)
        
        # Directory listing with glass container
        list_container = self.create_glass_frame(right_frame, '#ffffff70')
        list_container.pack(fill=BOTH, expand=True, padx=25, pady=(0, 25))
        
        # Directory tree
        self.create_directory_tree(list_container)
    
    def create_directory_tree(self, parent):
        """Create the directory tree view with enhanced styling"""
        tree_frame = Frame(parent, bg='#ffffff70')
        tree_frame.pack(fill=BOTH, expand=True, padx=2, pady=2)
        
        # Columns
        columns = ('Name', 'Size', 'Type', 'Permission')
        self.tree = ttk.Treeview(tree_frame, columns=columns, show='tree headings', height=22)
        
        # Configure columns
        self.tree.heading('#0', text='🗂️', anchor=W)
        self.tree.heading('Name', text='Directory Name', anchor=W)
        self.tree.heading('Size', text='Size', anchor=E)
        self.tree.heading('Type', text='Type', anchor=W)
        self.tree.heading('Permission', text='Access', anchor=W)
        
        self.tree.column('#0', width=60, minwidth=60)
        self.tree.column('Name', width=350, minwidth=250)
        self.tree.column('Size', width=120, minwidth=100)
        self.tree.column('Type', width=100, minwidth=80)
        self.tree.column('Permission', width=100, minwidth=80)
        
        # Scrollbars with styling
        v_scrollbar = ttk.Scrollbar(tree_frame, orient=VERTICAL, command=self.tree.yview)
        h_scrollbar = ttk.Scrollbar(tree_frame, orient=HORIZONTAL, command=self.tree.xview)
        self.tree.configure(yscrollcommand=v_scrollbar.set, xscrollcommand=h_scrollbar.set)
        
        # Pack scrollbars and tree
        v_scrollbar.pack(side=RIGHT, fill=Y)
        h_scrollbar.pack(side=BOTTOM, fill=X)
        self.tree.pack(side=LEFT, fill=BOTH, expand=True)
        
        # Bind events
        self.tree.bind('<Double-1>', self.on_directory_double_click)
        self.tree.bind('<Button-3>', self.show_context_menu)  # Right-click menu
        
        # Style the treeview for transparency
        style = ttk.Style()
        style.configure('Treeview', 
                       background='#ffffff90', 
                       foreground=self.colors['text_primary'],
                       fieldbackground='#ffffff90',
                       borderwidth=0)
        style.configure('Treeview.Heading', 
                       background='#ffffff95',
                       foreground=self.colors['text_primary'],
                       font=self.fonts['body_medium'],
                       borderwidth=1,
                       relief='solid')
        
        # Configure tag colors for different file types
        self.tree.tag_configure('large', background='#ff950020')
        self.tree.tag_configure('restricted', background='#ff3b3020')
        self.tree.tag_configure('normal', background='#ffffff00')
    
    def create_arch_system_info(self, parent):
        """Create Arch Linux specific system information"""
        sys_section = Frame(parent, bg='#ffffff45')
        sys_section.pack(fill=X, padx=20, pady=(0, 20))
        
        # Section title
        Label(sys_section, text="⚡ System Information", 
              font=self.fonts['heading'], fg=self.colors['arch_blue'],
              bg='#ffffff45').pack(anchor=W)
        
        # Info container with high contrast
        info_container = self.create_glass_frame(sys_section, '#ffffff80')
        info_container.pack(fill=X, pady=(15, 0))
        
        self.sys_info_frame = Frame(info_container, bg='#ffffff80')
        self.sys_info_frame.pack(fill=X, padx=15, pady=15)
        
        # Filesystem info
        self.total_label = Label(self.sys_info_frame, text="💾 Total: --", 
                                font=self.fonts['body'], fg=self.colors['text_primary'],
                                bg='#ffffff80')
        self.total_label.pack(anchor=W, pady=2)
        
        self.used_label = Label(self.sys_info_frame, text="📊 Used: --", 
                               font=self.fonts['body'], fg=self.colors['text_primary'],
                               bg='#ffffff80')
        self.used_label.pack(anchor=W, pady=2)
        
        self.free_label = Label(self.sys_info_frame, text="🆓 Free: --", 
                               font=self.fonts['body'], fg=self.colors['text_primary'],
                               bg='#ffffff80')
        self.free_label.pack(anchor=W, pady=2)
        
        # Arch-specific info
        self.pacman_label = Label(self.sys_info_frame, text="📦 Checking pacman cache...", 
                                 font=self.fonts['caption'], fg=self.colors['secondary'],
                                 bg='#ffffff80')
        self.pacman_label.pack(anchor=W, pady=(5, 2))
    
    def create_footer(self, parent):
        """Create footer with Arch Linux branding"""
        footer_frame = self.create_glass_frame(parent, '#ffffff30')
        footer_frame.pack(fill=X, padx=20, pady=(0, 20))
        
        footer_content = Frame(footer_frame, bg='#ffffff30')
        footer_content.pack(fill=X, padx=20, pady=10)
        
        # Left side - Arch branding
        left_footer = Frame(footer_content, bg='#ffffff30')
        left_footer.pack(side=LEFT)
        
        Label(left_footer, text="Built for Arch Linux", 
              font=self.fonts['caption'], fg=self.colors['arch_blue'],
              bg='#ffffff30').pack(side=LEFT)
        
        # Right side - Stats
        right_footer = Frame(footer_content, bg='#ffffff30')
        right_footer.pack(side=RIGHT)
        
        self.stats_label = Label(right_footer, text="Ready to scan", 
                                font=self.fonts['caption'], fg=self.colors['text_secondary'],
                                bg='#ffffff30')
        self.stats_label.pack(side=RIGHT)
    
    def create_glass_button(self, parent, text, command, color):
        """Create a button with glass effect and hover animations"""
        # Button container for glass effect
        btn_container = self.create_glass_frame(parent, '#ffffff50')
        
        btn = Button(btn_container, text=text, command=command,
                    font=self.fonts['body'], fg='white', bg=color,
                    relief=FLAT, bd=0, padx=20, pady=10,
                    activebackground=self.lighten_color(color),
                    activeforeground='white', cursor='hand2')
        btn.pack(fill=X, padx=2, pady=2)
        
        # Enhanced hover effects
        def on_enter(e):
            btn.configure(bg=self.lighten_color(color))
            btn_container.configure(bg='#ffffff70')
        
        def on_leave(e):
            btn.configure(bg=color)
            btn_container.configure(bg='#ffffff50')
        
        btn.bind("<Enter>", on_enter)
        btn.bind("<Leave>", on_leave)
        
        return btn_container
    
    def lighten_color(self, color):
        """Lighten a hex color for hover effects"""
        color_map = {
            self.colors['primary']: '#1a8cff',
            self.colors['secondary']: '#a0a0a5',
            self.colors['accent']: '#4dd36b',
            self.colors['warning']: '#ffa31a',
            self.colors['danger']: '#ff5547',
            self.colors['arch_blue']: '#2aa3e1'
        }
        return color_map.get(color, color)
    
    def show_context_menu(self, event):
        """Show context menu for directories"""
        selection = self.tree.selection()
        if not selection:
            return
        
        context_menu = Menu(self.root, tearoff=0, bg='#ffffff90', fg=self.colors['text_primary'])
        context_menu.add_command(label="📂 Open in File Manager", command=self.open_in_filemanager)
        context_menu.add_command(label="📋 Copy Path", command=self.copy_path)
        context_menu.add_separator()
        context_menu.add_command(label="🔍 Analyze", command=self.analyze_directory)
        
        try:
            context_menu.tk_popup(event.x_root, event.y_root)
        finally:
            context_menu.grab_release()
    
    def clear_cache(self):
        """Clear any cached data"""
        self.tree.delete(*self.tree.get_children())
        self.stats_label.config(text="Cache cleared")
        messagebox.showinfo("Cache Cleared", "Directory cache has been cleared.")
    
    def get_pacman_cache_size(self):
        """Get Arch Linux pacman cache size"""
        try:
            cache_path = "/var/cache/pacman/pkg"
            if os.path.exists(cache_path):
                size = self.get_directory_size(cache_path)
                return self.bytes_to_unit(size, self.current_unit)
            return 0
        except:
            return 0
    
    def update_arch_info(self):
        """Update Arch Linux specific information"""
        # Update pacman cache info
        cache_size = self.get_pacman_cache_size()
        if cache_size > 0:
            self.pacman_label.config(text=f"📦 Pacman cache: {cache_size:.1f} {self.current_unit}")
        else:
            self.pacman_label.config(text="📦 Pacman cache: Not accessible")
    
    # Core functionality methods (keeping the same logic as before but with Arch-specific enhancements)
    def bytes_to_unit(self, b, unit):
        """Convert bytes to specified unit"""
        if unit.upper() == "GB":
            return b / (1024 ** 3)
        elif unit.upper() == "MB":
            return b / (1024 ** 2)
        elif unit.upper() == "KB":
            return b / 1024
        else:
            return b
    
    def get_directory_size(self, path):
        """Get directory size (optimized for Arch Linux)"""
        total = 0
        try:
            for entry in os.scandir(path):
                try:
                    if entry.is_file(follow_symlinks=False):
                        total += entry.stat().st_size
                    elif entry.is_dir(follow_symlinks=False):
                        total += self.get_directory_size(entry.path)
                except (PermissionError, OSError):
                    continue
        except (PermissionError, OSError):
            pass
        return total
    
    def get_filesystem_info(self, path):
        """Get filesystem information"""
        try:
            stat = os.statvfs(path)
            total_space = stat.f_blocks * stat.f_frsize
            free_space = stat.f_available * stat.f_frsize
            used_space = total_space - free_space
            return total_space, used_space, free_space
        except Exception:
            return None, None, None
    
    def update_filesystem_info(self):
        """Update filesystem information display"""
        total, used, free = self.get_filesystem_info(self.current_path)
        if total:
            unit = self.current_unit
            self.total_label.config(text=f"💾 Total: {self.bytes_to_unit(total, unit):.1f} {unit}")
            self.used_label.config(text=f"📊 Used: {self.bytes_to_unit(used, unit):.1f} {unit}")
            self.free_label.config(text=f"🆓 Free: {self.bytes_to_unit(free, unit):.1f} {unit}")
        else:
            self.total_label.config(text="💾 Total: --")
            self.used_label.config(text="📊 Used: --")
            self.free_label.config(text="🆓 Free: --")
        
        # Update Arch-specific info
        self.update_arch_info()
    
    def refresh_data(self):
        """Refresh directory data in background thread"""
        if self.scanning:
            return
        
        self.scanning = True
        self.show_loading(True)
        self.refresh_btn.configure(text="⏳ Scanning...")
        
        def scan_thread():
            try:
                # Update path display
                self.path_label.config(text=self.current_path)
                
                # Update filesystem info
                self.root.after(0, self.update_filesystem_info)
                
                # Clear tree
                self.root.after(0, lambda: self.tree.delete(*self.tree.get_children()))
                
                # Scan directories
                dirs = []
                file_count = 0
                try:
                    for entry in os.scandir(self.current_path):
                        if entry.is_dir(follow_symlinks=False):
                            try:
                                size = self.get_directory_size(entry.path)
                                dirs.append((entry.name, entry.path, size))
                            except (PermissionError, OSError):
                                dirs.append((entry.name, entry.path, 0))
                        else:
                            file_count += 1
                except (PermissionError, OSError):
                    pass
                
                # Sort by size
                dirs.sort(key=lambda x: x[2], reverse=True)
                
                # Update tree in main thread
                self.root.after(0, lambda: self.populate_tree(dirs))
                
                # Update stats
                self.root.after(0, lambda: self.stats_label.config(
                    text=f"{len(dirs)} directories, {file_count} files"))
                
            finally:
                self.scanning = False
                self.root.after(0, lambda: self.show_loading(False))
                self.root.after(0, lambda: self.refresh_btn.configure(text="🔄 Refresh"))
        
        threading.Thread(target=scan_thread, daemon=True).start()
    
    def populate_tree(self, dirs):
        """Populate the tree view with directory data"""
        for name, path, size in dirs:
            size_display = self.bytes_to_unit(size, self.current_unit)
            if size_display >= 0.01:  # Only show if above threshold
                # Check permissions and classify
                accessible = os.access(path, os.R_OK)
                icon = "📁" if accessible else "🔒"
                type_text = "Directory" if accessible else "System"
                perm_text = "Read/Write" if accessible else "Restricted"
                
                # Determine tag for styling
                tag = 'normal'
                if not accessible:
                    tag = 'restricted'
                elif size_display > 1:  # Large directories (> 1 unit)
                    tag = 'large'
                
                self.tree.insert('', 'end', text=icon,
                               values=(name, f"{size_display:.2f} {self.current_unit}", 
                                     type_text, perm_text),
                               tags=(path, tag))
    
    def show_loading(self, show):
        """Show or hide loading indicator"""
        if show:
            self.loading_frame.pack(fill=X, padx=25, pady=15)
        else:
            self.loading_frame.pack_forget()
    
    def on_directory_double_click(self, event):
        """Handle directory double-click"""
        selection = self.tree.selection()
        if selection:
            item = self.tree.item(selection[0])
            if item['tags']:
                new_path = item['tags'][0]
                if new_path.startswith('/') or new_path.startswith('~'):
                    if os.access(new_path, os.R_OK):
                        self.history.append(self.current_path)
                        self.current_path = new_path
                        self.refresh_data()
                    else:
                        messagebox.showerror("Permission Denied", 
                                           f"Cannot access directory:\n{new_path}")
    
    def on_unit_changed(self, event):
        """Handle unit change"""
        self.current_unit = self.unit_var.get()
        self.refresh_data()
    
    def go_home(self):
        """Navigate to home directory"""
        self.history.append(self.current_path)
        self.current_path = os.path.expanduser("~")
        self.refresh_data()
    
    def go_root(self):
        """Navigate to root directory"""
        self.history.append(self.current_path)
        self.current_path = "/"
        self.refresh_data()
    
    def go_up(self):
        """Navigate to parent directory"""
        parent = os.path.dirname(self.current_path)
        if parent != self.current_path:
            self.history.append(self.current_path)
            self.current_path = parent
            self.refresh_data()
    
    def go_back(self):
        """Navigate back in history"""
        if self.history:
            self.current_path = self.history.pop()
            self.refresh_data()
    
    def browse_folder(self):
        """Open folder browser dialog"""
        folder = filedialog.askdirectory(initialdir=self.current_path)
        if folder:
            self.history.append(self.current_path)
            self.current_path = folder
            self.refresh_data()
    
    def open_in_filemanager(self):
        """Open selected directory in file manager"""
        selection = self.tree.selection()
        if selection:
            item = self.tree.item(selection[0])
            if item['tags']:
                path = item['tags'][0]
                try:
                    os.system(f'xdg-open "{path}"')
                except:
                    messagebox.showerror("Error", "Could not open file manager")
    
    def copy_path(self):
        """Copy selected path to clipboard"""
        selection = self.tree.selection()
        if selection:
            item = self.tree.item(selection[0])
            if item['tags']:
                path = item['tags'][0]
                self.root.clipboard_clear()
                self.root.clipboard_append(path)
                messagebox.showinfo("Copied", f"Path copied to clipboard:\n{path}")
    
    def analyze_directory(self):
        """Analyze selected directory"""
        selection = self.tree.selection()
        if selection:
            item = self.tree.item(selection[0])
            if item['tags']:
                new_path = item['tags'][0]
                if os.access(new_path, os.R_OK):
                    self.history.append(self.current_path)
                    self.current_path = new_path
                    self.refresh_data()
    
    def run(self):
        """Start the application"""
        self.root.mainloop()

if __name__ == "__main__":
    print("🚀 Starting Storage Analyzer - Arch Linux Transparent Edition")
    app = ArchTransparentStorageAnalyzer()
    app.run()