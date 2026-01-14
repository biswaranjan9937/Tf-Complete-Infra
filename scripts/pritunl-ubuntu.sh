#!/bin/bash
# Usage: ./init.sh <S3_BUCKET_NAME>
#S3_BUCKET_NAME="${1}"
sudo tee /etc/apt/sources.list.d/mongodb-org.list << EOF
deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse
EOF

sudo tee /etc/apt/sources.list.d/openvpn.list << EOF
deb [ signed-by=/usr/share/keyrings/openvpn-repo.gpg ] https://build.openvpn.net/debian/openvpn/stable jammy main
EOF

sudo tee /etc/apt/sources.list.d/pritunl.list << EOF
deb [ signed-by=/usr/share/keyrings/pritunl.gpg ] https://repo.pritunl.com/stable/apt jammy main
EOF

sudo apt --assume-yes install gnupg
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor --yes
curl -fsSL https://swupdate.openvpn.net/repos/repo-public.gpg | sudo gpg -o /usr/share/keyrings/openvpn-repo.gpg --dearmor --yes
curl -fsSL https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc | sudo gpg -o /usr/share/keyrings/pritunl.gpg --dearmor --yes

sudo ufw disable
sudo apt update
sudo apt --assume-yes install pritunl mongodb-org wireguard-tools
sudo systemctl start mongod pritunl
sudo systemctl enable mongod pritunl

apt install jq -y
#curl -s https://wm-cloudformation-templates.s3.ap-south-1.amazonaws.com/packages/mongo.sh | bash
touch Pritunl-Credentials.txt
#sudo echo "Below information is a case-sensitive Do not share with any one." > Pritunl-Credentials.txt && sudo pritunl default-password | grep -e 'password: \\|username:' | sed 's/\"//g' >> Pritunl-Credentials.txt
echo "Below information is case-sensitive. Do not share with anyone." | sudo tee Pritunl-Credentials.txt > /dev/null && sudo pritunl default-password | grep -e "password: \|username:" | sed "s/\"//g" | sudo tee -a Pritunl-Credentials.txt
aws s3 cp Pritunl-Credentials.txt s3://${S3_BUCKET_NAME}/client/Pritunl-Credentials.txt

sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service