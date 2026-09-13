#!/bin/sh
# hook-post-progress.sh — PostToolUse (Write, Edit).
# Après l'écriture d'un PROGRESS.md de sujet (02_*/Sxx_*/PROGRESS.md) ou du
# PROGRESS.md racine, projette l'état des sujets dans le parent via la copie
# scripts/sync-progress.sh du projet (DEC-0053). Le script est idempotent et
# silencieux quand rien ne change : le hook n'émet rien et ne bloque jamais.
# Sans dossier de sujets, il ne fait rien.

DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
. "$DIR/_lib.sh"

read_payload

PROJECT_DIR=$(project_dir)
is_project_os "$PROJECT_DIR" || exit 0

FILE_PATH=$(json_field "tool_input.file_path")
[ -n "$FILE_PATH" ] || exit 0

REL=${FILE_PATH#"$PROJECT_DIR"/}
[ "$REL" != "$FILE_PATH" ] || exit 0

case "$REL" in
    PROGRESS.md|02_*/S[0-9][0-9]_*/PROGRESS.md) ;;
    *) exit 0 ;;
esac

SYNC="$PROJECT_DIR/scripts/sync-progress.sh"
[ -f "$SYNC" ] || exit 0

sh "$SYNC" "$PROJECT_DIR" >/dev/null 2>&1
exit 0
