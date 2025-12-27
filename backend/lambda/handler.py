import json
import boto3
from botocore.exceptions import ClientError
import os
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def get_cors_headers():
    return {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }


def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    # Handle OPTIONS request for CORS preflight
    if event.get("httpMethod") == "OPTIONS":
        return {
            "statusCode": 200,
            "headers": get_cors_headers(),
            "body": json.dumps({"message": "OK"}),
        }

    try:
        # Get table name from environment variable
        table_name = os.environ.get("TABLE_NAME", "cloud-resume-visitor-count-dev")
        logger.info(f"Using DynamoDB table: {table_name}")

        # Initialize DynamoDB resource
        dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
        table = dynamodb.Table(table_name)

        # Get current count first
        try:
            response = table.get_item(Key={"id": "visitor_count"})
            if "Item" in response:
                current_count = int(response["Item"]["count"])
                logger.info(f"Current visitor count: {current_count}")
            else:
                current_count = 0
                logger.info("No existing visitor count found, starting from 0")
        except ClientError as e:
            logger.error(f"Error getting current count: {e}")
            current_count = 0

        # Increment count
        new_count = current_count + 1
        logger.info(f"Updating count to: {new_count}")

        # Update the count in DynamoDB
        table.update_item(
            Key={"id": "visitor_count"},
            UpdateExpression="SET #count = :val",
            ExpressionAttributeNames={"#count": "count"},
            ExpressionAttributeValues={":val": new_count},
            ReturnValues="UPDATED_NEW",
        )

        logger.info(f"Successfully updated visitor count to: {new_count}")

        return {
            "statusCode": 200,
            "headers": get_cors_headers(),
            "body": json.dumps({"visitor_count": new_count}),
        }

    except ClientError as e:
        error_code = e.response["Error"]["Code"]
        error_message = e.response["Error"]["Message"]
        logger.error(f"DynamoDB error ({error_code}): {error_message}")

        return {
            "statusCode": 500,
            "headers": get_cors_headers(),
            "body": json.dumps(
                {
                    "error": "Failed to update visitor count",
                    "details": f"DynamoDB error: {error_code} - {error_message}",
                }
            ),
        }
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        return {
            "statusCode": 500,
            "headers": get_cors_headers(),
            "body": json.dumps({"error": "Internal server error", "details": str(e)}),
        }
