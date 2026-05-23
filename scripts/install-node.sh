#!/bin/bash
# Pop!_OS AI Dev Setup - Node.js + PNPM Installation (Step 10)
# MUST RUN AFTER REBOOT (when ZSH is active)

set -e

echo "🚀 Installing Node.js + PNPM"
echo ""

# Verify ZSH is active
echo "=== Checking shell status ==="
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo ""
    echo "❌ ERROR: ZSH not active!"
    echo "   Current shell: $SHELL"
    echo ""
    echo "Did you reboot after running install-base.sh?"
    echo "Run: chsh -s /usr/bin/zsh && reboot"
    exit 1
fi
echo "✅ ZSH active: $SHELL"

# Install NVM (Node Version Manager)
echo ""
echo "=== Installing NVM ==="
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Load NVM (source zshrc to get NVM)
source ~/.zshrc 2>/dev/null || export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js 20 LTS (latest)
echo ""
echo "=== Installing Node.js 20 LTS ==="
nvm install 20
nvm use 20
nvm alias default 20

# Verify Node
echo ""
echo "=== Verification ==="
node --version
npm --version

# Install PNPM
echo ""
echo "=== Installing PNPM 9 ==="
npm install -g pnpm

# Configure PNPM
pnpm setup
source ~/.zshrc 2>/dev/null || export PNPM_HOME="$HOME/.local/share/pnpm" && export PATH="$PNPM_HOME:$PATH"

# Verify PNPM
echo ""
pnpm --version

# Install useful global packages
echo ""
echo "=== Installing global packages ==="
pnpm add -g typescript ts-node nodemon prettier

echo ""
echo "✅ Node.js + PNPM installed successfully"
echo ""
echo "Versions:"
echo "   Node:    $(node --version)"
echo "   NPM:     $(npm --version)"
echo "   PNPM:    $(pnpm --version)"
echo ""
echo "══════════════════════════════════════════════════════════"
echo "Next step: bash scripts/install-opencode.sh"