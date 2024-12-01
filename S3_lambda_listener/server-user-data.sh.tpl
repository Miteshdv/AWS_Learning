#!/bin/bash
sudo apt-get update

# Install the latest version of Node.js and npm from NodeSource
curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 globally
sudo npm install -g pm2

# Set environment variables
echo "export SNS_TOPIC_ARN=${sns_topic_arn}" >> /home/ubuntu/.bashrc
echo "export AWS_ACCESS_KEY_ID=${aws_access_key}" >> /home/ubuntu/.bashrc
echo "export AWS_SECRET_ACCESS_KEY=${aws_secret_key}" >> /home/ubuntu/.bashrc

# Log environment variables
echo "SNS_TOPIC_ARN=${sns_topic_arn}"
echo "AWS_ACCESS_KEY_ID=${aws_access_key}"
echo "AWS_SECRET_ACCESS_KEY=${aws_secret_key}"

# Create the Express server script
cat << 'EOL' > /home/ubuntu/server.js
${server_js_content}
EOL

# Create the HTML file
cat << 'EOL' > /home/ubuntu/index.html
${index_html_content}
EOL

# Change to the home directory
cd /home/ubuntu

# Initialize a new Node.js project and install dependencies
npm init -y
npm install express aws-sdk multer axios ws

# Stop any existing processes using port 3000 and 3001
sudo fuser -k 3000/tcp
sudo fuser -k 3001/tcp

# Stop any existing PM2 processes
pm2 delete all

# Start the Express server using PM2
pm2 start /home/ubuntu/server.js --name server

# Wait for a few seconds to allow the server to start
sleep 10

# Check if the server is running using PM2
pm2 list

# Check if the server is listening on port 3001 and log the output
if sudo lsof -i :3001; then
  echo "Express server is running and listening on port 3001"
  sudo lsof -i :3001
else
  echo "Express server is not running or not listening on port 3001"
fi

# Check PM2 logs for the server
pm2 logs server