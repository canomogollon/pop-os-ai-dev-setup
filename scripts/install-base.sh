#!/bin/bash
# Pop!_OS AI Dev Setup - Base Installation (Steps 1-6)
# OS Update, Inotify, ZSH + Oh My Zsh, Starship, Fonts, COSMIC Desktop

set -e

echo "🚀 Starting base installation for Pop!_OS 24.04 LTS"
echo ""

# Step 1: OS Update
echo "=== [1] Updating OS packages ==="
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git build-essential
echo "✅ OS updated"

# Step 2: Inotify (required for many dev tools)
echo ""
echo "=== [2] Installing inotify-tools ==="
sudo apt install -y inotify-tools
echo "✅ inotify-tools installed"

# Step 3: ZSH + Oh My Zsh + Starship
echo ""
echo "=== [3] Installing ZSH + Oh My Zsh + Starship ==="

# Install ZSH
sudo apt install -y zsh

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Starship prompt
curl -sS https://starship.rs/install.sh | sh

# Configure ZSH with Starship
cat > ~/.zshrc << 'EOF'
# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Starship prompt
eval "$(starship init zsh)"

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# PNPM
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# AI API Keys (load from file)
[ -f "$HOME/.config/ai-keys/exports.sh" ] && source "$HOME/.config/ai-keys/exports.sh"

# Aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
EOF

# Install zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions 2>/dev/null || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting 2>/dev/null || true

# Change default shell to ZSH
sudo chsh -s $(which zsh) $USER

echo "✅ ZSH + Oh My Zsh + Starship installed"
echo "⚠️  Shell changed to ZSH - requires logout/login to activate"

# Step 4: Nerd Fonts
echo ""
echo "=== [4] Installing Nerd Fonts ==="
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

# JetBrains Mono Nerd Font (recommended for code)
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip
unzip -q JetBrainsMono.zip
rm JetBrainsMono.zip

# FiraCode Nerd Font (alternative)
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip
unzip -q FiraCode.zip
rm FiraCode.zip

# Update font cache
fc-cache -fv

cd ~
echo "✅ Nerd Fonts installed"

# Step 5: COSMIC Desktop (Pop!_OS 24.04 feature)
echo ""
echo "=== [5] COSMIC Desktop Environment ==="
if command -v cosmic-session &> /dev/null; then
    echo "✅ COSMIC Desktop already installed"
else
    echo "ℹ️  COSMIC Desktop is pre-installed in Pop!_OS 24.04"
    echo "   No additional installation needed"
fi

# Step 6: Terminal + Desktop Apps
echo ""
echo "=== [6] Installing Terminal and Desktop Apps ==="
sudo apt install -y kitty

# Kitty config with Nerd Font
mkdir -p ~/.config/kitty
cat > ~/.config/kitty/kitty.conf << 'EOF'
font_family      JetBrainsMono Nerd Font Mono
bold_font        JetBrainsMono Nerd Font Mono Bold
italic_font      JetBrainsMono Nerd Font Mono Italic
font_size        14.0

# Theme (Catppuccin Mocha)
background #1e1e2e
foreground #cdd6f4
selection_background #f5e0dc
selection_foreground #1e1e2e
url_color #f5e0dc
cursor #f5e0dc

# Tabs
active_tab_background #cba6f7
active_tab_foreground #1e1e2e
inactive_tab_background #313244
inactive_tab_foreground #cdd6f4

# Colors
color0  #45475a
color8  #585b70
color1  #f38ba8
color9  #f38ba8
color2  #a6e3a1
color10 #a6e3a1
color3  #f9e2af
color11 #f9e2af
color4  #89b4fa
color12 #89b4fa
color5  #f5c2e7
color13 #f5c2e7
color6  #94e2d5
color14 #94e2d5
color7  #bac2de
color15 #a6adc8
EOF

echo "✅ Kitty terminal installed and configured"

# Summary
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║           PHASE 1 COMPLETE - REBOOT REQUIRED!            ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "⚠️  REBOOT now to activate ZSH shell!"
echo ""
echo "After reboot, verify ZSH is active:"
echo "   echo \$SHELL  (should show /usr/bin/zsh)"
echo ""
echo "Then run Phase 2:"
echo "   bash scripts/install-node.sh"