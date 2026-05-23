#!/bin/bash
# Pop!_OS AI Dev Setup - Development Tools (Steps 7-8, 11-14)
# VS Code, Cursor, Git, GH CLI, AI CLIs, Biome

set -e

echo "🚀 Installing development tools"
echo ""

# Step 7: VS Code
echo "=== [7] Installing VS Code ==="
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update && sudo apt install -y code

# Install VS Code extensions
echo ""
echo "=== Installing VS Code AI extensions ==="
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat
code --install-extension Continue.continue
code --install-extension biomejs.biome
code --install-extension usernamehw.errorlens
code --install-extension eamodio.gitlens
code --install-extension humao.rest-client

# Create VS Code settings
mkdir -p ~/.config/Code/User
cat > ~/.config/Code/User/settings.json << 'EOF'
{
  "editor.fontFamily": "'JetBrainsMono Nerd Font', monospace",
  "editor.fontSize": 14,
  "editor.fontLigatures": true,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "biomejs.biome",
  "terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font Mono'",
  "editor.inlineSuggest.enabled": true,
  "github.copilot.enable": { "*": true }
}
EOF
echo "✅ VS Code installed"

# Step 8: Cursor IDE
echo ""
echo "=== [8] Installing Cursor IDE ==="
mkdir -p ~/Applications
wget -O ~/Applications/cursor.AppImage "https://downloader.cursor.sh/linux/appImage/x64"
chmod +x ~/Applications/cursor.AppImage

# Create desktop launcher
cat > ~/.local/share/applications/cursor.desktop << 'EOF'
[Desktop Entry]
Name=Cursor
Exec=/home/$USER/Applications/cursor.AppImage --no-sandbox
Icon=cursor
Type=Application
Categories=Development;TextEditor;
EOF
update-desktop-database ~/.local/share/applications/
echo "✅ Cursor installed"

# Step 11: Git config (user needs to edit)
echo ""
echo "=== [11] Git configuration ==="
git config --global core.editor "code --wait"
git config --global init.defaultBranch main
git config --global pull.rebase false
echo ""
echo "⚠️  Run these commands with YOUR info:"
echo "   git config --global user.name 'Your Name'"
echo "   git config --global user.email 'your@email.com'"
echo "   ssh-keygen -t ed25519 -C 'your@email.com'"

# Step 12: GitHub CLI
echo ""
echo "=== [12] Installing GitHub CLI ==="
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && wget -nv -O/tmp/githubcli.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  && cat /tmp/githubcli.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y

echo "⚠️  Run: gh auth login"
gh extension install github/gh-copilot 2>/dev/null || echo "ℹ️  Copilot extension (optional)"
echo "✅ GitHub CLI installed"

# Step 13: AI Cloud CLIs
echo ""
echo "=== [13] Installing AI Cloud CLIs ==="
npm install -g @anthropic-ai/claude-code
npm install -g @google/gemini-cli
echo "✅ Claude CLI + Gemini CLI installed"

# Step 14: Biome
echo ""
echo "=== [14] Installing Biome ==="
npm install -g @biomejs/biome
echo "✅ Biome installed"

echo ""
echo "══════════════════════════════════════════════════════════"
echo "✅ All development tools installed!"
echo ""
echo "⚠️  Manual steps remaining:"
echo "   1. Configure Git user.name/email"
echo "   2. Generate SSH key and add to GitHub"
echo "   3. Run: gh auth login"
echo "══════════════════════════════════════════════════════════"