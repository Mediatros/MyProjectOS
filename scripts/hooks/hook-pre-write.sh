#!/bin/sh
# hook-pre-write.sh — PreToolUse (Write).
# Fait respecter le nommage et le placement (docs/enforcement.md).
# Bloque le clair et sans ambiguïté ; laisse passer le reste.

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$DIR/_lib.sh"

read_payload

PROJECT_DIR=$(project_dir)
is_project_os "$PROJECT_DIR" || exit 0

FILE_PATH=$(json_field "tool_input.file_path")
[ -n "$FILE_PATH" ] || exit 0

# Chemin relatif au projet ; hors projet -> on ne fait rien.
REL=${FILE_PATH#"$PROJECT_DIR"/}
[ "$REL" != "$FILE_PATH" ] || exit 0

BASE=${FILE_PATH##*/}

# Nommage : espaces interdits.
case "$BASE" in
    *" "*)
        deny "Nommage Project OS : pas d'espace dans un nom de fichier. Utilise des tirets : '$(printf '%s' "$BASE" | tr ' ' '-')'. Voir docs/NAMING-CONVENTIONS.md." ;;
esac

# Nommage : pas d'accent ni de caractère non-ASCII (analyse octet par octet).
if printf '%s' "$BASE" | LC_ALL=C grep -q '[^ -~]'; then
    deny "Nommage Project OS : pas d'accent ni de caractère spécial dans un nom de fichier (ex : 'echeancier.md', pas 'échéancier.md'). Voir docs/NAMING-CONVENTIONS.md."
fi

# Placement : un document/binaire ne se pose pas à la racine du projet.
case "$REL" in
    */*) : ;;  # déjà dans un sous-dossier
    *)
        case "$BASE" in
            *.pdf|*.PDF|*.jpg|*.jpeg|*.png|*.gif|*.eml|*.msg|*.docx|*.doc|*.xlsx|*.xls|*.pptx|*.ppt|*.zip)
                deny "Placement Project OS : un document ('$BASE') ne se range pas à la racine. Mets-le dans 00_inbox/ puis classe-le dans le bon dossier numéroté. Voir structures/core-tree.md." ;;
        esac ;;
esac

exit 0
