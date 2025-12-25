import boto3
import json
import os
import logging
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    # Get table name from environment variable
    table_name = os.environ.get("TABLE_NAME")

    # What should happen if TABLE_NAME is not set?
    # Add error handling here!
    if not table_name:
        logger.error("TABLE_NAME environment variable is not set")
        raise ValueError("TABLE_NAME environment variable is not set")
    try:
        # Connect to DynamoDB
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table(table_name)

        response = table.get_item(Key={"id": "visitor_count"})

        current_count = int(
            response.get("Item", {}).get("count", 0)
        )  # Convert to int first
        new_count = current_count + 1

        table.update_item(
            Key={"id": "visitor_count"},
            UpdateExpression="SET #count = #count + :val",
            ExpressionAttributeNames={"#count": "count"},
            ExpressionAttributeValues={":val": 1},
            ReturnValues="UPDATED_NEW",
        )

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET",
                "Content-Type": "application/json",
            },
            "body": json.dumps({"visitor_count": new_count}),
        }
    except ClientError as e:
        logger.error(f"DynamoDB error: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Failed to update visitor count"}),
        }
