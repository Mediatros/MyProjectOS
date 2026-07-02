#!/bin/sh
# init-project.sh — pose un nouveau projet MyProjectOS.
# Usage : init-project.sh <chemin-projet> [--life] [--code] [--knowledge] [--into-existing] [--sync]
#   (aucun flag = Core seul ; --life + --code = Hybrid ; --knowledge = extension documentaire transverse)
#   --into-existing : greffe sur un projet déjà peuplé (ne pose que les fichiers manquants, n'écrase rien)
#   --sync          : met à jour la copie locale de MyProjectOS depuis GitHub avant de poser les fichiers
# POSIX sh.

set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TODAY=$(date +%Y-%m-%d)
OS_VERSION=$(head -n 1 "$REPO/VERSION" 2>/dev/null | tr -d '[:space:]')
[ -n "$OS_VERSION" ] || OS_VERSION="0.0.0"

# --- Arguments ---------------------------------------------------------------
TARGET=""
WANT_LIFE=0
WANT_CODE=0
WANT_KNOWLEDGE=0
WANT_MERGE=0
WANT_SYNC=0
for arg in "$@"; do
    case "$arg" in
        --life) WANT_LIFE=1 ;;
        --code) WANT_CODE=1 ;;
        --knowledge) WANT_KNOWLEDGE=1 ;;
        --into-existing|--merge) WANT_MERGE=1 ;;
        --sync) WANT_SYNC=1 ;;
        -*) echo "Option inconnue : $arg" >&2; exit 1 ;;
        *) TARGET=$arg ;;
    esac
done

if [ -z "$TARGET" ]; then
    echo "Usage : $0 <chemin-projet> [--life] [--code] [--knowledge] [--into-existing] [--sync]" >&2
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

if [ "$WANT_MERGE" -eq 0 ] && [ -e "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null)" ]; then
    echo "Le dossier '$TARGET' existe déjà et n'est pas vide. Arrêt par sécurité." >&2
    echo "Pour greffer MyProjectOS sur un projet existant, relance avec --into-existing." >&2
    exit 1
fi

if [ "$WANT_SYNC" -eq 1 ]; then
    echo "Synchronisation de MyProjectOS depuis GitHub..."
    if git -C "$REPO" pull --ff-only >/dev/null 2>&1; then
        OS_VERSION=$(head -n 1 "$REPO/VERSION" 2>/dev/null | tr -d '[:space:]')
        [ -n "$OS_VERSION" ] || OS_VERSION="0.0.0"
        echo "  copie locale à jour (version $OS_VERSION)"
    else
        echo "  pull impossible (réseau, auth ou modifs locales) : on continue avec la copie locale telle quelle." >&2
    fi
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
        -e "s#^derniere_maj: YYYY-MM-DD\$#derniere_maj: $TODAY#" \
        -e "s#^cree_le: YYYY-MM-DD\$#cree_le: $TODAY#" \
        -e "s#^version_methode: <VERSION>\$#version_methode: $OS_VERSION#" \
        "$_f" > "$_f.tmp" && mv "$_f.tmp" "$_f"
}

# Compteurs pour le résumé du mode greffe.
CREATED=""
KEPT=""

migrate_progress_frontmatter() {
    # migrate_progress_frontmatter <src> <dst> : préfixe le frontmatter du template
    # au PROGRESS.md existant qui n'en a pas, sans toucher au contenu.
    _src=$1
    _dst=$2
    awk 'NR==1{print;next} {print; if($0=="---") exit}' "$_src" > "$_dst.fm"
    subst "$_dst.fm"
    { cat "$_dst.fm"; printf '\n'; cat "$_dst"; } > "$_dst.tmp"
    mv "$_dst.tmp" "$_dst"
    rm -f "$_dst.fm"
}

copy_template() {
    # copy_template <src> <dst> : pose le fichier ; en mode greffe, n'écrase jamais un existant.
    _src=$1
    _dst=$2
    _base=$(basename -- "$_dst")
    if [ "$WANT_MERGE" -eq 1 ] && [ -e "$_dst" ]; then
        if [ "$_base" = "PROGRESS.md" ] && ! head -n 1 "$_dst" | grep -q '^---$'; then
            migrate_progress_frontmatter "$_src" "$_dst"
            echo "  ~ $_base (frontmatter ajouté, contenu conservé)"
        else
            echo "  = $_base (déjà présent, conservé)"
        fi
        KEPT="$KEPT $_base"
        return
    fi
    cp "$_src" "$_dst"
    subst "$_dst"
    echo "  + $_base"
    CREATED="$CREATED $_base"
}

copy_tree() {
    # copy_tree <src-dir> <dst-dir> : copie récursive puis substitue les fichiers Markdown.
    # En mode greffe, n'écrase jamais un fichier déjà présent.
    _src=$1
    _dst=$2
    mkdir -p "$_dst"
    (cd "$_src" && find . -type d -exec mkdir -p "$_dst/{}" \;)
    (cd "$_src" && find . -type f | while IFS= read -r _file; do
        if [ "$WANT_MERGE" -eq 1 ] && [ -e "$_dst/$_file" ]; then
            continue
        fi
        cp "$_src/$_file" "$_dst/$_file"
        case "$_file" in
            *.md) subst "$_dst/$_file" ;;
        esac
    done)
}

# --- Création ----------------------------------------------------------------
mkdir -p "$TARGET"
if [ "$WANT_MERGE" -eq 1 ]; then
    echo "Greffe MyProjectOS (type : $TYPE) sur le projet existant $TARGET"
