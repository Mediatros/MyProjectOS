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

# Normalise un nom de dossier racine pour comparer des quasi-doublons :
# accents translittérés (si iconv présent), minuscules, tirets -> underscores,
# 's' final retiré. Attrape 99_archives/99_archive, Preuves/06_preuves, etc.
# Même logique que norm_dirname dans scripts/check-project.sh (script autonome).
normalize_root_name() {
    _n=$1
    if command -v iconv >/dev/null 2>&1; then
        _n=$(printf '%s' "$_n" | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null || printf '%s' "$_n")
    fi
    printf '%s' "$_n" | LC_ALL=C tr '[:upper:]' '[:lower:]' | tr '-' '_' | sed 's/s$//'
}

# Préfixe numérique à deux chiffres d'un nom de dossier racine (ex. "98" pour
# "98_configuration"), vide si absent. Attrape les abréviations qu'un simple
# rapprochement de nom ne verrait pas (ex. "98_config" à côté de
# "98_configuration") : même préfixe = même rang de lecture visé.
root_prefix() {
    case "$1" in
        [0-9][0-9]_*) printf '%s' "${1%%_*}" ;;
        *) : ;;
    esac
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
