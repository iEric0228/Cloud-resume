"""Visitor-counter Lambda.

Atomically increments a single DynamoDB counter and returns the new value.
Behind API Gateway (AWS_PROXY). The frontend reads ``visitor_count`` from the
JSON body.
"""
import json
import logging
import os

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

DEFAULT_TABLE_NAME = "cloud-resume-visitor-count-dev"
COUNTER_KEY = {"id": "visitor_count"}


def get_cors_headers():
    return {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": get_cors_headers(),
        "body": json.dumps(body),
    }


def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))

    # CORS preflight
    if event.get("httpMethod") == "OPTIONS":
        return _response(200, {"message": "OK"})

    table_name = os.environ.get("TABLE_NAME", DEFAULT_TABLE_NAME)
    region = os.environ.get("AWS_REGION", "us-east-1")

    try:
        table = boto3.resource("dynamodb", region_name=region).Table(table_name)

        # Atomic increment. DynamoDB `ADD` treats a missing attribute as 0, so
        # concurrent invocations can never read-modify-write over each other and
        # lose a count. This replaces the previous get_item + SET race.
        result = table.update_item(
            Key=COUNTER_KEY,
            UpdateExpression="ADD #count :inc",
            ExpressionAttributeNames={"#count": "count"},
            ExpressionAttributeValues={":inc": 1},
            ReturnValues="UPDATED_NEW",
        )
        new_count = int(result["Attributes"]["count"])
        logger.info("Visitor count incremented to %s", new_count)

        return _response(200, {"visitor_count": new_count})

    except ClientError as e:
        # Log full detail server-side; return a generic message to the client
        # so internal error codes are never leaked in the response body.
        error_code = e.response.get("Error", {}).get("Code", "Unknown")
        logger.error("DynamoDB error (%s)", error_code, exc_info=True)
        return _response(500, {"error": "Failed to update visitor count"})

    except Exception:
        logger.error("Unexpected error", exc_info=True)
        return _response(500, {"error": "Internal server error"})