else
    echo "Projet '$NAME' (type : $TYPE) dans $TARGET"
fi

echo "Fichiers sacrés Core :"
for f in PROJECT PROGRESS CHANGELOG TASKS DECISIONS; do
    copy_template "$REPO/templates/core/$f.md" "$TARGET/$f.md"
done

if [ "$WANT_LIFE" -eq 1 ]; then
    echo "Extension Life :"
    for f in PREUVES ECHEANCES CORRESPONDANCES; do
        copy_template "$REPO/templates/extensions/life/$f.md" "$TARGET/$f.md"
    done
fi

if [ "$WANT_CODE" -eq 1 ]; then
    echo "Extension Code :"
    for f in AGENTS CONSTITUTION STACK_VALIDATION ARCHITECTURE SPECS TEST_PLAN IMPACT_ANALYSIS RELEASE; do
        copy_template "$REPO/templates/extensions/code/$f.md" "$TARGET/$f.md"
    done
fi

if [ "$WANT_KNOWLEDGE" -eq 1 ]; then
    echo "Extension Knowledge :"
    copy_tree "$REPO/templates/extensions/knowledge" "$TARGET"
    echo "  + docs/ (INDEX, kb_governance, niveaux, runbooks, plans)"
fi

# Zone d'entrée. Les autres dossiers numérotés sont créés à la demande.
mkdir -p "$TARGET/00_inbox"
: > "$TARGET/00_inbox/.gitkeep"
echo "  + 00_inbox/ (les autres dossiers numérotés se créent à la demande)"

# --- Câblage des hooks -------------------------------------------------------
# Les hooks sont copiés dans le projet (.claude/hooks/) puis référencés via
# $CLAUDE_PROJECT_DIR : le projet reste autonome, insensible à un déplacement
# du dépôt MyProjectOS. Pour mettre à jour les hooks, relancer l'init.
mkdir -p "$TARGET/.claude/hooks"
for _h in _lib.sh hook-pre-write.sh hook-stop-progress.sh; do
    cp "$REPO/scripts/hooks/$_h" "$TARGET/.claude/hooks/$_h"
    chmod +x "$TARGET/.claude/hooks/$_h"
done
echo "  + .claude/hooks/ (hooks copiés localement, autonomes)"

# --- Installation de la skill assistant --------------------------------------
if [ "$WANT_MERGE" -eq 1 ] && [ -e "$TARGET/.claude/skills/my-project-os/SKILL.md" ]; then
    echo "  = .claude/skills/my-project-os/SKILL.md (déjà présente, conservée)"
else
    mkdir -p "$TARGET/.claude/skills/my-project-os"
    cp "$REPO/skills/my-project-os/SKILL.md" "$TARGET/.claude/skills/my-project-os/SKILL.md"
    echo "  + .claude/skills/my-project-os/SKILL.md (skill assistant installée)"
fi

SETTINGS="$TARGET/.claude/settings.json"
HOOKS_BLOCK=$(cat <<'EOF'
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Write",
        "hooks": [{ "type": "command", "command": "sh \"$CLAUDE_PROJECT_DIR/.claude/hooks/hook-pre-write.sh\"" }] }
    ],
    "Stop": [
      { "matcher": "",
        "hooks": [{ "type": "command", "command": "sh \"$CLAUDE_PROJECT_DIR/.claude/hooks/hook-stop-progress.sh\"" }] }
    ]
  }
}
EOF
)

PRE_CMD='sh "$CLAUDE_PROJECT_DIR/.claude/hooks/hook-pre-write.sh"'
STOP_CMD='sh "$CLAUDE_PROJECT_DIR/.claude/hooks/hook-stop-progress.sh"'

if [ -e "$SETTINGS" ]; then
    if command -v python3 >/dev/null 2>&1; then
        python3 - "$SETTINGS" "$PRE_CMD" "$STOP_CMD" <<'PY'
import json, sys
path, pre, stop = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    with open(path) as f:
        cfg = json.load(f)
except Exception:
    cfg = {}
if not isinstance(cfg, dict):
    cfg = {}
hooks = cfg.setdefault("hooks", {})

def ensure(event, matcher, cmd):
    arr = hooks.setdefault(event, [])
    for grp in arr:
        for h in grp.get("hooks", []):
            if h.get("command") == cmd:
                return
    arr.append({"matcher": matcher, "hooks": [{"type": "command", "command": cmd}]})

ensure("PreToolUse", "Write", pre)
ensure("Stop", "", stop)
with open(path, "w") as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY
        echo "  ~ .claude/settings.json (hooks fusionnés sans écraser l'existant)"
    else
        echo ""
        echo "python3 absent : fusionne ce bloc hooks à la main dans $SETTINGS :"
        echo "$HOOKS_BLOCK"
    fi
else
    printf '%s\n' "$HOOKS_BLOCK" > "$SETTINGS"
    echo "  + .claude/settings.json (hooks enforcement câblés)"
fi

if [ "$WANT_MERGE" -eq 1 ]; then
    echo ""
    echo "Résumé de la greffe :"
    [ -n "$CREATED" ] && echo "  créés :$CREATED"
    [ -n "$KEPT" ] && echo "  conservés (à relire pour cohérence) :$KEPT"
fi

echo ""
echo "Fait. Prochaine étape : renseigner PROJECT.md (pourquoi, périmètre, objectifs, critères de réussite)."
