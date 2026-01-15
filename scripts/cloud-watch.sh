#!/bin/bash

# step 1: install ssm agent
echo "Installing Amazon SSM Agent..."
sudo dnf install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Step 2: Install required packages and download CloudWatch Agent
dnf install wget unzip -y  # Use dnf for AlmaLinux, not yum
echo "Downloading the Amazon CloudWatch Agent..."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip

# Step 3: Unzip the CloudWatch Agent
echo "Unzipping the Amazon CloudWatch Agent..."
unzip AmazonCloudWatchAgent.zip

# Step 4: Install the CloudWatch Agent
echo "Installing the Amazon CloudWatch Agent..."
sudo ./install.sh

# Step 5: Create the CloudWatch Agent configuration file
echo "Creating the CloudWatch Agent configuration file..."
CONFIG_FILE="/opt/aws/amazon-cloudwatch-agent/bin/config.json"

sudo cat <<EOT > $CONFIG_FILE
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "metrics": {
        "namespace": "CWAgent",
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
        }
    }
}
EOT

# Step 6: Set proper permissions
sudo chown cwagent:cwagent $CONFIG_FILE

# Step 7: Apply the configuration and start the CloudWatch Agent
echo "Applying the configuration and starting the CloudWatch Agent..."
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:$CONFIG_FILE -s

# Step 8: Enable and start the service
echo "Enabling and starting the CloudWatch Agent service..."
sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl start amazon-cloudwatch-agent

# Step 9: Check the status
echo "Checking the status of the CloudWatch Agent service..."
sudo systemctl status amazon-cloudwatch-agent

