-- Acer Branding Machine — Postgres Init
CREATE EXTENSION IF NOT EXISTS vector;
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS intel;
CREATE SCHEMA IF NOT EXISTS content;
CREATE SCHEMA IF NOT EXISTS media;
CREATE SCHEMA IF NOT EXISTS persona;
CREATE SCHEMA IF NOT EXISTS ops;
CREATE TABLE IF NOT EXISTS content.production_log (
    id SERIAL PRIMARY KEY, title TEXT NOT NULL, content_type TEXT, platform TEXT,
    status TEXT DEFAULT 'draft', comfyui_job_id TEXT, forge_job_id TEXT,
    remotion_composition TEXT, output_path TEXT, published_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(), published_at TIMESTAMPTZ);
CREATE TABLE IF NOT EXISTS persona.generations (
    id SERIAL PRIMARY KEY, prompt TEXT NOT NULL, model TEXT, face_ref TEXT, lora TEXT,
    output_path TEXT, quality_score FLOAT, clip_score FLOAT, created_at TIMESTAMPTZ DEFAULT NOW());
CREATE TABLE IF NOT EXISTS persona.face_refs (
    id SERIAL PRIMARY KEY, name TEXT NOT NULL, ref_path TEXT NOT NULL, lora_path TEXT,
    descriptor TEXT, created_at TIMESTAMPTZ DEFAULT NOW());
CREATE DATABASE n8n;
GRANT ALL ON DATABASE n8n TO belken;
CREATE TABLE IF NOT EXISTS ops.sync_log (
    id SERIAL PRIMARY KEY, direction TEXT NOT NULL, table_name TEXT NOT NULL,
    rows_synced INTEGER DEFAULT 0, synced_at TIMESTAMPTZ DEFAULT NOW());
