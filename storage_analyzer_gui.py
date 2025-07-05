#!/usr/bin/env python3
import os
import sys
import threading
import time
from tkinter import *
from tkinter import ttk, messagebox, filedialog
import tkinter.font as tkfont

class SwiftStyleApp:
    def __init__(self):
        self.root = Tk()
        self.root.title("Storage Analyzer")
        self.root.geometry("1200x800")
        self.root.configure(bg='#f5f5f7')
        
        # Modern font setup
        self.setup_fonts()
        
        # Swift-style colors
        self.colors = {
            'bg': '#f5f5f7',
            'card_bg': '#ffffff',
            'primary': '#007aff',
            'secondary': '#8e8e93',
            'accent': '#34c759',
            'warning': '#ff9500',
            'danger': '#ff3b30',
            'text_primary': '#1d1d1f',
            'text_secondary': '#86868b',
            'border': '#d2d2d7'
        }
        
        # Data storage
        self.current_path = os.path.expanduser("~")
        self.history = []
        self.current_unit = "GB"
        self.scanning = False
        
        self.setup_ui()
        self.refresh_data()
    
    def setup_fonts(self):
        """Setup modern font families"""
        self.fonts = {
            'title': tkfont.Font(family='SF Pro Display', size=24, weight='bold'),
            'heading': tkfont.Font(family='SF Pro Display', size=18, weight='bold'),
            'body': tkfont.Font(family='SF Pro Text', size=14),
            'body_medium': tkfont.Font(family='SF Pro Text', size=14, weight='bold'),
            'caption': tkfont.Font(family='SF Pro Text', size=12),
            'small': tkfont.Font(family='SF Pro Text', size=10)
        }
        
        # Fallback to system fonts if SF Pro not available
        try:
            self.fonts['title'].configure()
        except:
            self.fonts = {
                'title': tkfont.Font(family='Helvetica', size=24, weight='bold'),
                'heading': tkfont.Font(family='Helvetica', size=18, weight='bold'),
                'body': tkfont.Font(family='Helvetica', size=14),
                'body_medium': tkfont.Font(family='Helvetica', size=14, weight='bold'),
                'caption': tkfont.Font(family='Helvetica', size=12),
                'small': tkfont.Font(family='Helvetica', size=10)
            }
    
    def setup_ui(self):
        """Create the modern Swift-style interface"""
        # Main container with padding
        main_frame = Frame(self.root, bg=self.colors['bg'])
        main_frame.pack(fill=BOTH, expand=True, padx=20, pady=20)
        
        # Header section
        self.create_header(main_frame)
        
        # Content area
        content_frame = Frame(main_frame, bg=self.colors['bg'])
        content_frame.pack(fill=BOTH, expand=True, pady=(20, 0))
        
        # Left panel (navigation and controls)
        self.create_left_panel(content_frame)
        
        # Right panel (directory listing)
        self.create_right_panel(content_frame)
    
    def create_header(self, parent):
        """Create the header with title and controls"""
        header_frame = Frame(parent, bg=self.colors['card_bg'], relief=FLAT, bd=0)
        header_frame.pack(fill=X, pady=(0, 10))
        
        # Add rounded corner effect with padding
        header_content = Frame(header_frame, bg=self.colors['card_bg'])
        header_content.pack(fill=X, padx=20, pady=15)
        
        # Title
        title_label = Label(header_content, text="Storage Analyzer", 
                           font=self.fonts['title'], fg=self.colors['text_primary'],
                           bg=self.colors['card_bg'])
        title_label.pack(side=LEFT)
        
        # Unit selector
        unit_frame = Frame(header_content, bg=self.colors['card_bg'])
        unit_frame.pack(side=RIGHT)
        
        Label(unit_frame, text="Display unit:", font=self.fonts['caption'],
              fg=self.colors['text_secondary'], bg=self.colors['card_bg']).pack(side=LEFT, padx=(0, 10))
        
        self.unit_var = StringVar(value=self.current_unit)
        unit_menu = ttk.Combobox(unit_frame, textvariable=self.unit_var, 
                                values=["GB", "MB", "KB"], state="readonly", width=5)
        unit_menu.pack(side=LEFT)
        unit_menu.bind('<<ComboboxSelected>>', self.on_unit_changed)
        
        # Style the combobox
        style = ttk.Style()
        style.configure('TCombobox', fieldbackground=self.colors['card_bg'])
    
    def create_left_panel(self, parent):
        """Create the left navigation panel"""
        left_frame = Frame(parent, bg=self.colors['card_bg'], width=300)
        left_frame.pack(side=LEFT, fill=Y, padx=(0, 10))
        left_frame.pack_propagate(False)
        
        # Path section
        path_section = Frame(left_frame, bg=self.colors['card_bg'])
        path_section.pack(fill=X, padx=20, pady=20)
        
        Label(path_section, text="Current Path", font=self.fonts['heading'],
              fg=self.colors['text_primary'], bg=self.colors['card_bg']).pack(anchor=W)
        
        # Path display with scrolling
        path_frame = Frame(path_section, bg=self.colors['bg'], relief=SOLID, bd=1)
        path_frame.pack(fill=X, pady=(10, 0))
        
        self.path_label = Label(path_frame, text=self.current_path, font=self.fonts['caption'],
                               fg=self.colors['text_secondary'], bg=self.colors['bg'],
                               wraplength=250, justify=LEFT, anchor=W)
        self.path_label.pack(padx=10, pady=8, anchor=W)
        
        # Navigation buttons
        nav_section = Frame(left_frame, bg=self.colors['card_bg'])
        nav_section.pack(fill=X, padx=20, pady=(0, 20))
        
        nav_buttons = [
            ("🏠 Home", self.go_home, self.colors['primary']),
            ("📁 Root", self.go_root, self.colors['primary']),
            ("⬆️ Parent", self.go_up, self.colors['secondary']),
            ("↩️ Back", self.go_back, self.colors['secondary'])
        ]
        
        for text, command, color in nav_buttons:
            btn = self.create_modern_button(nav_section, text, command, color)
            btn.pack(fill=X, pady=2)
        
        # Browse button
        browse_btn = self.create_modern_button(nav_section, "📂 Browse...", self.browse_folder, self.colors['accent'])
        browse_btn.pack(fill=X, pady=(10, 0))
        
        # Filesystem info section
        self.create_filesystem_info(left_frame)
    
    def create_right_panel(self, parent):
        """Create the right panel with directory listing"""
        right_frame = Frame(parent, bg=self.colors['card_bg'])
        right_frame.pack(side=RIGHT, fill=BOTH, expand=True)
        
        # Header
        list_header = Frame(right_frame, bg=self.colors['card_bg'])
        list_header.pack(fill=X, padx=20, pady=(20, 10))
        
        Label(list_header, text="Directories", font=self.fonts['heading'],
              fg=self.colors['text_primary'], bg=self.colors['card_bg']).pack(side=LEFT)
        
        # Refresh button
        self.refresh_btn = self.create_modern_button(list_header, "🔄 Refresh", self.refresh_data, self.colors['primary'])
        self.refresh_btn.pack(side=RIGHT)
        
        # Loading indicator
        self.loading_frame = Frame(right_frame, bg=self.colors['card_bg'])
        self.loading_label = Label(self.loading_frame, text="🔄 Scanning directories...", 
                                  font=self.fonts['body'], fg=self.colors['text_secondary'],
                                  bg=self.colors['card_bg'])
        self.loading_label.pack(pady=20)
        
        # Directory listing
        list_container = Frame(right_frame, bg=self.colors['bg'], relief=SOLID, bd=1)
        list_container.pack(fill=BOTH, expand=True, padx=20, pady=(0, 20))
        
        # Treeview for directory listing
        self.create_directory_tree(list_container)
    
    def create_directory_tree(self, parent):
        """Create the directory tree view"""
        tree_frame = Frame(parent, bg=self.colors['card_bg'])
        tree_frame.pack(fill=BOTH, expand=True, padx=1, pady=1)
        
        # Columns
        columns = ('Name', 'Size', 'Type')
        self.tree = ttk.Treeview(tree_frame, columns=columns, show='tree headings', height=20)
        
        # Configure columns
        self.tree.heading('#0', text='📁', anchor=W)
        self.tree.heading('Name', text='Name', anchor=W)
        self.tree.heading('Size', text='Size', anchor=E)
        self.tree.heading('Type', text='Type', anchor=W)
        
        self.tree.column('#0', width=50, minwidth=50)
        self.tree.column('Name', width=300, minwidth=200)
        self.tree.column('Size', width=120, minwidth=100)
        self.tree.column('Type', width=100, minwidth=80)
        
        # Scrollbars
        v_scrollbar = ttk.Scrollbar(tree_frame, orient=VERTICAL, command=self.tree.yview)
        h_scrollbar = ttk.Scrollbar(tree_frame, orient=HORIZONTAL, command=self.tree.xview)
        self.tree.configure(yscrollcommand=v_scrollbar.set, xscrollcommand=h_scrollbar.set)
        
        # Pack scrollbars and tree
        v_scrollbar.pack(side=RIGHT, fill=Y)
        h_scrollbar.pack(side=BOTTOM, fill=X)
        self.tree.pack(side=LEFT, fill=BOTH, expand=True)
        
        # Bind double-click
        self.tree.bind('<Double-1>', self.on_directory_double_click)
        
        # Style the treeview
        style = ttk.Style()
        style.configure('Treeview', background=self.colors['card_bg'], 
                       foreground=self.colors['text_primary'], fieldbackground=self.colors['card_bg'])
        style.configure('Treeview.Heading', background=self.colors['bg'], 
                       foreground=self.colors['text_primary'], font=self.fonts['body_medium'])
    
    def create_filesystem_info(self, parent):
        """Create filesystem information display"""
        fs_section = Frame(parent, bg=self.colors['card_bg'])
        fs_section.pack(fill=X, padx=20, pady=(0, 20))
        
        Label(fs_section, text="Filesystem Info", font=self.fonts['heading'],
              fg=self.colors['text_primary'], bg=self.colors['card_bg']).pack(anchor=W)
        
        # Info container
        info_container = Frame(fs_section, bg=self.colors['bg'], relief=SOLID, bd=1)
        info_container.pack(fill=X, pady=(10, 0))
        
        self.fs_info_frame = Frame(info_container, bg=self.colors['bg'])
        self.fs_info_frame.pack(fill=X, padx=10, pady=10)
        
        # Placeholder labels
        self.total_label = Label(self.fs_info_frame, text="Total: --", font=self.fonts['caption'],
                                fg=self.colors['text_secondary'], bg=self.colors['bg'])
        self.total_label.pack(anchor=W)
        
        self.used_label = Label(self.fs_info_frame, text="Used: --", font=self.fonts['caption'],
                               fg=self.colors['text_secondary'], bg=self.colors['bg'])
        self.used_label.pack(anchor=W)
        
        self.free_label = Label(self.fs_info_frame, text="Free: --", font=self.fonts['caption'],
                               fg=self.colors['text_secondary'], bg=self.colors['bg'])
        self.free_label.pack(anchor=W)
    
    def create_modern_button(self, parent, text, command, color):
        """Create a modern Swift-style button"""
        btn = Button(parent, text=text, command=command, 
                    font=self.fonts['body'], fg='white', bg=color,
                    relief=FLAT, bd=0, padx=20, pady=8,
                    activebackground=self.lighten_color(color),
                    activeforeground='white', cursor='hand2')
        
        # Add hover effects
        def on_enter(e):
            btn.configure(bg=self.lighten_color(color))
        
        def on_leave(e):
            btn.configure(bg=color)
        
        btn.bind("<Enter>", on_enter)
        btn.bind("<Leave>", on_leave)
        
        return btn
    
    def lighten_color(self, color):
        """Lighten a hex color for hover effects"""
        color_map = {
            self.colors['primary']: '#1a8cff',
            self.colors['secondary']: '#a0a0a5',
            self.colors['accent']: '#4dd36b',
            self.colors['warning']: '#ffa31a',
            self.colors['danger']: '#ff5547'
        }
        return color_map.get(color, color)
    
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
        """Get directory size (runs in background thread)"""
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
            self.total_label.config(text=f"Total: {self.bytes_to_unit(total, unit):.1f} {unit}")
            self.used_label.config(text=f"Used: {self.bytes_to_unit(used, unit):.1f} {unit}")
            self.free_label.config(text=f"Free: {self.bytes_to_unit(free, unit):.1f} {unit}")
        else:
            self.total_label.config(text="Total: --")
            self.used_label.config(text="Used: --")
            self.free_label.config(text="Free: --")
    
    def refresh_data(self):
        """Refresh directory data in background thread"""
        if self.scanning:
            return
        
        self.scanning = True
        self.show_loading(True)
        self.refresh_btn.config(state=DISABLED)
        
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
                try:
                    for entry in os.scandir(self.current_path):
                        if entry.is_dir(follow_symlinks=False):
                            try:
                                size = self.get_directory_size(entry.path)
                                dirs.append((entry.name, entry.path, size))
                            except (PermissionError, OSError):
                                dirs.append((entry.name, entry.path, 0))
                except (PermissionError, OSError):
                    pass
                
                # Sort by size
                dirs.sort(key=lambda x: x[2], reverse=True)
                
                # Update tree in main thread
                self.root.after(0, lambda: self.populate_tree(dirs))
                
            finally:
                self.scanning = False
                self.root.after(0, lambda: self.show_loading(False))
                self.root.after(0, lambda: self.refresh_btn.config(state=NORMAL))
        
        threading.Thread(target=scan_thread, daemon=True).start()
    
    def populate_tree(self, dirs):
        """Populate the tree view with directory data"""
        for name, path, size in dirs:
            size_display = self.bytes_to_unit(size, self.current_unit)
            if size_display >= 0.01:  # Only show if above threshold
                # Check permissions
                accessible = os.access(path, os.R_OK)
                icon = "📁" if accessible else "🔒"
                type_text = "Directory" if accessible else "Restricted"
                
                self.tree.insert('', 'end', text=icon, 
                               values=(name, f"{size_display:.2f} {self.current_unit}", type_text),
                               tags=(path,))
    
    def show_loading(self, show):
        """Show or hide loading indicator"""
        if show:
            self.loading_frame.pack(fill=X, padx=20, pady=10)
        else:
            self.loading_frame.pack_forget()
    
    def on_directory_double_click(self, event):
        """Handle directory double-click"""
        selection = self.tree.selection()
        if selection:
            item = self.tree.item(selection[0])
            if item['tags']:
                new_path = item['tags'][0]
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
        if parent != self.current_path:  # Not already at root
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
    
    def run(self):
        """Start the application"""
        self.root.mainloop()

if __name__ == "__main__":
    app = SwiftStyleApp()
    app.run()