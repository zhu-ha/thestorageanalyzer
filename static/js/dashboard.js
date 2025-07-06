// Power Control Dashboard JavaScript
// Real-time system monitoring and remote control

// API endpoints
const API_BASE = '';
const API_ENDPOINTS = {
    system: '/api/system',
    power: '/api/power',
    processes: '/api/processes',
    auth: '/api/auth/verify'
};

// Global state
let systemData = {};
let isConnected = false;
let updateTimer = null;
let reconnectTimer = null;
let reconnectAttempts = 0;
const MAX_RECONNECT_ATTEMPTS = 5;

// Authentication functions
function showAuthModal() {
    const modal = document.getElementById('authModal');
    modal.classList.add('show');
}

function hideAuthModal() {
    const modal = document.getElementById('authModal');
    modal.classList.remove('show');
}

function showLoading(message = 'Loading...') {
    const overlay = document.getElementById('loadingOverlay');
    const text = overlay.querySelector('.loading-text');
    text.textContent = message;
    overlay.classList.add('show');
}

function hideLoading() {
    const overlay = document.getElementById('loadingOverlay');
    overlay.classList.remove('show');
}

function authenticate() {
    const tokenInput = document.getElementById('authToken');
    const token = tokenInput.value.trim();
    
    if (!token) {
        showNotification('Please enter an authentication token', 'error');
        return;
    }
    
    showLoading('Authenticating...');
    
    fetch(API_ENDPOINTS.auth, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ token: token })
    })
    .then(response => response.json())
    .then(data => {
        if (data.valid) {
            currentToken = token;
            localStorage.setItem('powerControlToken', token);
            isAuthenticated = true;
            hideAuthModal();
            hideLoading();
            startMonitoring();
            showNotification('Connected successfully!', 'success');
        } else {
            throw new Error('Invalid token');
        }
    })
    .catch(error => {
        hideLoading();
        showNotification('Authentication failed: ' + error.message, 'error');
    });
}

function verifyAuthentication() {
    if (!currentToken) {
        showAuthModal();
        return;
    }
    
    showLoading('Verifying connection...');
    
    fetch(API_ENDPOINTS.auth, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ token: currentToken })
    })
    .then(response => response.json())
    .then(data => {
        if (data.valid) {
            isAuthenticated = true;
            hideLoading();
            startMonitoring();
        } else {
            throw new Error('Token expired');
        }
    })
    .catch(error => {
        hideLoading();
        localStorage.removeItem('powerControlToken');
        currentToken = '';
        showAuthModal();
        showNotification('Authentication expired', 'warning');
    });
}

// System monitoring functions
function startMonitoring() {
    if (updateTimer) {
        clearInterval(updateTimer);
    }
    
    // Initial load
    updateSystemData();
    
    // Start regular updates
    updateTimer = setInterval(updateSystemData, 3000);
    
    updateConnectionStatus(true);
}

function stopMonitoring() {
    if (updateTimer) {
        clearInterval(updateTimer);
        updateTimer = null;
    }
    
    updateConnectionStatus(false);
}

function updateSystemData() {
    if (!isAuthenticated || !currentToken) {
        return;
    }
    
    fetch(API_ENDPOINTS.system, {
        headers: {
            'Authorization': `Bearer ${currentToken}`
        }
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        systemData = data;
        updateUI(data);
        updateConnectionStatus(true);
        reconnectAttempts = 0;
    })
    .catch(error => {
        console.error('Failed to update system data:', error);
        updateConnectionStatus(false);
        handleConnectionError();
    });
}

function handleConnectionError() {
    if (reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
        reconnectAttempts++;
        showNotification(`Connection lost. Retrying... (${reconnectAttempts}/${MAX_RECONNECT_ATTEMPTS})`, 'warning');
        
        setTimeout(() => {
            updateSystemData();
        }, 5000 * reconnectAttempts);
    } else {
        stopMonitoring();
        showNotification('Connection lost. Please refresh the page.', 'error');
    }
}

