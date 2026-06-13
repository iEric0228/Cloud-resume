"""Unit tests for the visitor-counter Lambda handler.

Covers the contract the frontend depends on:
- GET atomically increments and returns the new ``visitor_count``
- the increment ADDs to the existing value (never resets it)
- OPTIONS preflight returns 200 with CORS headers
- failures return a generic 500 that does NOT leak internal error detail
"""
import json

import boto3
import pytest
from moto import mock_aws

TABLE_NAME = "cloud-resume-visitor-count-test"
REGION = "us-east-1"


@pytest.fixture
def handler(monkeypatch):
    """Import the handler with a mocked DynamoDB table in place."""
    monkeypatch.setenv("AWS_DEFAULT_REGION", REGION)
    monkeypatch.setenv("AWS_REGION", REGION)
    monkeypatch.setenv("TABLE_NAME", TABLE_NAME)

    with mock_aws():
        ddb = boto3.resource("dynamodb", region_name=REGION)
        ddb.create_table(
            TableName=TABLE_NAME,
            KeySchema=[{"AttributeName": "id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "id", "AttributeType": "S"}],
            BillingMode="PAY_PER_REQUEST",
        )
        import handler as handler_module

        yield handler_module


def _invoke(handler, method="GET"):
    return handler.lambda_handler({"httpMethod": method}, None)


def test_get_increments_from_zero(handler):
    first = _invoke(handler)
    assert first["statusCode"] == 200
    assert json.loads(first["body"])["visitor_count"] == 1

    second = _invoke(handler)
    assert json.loads(second["body"])["visitor_count"] == 2


def test_increment_adds_to_existing_value(handler):
    ddb = boto3.resource("dynamodb", region_name=REGION)
    ddb.Table(TABLE_NAME).put_item(Item={"id": "visitor_count", "count": 41})

    resp = _invoke(handler)
    assert json.loads(resp["body"])["visitor_count"] == 42


def test_get_includes_cors_header(handler):
    resp = _invoke(handler)
    assert resp["headers"]["Access-Control-Allow-Origin"] == "*"


def test_options_preflight(handler):
    resp = _invoke(handler, method="OPTIONS")
    assert resp["statusCode"] == 200
    assert "Access-Control-Allow-Methods" in resp["headers"]


def test_failure_returns_generic_message(handler, monkeypatch):
    # Point at a table that does not exist -> DynamoDB error.
    monkeypatch.setenv("TABLE_NAME", "does-not-exist")
    resp = _invoke(handler)

    assert resp["statusCode"] == 500
    body = json.loads(resp["body"])
    # Must not leak internal exception detail to the client.
    assert "details" not in body
    serialized = json.dumps(body).lower()
    for leak in ("resourcenotfound", "traceback", "exception", "table"):
        assert leak not in serialized
