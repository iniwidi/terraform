#!/bin/bash

set -e

echo "[INFO] Updating package index..."
sudo apt-get update -y

# Install dependencies
echo "[INFO] Installing wget if not available..."
sudo apt-get install -y wget

# Download and install CloudWatch Agent
echo "[INFO] Downloading CloudWatch Agent package..."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb -O /tmp/amazon-cloudwatch-agent.deb

echo "[INFO] Installing CloudWatch Agent..."
sudo dpkg -i /tmp/amazon-cloudwatch-agent.deb

# Buat konfigurasi CloudWatch Agent untuk log syslog dan nginx
echo "[INFO] Creating CloudWatch Agent config..."
sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json > /dev/null <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/syslog",
            "log_group_name": "syslog",
            "log_stream_name": "{instance_id}-syslog",
            "timestamp_format": "%b %d %H:%M:%S"
          },
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "nginx-access",
            "log_stream_name": "{instance_id}-access",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "nginx-error",
            "log_stream_name": "{instance_id}-error",
            "timestamp_format": "%Y/%m/%d %H:%M:%S"
          }
        ]
      }
    }
  }
}
EOF

# Start the CloudWatch agent
echo "[INFO] Starting CloudWatch Agent service..."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
  -s

echo "[SUCCESS] CloudWatch Agent has been installed and started successfully."