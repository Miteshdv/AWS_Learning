const express = require('express');
const AWS = require('aws-sdk');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });
const fs = require('fs');
const path = require('path');
const WebSocket = require('ws');
const axios = require('axios');
const dotenv = require('dotenv');

// Load environment variables from .env file
dotenv.config();

const app = express();
const port = 3001;

// Middleware to parse JSON bodies
app.use(express.json({
    type: [
        'application/json',
        'text/plain', // AWS sends this content-type for its messages/notifications
    ],
}));
app.use(express.urlencoded({ extended: true }));

// Serve static files from the React app build directory
app.use(express.static(path.join(__dirname, 'address-info/build')));

// Configure AWS SDK
AWS.config.update({
    region: 'us-west-2',
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
});

const sns = new AWS.SNS();
const s3 = new AWS.S3();
const dynamodb = new AWS.DynamoDB.DocumentClient();

// Environment variables
const topicARN = process.env.SNS_TOPIC_ARN;
const bucketName = process.env.S3_BUCKET_NAME;
const tableName = process.env.DYNAMODB_TABLE_NAME;

// Log environment variables to verify they are set
console.log('Environment Variables:');
console.log('SNS_TOPIC_ARN:', topicARN);
console.log('AWS_ACCESS_KEY_ID:', process.env.AWS_ACCESS_KEY_ID);
console.log('AWS_SECRET_ACCESS_KEY:', process.env.AWS_SECRET_ACCESS_KEY);
console.log('S3_BUCKET_NAME:', bucketName);
console.log('DYNAMODB_TABLE_NAME:', tableName);

// Create a writable stream for logs
const logStream = fs.createWriteStream(path.join(__dirname, 'server.log'), { flags: 'a' });

// Override console methods to write to the log file
console.log = (message, ...optionalParams) => {
    logStream.write(`[LOG] ${new Date().toISOString()} - ${message} ${optionalParams.join(' ')}\n`);
    process.stdout.write(`[LOG] ${new Date().toISOString()} - ${message} ${optionalParams.join(' ')}\n`);
};

console.error = (message, ...optionalParams) => {
    logStream.write(`[ERROR] ${new Date().toISOString()} - ${message} ${optionalParams.join(' ')}\n`);
    process.stderr.write(`[ERROR] ${new Date().toISOString()} - ${message} ${optionalParams.join(' ')}\n`);
};

// WebSocket server
const wss = new WebSocket.Server({ noServer: true });

wss.on('connection', (ws) => {
    console.log('WebSocket client connected');
});

// Function to handle incoming messages from SNS
const handleMessage = async (message) => {
    console.log('Received message:', message);

    try {
        // Send the received message to WebSocket clients
        wss.clients.forEach((client) => {
            if (client.readyState === WebSocket.OPEN) {
                client.send(JSON.stringify({ message }));
            }
        });
        console.log('Message sent to WebSocket clients successfully');
    } catch (error) {
        console.error('Error processing message', error);
    }
};

// Endpoint to receive SNS notifications
app.post('/sns', (req, res) => {
    const messageType = req.headers['x-amz-sns-message-type'];

    if (messageType === 'SubscriptionConfirmation') {
        console.log('SubscriptionConfirmation message received:');
        console.log('Headers:', req.headers);
        console.log('Body:', req.body); // Log the entire request body

        const subscribeUrl = req.body.SubscribeURL;
        console.log('Subscription confirmation URL:', subscribeUrl); // Log the SubscribeURL

        axios.get(subscribeUrl)
            .then(() => {
                console.log('Subscription confirmed');
                res.send('Subscription confirmed');
            })
            .catch((error) => {
                console.error('Error confirming subscription', error);
                res.status(500).send('Error confirming subscription');
            });
    } else if (messageType === 'Notification') {
        const message = req.body.Message;
        handleMessage(message);
        res.send('Notification received');
    } else {
        res.status(400).send('Invalid message type');
    }
});

// API route to upload a file to S3
app.post('/upload', upload.single('file'), (req, res) => {
    const fileContent = fs.readFileSync(req.file.path);
    const fileName = req.file.originalname;
    const fileFormat = path.extname(fileName);

    const params = {
        Bucket: bucketName,
        Key: fileName,
        Body: fileContent,
        Metadata: {
            format: fileFormat
        }
    };

    s3.upload(params, (err, data) => {
        if (err) {
            console.error('Error uploading file', err);
            res.status(500).send(`Error uploading file to S3: ${JSON.stringify(err)}`);
        } else {
            console.log('File uploaded successfully', data);
            res.status(200).send(`File uploaded successfully, ${JSON.stringify(data)}`);
        }
    });
});

// API route to get data from DynamoDB
app.get('/data', (req, res) => {
    const params = {
        TableName: tableName,
        Key: {
            id: req.query.id,
        },
    };

    dynamodb.get(params, (err, data) => {
        if (err) {
            console.error('Error getting data from DynamoDB', err);
            res.status(500).send(`Error getting data from DynamoDB: ${JSON.stringify(err)}`);
        } else {
            console.log('Data retrieved successfully', JSON.stringify(data));
            res.status(200).json(data);
        }
    });
});

// API route to get all data from DynamoDB
app.get('/all-data', (req, res) => {
    const params = {
        TableName: tableName,
    };

    dynamodb.scan(params, (err, data) => {
        if (err) {
            console.error('Error scanning DynamoDB table', err);
            res.status(500).send(`Error scanning DynamoDB table: ${JSON.stringify(err)}`);
        } else {
            console.log('All data retrieved successfully', data);
            res.status(200).json(data.Items);
        }
    });
});

// Catch-all route to serve the React app
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'address-info/build', 'index.html'));
});

// Start the server
const server = app.listen(port, () => {
    console.log(`Express server listening at http://localhost:${port}`);
});

// Upgrade HTTP server to handle WebSocket connections
server.on('upgrade', (request, socket, head) => {
    wss.handleUpgrade(request, socket, head, (ws) => {
        wss.emit('connection', ws, request);
    });
});

// Error handling
process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});