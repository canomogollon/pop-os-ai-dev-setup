#!/bin/bash
# Pop!_OS AI Dev Setup - OpenCode CLI + Configuration (Step 9)
# MUST RUN AFTER Node.js is installed

set -e

echo "🚀 Installing OpenCode CLI + Configuration"
echo ""

# Verify Node.js
echo "=== Checking Node.js ==="
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Run install-node.sh first"
    exit 1
fi
echo "✅ Node.js: $(node --version)"

# Install OpenCode CLI globally
echo ""
echo "=== Installing OpenCode CLI ==="
npm install -g @anthropic-ai/opencode

# Verify installation
echo ""
echo "=== Verification ==="
which opencode || echo "❌ opencode not in PATH"
opencode --version || echo "❌ opencode failed to run"

# Create config directory
echo ""
echo "=== Creating OpenCode config ==="
mkdir -p ~/.config/opencode
mkdir -p ~/.config/opencode/plugins

# Create default config
cat > ~/.config/opencode/config.json << 'EOF'
{
  "$schema": "https://opencode.ai/config.schema.json",
  "version": 1,
  "providers": {
    "anthropic": {
      "api_key_env": "ANTHROPIC_API_KEY",
      "models": ["claude-sonnet-4-20250514", "claude-3-5-haiku-20241022"]
    },
    "google": {
      "api_key_env": "GOOGLE_AI_API_KEY",
      "models": ["gemini-2.5-pro-preview-05-06", "gemini-2.0-flash"]
    }
  },
  "agents": {
    "default": {
      "model": "claude-sonnet-4-20250514",
      "provider": "anthropic"
    }
  },
  "format": {
    "enabled": true,
    "formatter": "biome",
    "languages": {
      "typescript": "biome",
      "javascript": "biome",
      "json": "biome"
    }
  }
}
EOF

# Create AI keys directory and template
echo ""
echo "=== Creating API keys template ==="
mkdir -p ~/.config/ai-keys

cat > ~/.config/ai-keys/exports.sh << 'EOF'
#!/bin/bash
# AI API Keys - EDIT THIS FILE WITH YOUR ACTUAL KEYS
# Then run: source ~/.zshrc

# Anthropic (Claude)
export ANTHROPIC_API_KEY="sk-ant-api03-YOUR_KEY_HERE"

# Google AI (Gemini)
export GOOGLE_AI_API_KEY="YOUR_GOOGLE_KEY_HERE"

# Optional: OpenAI
# export OPENAI_API_KEY="sk-proj-YOUR_KEY_HERE"

# Optional: GitHub (for GH CLI)
# export GH_TOKEN="ghp_YOUR_TOKEN_HERE"
EOF

chmod 600 ~/.config/ai-keys/exports.sh

echo ""
echo "⚠️  EDIT ~/.config/ai-keys/exports.sh with your actual API keys"
echo "   nano ~/.config/ai-keys/exports.sh"
echo "   source ~/.zshrc"

# Add to zshrc if not already there
if ! grep -q "ai-keys/exports.sh" ~/.zshrc 2>/dev/null; then
    echo "" >> ~/.zshrc
    echo "# AI API Keys" >> ~/.zshrc
    echo '[ -f "$HOME/.config/ai-keys/exports.sh" ] && source "$HOME/.config/ai-keys/exports.sh"' >> ~/.zshrc
fi

# Create plugins directory structure
mkdir -p ~/.config/opencode/skills
mkdir -p ~/.config/opencode/context

echo ""
echo "✅ OpenCode installed and configured"
echo ""
echo "══════════════════════════════════════════════════════════"
echo "Next steps:"
echo "   1. Edit API keys: nano ~/.config/ai-keys/exports.sh"
echo "   2. Reload config: source ~/.zshrc"
echo "   3. Verify keys:   opencode run test"
echo "══════════════════════════════════════════════════════════"