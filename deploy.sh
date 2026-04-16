#!/bin/bash
set -e
echo "============================================"
echo "  Acer Branding Machine — Deploy"
echo "============================================"
echo ""
echo "[1/6] Checking prerequisites..."
if ! command -v docker &> /dev/null; then echo "ERROR: Docker not installed."; exit 1; fi
if ! docker compose version &> /dev/null; then echo "ERROR: Docker Compose not found."; exit 1; fi
if ! nvidia-smi &> /dev/null; then
    echo "WARNING: nvidia-smi not found. GPU containers won't work."
    read -p "Continue without GPU? (y/N) " -n 1 -r; echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi
else
    echo "  GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader)"
    echo "  VRAM: $(nvidia-smi --query-gpu=memory.total --format=csv,noheader)"
fi
RAM_MB=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}' || echo "0")
echo "  RAM: ${RAM_MB}MB"
if [ "$RAM_MB" -lt 28000 ]; then echo "  NOTE: <32GB RAM. Ollama disabled by default."; fi
echo "  OK"
echo ""
echo "[2/6] Creating directory structure..."
DEPLOY_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DEPLOY_DIR"
mkdir -p face-refs brands/ken/photos brands/lucy/assets templates comfyui/workflows
echo "  OK"
echo ""
echo "[3/6] Checking .env..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "  Created .env from .env.example — EDIT IT NOW!"
    read -p "Press Enter after editing .env..."
else echo "  .env exists"; fi
echo ""
echo "[4/6] Pulling Docker images..."
docker compose pull comfyui postgres n8n searxng watchtower
echo "  OK"
echo ""
echo "[5/6] Building custom images..."
docker compose build forge remotion
echo "  OK"
echo ""
echo "[6/6] Starting services..."
docker compose up -d
sleep 10
echo ""
echo "============================================"
echo "  DEPLOY COMPLETE"
echo "============================================"
echo "  ComfyUI:   http://localhost:8188"
echo "  Forge API: http://localhost:8200"
echo "  Remotion:  http://localhost:3100"
echo "  n8n:       http://localhost:5678"
echo "  SearXNG:   http://localhost:8080"
echo "  Postgres:  localhost:5432"
echo ""
echo "  For Ollama (needs 32GB RAM):"
echo "    docker compose --profile full up -d ollama"
echo "============================================"
