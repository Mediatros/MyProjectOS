#!/bin/sh
# init-project.sh — pose un nouveau projet Project OS.
# Usage : init-project.sh <chemin-projet> [--life] [--code]
#   (aucun flag = Core seul ; --life + --code = Hybrid)
# POSIX sh.

set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TODAY=$(date +%Y-%m-%d)

# --- Arguments ---------------------------------------------------------------
TARGET=""
WANT_LIFE=0
WANT_CODE=0
for arg in "$@"; do
    case "$arg" in
        --life) WANT_LIFE=1 ;;
        --code) WANT_CODE=1 ;;
        -*) echo "Option inconnue : $arg" >&2; exit 1 ;;
        *) TARGET=$arg ;;
    esac
done

if [ -z "$TARGET" ]; then
    echo "Usage : $0 <chemin-projet> [--life] [--code]" >&2
    exit 1
fi

if [ "$WANT_LIFE" -eq 1 ] && [ "$WANT_CODE" -eq 1 ]; then
    TYPE="Hybrid"
elif [ "$WANT_LIFE" -eq 1 ]; then
    TYPE="Life"
elif [ "$WANT_CODE" -eq 1 ]; then
    TYPE="Code"
else
    TYPE="Core"
fi

NAME=$(basename -- "$TARGET")

if [ -e "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null)" ]; then
    echo "Le dossier '$TARGET' existe déjà et n'est pas vide. Arrêt par sécurité." >&2
    exit 1
fi

# --- Substitution portable (sans sed -i) -------------------------------------
subst() {
    # subst <fichier> : remplace placeholders et frontmatter.
    _f=$1
    if [ "$TYPE" = "Core" ]; then _type_label="Core"; else _type_label="$TYPE"; fi
    sed \
        -e "s#<NomDuProjet>#$NAME#g" \
        -e "s#^type: Life | Code | Hybrid\$#type: $_type_label#" \
        -e "s#^statut: actif | en pause | clôturé\$#statut: actif#" \
        -e "s#^derniere_maj: AAAA-MM-JJ\$#derniere_maj: $TODAY#" \
        -e "s#^cree_le: AAAA-MM-JJ\$#cree_le: $TODAY#" \
        "$_f" > "$_f.tmp" && mv "$_f.tmp" "$_f"
}

copy_template() {
    # copy_template <src> <dst>
    cp "$1" "$2"
    subst "$2"
    echo "  + $(basename -- "$2")"
}

# --- Création ----------------------------------------------------------------
mkdir -p "$TARGET"
echo "Projet '$NAME' (type : $TYPE) dans $TARGET"

echo "Fichiers sacrés Core :"
for f in PROJECT PROGRESS CHANGELOG TASKS DECISIONS; do
    copy_template "$REPO/templates/core/$f.md" "$TARGET/$f.md"
done

if [ "$WANT_LIFE" -eq 1 ]; then
    echo "Extension Life :"
    for f in PREUVES ECHEANCES CORRESPONDANCES; do
        copy_template "$REPO/templates/life/$f.md" "$TARGET/$f.md"
    done
fi

if [ "$WANT_CODE" -eq 1 ]; then
    echo "Extension Code :"
    for f in AGENTS STACK_VALIDATION ARCHITECTURE SPECS TEST_PLAN IMPACT_ANALYSIS RELEASE; do
        copy_template "$REPO/templates/code/$f.md" "$TARGET/$f.md"
    done
fi

# Zone d'entrée. Les autres dossiers numérotés sont créés à la demande.
mkdir -p "$TARGET/00_inbox"
: > "$TARGET/00_inbox/.gitkeep"
echo "  + 00_inbox/ (les autres dossiers numérotés se créent à la demande)"

# --- Câblage des hooks -------------------------------------------------------
mkdir -p "$TARGET/.claude"
SETTINGS="$TARGET/.claude/settings.json"
HOOKS_BLOCK=$(cat <<EOF
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Write",
        "hooks": [{ "type": "command", "command": "sh $REPO/scripts/hooks/hook-pre-write.sh" }] }
    ],
    "Stop": [
      { "matcher": "",
        "hooks": [{ "type": "command", "command": "sh $REPO/scripts/hooks/hook-stop-progress.sh" }] }
    ]
  }
}
EOF
)

if [ -e "$SETTINGS" ]; then
    echo ""
    echo "Un .claude/settings.json existe déjà : fusionne ce bloc hooks à la main :"
    echo "$HOOKS_BLOCK"
else
    printf '%s\n' "$HOOKS_BLOCK" > "$SETTINGS"
    echo "  + .claude/settings.json (hooks enforcement câblés)"
fi

echo ""
echo "Fait. Prochaine étape : renseigner PROJECT.md (pourquoi, périmètre, objectifs, critères de réussite)."
