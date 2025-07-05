#!/usr/bin/env python3
"""
Power Control Dashboard Server for Arch Linux
HP ProBook 440 G8 - KDE Plasma 6 Wayland Edition

Remote power control and system monitoring from phone
Hyprland-style UI with real-time system stats
"""

import os
import sys
import json
import time
import psutil
import subprocess
import threading
from datetime import datetime
from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
import hashlib
import secrets
import logging
from pathlib import Path

class ArchPowerControlServer:
    def __init__(self, host='0.0.0.0', port=8888, auth_token=None):
        self.app = Flask(__name__, 
                        template_folder='templates',
                        static_folder='static')
        CORS(self.app)
        
        self.host = host
        self.port = port
        self.auth_token = auth_token or self.generate_auth_token()
        
        # System info cache
        self.system_cache = {}
        self.cache_timestamp = 0
        self.cache_timeout = 2  # seconds
        
        # Setup logging
        self.setup_logging()
        
        # Setup routes
        self.setup_routes()
        
        # Start background monitoring
        self.monitoring_active = True
        self.start_background_monitoring()
        
    def setup_logging(self):
        """Setup logging for the server"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('power-control.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
        
    def generate_auth_token(self):
        """Generate a secure authentication token"""
        return secrets.token_urlsafe(32)
    
    def verify_auth(self, token):
        """Verify authentication token"""
        return token == self.auth_token
    
    def get_system_info(self):
        """Get comprehensive system information"""
        current_time = time.time()
        
        # Use cache if recent
        if current_time - self.cache_timestamp < self.cache_timeout:
            return self.system_cache
        
        try:
            # CPU Information
            cpu_percent = psutil.cpu_percent(interval=1)
            cpu_count = psutil.cpu_count()
            cpu_freq = psutil.cpu_freq()
            
            # Memory Information
            memory = psutil.virtual_memory()
            swap = psutil.swap_memory()
            
            # Disk Information
            disk = psutil.disk_usage('/')
            
            # Network Information
            network = psutil.net_io_counters()
            
            # Temperature (try different sensors)
            temperature = self.get_temperature()
            
            # Battery Information (laptop specific)
            battery = self.get_battery_info()
            
            # System Uptime
            boot_time = psutil.boot_time()
            uptime = current_time - boot_time
            
            # Top processes
            top_processes = self.get_top_processes()
            
            # System load
            load_avg = os.getloadavg()
            
            # KDE/Plasma specific info
            desktop_info = self.get_desktop_info()
            
            system_info = {
                'timestamp': current_time,
                'hostname': os.uname().nodename,
                'arch': os.uname().machine,
                'kernel': os.uname().release,
                'desktop': desktop_info,
                'uptime': {
                    'seconds': int(uptime),
                    'formatted': self.format_uptime(uptime)
                },
                'cpu': {
                    'usage_percent': cpu_percent,
                    'count': cpu_count,
                    'frequency': {
                        'current': cpu_freq.current if cpu_freq else None,
                        'min': cpu_freq.min if cpu_freq else None,
                        'max': cpu_freq.max if cpu_freq else None
                    },
                    'load_avg': {
                        '1min': load_avg[0],
                        '5min': load_avg[1],
                        '15min': load_avg[2]
                    }
                },
                'memory': {
                    'total': memory.total,
                    'available': memory.available,
                    'used': memory.used,
                    'percent': memory.percent,
                    'total_gb': round(memory.total / (1024**3), 2),
                    'used_gb': round(memory.used / (1024**3), 2),
                    'available_gb': round(memory.available / (1024**3), 2)
                },
                'swap': {
                    'total': swap.total,
                    'used': swap.used,
                    'percent': swap.percent,
                    'total_gb': round(swap.total / (1024**3), 2) if swap.total > 0 else 0,
                    'used_gb': round(swap.used / (1024**3), 2) if swap.used > 0 else 0
                },
                'disk': {
                    'total': disk.total,
                    'used': disk.used,
                    'free': disk.free,
                    'percent': (disk.used / disk.total) * 100,
                    'total_gb': round(disk.total / (1024**3), 2),
                    'used_gb': round(disk.used / (1024**3), 2),
                    'free_gb': round(disk.free / (1024**3), 2)
                },
                'network': {
                    'bytes_sent': network.bytes_sent,
                    'bytes_recv': network.bytes_recv,
                    'packets_sent': network.packets_sent,
                    'packets_recv': network.packets_recv,
                    'sent_gb': round(network.bytes_sent / (1024**3), 2),
                    'recv_gb': round(network.bytes_recv / (1024**3), 2)
                },
                'temperature': temperature,
                'battery': battery,
                'processes': top_processes
            }
            
            # Cache the result
            self.system_cache = system_info
            self.cache_timestamp = current_time
            
            return system_info
            
        except Exception as e:
            self.logger.error(f"Error getting system info: {e}")
            return {'error': str(e)}
    
    def get_temperature(self):
        """Get system temperature from various sources"""
        try:
            temps = {}
            
            # Try psutil sensors first
            try:
                sensors = psutil.sensors_temperatures()
                for name, entries in sensors.items():
                    for entry in entries:
                        temps[f"{name}_{entry.label or 'temp'}"] = {
                            'current': entry.current,
                            'high': entry.high,
                            'critical': entry.critical
                        }
            except:
                pass
            
            # Manual temperature reading for HP ProBook 440 G8
            temp_files = [
                '/sys/class/thermal/thermal_zone0/temp',
                '/sys/class/thermal/thermal_zone1/temp',
                '/sys/class/hwmon/hwmon0/temp1_input',
                '/sys/class/hwmon/hwmon1/temp1_input'
            ]
            
            for i, temp_file in enumerate(temp_files):
                try:
                    if os.path.exists(temp_file):
                        with open(temp_file, 'r') as f:
                            temp_millic = int(f.read().strip())
                            temp_celsius = temp_millic / 1000
                            temps[f'sensor_{i}'] = {
                                'current': temp_celsius,
                                'high': None,
                                'critical': None
                            }
                except:
                    continue
            
            return temps if temps else {'cpu': {'current': None}}
            
        except Exception as e:
            self.logger.error(f"Error getting temperature: {e}")
            return {'error': str(e)}
    
    def get_battery_info(self):
        """Get battery information for HP ProBook 440 G8"""
        try:
            battery = psutil.sensors_battery()
            if battery:
                return {
                    'percent': battery.percent,
                    'power_plugged': battery.power_plugged,
                    'time_left': battery.secsleft if battery.secsleft != psutil.POWER_TIME_UNLIMITED else None,
                    'status': 'charging' if battery.power_plugged else 'discharging'
                }
            else:
                return {'percent': None, 'status': 'no_battery'}
        except Exception as e:
            return {'error': str(e)}
    
    def get_top_processes(self, limit=10):
        """Get top processes by CPU usage"""
        try:
            processes = []
            for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_percent', 'username']):
                try:
                    pinfo = proc.info
                    pinfo['cpu_percent'] = proc.cpu_percent()
                    processes.append(pinfo)
                except (psutil.NoSuchProcess, psutil.AccessDenied):
                    pass
            
            # Sort by CPU usage
            processes.sort(key=lambda x: x['cpu_percent'] or 0, reverse=True)
            return processes[:limit]
            
        except Exception as e:
            self.logger.error(f"Error getting processes: {e}")
            return []
    
    def get_desktop_info(self):
        """Get KDE Plasma 6 and desktop environment info"""
        try:
            desktop_info = {
                'session': os.environ.get('XDG_CURRENT_DESKTOP', 'Unknown'),
                'session_type': os.environ.get('XDG_SESSION_TYPE', 'Unknown'),
                'wayland': os.environ.get('WAYLAND_DISPLAY') is not None,
                'display': os.environ.get('DISPLAY', 'Not set')
            }
            
            # Try to get KDE version
            try:
                result = subprocess.run(['plasmashell', '--version'], 
                                      capture_output=True, text=True, timeout=5)
                if result.returncode == 0:
                    desktop_info['kde_version'] = result.stdout.strip()
            except:
                pass
            
            return desktop_info
            
        except Exception as e:
            return {'error': str(e)}
    
    def format_uptime(self, seconds):
        """Format uptime in human readable format"""
        days = int(seconds // 86400)
        hours = int((seconds % 86400) // 3600)
        minutes = int((seconds % 3600) // 60)
        
        if days > 0:
            return f"{days}d {hours}h {minutes}m"
        elif hours > 0:
            return f"{hours}h {minutes}m"
        else:
            return f"{minutes}m"
    
    def start_background_monitoring(self):
        """Start background thread for continuous monitoring"""
        def monitor():
            while self.monitoring_active:
                try:
                    self.get_system_info()  # Update cache
                    time.sleep(self.cache_timeout)
                except Exception as e:
                    self.logger.error(f"Background monitoring error: {e}")
                    time.sleep(5)
        
        monitor_thread = threading.Thread(target=monitor, daemon=True)
        monitor_thread.start()
        self.logger.info("Background monitoring started")
    
    def setup_routes(self):
        """Setup Flask routes"""
        
        @self.app.route('/')
        def index():
            """Main dashboard page"""
            return render_template('dashboard.html', 
                                 hostname=os.uname().nodename,
                                 auth_token=self.auth_token)
        
        @self.app.route('/api/system')
        def api_system():
            """API endpoint for system information"""
            auth_token = request.headers.get('Authorization', '').replace('Bearer ', '')
            if not self.verify_auth(auth_token):
                return jsonify({'error': 'Unauthorized'}), 401
            
            return jsonify(self.get_system_info())
        
        @self.app.route('/api/power/<action>', methods=['POST'])
        def api_power(action):
            """API endpoint for power actions"""
            auth_token = request.headers.get('Authorization', '').replace('Bearer ', '')
            if not self.verify_auth(auth_token):
                return jsonify({'error': 'Unauthorized'}), 401
            
            if action not in ['shutdown', 'reboot', 'suspend', 'hibernate']:
                return jsonify({'error': 'Invalid action'}), 400
            
            try:
                result = self.execute_power_action(action)
                return jsonify(result)
            except Exception as e:
                self.logger.error(f"Power action error: {e}")
                return jsonify({'error': str(e)}), 500
        
        @self.app.route('/api/processes')
        def api_processes():
            """API endpoint for process list"""
            auth_token = request.headers.get('Authorization', '').replace('Bearer ', '')
            if not self.verify_auth(auth_token):
                return jsonify({'error': 'Unauthorized'}), 401
            
            limit = request.args.get('limit', 20, type=int)
            return jsonify(self.get_top_processes(limit))
        
        @self.app.route('/api/auth/verify', methods=['POST'])
        def api_auth_verify():
            """Verify authentication token"""
            data = request.get_json()
            token = data.get('token', '')
            
            if self.verify_auth(token):
                return jsonify({'valid': True, 'hostname': os.uname().nodename})
            else:
                return jsonify({'valid': False}), 401
    
    def execute_power_action(self, action):
        """Execute power management actions"""
        commands = {
            'shutdown': ['sudo', 'systemctl', 'poweroff'],
            'reboot': ['sudo', 'systemctl', 'reboot'],
            'suspend': ['sudo', 'systemctl', 'suspend'],
            'hibernate': ['sudo', 'systemctl', 'hibernate']
        }
        
        if action not in commands:
            raise ValueError(f"Invalid action: {action}")
        
        self.logger.info(f"Executing power action: {action}")
        
        try:
            # Schedule the action with a delay to allow response
            def delayed_action():
                time.sleep(2)  # Give time for response to be sent
                subprocess.run(commands[action], check=True)
            
            threading.Thread(target=delayed_action, daemon=True).start()
            
            return {
                'success': True,
                'action': action,
                'message': f'{action.title()} command sent successfully',
                'timestamp': datetime.now().isoformat()
            }
            
        except subprocess.CalledProcessError as e:
            raise Exception(f"Failed to execute {action}: {e}")
    
    def run(self):
        """Start the Flask server"""
        print(f"""
