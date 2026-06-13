"""Make ``handler.py`` (one directory up) importable as ``handler``."""
import os
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
