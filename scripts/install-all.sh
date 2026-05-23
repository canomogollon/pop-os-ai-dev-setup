#!/bin/bash
# Pop!_OS AI Dev Setup - Master Installer
# Interactive installer that guides through all phases

set -e

echo "╔══════════════════════════════════════════════════════════╗"
echo "║     Pop!_OS 24.04 LTS - AI Dev Setup Master Installer    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "This script will guide you through the complete setup process."
echo "It checks dependencies and pauses for critical steps (reboot)."
echo ""

# Phase 0: Diagnostic
echo "=== [0] Running diagnostic ==="
bash scripts/diagnostic.sh
echo ""
read -p "Continue with installation? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Phase 1: Base System
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                    PHASE 1: BASE SYSTEM                  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "This phase installs:"
echo "  - OS updates"
echo "  - Inotify max watches"
echo "  - ZSH + Oh My Zsh + Starship"
echo "  - Nerd Fonts"
echo "  - Kitty terminal"
echo ""
read -p "Run Phase 1? (y/n): " phase1
if [[ "$phase1" == "y" ]]; then
    bash scripts/install-base.sh
    
    echo ""
    echo "⚠️  CRITICAL: REBOOT REQUIRED!"
    echo ""
    read -p "Reboot now? (y/n): " reboot_now
    if [[ "$reboot_now" == "y" ]]; then
        sudo reboot
        exit 0
    else
        echo ""
        echo "⚠️  You MUST reboot before continuing!"
        echo "After reboot, run: bash scripts/install-all.sh"
        echo "The script will detect and continue from Phase 2."
        exit 0
    fi
fi

# Phase 2: Node.js
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                 PHASE 2: NODE.JS + PNPM                  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Check if ZSH is active
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "❌ ERROR: ZSH not active!"
    echo "Did you reboot after Phase 1?"
    echo ""
    echo "Run: chsh -s /usr/bin/zsh && reboot"
    echo "Then run this script again."
    exit 1
fi
echo "✅ ZSH active: $SHELL"

echo ""
echo "This phase installs:"
echo "  - NVM (Node Version Manager)"
echo "  - Node.js 20 LTS"
echo "  - PNPM 9"
echo ""
read -p "Run Phase 2? (y/n): " phase2
if [[ "$phase2" == "y" ]]; then
    bash scripts/install-node.sh
fi

# Phase 3: OpenCode
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║               PHASE 3: OPENCODE + API KEYS               ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Check Node.js
if ! command -v node &>/dev/null; then
    echo "❌ ERROR: Node.js not installed!"
    echo "Run Phase 2 first: bash scripts/install-node.sh"
    exit 1
fi
echo "✅ Node.js: $(node --version)"

echo ""
echo "This phase installs:"
echo "  - OpenCode CLI"
echo "  - API keys template"
echo "  - Config files"
echo ""
read -p "Run Phase 3? (y/n): " phase3
if [[ "$phase3" == "y" ]]; then
    bash scripts/install-opencode.sh
    
    echo ""
    echo "⚠️  EDIT API KEYS NOW!"
    echo "File: ~/.config/ai-keys/exports.sh"
    echo ""
    read -p "Edit API keys now? (opens nano) (y/n): " edit_keys
    if [[ "$edit_keys" == "y" ]]; then
        nano ~/.config/ai-keys/exports.sh
        source ~/.zshrc
        echo "Keys loaded."
    fi
fi

# Phase 4: Tools
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║            PHASE 4: IDEs + GIT + GH CLI + BIOME          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "This phase installs:"
echo "  - VS Code + AI extensions"
echo "  - Cursor IDE"
echo "  - Git + SSH keys"
echo "  - GitHub CLI + Copilot"
echo "  - Biome linter/formatter"
echo ""
read -p "Run Phase 4? (y/n): " phase4
if [[ "$phase4" == "y" ]]; then
    bash scripts/install-tools.sh
fi

# Phase 5: Docker
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║               PHASE 5: DOCKER + DATABASES                ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "This phase installs:"
echo "  - Docker + Docker Compose"
echo "  - PostgreSQL 16 (container)"
echo "  - Redis 7 (container)"
echo ""
read -p "Run Phase 5? (y/n): " phase5
if [[ "$phase5" == "y" ]]; then
    bash scripts/install-docker.sh
    
    echo ""
    echo "⚠️  Logout/login required for docker group!"
fi

# Phase 6: Python
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                 PHASE 6: PYTHON + UV                     ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "This phase installs:"
echo "  - Python 3 (verify version)"
echo "  - uv package manager"
echo ""
read -p "Run Phase 6? (y/n): " phase6
if [[ "$phase6" == "y" ]]; then
    bash scripts/install-python.sh
fi

# Phase 7: Optional
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║          PHASE 7: OPTIONAL (Ollama + Apps + Runtimes)    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "This phase is OPTIONAL and requires hardware checks."
echo ""
read -p "Run Phase 7? (y/n): " phase7
if [[ "$phase7" == "y" ]]; then
    bash scripts/install-optional.sh
fi

# Final Summary
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║               INSTALLATION COMPLETE!                     ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "Run diagnostic to verify all components:"
echo "  bash scripts/diagnostic.sh"
echo ""
echo "If docker group was added, logout/login for it to take effect."
echo ""
echo "Test OpenCode:"
echo "  opencode run test"
echo ""
echo "Happy coding! 🚀"