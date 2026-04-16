#!/bin/bash
# ============================================================
# Belken Branding Machine — Installer
# One-liner: curl -fsSL https://raw.githubusercontent.com/belkenbot/branding-machine/main/install.sh | bash
#
# What it does:
#   1. Checks Docker + NVIDIA prerequisites
#   2. Clones the repo
#   3. Runs deploy.sh to pull/build/start everything
# ============================================================
set -e

REPO="https://github.com/belkenbot/branding-machine.git"
INSTALL_DIR="${INSTALL_DIR:-$HOME/branding-machine}"
BRANCH="${BRANCH:-main}"

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║   Belken Branding Machine — Installer      ║"
echo "║   Personal Content Factory                  ║"
echo "╚════════════════════════════════════════════╝"
echo ""
# ─── Check prerequisites ───────────────────────────────────
echo "[1/4] Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo ""
    echo "  Docker not found. Installing..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker "$USER"
    echo "  Docker installed. You may need to log out and back in for group changes."
    echo "  If 'docker compose' fails below, run: newgrp docker"
    echo ""
fi

if ! docker compose version &> /dev/null 2>&1; then
    echo "  ERROR: Docker Compose plugin not found."
    echo "  Install: sudo apt install -y docker-compose-plugin"
    exit 1
fi

if ! nvidia-smi &> /dev/null; then
    echo ""
    echo "  NVIDIA GPU not detected (nvidia-smi failed)."
    echo "  ComfyUI and Ollama need a GPU to run."
    echo ""
    echo "  To install NVIDIA Container Toolkit:"
    echo "    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg"
    echo "    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \\"
    echo "      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \\"
    echo "      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list"
    echo "    sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit"
    echo "    sudo nvidia-ctk runtime configure --runtime=docker"
    echo "    sudo systemctl restart docker"
    echo ""
    read -p "  Continue without GPU? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi
else
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
    GPU_VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null | head -1)
    echo "  GPU: $GPU_NAME ($GPU_VRAM)"
fi

if ! docker info 2>/dev/null | grep -q "nvidia"; then
    echo "  WARNING: NVIDIA runtime not registered with Docker."
    echo "  Run: sudo nvidia-ctk runtime configure --runtime=docker && sudo systemctl restart docker"
fi

echo "  OK"
echo ""
# ─── Clone the repo ────────────────────────────────────────
echo "[2/4] Cloning branding-machine..."

if [ -d "$INSTALL_DIR" ]; then
    echo "  Directory $INSTALL_DIR already exists."
    read -p "  Pull latest and re-deploy? (Y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then exit 0; fi
    cd "$INSTALL_DIR"
    git pull origin "$BRANCH"
else
    git clone -b "$BRANCH" "$REPO" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

echo "  OK — installed to $INSTALL_DIR"
echo ""

# ─── Configure .env ────────────────────────────────────────
echo "[3/4] Configuring environment..."

if [ ! -f .env ]; then
    cp .env.example .env
    echo ""
    echo "  Created .env from template."
    echo "  You MUST edit .env with your API keys before the stack works fully."
    echo ""
    echo "  Required keys:"
    echo "    GOOGLE_API_KEY     — for Gemini/Imagen"
    echo "    MAC_MINI_IP        — Tailscale IP of your Mac Mini"
    echo ""
    echo "  Optional keys (add later):"
    echo "    MINIMAX_API_KEY    — TTS voice synthesis"
    echo "    ANTHROPIC_API_KEY  — Claude for Lucy-Persona"
    echo "    GROQ_API_KEY       — Groq fallback LLM"
    echo ""
    read -p "  Edit .env now? (Y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        ${EDITOR:-nano} .env
    fi
else
    echo "  .env already exists — keeping existing config"
fi
echo ""

# ─── Deploy ────────────────────────────────────────────────
echo "[4/4] Deploying stack..."
bash deploy.sh

echo ""
echo "Installation complete!"
echo "Location: $INSTALL_DIR"
echo ""
echo "Useful commands:"
echo "  cd $INSTALL_DIR"
echo "  docker compose logs -f          # watch all logs"
echo "  docker compose ps               # check status"
echo "  bash sync-with-mini.sh          # sync knowledge from Mac Mini"
