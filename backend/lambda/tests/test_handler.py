"""Unit tests for the Cloud Resume visitor counter Lambda handler."""

import json
import os
from unittest.mock import MagicMock, patch

import pytest

# Set env before importing handler
os.environ["TABLE_NAME"] = "test-visitor-count"


@pytest.fixture
def mock_dynamodb_table():
    """Create a mock DynamoDB table."""
    with patch("boto3.resource") as mock_resource:
        mock_table = MagicMock()
        mock_resource.return_value.Table.return_value = mock_table
        yield mock_table


@pytest.fixture
def api_gw_event():
    """Sample API Gateway event."""
    return {
        "httpMethod": "GET",
        "path": "/",
        "headers": {},
        "body": None,
    }


@pytest.fixture
def options_event():
    """Sample OPTIONS preflight event."""
    return {
        "httpMethod": "OPTIONS",
        "path": "/",
        "headers": {},
        "body": None,
    }


class TestCorsHeaders:
    def test_options_returns_200(self, options_event, mock_dynamodb_table):
        from handler import lambda_handler

        response = lambda_handler(options_event, None)

        assert response["statusCode"] == 200
        assert response["headers"]["Access-Control-Allow-Origin"] == "*"
        assert "GET" in response["headers"]["Access-Control-Allow-Methods"]

    def test_response_includes_cors_headers(self, api_gw_event, mock_dynamodb_table):
        mock_dynamodb_table.get_item.return_value = {
            "Item": {"id": "visitor_count", "count": 5}
        }
        mock_dynamodb_table.update_item.return_value = {}

        from handler import lambda_handler

        response = lambda_handler(api_gw_event, None)

        assert "Access-Control-Allow-Origin" in response["headers"]


class TestVisitorCounter:
    def test_increments_existing_count(self, api_gw_event, mock_dynamodb_table):
        mock_dynamodb_table.get_item.return_value = {
            "Item": {"id": "visitor_count", "count": 41}
        }
        mock_dynamodb_table.update_item.return_value = {}

        from handler import lambda_handler

        response = lambda_handler(api_gw_event, None)
        body = json.loads(response["body"])

        assert response["statusCode"] == 200
        assert body["visitor_count"] == 42

    def test_starts_from_zero_when_no_item(self, api_gw_event, mock_dynamodb_table):
        mock_dynamodb_table.get_item.return_value = {}
        mock_dynamodb_table.update_item.return_value = {}

        from handler import lambda_handler

        response = lambda_handler(api_gw_event, None)
        body = json.loads(response["body"])

        assert response["statusCode"] == 200
        assert body["visitor_count"] == 1

    def test_calls_update_item_with_new_count(self, api_gw_event, mock_dynamodb_table):
        mock_dynamodb_table.get_item.return_value = {
            "Item": {"id": "visitor_count", "count": 10}
        }
        mock_dynamodb_table.update_item.return_value = {}

        from handler import lambda_handler

        lambda_handler(api_gw_event, None)

        mock_dynamodb_table.update_item.assert_called_once()
        call_kwargs = mock_dynamodb_table.update_item.call_args[1]
        assert call_kwargs["ExpressionAttributeValues"][":val"] == 11

    def test_handles_dynamodb_client_error(self, api_gw_event, mock_dynamodb_table):
        from botocore.exceptions import ClientError

        mock_dynamodb_table.get_item.side_effect = ClientError(
            {"Error": {"Code": "ResourceNotFoundException", "Message": "Table not found"}},
            "GetItem",
        )
        mock_dynamodb_table.update_item.return_value = {}

        from handler import lambda_handler

        response = lambda_handler(api_gw_event, None)

        # Should still attempt to update with count=1 after get_item fails
        assert response["statusCode"] == 200

    def test_returns_500_on_update_failure(self, api_gw_event, mock_dynamodb_table):
        from botocore.exceptions import ClientError

        mock_dynamodb_table.get_item.return_value = {
            "Item": {"id": "visitor_count", "count": 5}
        }
        mock_dynamodb_table.update_item.side_effect = ClientError(
            {"Error": {"Code": "ConditionalCheckFailedException", "Message": "Update failed"}},
            "UpdateItem",
        )

        from handler import lambda_handler

        response = lambda_handler(api_gw_event, None)

        assert response["statusCode"] == 500
        body = json.loads(response["body"])
        assert "error" in body
