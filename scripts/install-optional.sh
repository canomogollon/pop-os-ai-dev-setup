#!/bin/bash
# Pop!_OS AI Dev Setup - Optional components (Steps 18-21)
# Ollama, Security, Apps, Runtimes

set -e

echo "🚀 Optional components - Choose what to install"
echo ""

# Ask user what to install
echo "Available options:"
echo "  1. Ollama (local AI models - requires 16GB+ RAM)"
echo "  2. Security essentials (UFW firewall + Bitwarden CLI)"
echo "  3. Additional apps (Slack, Bruno, Obsidian, VLC)"
echo "  4. Optional runtimes (Go, Rust, Bun)"
echo ""
read -p "Enter numbers to install (e.g., '2 3'): " choices

# Process choices
for choice in $choices; do
    case $choice in
        1)
            echo ""
            echo "=== [18] Installing Ollama ==="
            echo "⚠️  Hardware requirements: 16GB+ RAM, 8GB+ GPU VRAM"
            read -p "Continue? (y/n): " confirm
            if [ "$confirm" = "y" ]; then
                curl -fsSL https://ollama.com/install.sh | sh
                sudo systemctl enable --now ollama
                echo "✅ Ollama installed"
                echo ""
                echo "Download models:"
                echo "   ollama pull qwen2.5-coder:7b   # 4.7GB"
                echo "   ollama pull phi4-mini           # 2.5GB"
            fi
            ;;
        2)
            echo ""
            echo "=== [19] Security essentials ==="
            sudo ufw enable
            sudo ufw default deny incoming
            sudo ufw default allow outgoing
            sudo ufw allow ssh
            echo "✅ UFW firewall enabled"
            npm install -g @bitwarden/cli
            echo "✅ Bitwarden CLI installed"
            ;;
        3)
            echo ""
            echo "=== [20] Additional apps ==="
            sudo apt install -y slack-desktop vlc htop
            sudo snap install bruno
            sudo snap install obsidian --classic
            echo "✅ Apps installed"
            ;;
        4)
            echo ""
            echo "=== [21] Optional runtimes ==="
            # Go
            sudo add-apt-repository -y ppa:longsleep/golang-backports
            sudo apt update
            sudo apt install -y golang-go
            
            # Rust
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
            
            # Bun
            curl -fsSL https://bun.sh/install | bash
            
            echo "✅ Go, Rust, Bun installed"
            ;;
        *)
            echo "Invalid choice: $choice"
            ;;
    esac
done

echo ""
echo "══════════════════════════════════════════════════════════"
echo "✅ Optional components installed!"
echo "══════════════════════════════════════════════════════════"