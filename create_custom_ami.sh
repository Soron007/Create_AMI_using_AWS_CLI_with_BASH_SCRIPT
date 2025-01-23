#!/bin/bash

# Loading variables from config.env (did not push to github)
if [ -f config.env ]; then
    source config.env
else
    echo "Error: config.env file not found!"
    exit 1
fi


if [[ -z "$BASE_AMI" || -z "$INSTANCE_TYPE" || -z "$KEY_NAME" || -z "$SECURITY_GROUP" || -z "$SUBNET_ID" ]]; then
    echo "Error: One or more required variables are missing in config.env"
    exit 1
fi


AMI_NAME="CustomAMI-Ubuntu-$(date +%Y-%m-%d)"


echo "Launching EC2 instance with Ubuntu..."
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $BASE_AMI \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SECURITY_GROUP \
    --subnet-id $SUBNET_ID \
    --query "Instances[0].InstanceId" \
    --output text)

if [[ -z "$INSTANCE_ID" ]]; then
    echo "Error: Failed to launch instance."
    exit 1
fi

echo "Instance ID: $INSTANCE_ID"


echo "Waiting for the instance to be running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
echo "Instance is running."


PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text)

if [[ -z "$PUBLIC_IP" ]]; then
    echo "Error: Failed to retrieve public IP."
    exit 1
fi

echo "Public IP: $PUBLIC_IP"
echo "Installing software on the instance..."

ssh -o StrictHostKeyChecking=no -i "$KEY_NAME.pem" ubuntu@$PUBLIC_IP <<EOF
    sudo apt-get update -y
    sudo apt-get upgrade -y

    # For Docker
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu

    # For Ansible
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt-get install -y ansible

    # For Jenkins
    sudo apt-get install -y openjdk-11-jdk
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    sudo apt-get update
    sudo apt-get install -y jenkins
    sudo systemctl start jenkins
    sudo systemctl enable jenkins

    # Install Python
    sudo apt-get install -y python3 python3-pip

    # Install Node.js
    curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt-get install -y nodejs
EOF

# Step 4: Create AMI
echo "Creating custom AMI..."
AMI_ID=$(aws ec2 create-image \
    --instance-id $INSTANCE_ID \
    --name $AMI_NAME \
    --description "Custom Ubuntu AMI with Ansible, Docker, Jenkins, Python, Node.js" \
    --no-reboot \
    --query "ImageId" \
    --output text)

if [[ -z "$AMI_ID" ]]; then
    echo "Error: Failed to create AMI."
    exit 1
fi

echo "AMI ID: $AMI_ID"

# Terminating the Instance after creating custom AMI
echo "Terminating the EC2 instance..."
aws ec2 terminate-instances --instance-ids $INSTANCE_ID
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
echo "Instance terminated."

echo "Custom AMI created successfully with ID: $AMI_ID"
