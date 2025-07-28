#!/bin/bash

APP_DIR="/opt/sample-app"
CONFIG_FILE="$APP_DIR/app.conf"
STATUS_FILE="$APP_DIR/status.json"

echo "[SAMPLE-SCRIPT] Starting minimal provisioning script..."

# Create application directory
mkdir -p "$APP_DIR"

# Write a simple config file
cat > "$CONFIG_FILE" <<EOF
# Sample Config
app_name=CloudInitSampleApp
created_at=$(date)
hostname=$(hostname)
EOF

# Write a simple status file
cat > "$STATUS_FILE" <<EOF
{
  "status": "completed",
  "timestamp": "$(date -Iseconds)"
}
EOF

echo "[SAMPLE-SCRIPT] Provisioning complete."
echo "[SAMPLE-SCRIPT] Config: $CONFIG_FILE"
echo "[SAMPLE-SCRIPT] Status: $STATUS_FILE"

exit 0