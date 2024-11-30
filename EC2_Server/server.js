const express = require('express');
const AWS = require('aws-sdk');

const app = express();
const port = 3001;

// Configure AWS SDK
AWS.config.update({
    region: 'us-west-2',
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
});

const sqs = new AWS.SQS();

// SQS queue URL
const queueURL = process.env.SQS_URL;

// Function to poll SQS queue
const pollQueue = () => {
    const params = {
        QueueUrl: queueURL,
        MaxNumberOfMessages: 10,
        WaitTimeSeconds: 20,
    };

    sqs.receiveMessage(params, (err, data) => {
        if (err) {
            console.error('Error receiving message', err);
        } else if (data.Messages) {
            data.Messages.forEach((message) => {
                console.log('Received message:', message.Body);

                // Process the message here

                // Delete the message after processing
                const deleteParams = {
                    QueueUrl: queueURL,
                    ReceiptHandle: message.ReceiptHandle,
                };

                sqs.deleteMessage(deleteParams, (err) => {
                    if (err) {
                        console.error('Error deleting message', err);
                    } else {
                        console.log('Message deleted');
                    }
                });
            });
        }
    });
};

// Start polling the queue
setInterval(pollQueue, 20000); // Poll every 20 seconds

app.listen(port, () => {
    console.log(`Express server listening at http://localhost:${port}`);
});


// Error handling
process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});