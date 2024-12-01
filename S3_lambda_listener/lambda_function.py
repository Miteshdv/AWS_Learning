import json
import boto3
import csv
import os

# Initialize S3, DynamoDB, and SNS clients
s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
sns_client = boto3.client('sns')

# Get the DynamoDB table name and SNS topic ARN from environment variables
table_name = os.environ['DYNAMODB_TABLE']
sns_topic_arn = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    # Log the received event
    print("Received event: " + json.dumps(event, indent=2))
    
    # Extract bucket name and object key from the event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']
    
    # Log bucket name and object key
    print(f"Bucket: {bucket_name}, Key: {object_key}")
    
    # Get the object from S3
    response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
    
    # Read the content of the object
    content = response['Body'].read().decode('utf-8')
    
    # Log the content of the object
    print(f"Content of the object: {content}")
    
    # Parse the CSV content
    csv_reader = csv.DictReader(content.splitlines())
    
    # Get the DynamoDB table
    table = dynamodb.Table(table_name)
    
    # Insert each row into DynamoDB
    for row in csv_reader:
        print(f"Inserting row: {row}")
        table.put_item(Item=row)

    # Notify via SNS that the update is complete
    sns_client.publish(
        TopicArn=sns_topic_arn,
        Message=json.dumps({
            'message': 'DynamoDB update is complete',
            'bucket_name': bucket_name,
            'object_key': object_key
        })
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Processing complete')
    }