#!/bin/bash
cd "$(dirname "$0")"
git add -A
git commit -m "fix: install.sh handles non-interactive curl|bash mode

- Detect tty for interactive prompts vs piped execution
- No-GPU defaults to exit in non-interactive, prompt in interactive
- Skip editor prompt when piped, show manual command instead
- Fix repo URL to belkenbot/branding-machine
- Remove push-to-github.sh from tracked files"
git rm --cached push-to-github.sh 2>/dev/null || true
echo "push-to-github.sh" >> .gitignore
git add -A
git commit -m "chore: exclude push scripts from repo" 2>/dev/null || true
git push origin main
echo "Pushed! Installer fixed."
rm push-fix.sh push-to-github.sh 2>/dev/null
