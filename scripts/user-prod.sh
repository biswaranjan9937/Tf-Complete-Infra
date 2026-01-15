#!/bin/bash
# This script creates users, generates SSH key pairs, renames keyfiles,
# copies user.pem to home directory, adds users to sudo group, uploads keys to S3,
# sets appropriate permissions, and changes SSH port to 2223
#######################
##MODIFIED FOR ALMALINUX 9 WITH LOGGING##
#######################

# Enable detailed logging
set -x  # Print each command before executing

# Create log directory and set up logging
LOG_DIR="/var/log/scripts"
LOG_FILE="$LOG_DIR/user-creation-$(date +%Y%m%d-%H%M%S).log"
sudo mkdir -p "$LOG_DIR"

# Redirect all output to log file and console
exec > >(tee -a "$LOG_FILE") 2>&1

# Function to log command execution
log_command() {
    echo "=== EXECUTING: $1 at $(date) ==="
    eval "$1"
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "=== SUCCESS: Command completed successfully ==="
    else
        echo "=== FAILED: Command failed with exit code $exit_code ==="
    fi
    echo ""
    return $exit_code
}

echo "=== User Creation Script Started at $(date) ==="
echo "Log file: $LOG_FILE"

# Define usernames to create - MOVED HERE AFTER LOGGING SETUP
user_prefix="prod"
usernames=("${user_prefix}-admin1" "${user_prefix}-admin2")
S3_BUCKET="cwm-s3-loki-logs"

# Debug output to verify variables
echo "DEBUG: user_prefix = '$user_prefix'"
echo "DEBUG: usernames = ${usernames[@]}"
echo "DEBUG: S3_BUCKET = '$S3_BUCKET'"

# Function to check the OS type
get_os_type() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case $ID in
            amzn|amzn2)
                echo "amazon"
                ;;
            ubuntu|debian)
                echo "ubuntu"
                ;;
            centos|rhel|almalinux|rocky)  # Add AlmaLinux and Rocky Linux
                echo "centos"
                ;;
            sles)
                echo "sles"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    else
        echo "unknown"
    fi
}

# Function to install AWS CLI on AlmaLinux 9
install_aws_cli() {
    echo "=== Installing AWS CLI on AlmaLinux 9 ==="

    # Update system
    log_command "sudo dnf update -y"

    # Install required packages
    log_command "sudo dnf install -y curl unzip"

    # Download and install AWS CLI v2
    log_command "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'"
    log_command "unzip awscliv2.zip"
    log_command "sudo ./aws/install"

    # Clean up
    log_command "rm -rf awscliv2.zip aws/"

    # Verify installation
    if command -v aws &> /dev/null; then
        echo "✅ AWS CLI installed successfully!"
        log_command "aws --version"
    else
        echo "❌ AWS CLI installation failed"
        return 1
    fi
}

# Get the OS type
echo "=== Detecting OS Type ==="
os_type=$(get_os_type)
echo "Detected OS: $os_type"

ssh_port=2223

# Check if SSH port is already set to 2223
echo "=== Checking SSH Port Configuration ==="
current_ssh_port=$(sudo awk '$1 == "Port" {print $2}' /etc/ssh/sshd_config)
if [ "$current_ssh_port" == "2223" ]; then
    echo "SSH port is already set to $ssh_port. Continuing with user creation."
else
    # Change SSH port to 2223
    echo "=== Changing SSH Port to 2223 ==="
    log_command "sudo sed -i 's/^#Port 22/Port $ssh_port/' /etc/ssh/sshd_config"
    echo "SSH port has been changed to $ssh_port."

    # Install SELinux tools and configure port
    echo "=== Configuring SELinux for SSH port 2223 ==="
    log_command "sudo dnf install -y policycoreutils-python-utils"
    log_command "sudo semanage port -a -t ssh_port_t -p tcp 2223"
    log_command "sudo semanage port -l | grep ssh"

    # Restart SSH service with error handling
    echo "=== Restarting SSH Service ==="
    if log_command "sudo systemctl restart sshd.service"; then
        echo "SSH service restarted successfully"
        log_command "sudo systemctl status sshd.service"
    else
        echo "⚠️ SSH service restart failed, but continuing with user creation..."
    fi

    # Restart the SSM
    log_command "sudo systemctl restart amazon-ssm-agent.service"
    log_command "sudo systemctl enable amazon-ssm-agent.service"
fi

# Set home directory based on OS (AlmaLinux uses centos path)
echo "=== Setting Home Directory Based on OS ==="
case "$os_type" in
    amazon)
        home_directory="/home/ec2-user"
        default_user="ec2-user"
        ;;
    ubuntu)
        home_directory="/home/ubuntu"
        default_user="ubuntu"
        ;;
    centos)
        home_directory="/home/ec2-user"  # AlmaLinux typically uses ec2-user
        default_user="ec2-user"
        ;;
    sles)
        home_directory="/home/ec2-user"
        default_user="ec2-user"
        ;;
    *)
        echo "Unsupported OS: $os_type"
        exit 1
        ;;
esac

echo "Home directory set to: $home_directory"
echo "Default user set to: $default_user"

# Centralized password file
passwords_file="$home_directory/Usernames-passwd.txt"

