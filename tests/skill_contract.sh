#!/usr/bin/env bash
set -euo pipefail

skill="text-sparring/SKILL.md"

require() {
  local pattern="$1"
  local message="$2"
  if ! grep -Eiq "$pattern" "$skill"; then
    echo "FAIL: $message" >&2
    exit 1
  fi
}

reject() {
  local pattern="$1"
  local message="$2"
  if grep -Eiq "$pattern" "$skill"; then
    echo "FAIL: $message" >&2
    exit 1
  fi
}

require 'auto-sparring|autosparring' \
  "Auto-Sparring phrasing must be an explicit trigger."

require 'sparring ueber|sparring über|sparring.*dateien' \
  "Prompts asking for sparring over files must be covered."

require 'keine.*einzel.*datei|single-file|finale analyse-datei' \
  "Skill must forbid shortcutting a requested sparring into one final analysis file."

require 'resume sparring|sparring.*fortsetzen|wieder.*aufnehmen|context-limit|context limit|abgebrochen' \
  "Resume after context limit or aborted sessions must be an explicit trigger."

require '## RESUME-Modus' \
  "Skill must define a dedicated RESUME mode."

require 'Chatverlauf|conversation history|state\.md.*einzige Wahrheit' \
  "Resume must reconstruct from project files/state.md, not from chat history."

require 'Genau eine.*aktive|genau ein.*aktive|mehrere aktive.*frage' \
  "Resume must auto-select one active sparring and ask on ambiguity."

require 'New-Run-Intent|neues Sparring|neuen Lauf|Start-Absicht' \
  "Starting a new sparring must be an explicit intent distinct from JOIN/RESUME."

require 'aktive.*Sparrings.*blockieren.*INIT|blockieren.*INIT.*aktive.*Sparrings|bestehende.*Sparrings.*blockieren.*nicht' \
  "Existing active sparrings must not block a new INIT run."

require 'Kollision.*-v2|-v3|kollisionsfrei' \
  "Name collisions must auto-version to a free slug instead of stopping."

require 'State-Konflikt.*nicht.*bei.*neuen|neuer.*Lauf.*State-Konflikt|Turbo.*aktive.*Sparrings.*nicht.*abbrechen' \
  "Turbo/new-run flow must not abort just because another sparring state exists."

if grep -Eq 'Hauptskill `text-sparring`.*\(INIT \+ JOIN\):' README.md; then
  echo "FAIL: README must not describe the main skill as INIT + JOIN only." >&2
  exit 1
fi

require 'SKILL\.md.*INIT.*JOIN.*RESUME|SKILL\.md.*RESUME.*INIT.*JOIN' \
  "Skill file overview must mention RESUME alongside INIT/JOIN."

reject 'Trigger-Phrase Worte wie "Turbo", "Schnellstart", "ohne Fragen", "auto", "quick"' \
  "Generic 'auto' must not route to Turbo mode; it catches Auto-Sparring."

echo "skill contract ok"
