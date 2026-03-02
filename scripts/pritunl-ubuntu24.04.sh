#!/bin/bash
sudo tee /etc/apt/sources.list.d/mongodb-org.list << EOF
deb [ signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse
EOF

sudo tee /etc/apt/sources.list.d/openvpn.list << EOF
deb [ signed-by=/usr/share/keyrings/openvpn-repo.gpg ] https://build.openvpn.net/debian/openvpn/stable noble main
EOF

sudo tee /etc/apt/sources.list.d/pritunl.list << EOF
deb [ signed-by=/usr/share/keyrings/pritunl.gpg ] https://repo.pritunl.com/stable/apt noble main
EOF

sudo apt --assume-yes install gnupg

curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor --yes
curl -fsSL https://swupdate.openvpn.net/repos/repo-public.gpg | sudo gpg -o /usr/share/keyrings/openvpn-repo.gpg --dearmor --yes
curl -fsSL https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc | sudo gpg -o /usr/share/keyrings/pritunl.gpg --dearmor --yes
sudo apt update
sudo apt --assume-yes install pritunl openvpn mongodb-org wireguard wireguard-tools

sudo ufw disable

sudo systemctl start pritunl mongod
sudo systemctl enable pritunl mongod

### Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

### Install aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip 
unzip awscliv2.zip
sudo ./aws/install

####### Pritunl Bux Fix #######
set -e

echo "Pritunl 404 Fix Script"
echo "======================"

# Must run as root
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root"
   exit 1
fi

# Check config exists
if [[ ! -f /etc/pritunl.conf ]]; then
    echo "Error: /etc/pritunl.conf not found"
    exit 1
fi

# Read MongoDB URI safely
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


###########
# Below setup is for ubuntu 24.04 machine

NEW_PORT=${NEW_PORT}

# Update sshd_config safely (replace any existing Port line or commented Port)
sed -i "s/^#\?Port .*/Port ${NEW_PORT}/" /etc/ssh/sshd_config

# If no Port line exists, append it
grep -q "^Port ${NEW_PORT}" /etc/ssh/sshd_config || echo "Port ${NEW_PORT}" >> /etc/ssh/sshd_config

# If system uses socket activation, update socket port
if systemctl is-enabled ssh.socket >/dev/null 2>&1; then
    sed -i "s/^ListenStream=.*/ListenStream=${NEW_PORT}/" /lib/systemd/system/ssh.socket
    systemctl daemon-reload
    systemctl restart ssh.socket
else
    systemctl restart ssh || systemctl restart sshd
fi

######################
# installing aws cli, kubectl, and helm

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh