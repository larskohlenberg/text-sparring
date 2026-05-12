#!/usr/bin/env bash
# setup-github.sh
# Legt das text-sparring Repo privat auf GitHub an und pusht den Initial-Commit.
#
# Voraussetzung: `gh` CLI installiert und authentifiziert
#   Installation:    brew install gh
#   Authentifizierung: gh auth login
#
# Aufruf:
#   bash setup-github.sh                  # Default: privat unter eigenem GitHub-Account
#   bash setup-github.sh org/repo-name    # Optional: in eine Organisation pushen
#
set -euo pipefail

REPO_NAME="${1:-text-sparring}"
VISIBILITY="--private"

echo "🔧 Initialisiere text-sparring Repo..."
echo

# Prüfen ob gh verfügbar
if ! command -v gh >/dev/null 2>&1; then
  echo "❌ gh CLI nicht gefunden. Installiere mit:  brew install gh"
  exit 1
fi

# Prüfen ob authentifiziert
if ! gh auth status >/dev/null 2>&1; then
  echo "❌ gh nicht authentifiziert. Führe aus:  gh auth login"
  exit 1
fi

# Git-Repo initialisieren falls noch nicht
if [ ! -d .git ]; then
  echo "→ git init"
  git init -q
  git branch -M main
fi

# .git-Config: deinen Namen/E-Mail nicht überschreiben — gh übernimmt das
echo "→ git add ."
git add .

echo "→ git commit"
git commit -q -m "Initial commit: text-sparring v0.1.0

- SKILL.md mit INIT- und JOIN-Modus
- Vollrotations-Plan (10 Runden, 5×5 Rollenverteilung)
- watch_loop.sh als Pure-Bash Polling (30s / 30min Timeout)
- Templates für CLAUDE.md und ChatGPT/Codex Custom Instructions
- Gepacktes .skill-Bundle in dist/
- README + MIT-Lizenz + CHANGELOG"

echo "→ gh repo create $REPO_NAME (private)"
gh repo create "$REPO_NAME" $VISIBILITY --source=. --remote=origin --push \
  --description "Harness-agnostischer Skill für dialektisches Text-Sparring zwischen zwei AI-Agenten"

echo
echo "✅ Repo erstellt und gepusht."
echo
gh repo view "$REPO_NAME" --web 2>/dev/null && echo "(Browser geöffnet)" || \
  echo "Repo-URL: $(gh repo view "$REPO_NAME" --json url -q .url)"
