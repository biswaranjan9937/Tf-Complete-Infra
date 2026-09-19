#!/bin/bash
set -e

sudo tee /etc/yum.repos.d/mongodb-org.repo << EOF
[mongodb-org]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/8.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://pgp.mongodb.com/server-8.0.asc
EOF

sudo tee /etc/yum.repos.d/pritunl.repo << EOF
[pritunl]
name=Pritunl Repository
baseurl=https://repo.pritunl.com/stable/yum/amazonlinux/2023/
gpgcheck=1
enabled=1
gpgkey=https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc
EOF

sudo dnf -y update

sudo dnf -y install pritunl pritunl-openvpn wireguard-tools mongodb-org
sudo systemctl enable mongod pritunl
sudo systemctl start mongod pritunl

### Install kubectl
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

### Install AWS CLI
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo dnf -y install unzip
unzip awscliv2.zip
sudo ./aws/install

####### Pritunl Bug Fix #######
echo "Pritunl 404 Fix Script"
echo "======================"

if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root"
   exit 1
fi

if [[ ! -f /etc/pritunl.conf ]]; then
    echo "Error: /etc/pritunl.conf not found"
    exit 1
fi

current_uri=$(grep -o '"mongodb_uri": "[^"]*"' /etc/pritunl.conf | cut -d'"' -f4 || true)

if [[ -z "$current_uri" ]]; then
    echo "Found empty MongoDB URI - applying fix..."

    backup="/etc/pritunl.conf.backup.$(date +%Y%m%d_%H%M%S)"
    cp /etc/pritunl.conf "$backup"
    echo "Backup created: $backup"

    sed -i 's/"mongodb_uri": ""/"mongodb_uri": "mongodb:\/\/localhost:27017\/pritunl"/' /etc/pritunl.conf
    echo "MongoDB URI updated"

    systemctl restart pritunl
    echo "Pritunl service restarted"

    sleep 10

    if systemctl is-active --quiet pritunl; then
        echo "✓ Pritunl service is running"

        if curl -k -s https://localhost/login | grep -qi "<html"; then
            echo "✓ Web interface is responding correctly"
            echo "Fix completed successfully!"
        else
            echo "Service running but web interface may need more time"
        fi
    else
        echo "✗ Pritunl service failed to start"
        exit 1
    fi
else
    echo "MongoDB URI already configured: $current_uri"
    echo "No fix needed"
fi

### SSH Port Change
NEW_PORT=${NEW_PORT:-2223}

sed -i "s/^#\?Port .*/Port $NEW_PORT/" /etc/ssh/sshd_config
grep -q "^Port $NEW_PORT" /etc/ssh/sshd_config || echo "Port $NEW_PORT" >> /etc/ssh/sshd_config
systemctl restart sshd
systemctl status sshd

### Helm installation
sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
