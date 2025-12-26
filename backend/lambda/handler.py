import boto3
import json
import os
import logging
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def get_cors_headers():
    """Return CORS headers for all responses"""
    return {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
        "Content-Type": "application/json",
    }


def lambda_handler(event, context):
    # Handle OPTIONS requests for CORS preflight
    if event.get("httpMethod") == "OPTIONS":
        return {
            "statusCode": 200,
            "headers": get_cors_headers(),
            "body": json.dumps({"message": "OK"}),
        }

    # Get table name from environment variable
    table_name = os.environ.get("TABLE_NAME")

    if not table_name:
        logger.error("TABLE_NAME environment variable is not set")
        return {
            "statusCode": 500,
            "headers": get_cors_headers(),
            "body": json.dumps({"error": "Configuration error"}),
        }

    try:
        # Connect to DynamoDB
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table(table_name)

        response = table.get_item(Key={"id": "visitor_count"})

        current_count = int(response.get("Item", {}).get("count", 0))
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
            "headers": get_cors_headers(),
            "body": json.dumps({"visitor_count": new_count}),
        }

    except ClientError as e:
        logger.error(f"DynamoDB error: {e}")
        return {
            "statusCode": 500,
            "headers": get_cors_headers(),
            "body": json.dumps({"error": "Failed to update visitor count"}),
        }
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return {
            "statusCode": 500,
            "headers": get_cors_headers(),
            "body": json.dumps({"error": "Internal server error"}),
        }
