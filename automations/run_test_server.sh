#!/bin/bash
# Quick start script for the location test server

# Change to script directory
cd "$(dirname "$0")"

# Activate virtual environment
source venv/bin/activate

# Run the server
python test_location_server.py
