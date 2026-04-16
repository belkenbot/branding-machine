# Branding Machine

Personal content factory for TikTok, UGC, LinkedIn/X — powered by ComfyUI, Remotion, and n8n.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/belkenbot/branding-machine/main/install.sh | bash
```

Or clone manually:

```bash
git clone https://github.com/belkenbot/branding-machine.git
cd branding-machine
bash deploy.sh
```

## Requirements

- Linux (Ubuntu 22.04+ recommended) or WSL2
- Docker + Docker Compose plugin
- NVIDIA GPU with Container Toolkit installed
- 16GB+ RAM (32GB recommended for Ollama)

## What's Included

| Service | Port | Purpose |
|---------|------|---------|
| ComfyUI | 8188 | Image + video generation (GPU) |
| Forge Pipeline | 8200 | Video assembly (TTS + FFmpeg) |
| Remotion | 3100 | Programmatic video editor |
| n8n | 5678 | Workflow automation |
| SearXNG | 8080 | Private search for research |
| Postgres | 5432 | Local knowledge store (pgvector) |
| Watchtower | — | Auto-updates containers |
| Ollama | 11434 | Local LLM (optional, `--profile full`) |

## Configuration

After install, edit `.env` with your API keys:

```
GOOGLE_API_KEY=       # Gemini/Imagen
MINIMAX_API_KEY=      # TTS voice
MAC_MINI_IP=          # Tailscale IP for knowledge sync
```

## Syncing with Mac Mini

Pull research + lessons from your Mac Mini Postgres, push content logs back:

```bash
bash sync-with-mini.sh
```

Requires `MAC_MINI_IP` set in `.env` and Postgres Tailscale access enabled on the Mini.

## GPU Notes

- ComfyUI gets exclusive GPU by default
- Ollama shares GPU only when enabled: `docker compose --profile full up -d ollama`
- `--lowvram` flag is set for 8GB VRAM cards (RTX 5050)

## License

Private — Belken Ventures internal use.
