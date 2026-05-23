#!/bin/bash
# Pop!_OS AI Dev Setup - Python + uv (Step 17)

set -e

echo "🚀 Installing Python 3 + uv"
echo ""

# Verify Python
echo "=== Checking Python ==="
python3 --version || echo "❌ Python not found (should be pre-installed on Pop!_OS 24.04)"

# Install uv
echo ""
echo "=== Installing uv ==="
curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv to PATH (reload shell config)
source ~/.zshrc 2>/dev/null || source ~/.bashrc

# Verify
echo ""
echo "=== Verification ==="
uv --version || echo "❌ uv not found - may need to restart terminal"

echo ""
echo "✅ Python + uv installed"
echo ""
echo "Usage examples:"
echo "   uv venv                  # create virtual environment"
echo "   uv pip install fastapi   # install packages"
echo "   uv run python script.py  # run without activating venv"