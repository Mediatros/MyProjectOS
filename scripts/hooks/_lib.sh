#!/bin/sh
# _lib.sh — fonctions communes aux hooks MyProjectOS.
# POSIX sh. Aucune dépendance obligatoire : dégradation silencieuse si python3/jq absents.

# Lit l'intégralité de stdin dans la variable HOOK_PAYLOAD.
read_payload() {
    HOOK_PAYLOAD=$(cat)
}

# json_field <chemin.pointé> : extrait un champ du payload JSON.
# Essaie python3, puis jq. Renvoie une chaîne vide si rien n'est disponible.
json_field() {
    _path=$1
    if command -v python3 >/dev/null 2>&1; then
        printf '%s' "$HOOK_PAYLOAD" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
cur = d
for k in sys.argv[1].split("."):
    if isinstance(cur, dict):
        cur = cur.get(k)
    else:
        cur = None
        break
if cur is not None:
    print(cur)
' "$_path"
    elif command -v jq >/dev/null 2>&1; then
        printf '%s' "$HOOK_PAYLOAD" | jq -r "try (.${_path}) // empty" 2>/dev/null
    fi
}

# Dossier du projet : variable Claude Code, sinon racine git, sinon dossier courant.
project_dir() {
    if [ -n "$CLAUDE_PROJECT_DIR" ]; then
        printf '%s' "$CLAUDE_PROJECT_DIR"
    elif command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
        git rev-parse --show-toplevel
    else
        pwd
    fi
}

# Vrai si le dossier est un projet MyProjectOS (présence de PROJECT.md).
is_project_os() {
    [ -f "$1/PROJECT.md" ]
}

# Refuse l'action (PreToolUse) avec une raison, puis sort proprement.
deny() {
    _reason=$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$_reason"
    exit 0
}

# Avertit (Stop) sans bloquer, puis sort proprement.
warn() {
    _msg=$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')
    printf '{"systemMessage":"%s"}\n' "$_msg"
    exit 0
}
