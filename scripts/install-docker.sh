#!/bin/bash
# Pop!_OS AI Dev Setup - Docker + Databases (Steps 15-16)

set -e

echo "🚀 Installing Docker and database containers"
echo ""

# Step 15: Docker
echo "=== [15] Installing Docker ==="
sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
echo "✅ Docker installed"
echo "⚠️  Run: newgrp docker (or logout/login to apply group change)"

# Step 16: Database containers
echo ""
echo "=== [16] Creating database containers ==="
mkdir -p ~/dev

cat > ~/dev/docker-compose.dev.yml << 'EOF'
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: devuser
      POSTGRES_PASSWORD: devpassword
      POSTGRES_DB: devdb
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
EOF

echo "✅ Docker compose file created"
echo ""
echo "Start databases with:"
echo "   docker compose -f ~/dev/docker-compose.dev.yml up -d"

echo ""
echo "══════════════════════════════════════════════════════════"
echo "✅ Docker + databases configured!"
echo ""
echo "⚠️  Logout/login to apply docker group membership"
echo "══════════════════════════════════════════════════════════"