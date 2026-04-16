#!/bin/bash
# ============================================================
# Belken Branding Machine — Installer
#
# Interactive:   bash install.sh
# Non-interactive (curl pipe):
#   curl -fsSL https://raw.githubusercontent.com/belkenbot/branding-machine/main/install.sh | bash
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

# Detect if we're running interactively (tty available)
INTERACTIVE=false
if [ -t 0 ]; then
    INTERACTIVE=true
fi

prompt_yn() {
    local question="$1"
    local default="$2"
    if [ "$INTERACTIVE" = true ]; then
        read -p "$question " -n 1 -r
        echo
        if [ "$default" = "default_yes" ]; then
            [[ ! $REPLY =~ ^[Nn]$ ]]
        else
            [[ $REPLY =~ ^[Yy]$ ]]
        fi
    else
        [ "$default" = "default_yes" ]
    fi
}

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
    echo ""
fi

if ! docker compose version &> /dev/null 2>&1; then
    echo "  ERROR: Docker Compose plugin not found."
    echo "  Install: sudo apt install -y docker-compose-plugin"
    exit 1
fi

HAS_GPU=false
if ! nvidia-smi &> /dev/null; then
    echo ""
    echo "  NVIDIA GPU not detected (nvidia-smi failed)."
    echo "  ComfyUI and Ollama need a GPU to run."
    echo ""
    echo "  To install NVIDIA drivers + Container Toolkit:"
    echo "    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg"
    echo "    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \\"
    echo "      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \\"
    echo "      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list"
    echo "    sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit"
    echo "    sudo nvidia-ctk runtime configure --runtime=docker"
    echo "    sudo systemctl restart docker"
    echo ""
    if ! prompt_yn "  Continue without GPU? (y/N)" "default_no"; then
        exit 1
    fi
else
    HAS_GPU=true
    GPU_NAME=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
    GPU_VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null | head -1)
    echo "  GPU: $GPU_NAME ($GPU_VRAM)"
fi

if [ "$HAS_GPU" = true ] && ! docker info 2>/dev/null | grep -q "nvidia"; then
    echo "  WARNING: NVIDIA runtime not registered with Docker."
    echo "  Run: sudo nvidia-ctk runtime configure --runtime=docker && sudo systemctl restart docker"
fi

RAM_MB=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}' || echo "0")
if [ "$RAM_MB" -gt 0 ] 2>/dev/null; then
    echo "  RAM: ${RAM_MB}MB"
    if [ "$RAM_MB" -lt 28000 ]; then
        echo "  NOTE: <32GB detected. Ollama disabled by default (use --profile full to enable)."
    fi
fi

echo "  OK"
echo ""

# ─── Clone the repo ────────────────────────────────────────
echo "[2/4] Cloning branding-machine..."

if [ -d "$INSTALL_DIR" ]; then
    echo "  Directory $INSTALL_DIR already exists."
    if prompt_yn "  Pull latest and re-deploy? (Y/n)" "default_yes"; then
        cd "$INSTALL_DIR"
        git pull origin "$BRANCH"
    else
        exit 0
    fi
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
    echo "  IMPORTANT: Edit .env with your API keys before the stack works fully."
    echo ""
    echo "  Required:"
    echo "    GOOGLE_API_KEY     — Gemini/Imagen"
    echo "    MAC_MINI_IP        — Tailscale IP of your Mac Mini"
    echo ""
    echo "  Optional (add later):"
    echo "    MINIMAX_API_KEY    — TTS voice synthesis"
    echo "    ANTHROPIC_API_KEY  — Claude for Lucy-Persona"
    echo "    GROQ_API_KEY       — Groq fallback LLM"
    echo ""
    if [ "$INTERACTIVE" = true ]; then
        if prompt_yn "  Edit .env now? (Y/n)" "default_yes"; then
            ${EDITOR:-nano} .env
        fi
    else
        echo "  Run 'nano $INSTALL_DIR/.env' to configure API keys."
    fi
else
    echo "  .env already exists — keeping existing config"
fi
echo ""

# ─── Deploy ────────────────────────────────────────────────
echo "[4/4] Deploying stack..."
bash deploy.sh

echo ""
echo "============================================"
echo "  INSTALLATION COMPLETE"
echo "============================================"
echo ""
echo "  Location: $INSTALL_DIR"
echo ""
echo "  Services:"
echo "    ComfyUI:    http://localhost:8188"
echo "    Forge API:  http://localhost:8200"
echo "    Remotion:   http://localhost:3100"
echo "    n8n:        http://localhost:5678"
echo "    SearXNG:    http://localhost:8080"
echo "    Postgres:   localhost:5432"
echo ""
echo "  Commands:"
echo "    cd $INSTALL_DIR"
echo "    docker compose logs -f          # watch all logs"
echo "    docker compose ps               # check status"
echo "    bash sync-with-mini.sh          # sync from Mac Mini"
echo "    nano .env                       # edit API keys"
echo ""
