#!/usr/bin/env bash
# sparring/watch_loop.sh
#
# Pure-Bash Polling-Loop für die dialektische Challenge.
# Keine externen Abhängigkeiten außer Standard-Unix-Tools (grep, sleep).
#
# Aufruf:  bash sparring/watch_loop.sh "Claude"
#       (oder mit dem konkreten Agent-Namen, der in state.md steht)
#
# Exit Codes:
#   0  — du bist wieder dran (state.md zeigt "Dran: $1")
#   1  — Challenge abgeschlossen (state.md enthält "Status: completed")
#   2  — Timeout: andere Seite hat sich seit MAX_WAIT_MIN nicht gemeldet

set -u

MY_NAME="${1:-}"
if [ -z "$MY_NAME" ]; then
  echo "ERROR: Aufruf: bash watch_loop.sh <AGENT_NAME>" >&2
  exit 3
fi

# Konfiguration (kann via Umgebungsvariablen überschrieben werden)
POLL_SEC="${POLL_SEC:-30}"
MAX_WAIT_MIN="${MAX_WAIT_MIN:-30}"

STATE_FILE="sparring/state.md"
if [ ! -f "$STATE_FILE" ]; then
  # Alternativer Pfad, falls aus Projektroot aufgerufen wurde
  if [ -f "state.md" ]; then
    STATE_FILE="state.md"
  else
    echo "ERROR: state.md nicht gefunden (weder sparring/state.md noch state.md)" >&2
    exit 3
  fi
fi

MAX_ITER=$(( MAX_WAIT_MIN * 60 / POLL_SEC ))

echo "WAIT: $MY_NAME wartet (alle ${POLL_SEC}s, max ${MAX_WAIT_MIN}min) ..."

for i in $(seq 1 $MAX_ITER); do
  # Challenge fertig?
  if grep -qE '^\*\*Status:\*\*[[:space:]]*completed' "$STATE_FILE"; then
    echo "DONE: Alle 10 Runden abgeschlossen."
    cat "$STATE_FILE"
    exit 1
  fi

  # Ich dran?
  if grep -qE "^\*\*Dran:\*\*[[:space:]]*${MY_NAME}[[:space:]]*$" "$STATE_FILE"; then
    echo "WAKE: $MY_NAME ist jetzt dran (nach ${i} Polls)."
    echo "----- state.md -----"
    cat "$STATE_FILE"
    echo "--------------------"
    exit 0
  fi

  sleep "$POLL_SEC"
done

echo "TIMEOUT: ${MAX_WAIT_MIN} Min verstrichen, anderer Agent hat sich nicht gemeldet."
echo "----- state.md (aktuell) -----"
cat "$STATE_FILE"
echo "------------------------------"
exit 2
