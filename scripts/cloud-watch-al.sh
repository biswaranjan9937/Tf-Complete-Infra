#!/bin/bash

set -e

echo "=========================================="
echo "CloudWatch Agent Installation"
echo "=========================================="

ARCH=$(uname -m)

echo "Detected architecture: $ARCH"

if [ "$ARCH" = "aarch64" ]; then
    CW_ARCH="arm64"
elif [ "$ARCH" = "x86_64" ]; then
    CW_ARCH="amd64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

echo "CloudWatch Agent architecture: $CW_ARCH"

echo
echo "Installing required packages..."

dnf install -y wget unzip

echo
echo "Installing Amazon SSM Agent..."

dnf install -y amazon-ssm-agent || true

echo
echo "Starting SSM Agent..."

systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

echo
echo "Downloading Amazon CloudWatch Agent..."

DOWNLOAD_URL="https://s3.amazonaws.com/amazoncloudwatch-agent/linux/${CW_ARCH}/latest/AmazonCloudWatchAgent.zip"

echo "URL: $DOWNLOAD_URL"

wget -O AmazonCloudWatchAgent.zip "$DOWNLOAD_URL"

echo
echo "Unzipping CloudWatch Agent..."

rm -rf cloudwatch-agent-install
mkdir -p cloudwatch-agent-install

unzip -o AmazonCloudWatchAgent.zip -d cloudwatch-agent-install

echo
echo "Installing CloudWatch Agent..."

cd cloudwatch-agent-install

rpm -Uvh amazon-cloudwatch-agent.rpm

cd ..

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
echo "Enabling CloudWatch Agent..."

systemctl enable amazon-cloudwatch-agent
systemctl restart amazon-cloudwatch-agent

echo
echo "=========================================="
echo "CloudWatch Agent Status"
echo "=========================================="

systemctl --no-pager status amazon-cloudwatch-agent

echo
echo "Installation completed."