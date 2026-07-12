#!/bin/sh
# hook-pre-write.sh — PreToolUse (Write).
# Fait respecter le nommage et le placement (docs/enforcement.md).
# Bloque le clair et sans ambiguïté ; laisse passer le reste.

DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
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
        deny "Nommage MyProjectOS : pas d'espace dans un nom de fichier. Utilise des tirets : '$(printf '%s' "$BASE" | tr ' ' '-')'. Voir docs/NAMING-CONVENTIONS.md." ;;
esac

# Nommage : pas d'accent ni de caractère non-ASCII (analyse octet par octet).
if printf '%s' "$BASE" | LC_ALL=C grep -q '[^ -~]'; then
    deny "Nommage MyProjectOS : pas d'accent ni de caractère spécial dans un nom de fichier (ex : 'echeancier.md', pas 'échéancier.md'). Voir docs/NAMING-CONVENTIONS.md."
fi

# Placement : un document/binaire ne se pose pas à la racine du projet.
case "$REL" in
    */*) : ;;  # déjà dans un sous-dossier
    *)
        case "$BASE" in
            *.pdf|*.PDF|*.jpg|*.jpeg|*.png|*.gif|*.eml|*.msg|*.docx|*.doc|*.xlsx|*.xls|*.pptx|*.ppt|*.zip)
                deny "Placement MyProjectOS : un document ('$BASE') ne se range pas à la racine. Mets-le dans 00_inbox/ puis classe-le dans le bon dossier numéroté. Voir structures/core-tree.md." ;;
        esac ;;
esac

# Dossiers racine : écrire dans un dossier de premier niveau qui n'existe pas
# encore et dont le nom est un quasi-doublon (RETEX LaCIOTAT : 99_archives/
# créé à côté de 99_archive/, deux jours de dérive) ou une collision de
# préfixe numérique NN_ (ex. 98_config à côté de 98_configuration, RETEX
# 98_configuration) avec un dossier existant est refusé.
case "$REL" in
    */*)
        SEG1=${REL%%/*}
        case "$SEG1" in
            .*) : ;;  # dossiers cachés (.claude, .git) hors périmètre
            *)
                if [ ! -d "$PROJECT_DIR/$SEG1" ]; then
                    NORM_NEW=$(normalize_root_name "$SEG1")
                    PREFIX_NEW=$(root_prefix "$SEG1")
                    for _d in "$PROJECT_DIR"/*/; do
                        [ -d "$_d" ] || continue
                        _existing=$(basename -- "$_d")
                        case "$_existing" in .*) continue ;; esac
                        if [ "$(normalize_root_name "$_existing")" = "$NORM_NEW" ]; then
                            deny "Dossiers racine MyProjectOS : créer '$SEG1/' ferait un quasi-doublon de '$_existing/' qui existe déjà. Range le fichier dans '$_existing/' ou choisis un nom clairement distinct. Voir docs/NAMING-CONVENTIONS.md."
                        fi
                        if [ -n "$PREFIX_NEW" ] && [ "$(root_prefix "$_existing")" = "$PREFIX_NEW" ]; then
                            deny "Dossiers racine MyProjectOS : '$SEG1/' porterait le même préfixe numérique que '$_existing/' qui existe déjà, ce qui casse l'ordre de lecture. Range le fichier dans '$_existing/' ou choisis un autre préfixe. Voir docs/NAMING-CONVENTIONS.md."
                        fi
                    done
                fi ;;
        esac ;;
esac

exit 0
