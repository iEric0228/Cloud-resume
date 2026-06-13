"""Pytest configuration for backend Lambda tests.

Makes ``backend/lambda/handler.py`` importable as ``handler`` without packaging.
"""
import os
import sys

LAMBDA_DIR = os.path.join(
    os.path.dirname(__file__), "..", "backend", "lambda"
)
sys.path.insert(0, os.path.abspath(LAMBDA_DIR))
