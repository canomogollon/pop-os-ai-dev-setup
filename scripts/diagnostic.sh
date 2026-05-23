#!/bin/bash
# Pop!_OS AI Dev Setup - Diagnostic Tool
# Checks installation status and identifies missing components

echo "╔══════════════════════════════════════════════════════════╗"
echo "║       Pop!_OS AI Dev Setup - Diagnostic Tool             ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Status indicators
GREEN="✅"
RED="❌"
YELLOW="⚠️ "

# Helper function
check_status() {
    local name="$1"
    local check_cmd="$2"
    local success_msg="$3"
    local fail_msg="$4"
    
    if eval "$check_cmd" &>/dev/null; then
        echo "$GREEN $name: $success_msg"
    else
        echo "$RED $name: $fail_msg"
    fi
}

# System Info
echo "=== SYSTEM INFO ==="
lsb_release -a | grep Description || echo "Pop!_OS not detected"
echo ""

# Shell Status
echo "=== SHELL STATUS ==="
echo "Current shell: $SHELL"
if [ "$SHELL" = "/usr/bin/zsh" ]; then
    echo "$GREEN ZSH active"
else
    echo "$RED ZSH not active - run install-base.sh and reboot"
fi

if [ -f ~/.zshrc ]; then
    echo "$GREEN ~/.zshrc exists"
else
    echo "$RED ~/.zshrc missing"
fi

if command -v starship &>/dev/null; then
    echo "$GREEN Starship prompt installed"
else
    echo "$RED Starship not installed"
fi
echo ""

# Node.js / NPM / PNPM
echo "=== NODE.JS / NPM / PNPM ==="
check_status "Node.js" "command -v node" "$(node --version 2>/dev/null)" "NOT INSTALLED - run install-node.sh"
check_status "NPM" "command -v npm" "$(npm --version 2>/dev/null)" "NOT INSTALLED"
check_status "PNPM" "command -v pnpm" "$(pnpm --version 2>/dev/null)" "NOT INSTALLED"
check_status "NVM" "[ -d \$NVM_DIR ]" "NVM_DIR=${NVM_DIR:-NOT SET}" "NVM not loaded - check ~/.zshrc"
echo ""

# OpenCode
echo "=== OPENCODE CLI ==="
check_status "OpenCode" "command -v opencode" "$(opencode --version 2>/dev/null)" "NOT INSTALLED - run install-opencode.sh"

if [ -d ~/.config/opencode ]; then
    echo "$GREEN ~/.config/opencode exists"
    if [ -f ~/.config/opencode/config.json ]; then
        echo "$GREEN config.json found"
    else
        echo "$RED config.json missing"
    fi
else
    echo "$RED ~/.config/opencode missing"
fi
echo ""

# API Keys
echo "=== API KEYS ==="
if [ -f ~/.config/ai-keys/exports.sh ]; then
    echo "$GREEN API keys file exists"
    # Check if keys are set (don't print values!)
    if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
        echo "$GREEN ANTHROPIC_API_KEY is set"
    else
        echo "$RED ANTHROPIC_API_KEY not set - edit ~/.config/ai-keys/exports.sh"
    fi
    
    if [ -n "${GOOGLE_AI_API_KEY:-}" ]; then
        echo "$GREEN GOOGLE_AI_API_KEY is set"
    else
        echo "$YELLOW GOOGLE_AI_API_KEY optional"
    fi
else
    echo "$RED ~/.config/ai-keys/exports.sh missing - run install-opencode.sh"
fi
echo ""

# Fonts
echo "=== NERD FONTS ==="
if fc-list | grep -q "JetBrainsMono Nerd Font"; then
    echo "$GREEN JetBrainsMono Nerd Font installed"
else
    echo "$RED JetBrainsMono Nerd Font not found - run install-base.sh"
fi
echo ""

# Terminal
echo "=== TERMINAL ==="
check_status "Kitty" "command -v kitty" "installed" "NOT INSTALLED - run install-base.sh"
if [ -f ~/.config/kitty/kitty.conf ]; then
    echo "$GREEN Kitty config exists"
else
    echo "$RED Kitty config missing"
fi
echo ""

# Docker
echo "=== DOCKER ==="
check_status "Docker" "command -v docker" "$(docker --version 2>/dev/null)" "NOT INSTALLED - run install-docker.sh"
if groups | grep -q docker; then
    echo "$GREEN User in docker group"
else
    echo "$YELLOW User not in docker group - logout/login required"
fi
echo ""

# Python
echo "=== PYTHON ==="
check_status "Python3" "command -v python3" "$(python3 --version 2>/dev/null)" "NOT INSTALLED"
check_status "uv" "command -v uv" "$(uv --version 2>/dev/null)" "NOT INSTALLED - run install-python.sh"
echo ""

# Tools
echo "=== DEVELOPMENT TOOLS ==="
check_status "VS Code" "command -v code" "installed" "NOT INSTALLED - run install-tools.sh"
check_status "Git" "command -v git" "$(git --version 2>/dev/null)" "NOT INSTALLED"
check_status "GH CLI" "command -v gh" "$(gh --version 2>/dev/null)" "NOT INSTALLED - run install-tools.sh"
check_status "Biome" "command -v biome" "installed" "NOT INSTALLED"
echo ""

# Optional
echo "=== OPTIONAL ==="
check_status "Ollama" "command -v ollama" "installed" "NOT INSTALLED (optional)"
check_status "Cursor IDE" "[ -f ~/Applications/cursor.AppImage ]" "installed" "NOT INSTALLED"
echo ""

# Summary
echo "══════════════════════════════════════════════════════════"
echo ""
echo "Next steps based on missing components:"
echo ""

# Determine what needs to be installed
missing_base=false
missing_node=false
missing_opencode=false

[ "$SHELL" != "/usr/bin/zsh" ] && missing_base=true
! command -v node &>/dev/null && missing_node=true
! command -v opencode &>/dev/null && missing_opencode=true

if $missing_base; then
    echo "  1. bash scripts/install-base.sh"
    echo "  2. REBOOT"
fi

if $missing_node; then
    echo "  3. bash scripts/install-node.sh"
fi

if $missing_opencode; then
    echo "  4. bash scripts/install-opencode.sh"
    echo "  5. Edit ~/.config/ai-keys/exports.sh"
fi

echo ""
echo "Or run master installer: bash scripts/install-all.sh"
echo "══════════════════════════════════════════════════════════"