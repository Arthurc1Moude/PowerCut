#!/bin/bash
# PowerCut Linux Installer

set -e

echo "==================================="
echo "PowerCut Linux Installer"
echo "==================================="
echo ""

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed"
    echo "Please install Python 3.8 or later:"
    echo "  sudo apt install python3 python3-pip python3-venv"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "✅ Found Python $PYTHON_VERSION"

# Check if running in PowerCut directory
if [ ! -f "powercut.py" ]; then
    echo "❌ Please run this script from the powercut-linux directory"
    exit 1
fi

# Create virtual environment
echo ""
echo "Creating virtual environment..."
python3 -m venv venv

# Activate and install dependencies
echo "Installing dependencies..."
source venv/bin/activate
pip install --upgrade pip > /dev/null 2>&1
pip install -r requirements.txt

echo ""
echo "==================================="
echo "✅ Installation Complete!"
echo "==================================="
echo ""
echo "To run PowerCut:"
echo "  ./run.sh"
echo ""
echo "Or:"
echo "  source venv/bin/activate"
echo "  python3 powercut.py"
echo ""
