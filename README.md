**Custom AMI Creation using AWS CLI and Shell Scripting**

**Description**
This project automates the creation of a custom Amazon Machine Image (AMI) using the AWS CLI. The custom AMI includes commonly used DevOps tools like Ansible, Docker, Jenkins, Python, Node.js, and more. The process is secured with SSH key pairs and environment variables stored separately to ensure best practices in cloud security.

**Features**
🐧 Launch an Ubuntu-based EC2 instance using AWS CLI.

📦 Install essential tools and packages:
Ansible for configuration management.
Docker for containerization.
Jenkins for CI/CD automation.
Python for scripting and development.
Node.js for JavaScript-based applications.
🔒 Secure key management using custom SSH key pairs.
⚙️ Automate the setup and configuration process with a Bash script.
🚀 Create a reusable custom AMI for streamlined deployments.

**Setup and Usage**

**Prerequisites**
An AWS account with permissions to manage EC2 instances.
AWS CLI installed and configured.
Install AWS CLI
Bash shell environment (Linux/MacOS or WSL for Windows).
Key pair available in your AWS account.

**Steps to Run the Project**
**Clone the Repository**

git clone https://github.com/yourusername/custom-ami-project.git
cd custom-ami-project

**Set Up Environment Variables**
Create a .env file in the root directory with the following variables:
IMAGE_ID=<ubuntu-ami-id>
INSTANCE_TYPE=<ec2-instance-type>
KEY_NAME=<your-key-pair-name>
SECURITY_GROUP=<your-security-group-id>
⚠️ Note: Do not commit the .env file to the repository to keep credentials secure.

**Run the Script Execute the Bash script to launch the EC2 instance and configure it:**
bash create_custom_ami.sh
Verify the Custom AMI
After the script completes, the custom AMI will be available in your AWS account under Images > AMIs.

**Tools and Technologies**
**AWS CLI**: Command-line tool for AWS operations.
**Bash**: For automating EC2 instance launch and package installation.
**Ubuntu**: Base operating system for the EC2 instance.
**DevOps Tools**: Ansible, Docker, Jenkins, Python, Node.js.

**Security Practices**
Sensitive variables like AWS region, key pair name, and security group ID are stored in a separate .env file to avoid exposure in public repositories.
Ensure your .env file is added to .gitignore.

**Future Enhancements**
Add support for more customizable tools and configurations.
Automate the retrieval of the latest Ubuntu AMI ID.
Implement error handling and logging for better debugging.
Contributing
Contributions are welcome! Please fork this repository and submit a pull request with your changes.


**Acknowledgments**
Special thanks to the AWS and Ubuntu communities for their excellent documentation and support.

