#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/.env"
if [ -z "$MAC_MINI_IP" ]; then echo "ERROR: Set MAC_MINI_IP in .env"; exit 1; fi
MINI_PG="postgresql://belken:belken_local_dev@${MAC_MINI_IP}:${MAC_MINI_PG_PORT:-5432}/belken"
LOCAL_PG="postgresql://belken:${POSTGRES_PASSWORD}@localhost:5432/belken"
echo "Syncing with Mac Mini at ${MAC_MINI_IP}..."
echo "[1/2] Pulling knowledge from Mac Mini..."
MINI_COUNT=$(psql "$MINI_PG" -t -c "SELECT COUNT(*) FROM intel.research" 2>/dev/null | tr -d ' ')
LOCAL_COUNT=$(psql "$LOCAL_PG" -t -c "SELECT COUNT(*) FROM intel.research" 2>/dev/null | tr -d ' ')
if [ "${MINI_COUNT:-0}" -gt "${LOCAL_COUNT:-0}" ]; then
    echo "  intel.research: Mini=$MINI_COUNT, Acer=$LOCAL_COUNT — syncing..."
    psql "$MINI_PG" -c "\COPY (SELECT topic, source, finding, category, confidence, actionable, session_id, created_at FROM intel.research WHERE id > $LOCAL_COUNT) TO STDOUT CSV" | \
    psql "$LOCAL_PG" -c "\COPY intel.research(topic, source, finding, category, confidence, actionable, session_id, created_at) FROM STDIN CSV"
    echo "  Synced $((MINI_COUNT - LOCAL_COUNT)) new entries"
else echo "  intel.research: up to date ($LOCAL_COUNT rows)"; fi
MINI_L=$(psql "$MINI_PG" -t -c "SELECT COUNT(*) FROM core.lessons" 2>/dev/null | tr -d ' ')
LOCAL_L=$(psql "$LOCAL_PG" -t -c "SELECT COUNT(*) FROM core.lessons" 2>/dev/null | tr -d ' ')
echo "  core.lessons: Mini=$MINI_L, Acer=$LOCAL_L"
echo "[2/2] Pushing content logs to Mac Mini..."
ACER_CONTENT=$(psql "$LOCAL_PG" -t -c "SELECT COUNT(*) FROM content.production_log" 2>/dev/null | tr -d ' ')
echo "  content.production_log: $ACER_CONTENT entries on Acer"
psql "$LOCAL_PG" -c "INSERT INTO ops.sync_log (direction, table_name, rows_synced) VALUES ('mini_to_acer', 'intel.research', ${MINI_COUNT:-0})"
echo "Sync complete at $(date '+%Y-%m-%d %H:%M:%S')"