function updateUI(data) {
    if (data.error) {
        showNotification('System error: ' + data.error, 'error');
        return;
    }
    
    // Update CPU
    if (data.cpu) {
        updateProgressRing('cpuProgress', data.cpu.usage_percent);
        document.getElementById('cpuPercent').textContent = `${Math.round(data.cpu.usage_percent)}%`;
        document.getElementById('cpuCores').textContent = data.cpu.count;
        
        if (data.cpu.frequency && data.cpu.frequency.current) {
            document.getElementById('cpuFreq').textContent = `${Math.round(data.cpu.frequency.current / 1000)} MHz`;
        }
    }
    
    // Update Memory
    if (data.memory) {
        updateProgressRing('memoryProgress', data.memory.percent);
        document.getElementById('memoryPercent').textContent = `${Math.round(data.memory.percent)}%`;
        document.getElementById('memoryUsed').textContent = `${data.memory.used_gb} GB`;
        document.getElementById('memoryTotal').textContent = `${data.memory.total_gb} GB`;
    }
    
    // Update Disk
    if (data.disk) {
        updateProgressRing('diskProgress', data.disk.percent);
        document.getElementById('diskPercent').textContent = `${Math.round(data.disk.percent)}%`;
        document.getElementById('diskUsed').textContent = `${data.disk.used_gb} GB`;
        document.getElementById('diskFree').textContent = `${data.disk.free_gb} GB`;
    }
    
    // Update Temperature
    if (data.temperature) {
        updateTemperature(data.temperature);
    }
    
    // Update Battery
    if (data.battery) {
        updateBattery(data.battery);
    }
    
    // Update System Info
    if (data.uptime) {
        document.getElementById('uptime').textContent = data.uptime.formatted;
    }
    
    if (data.kernel) {
        document.getElementById('kernel').textContent = data.kernel;
    }
    
    if (data.desktop) {
        const session = data.desktop.session || 'Unknown';
        const type = data.desktop.session_type || '';
        document.getElementById('desktop').textContent = session;
        document.getElementById('session').textContent = type;
    }
    
    // Update Processes
    if (data.processes) {
        updateProcessList(data.processes);
    }
}

function updateProgressRing(elementId, percentage) {
    const circle = document.getElementById(elementId);
    if (!circle) return;
    
    const circumference = 2 * Math.PI * 35; // radius = 35
    const offset = circumference - (percentage / 100) * circumference;
    circle.style.strokeDashoffset = offset;
}

function updateTemperature(tempData) {
    let maxTemp = 0;
    let tempSource = 'N/A';
    
    // Find the highest temperature
    for (const [sensor, data] of Object.entries(tempData)) {
        if (data.current && data.current > maxTemp) {
            maxTemp = data.current;
            tempSource = sensor;
        }
    }
    
    if (maxTemp > 0) {
        document.getElementById('tempValue').textContent = `${Math.round(maxTemp)}°C`;
        
        // Update temperature status and progress bar
        let status = 'Normal';
        let progressWidth = (maxTemp / 100) * 100; // Assuming max 100°C
        
        if (maxTemp > 80) {
            status = 'Hot';
            document.getElementById('tempValue').style.color = 'var(--accent-red)';
        } else if (maxTemp > 60) {
            status = 'Warm';
            document.getElementById('tempValue').style.color = 'var(--accent-yellow)';
        } else {
            document.getElementById('tempValue').style.color = 'var(--accent-green)';
        }
        
        document.getElementById('tempStatus').textContent = status;
        document.getElementById('tempProgress').style.width = `${Math.min(progressWidth, 100)}%`;
    }
}

