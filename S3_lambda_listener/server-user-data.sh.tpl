#!/bin/bash
sudo apt-get update

# Install the latest version of Node.js and npm from NodeSource
curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 globally
sudo npm install -g pm2

# Set environment variables in a file
cat <<EOL >> /home/ubuntu/env-vars.sh
export SNS_TOPIC_ARN=${sns_topic_arn}
export AWS_ACCESS_KEY_ID=${aws_access_key}
export AWS_SECRET_ACCESS_KEY=${aws_secret_key}
export S3_BUCKET_NAME=${s3_bucket_name}
export DYNAMODB_TABLE_NAME=${dynamodb_table_name}
EOL

# Source the environment variables file
echo "source /home/ubuntu/env-vars.sh" >> /home/ubuntu/.bashrc
source /home/ubuntu/env-vars.sh

# Log environment variables
echo "SNS_TOPIC_ARN=${sns_topic_arn}"
echo "AWS_ACCESS_KEY_ID=${aws_access_key}"
echo "AWS_SECRET_ACCESS_KEY=${aws_secret_key}"
echo "S3_BUCKET_NAME=${s3_bucket_name}"
echo "DYNAMODB_TABLE_NAME=${dynamodb_table_name}"

# Clone the React project repository
git clone https://github.com/Miteshdv/address-info-ui.git /home/ubuntu/address-info

# Change to the project directory
cd /home/ubuntu/address-info

# Install project dependencies
npm install

# Build the React project
npm run build

# Install serve to serve the React app
sudo npm install -g serve

# Serve the React app using PM2
pm2 serve build 3000 --name "address-info"

# Create the Express server script
cat << 'EOL' > /home/ubuntu/server.js
${server_js_content}
EOL

# Change to the home directory
cd /home/ubuntu

# Initialize a new Node.js project and install dependencies
npm init -y
npm install express aws-sdk multer axios ws body-parser dotenv

# Stop any existing processes using port 3001
sudo fuser -k 3001/tcp

# Stop any existing PM2 processes
pm2 delete all

# Start the Express server using PM2
pm2 start /home/ubuntu/server.js --name server

# Save the PM2 process list and have it resurrect on reboot
pm2 save
pm2 startup systemd -u ubuntu --hp /home/ubuntu