# Function to generate a random password
generate_random_password() {
    openssl rand -base64 12
}

# Loop through each username and create users
for username in "${usernames[@]}"; do
    echo "=== Starting user creation for: $username ==="

    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "User '$username' already exists. Skipping... 👋"
        continue
    fi

    # Create the user based on the OS
    echo "=== Creating user: $username ==="
    case "$os_type" in
        amazon)
            log_command "sudo useradd -m '$username'"
            ;;
        ubuntu)
            log_command "sudo useradd -m -s /bin/bash '$username'"
            log_command "sudo usermod -aG sudo '$username'"
            ;;
        centos)
            log_command "sudo useradd -m '$username'"
            log_command "sudo usermod -aG wheel '$username'"
            ;;
        sles)
            log_command "sudo useradd -m '$username' -d '/home/$username'"
            log_command "sudo chown '$username:users' '/home/$username'"
            ;;
        *)
            echo "Unsupported OS: $os_type"
            continue
            ;;
    esac

    # Set a random password for the user
    echo "=== Setting password for user: $username ==="
    random_password=$(generate_random_password)
    log_command "echo '$username:$random_password' | sudo chpasswd"
    echo "$username:$random_password" | tee -a "$passwords_file" > /dev/null
    echo "$username's random password: $random_password"

    # Generate SSH Key Pair
    echo "=== Generating SSH Key Pair for: $username ==="
    log_command "sudo -u '$username' ssh-keygen -t rsa -b 4096 -N '' -f '/home/$username/.ssh/id_rsa'"

    # Rename key files
    echo "=== Renaming SSH key files for: $username ==="
    log_command "sudo -u '$username' mv '/home/$username/.ssh/id_rsa' '/home/$username/.ssh/$username.pem'"
    log_command "sudo -u '$username' mv '/home/$username/.ssh/id_rsa.pub' '/home/$username/.ssh/authorized_keys'"

    # Set proper permissions
    echo "=== Setting SSH key permissions for: $username ==="
    log_command "sudo chmod 700 '/home/$username/.ssh'"
    log_command "sudo chmod 600 '/home/$username/.ssh/$username.pem'"
    log_command "sudo chmod 600 '/home/$username/.ssh/authorized_keys'"

    # Add user to sudoers file
    echo "=== Adding user to sudoers: $username ==="
    log_command "echo '$username ALL=(ALL) NOPASSWD:ALL' | sudo tee -a '/etc/sudoers.d/sudo-users'"

    # Copy user.pem to the default user's home directory
    echo "=== Copying SSH key to default user home: $username ==="
    log_command "sudo cp '/home/$username/.ssh/$username.pem' '$home_directory/'"
    log_command "sudo chmod 400 '$home_directory/$username.pem'"
    log_command "sudo chown '$default_user:$default_user' '$home_directory/$username.pem'"
    echo "🌈 $username.pem copied to $home_directory/ 🏠"

    # Check and install AWS CLI if needed, then upload .pem file to S3
    echo "=== Checking AWS CLI installation ==="
    if ! command -v aws &> /dev/null; then
        echo "⚠️ AWS CLI not found. Installing..."
        install_aws_cli
    fi

    # Upload to S3 if AWS CLI is available
    echo "=== Uploading SSH key to S3 for: $username ==="
    if command -v aws &> /dev/null; then
        log_command "aws s3 cp '/home/$username/.ssh/$username.pem' 's3://$S3_BUCKET/${user_prefix}-credentials/$username.pem'"
        local upload_result=$?
        if [ $upload_result -eq 0 ]; then
            echo "🌈 $username.pem uploaded to S3 bucket: $S3_BUCKET 🚀"
        else
            echo "❌ Failed to upload $username.pem to S3"
        fi
    else
        echo "❌ AWS CLI installation failed. Skipping S3 upload for $username.pem"
    fi

    # Check the existence of the user after creation
    if id "$username" &>/dev/null; then
        echo "✅ User '$username' created and configured successfully! 🎉"
        echo "🔐 SSH key pair generated for user '$username'"
    else
        echo "❌ Error creating user '$username'"
    fi

    echo "=== Completed user creation for: $username ==="
    echo "----------------------------------------"
done

# Upload password file to S3
echo "=== Uploading password file to S3 ==="
if command -v aws &> /dev/null && [ -f "$passwords_file" ]; then
    log_command "aws s3 cp '$passwords_file' 's3://$S3_BUCKET/${user_prefix}-credentials/Usernames-passwd-$(date +%Y%m%d-%H%M%S).txt'"
    local password_upload_result=$?
    if [ $password_upload_result -eq 0 ]; then
        echo "🌈 Password file uploaded to S3 bucket: $S3_BUCKET 🚀"
    else
        echo "❌ Failed to upload password file to S3"
    fi
else
    echo "⚠️ AWS CLI not available or password file not found. Skipping password file upload."
fi

echo "🎉 All users creation process completed!"
echo "📝 Random passwords stored in $passwords_file"
echo "🔑 SSH keys and password file uploaded to S3 bucket: $S3_BUCKET"
echo "🚀 Welcome to AWS+Linux World! Happy Learning! 🥳"
echo "=== User Creation Script Completed at $(date) ==="
echo "Full log saved to: $LOG_FILE"