⚡ Power Control Dashboard Server Starting...

🏔️  System: {os.uname().nodename} (Arch Linux)
🖥️  Desktop: KDE Plasma 6 Wayland
💻 Laptop: HP ProBook 440 G8
📱 Phone Access: http://{self.host}:{self.port}
🔐 Auth Token: {self.auth_token}

📊 Features:
  ✅ Remote shutdown/reboot/suspend/hibernate
  ✅ Real-time CPU, memory, temperature monitoring
  ✅ Process monitoring with top CPU usage
  ✅ Battery status and power management
  ✅ Hyprland-style mobile UI
  ✅ KDE Plasma 6 integration

🔒 Security: Token-based authentication enabled
📱 Mobile: Open the URL on your phone for remote control
        """)
        
        self.logger.info(f"Starting Power Control Dashboard on {self.host}:{self.port}")
        self.app.run(host=self.host, port=self.port, debug=False, threaded=True)

def main():
    """Main entry point"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Power Control Dashboard for Arch Linux HP ProBook 440 G8')
    parser.add_argument('--host', default='0.0.0.0', help='Host to bind to')
    parser.add_argument('--port', type=int, default=8888, help='Port to bind to')
    parser.add_argument('--auth-token', help='Custom authentication token')
    parser.add_argument('--generate-token', action='store_true', 
                       help='Generate a new auth token and exit')
    
    args = parser.parse_args()
    
    if args.generate_token:
        token = secrets.token_urlsafe(32)
        print(f"Generated auth token: {token}")
        return
    
    # Check if running as root (needed for power actions)
    if os.geteuid() != 0:
        print("Warning: Not running as root. Power actions may require sudo.")
    
    server = ArchPowerControlServer(
        host=args.host,
        port=args.port,
        auth_token=args.auth_token
    )
    
    try:
        server.run()
    except KeyboardInterrupt:
        print("\n⚡ Power Control Dashboard stopped by user")
        server.monitoring_active = False
    except Exception as e:
        print(f"❌ Server error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()