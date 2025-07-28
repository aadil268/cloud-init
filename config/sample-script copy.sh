#!/bin/bash
# Sample script to be executed by cloud-init
# This script demonstrates various system operations and configurations

LOG_PREFIX="[SAMPLE-SCRIPT]"

echo "$LOG_PREFIX Starting sample script execution at $(date)"

# Function to log messages
log_message() {
    echo "$LOG_PREFIX $(date): $1"
}

# System Information Collection
log_message "Collecting system information..."

log_message "Hostname: $(hostname)"
log_message "Operating System: $(lsb_release -d | cut -f2)"
log_message "Kernel Version: $(uname -r)"
log_message "Architecture: $(uname -m)"
log_message "Uptime: $(uptime)"

# Network Configuration
log_message "Network configuration:"
ip addr show | grep -E "inet |inet6 " | awk '{print $2}' | while read ip; do
    log_message "IP Address: $ip"
done

# Disk Space Information
log_message "Disk space information:"
df -h | while read line; do
    log_message "Disk: $line"
done

# Memory Information
log_message "Memory information:"
free -h | while read line; do
    log_message "Memory: $line"
done

# CPU Information
log_message "CPU information:"
log_message "CPU Model: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)"
log_message "CPU Cores: $(nproc)"

# Create a sample application directory
APP_DIR="/opt/sample-app"
log_message "Creating sample application directory: $APP_DIR"
mkdir -p $APP_DIR

# Create a simple configuration file
CONFIG_FILE="$APP_DIR/app.conf"
log_message "Creating configuration file: $CONFIG_FILE"
cat > $CONFIG_FILE << EOF
# Sample Application Configuration
app_name=CloudInitSampleApp
version=1.0.0
environment=production
created_at=$(date)
hostname=$(hostname)
EOF

# Create a simple status file
STATUS_FILE="$APP_DIR/status.json"
log_message "Creating status file: $STATUS_FILE"
cat > $STATUS_FILE << EOF
{
  "status": "running",
  "timestamp": "$(date -Iseconds)",
  "hostname": "$(hostname)",
  "uptime": "$(uptime -p)",
  "load_average": "$(uptime | awk -F'load average:' '{print $2}')",
  "disk_usage": {
    "root": "$(df -h / | awk 'NR==2 {print $5}')"
  },
  "memory_usage": {
    "used": "$(free -h | awk 'NR==2{printf "%.1f%%", $3/$2*100}')"
  }
}
EOF

# Install additional packages if needed
log_message "Installing additional packages..."
apt-get update -qq
apt-get install -y -qq tree figlet > /dev/null 2>&1

# Create a welcome message
log_message "Creating welcome message..."
figlet "Cloud-Init" > /etc/motd
echo "" >> /etc/motd
echo "Welcome to your Ubuntu VM provisioned with cloud-init!" >> /etc/motd
echo "Provisioned on: $(date)" >> /etc/motd
echo "Hostname: $(hostname)" >> /etc/motd
echo "" >> /etc/motd
echo "Sample application files are located in: $APP_DIR" >> /etc/motd
echo "Logs are available in: /var/log/cloudinit-scripts/" >> /etc/motd
echo "" >> /etc/motd

# Create a simple monitoring script
MONITOR_SCRIPT="$APP_DIR/monitor.sh"
log_message "Creating monitoring script: $MONITOR_SCRIPT"
cat > $MONITOR_SCRIPT << 'EOF'
#!/bin/bash
# Simple monitoring script

while true; do
    echo "$(date): System Status Check"
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo "Memory Usage: $(free -h | awk 'NR==2{printf "Used: %s/%s (%.1f%%)", $3,$2,$3/$2*100}')"
    echo "Disk Usage: $(df -h / | awk 'NR==2 {printf "Used: %s/%s (%s)", $3,$2,$5}')"
    echo "---"
    sleep 60
done
EOF
chmod +x $MONITOR_SCRIPT

# Create a systemd service for the monitoring script (optional)
SERVICE_FILE="/etc/systemd/system/sample-monitor.service"
log_message "Creating systemd service: $SERVICE_FILE"
cat > $SERVICE_FILE << EOF
[Unit]
Description=Sample Monitoring Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=$MONITOR_SCRIPT
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable the service (but don't start it automatically)
systemctl daemon-reload
systemctl enable sample-monitor.service

# Set up log rotation for our custom logs
LOGROTATE_CONFIG="/etc/logrotate.d/cloudinit-scripts"
log_message "Setting up log rotation: $LOGROTATE_CONFIG"
cat > $LOGROTATE_CONFIG << EOF
/var/log/cloudinit-scripts/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF

# Create a summary report
REPORT_FILE="$APP_DIR/provisioning-report.txt"
log_message "Creating provisioning report: $REPORT_FILE"
cat > $REPORT_FILE << EOF
Ubuntu VM Provisioning Report
=============================

Provisioning Date: $(date)
Hostname: $(hostname)
Operating System: $(lsb_release -d | cut -f2)
Kernel Version: $(uname -r)
Architecture: $(uname -m)

Network Configuration:
$(ip addr show | grep -E "inet |inet6 " | awk '{print "  " $2}')

Disk Usage:
$(df -h | grep -E "^/dev" | awk '{print "  " $1 ": " $3 "/" $2 " (" $5 " used)"}')

Memory:
$(free -h | awk 'NR==2{print "  Total: " $2 ", Used: " $3 ", Available: " $7}')

Installed Packages:
  Total packages: $(dpkg -l | grep -c "^ii")

Created Files:
  - Configuration: $CONFIG_FILE
  - Status: $STATUS_FILE
  - Monitor Script: $MONITOR_SCRIPT
  - Service: $SERVICE_FILE
  - This Report: $REPORT_FILE

Services:
  - sample-monitor.service (enabled, not started)

Log Files:
  - Main script: /var/log/cloudinit-scripts/main-script.log
  - Cloud-init: /var/log/cloud-init.log
  - Cloud-init output: /var/log/cloud-init-output.log

Next Steps:
  1. Start monitoring service: sudo systemctl start sample-monitor.service
  2. Check service status: sudo systemctl status sample-monitor.service
  3. View logs: sudo journalctl -u sample-monitor.service -f
  4. Check application status: cat $STATUS_FILE

EOF

# Final status update
log_message "Updating final status..."
jq '.status = "completed" | .completion_time = "'$(date -Iseconds)'"' $STATUS_FILE > ${STATUS_FILE}.tmp && mv ${STATUS_FILE}.tmp $STATUS_FILE

log_message "Sample script execution completed successfully!"
log_message "Check the following files for more information:"
log_message "  - Provisioning report: $REPORT_FILE"
log_message "  - Application status: $STATUS_FILE"
log_message "  - Configuration: $CONFIG_FILE"

echo "$LOG_PREFIX Script completed at $(date)"
exit 0