function updateBattery(batteryData) {
    const batteryIndicator = document.getElementById('batteryIndicator');
    const batteryPercent = batteryIndicator.querySelector('.battery-percent');
    const batteryIcon = batteryIndicator.querySelector('.battery-icon');
    
    if (batteryData.percent !== null) {
        batteryPercent.textContent = `${Math.round(batteryData.percent)}%`;
        
        // Update battery icon based on level and charging status
        if (batteryData.power_plugged) {
            batteryIcon.textContent = '🔌';
        } else if (batteryData.percent > 75) {
            batteryIcon.textContent = '🔋';
        } else if (batteryData.percent > 50) {
            batteryIcon.textContent = '🔋';
        } else if (batteryData.percent > 25) {
            batteryIcon.textContent = '🪫';
        } else {
            batteryIcon.textContent = '🪫';
        }
    } else {
        batteryPercent.textContent = 'AC';
        batteryIcon.textContent = '🔌';
    }
}

function updateProcessList(processes) {
    const processList = document.getElementById('processList');
    const header = processList.querySelector('.process-header');
    
    // Clear existing items except header
    const items = processList.querySelectorAll('.process-item');
    items.forEach(item => item.remove());
    
    // Add new process items
    processes.slice(0, 10).forEach(process => {
        const item = document.createElement('div');
        item.className = 'process-item';
        
        item.innerHTML = `
            <div class="process-name">${process.name || 'Unknown'}</div>
            <div class="process-cpu">${(process.cpu_percent || 0).toFixed(1)}%</div>
            <div class="process-memory">${(process.memory_percent || 0).toFixed(1)}%</div>
        `;
        
        processList.appendChild(item);
    });
}

function updateConnectionStatus(connected) {
    const statusElement = document.getElementById('connectionStatus');
    const statusDot = statusElement.querySelector('.status-dot');
    const statusText = statusElement.querySelector('.status-text');
    
    if (connected) {
        statusDot.classList.remove('disconnected');
        statusText.textContent = 'Connected';
        isConnected = true;
    } else {
        statusDot.classList.add('disconnected');
        statusText.textContent = 'Disconnected';
        isConnected = false;
    }
}

// Power control functions
function executePowerAction(action) {
    if (!isAuthenticated || !currentToken) {
        showNotification('Not authenticated', 'error');
        return;
    }
    
    const confirmMessage = `Are you sure you want to ${action} the system?`;
    if (!confirm(confirmMessage)) {
        return;
    }
    
    showLoading(`Executing ${action}...`);
    
    fetch(`${API_ENDPOINTS.power}/${action}`, {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${currentToken}`,
            'Content-Type': 'application/json'
        }
    })
    .then(response => response.json())
    .then(data => {
        hideLoading();
        if (data.success) {
            showNotification(`${action.charAt(0).toUpperCase() + action.slice(1)} command sent successfully`, 'success');
            if (action === 'shutdown' || action === 'reboot') {
                stopMonitoring();
                showNotification('System is shutting down. Connection will be lost.', 'warning');
            }
        } else {
            throw new Error(data.error || 'Unknown error');
        }
    })
    .catch(error => {
        hideLoading();
        showNotification(`Failed to ${action}: ${error.message}`, 'error');
    });
}

// Notification system
function showNotification(message, type = 'info') {
    const container = document.getElementById('notifications');
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    
    container.appendChild(notification);
    
    // Trigger animation
    setTimeout(() => {
        notification.classList.add('show');
    }, 100);
    
    // Auto remove after 5 seconds
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }, 5000);
}

// Event listeners
document.addEventListener('keydown', function(event) {
    // Enter key in auth modal
    if (event.key === 'Enter' && document.getElementById('authModal').classList.contains('show')) {
        authenticate();
    }
});

// Handle page visibility changes
document.addEventListener('visibilitychange', function() {
    if (document.hidden) {
        stopMonitoring();
    } else if (isAuthenticated) {
        startMonitoring();
    }
});

// Handle window focus/blur
window.addEventListener('focus', function() {
    if (isAuthenticated && !updateTimer) {
        startMonitoring();
    }
});

window.addEventListener('blur', function() {
    // Reduce update frequency when window is not focused
    if (updateTimer) {
        clearInterval(updateTimer);
        updateTimer = setInterval(updateSystemData, 10000); // Update every 10 seconds
    }
});

// Cleanup on page unload
window.addEventListener('beforeunload', function() {
    stopMonitoring();
});