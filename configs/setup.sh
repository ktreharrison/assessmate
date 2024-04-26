#!/bin/bash

# Check if pip is installed
if ! command -v pip &> /dev/null; then
    echo "pip is not installed. Please install pip first."
    exit 1
fi

# Create a virtual environment
python3.10 -m venv .venv
source $(pwd)/.venv/bin/activate
$(pwd)/.venv/bin/python3 -m pip install --upgrade pip

# Install required Python packages
pip install -r configs/requirements.txt

# Install system-level tools
case "$OSTYPE" in
    darwin*)  # macOS
        brew install bandit
        ;;
    linux*)   # Linux
        sudo apt-get update
        sudo apt-get install -y bandit
        ;;
    *)        # Other OS
        echo "Please install the required tools manually for your system."
        ;;
esac

echo "Installation completed successfully!"
