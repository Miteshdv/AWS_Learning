#!/bin/bash
sudo apt-get update

# Install the latest version of Node.js and npm from NodeSource
curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PM2 globally
sudo npm install -g pm2

# Create .env file with environment variables
cat <<EOL >> /home/ubuntu/.env
SNS_TOPIC_ARN=${sns_topic_arn}
AWS_ACCESS_KEY_ID=${aws_access_key}
AWS_SECRET_ACCESS_KEY=${aws_secret_key}
S3_BUCKET_NAME=${s3_bucket_name}
DYNAMODB_TABLE_NAME=${dynamodb_table_name}
EOL

# Log environment variables
echo "SNS_TOPIC_ARN=${sns_topic_arn}"
echo "AWS_ACCESS_KEY_ID=${aws_access_key}"
echo "AWS_SECRET_ACCESS_KEY=${aws_secret_key}"
echo "S3_BUCKET_NAME=${s3_bucket_name}"
echo "DYNAMODB_TABLE_NAME=${dynamodb_table_name}"

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
npm install express aws-sdk multer axios ws body-parser dotenv

# Stop any existing processes using port 3000 and 3001
sudo fuser -k 3000/tcp
sudo fuser -k 3001/tcp

# Stop any existing PM2 processes
pm2 delete all

# Start the Express server using PM2
pm2 start /home/ubuntu/server.js --name server

# Save the PM2 process list and have it resurrect on reboot
pm2 save
pm2 startup systemd -u ubuntu --hp /home/ubuntu