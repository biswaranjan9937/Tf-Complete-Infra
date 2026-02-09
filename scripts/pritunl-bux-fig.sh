#!/bin/bash
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
