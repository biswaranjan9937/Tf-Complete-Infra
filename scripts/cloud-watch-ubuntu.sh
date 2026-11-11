#!/bin/bash

set -e

echo "=========================================="
echo " CloudWatch Agent Installation"
echo "=========================================="

ARCH=$(uname -m)

case "$ARCH" in
    x86_64)
        AWS_ARCH="amd64"
        ;;
    aarch64|arm64)
        AWS_ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Detected OS architecture : $ARCH"
echo "CloudWatch Agent package : $AWS_ARCH"

echo
echo "Installing Amazon SSM Agent..."

snap install amazon-ssm-agent --classic || true

echo
echo "Installing required packages..."

apt-get update
apt-get install -y wget unzip

echo
echo "Downloading Amazon CloudWatch Agent..."

DOWNLOAD_URL="https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/${AWS_ARCH}/latest/amazon-cloudwatch-agent.deb"

echo "Download URL:"
echo "$DOWNLOAD_URL"

wget -O amazon-cloudwatch-agent.deb "$DOWNLOAD_URL"

echo
echo "Installing Amazon CloudWatch Agent..."

dpkg -i amazon-cloudwatch-agent.deb

echo
echo "Creating CloudWatch Agent configuration..."

mkdir -p /opt/aws/amazon-cloudwatch-agent/etc

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'EOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "cwagent"
  },
  "metrics": {
    "append_dimensions": {
      "InstanceId": "${aws:InstanceId}"
    },
    "metrics_collected": {
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "/"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    },
    "namespace": "CWAgent"
  }
}
EOF

echo
echo "Applying CloudWatch Agent configuration..."

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
  -s

echo
echo "Enabling CloudWatch Agent service..."

systemctl enable amazon-cloudwatch-agent
systemctl restart amazon-cloudwatch-agent

echo
echo "=========================================="
echo " CloudWatch Agent Status"
echo "=========================================="

systemctl --no-pager status amazon-cloudwatch-agent

echo
echo "Installation completed successfully."