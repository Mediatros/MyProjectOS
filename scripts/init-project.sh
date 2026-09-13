#!/bin/sh
# init-project.sh — pose un nouveau projet MyProjectOS.
# Usage : init-project.sh <chemin-projet> [--life] [--code] [--knowledge] [--into-existing] [--update-method] [--sync]
#   (aucun flag = Core seul ; --life + --code = Hybrid ; --knowledge = extension documentaire transverse)
#   --into-existing : greffe sur un projet déjà peuplé (ne pose que les fichiers manquants, n'écrase rien)
#   --update-method : rafraîchit uniquement les artefacts méthode d'un projet existant (hooks, skill,
#                     check-project.sh, check-update.sh, VERSION, empreinte version_methode), avec
#                     sauvegarde préalable dans 99_archive/. Le contenu du projet n'est jamais touché.
#   --sync          : met à jour la copie locale de MyProjectOS depuis GitHub avant de poser les fichiers
# POSIX sh.

set -eu

REPO=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
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
WANT_UPDATE=0
for arg in "$@"; do
    case "$arg" in
        --life) WANT_LIFE=1 ;;
        --code) WANT_CODE=1 ;;
        --knowledge) WANT_KNOWLEDGE=1 ;;
        --into-existing|--merge) WANT_MERGE=1 ;;
        --update-method) WANT_UPDATE=1 ;;
        --sync) WANT_SYNC=1 ;;
        -*) echo "Option inconnue : $arg" >&2; exit 1 ;;
        *) TARGET=$arg ;;
    esac
done

if [ -z "$TARGET" ]; then
    echo "Usage : $0 <chemin-projet> [--life] [--code] [--knowledge] [--into-existing] [--update-method] [--sync]" >&2
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

if [ "$WANT_MERGE" -eq 0 ] && [ "$WANT_UPDATE" -eq 0 ] && [ -e "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null)" ]; then
    echo "Le dossier '$TARGET' existe déjà et n'est pas vide. Arrêt par sécurité." >&2
    echo "Pour greffer MyProjectOS sur un projet existant, relance avec --into-existing." >&2
    echo "Pour rafraîchir les artefacts méthode d'un projet déjà créé, relance avec --update-method." >&2
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

# --- Artefacts méthode et manifest --------------------------------------------
# Le manifest liste les fichiers qui appartiennent à la méthode (remplaçables par
# --update-method), par opposition au contenu du projet (jamais touché).
MANIFEST_REL=".myprojectos/manifest"
ARTEFACTS=".claude/hooks/_lib.sh
.claude/hooks/hook-pre-write.sh
.claude/hooks/hook-stop-progress.sh
.claude/hooks/hook-post-progress.sh
98_configuration/skills/my-project-os/SKILL.md
scripts/check-project.sh
scripts/check-secrets.sh
scripts/check-iteration.sh
scripts/check-update.sh
scripts/sync-progress.sh
scripts/sujet.sh
VERSION"

write_manifest() {
    mkdir -p "$TARGET/.myprojectos"
    {
        printf '%s\n' "# Manifest MyProjectOS : artefacts posés par la méthode, remplacés par init-project.sh --update-method."
        printf '%s\n' "# Ne pas éditer à la main. Le contenu du projet n'est jamais listé ici."
        printf 'version=%s\n' "$OS_VERSION"
        printf '%s\n' "$ARTEFACTS"
    } > "$TARGET/$MANIFEST_REL"
}

artefact_source() {
    # artefact_source <chemin-relatif-projet> : chemin du fichier source dans le repo méthode.
    case "$1" in
        .claude/hooks/*) printf '%s' "$REPO/scripts/hooks/${1##*/}" ;;
        98_configuration/skills/my-project-os/SKILL.md) printf '%s' "$REPO/templates/skills/my-project-os/SKILL.md" ;;
        scripts/check-project.sh) printf '%s' "$REPO/scripts/check-project.sh" ;;
        scripts/check-secrets.sh) printf '%s' "$REPO/scripts/check-secrets.sh" ;;
        scripts/check-iteration.sh) printf '%s' "$REPO/scripts/check-iteration.sh" ;;
        scripts/check-update.sh) printf '%s' "$REPO/scripts/check-update.sh" ;;
        scripts/sync-progress.sh) printf '%s' "$REPO/scripts/sync-progress.sh" ;;
        scripts/sujet.sh) printf '%s' "$REPO/scripts/sujet.sh" ;;
        VERSION) printf '%s' "$REPO/VERSION" ;;
    esac
}

# --- Câblage de .claude/settings.json ------------------------------------------
# Les hooks sont copiés dans le projet (.claude/hooks/) puis référencés via
# $CLAUDE_PROJECT_DIR : le projet reste autonome, insensible à un déplacement
# du dépôt MyProjectOS. Appelé à la création et par --update-method (un hook
# ajouté par une version doit aussi être câblé sur un projet existant, DEC-0053).
HOOKS_MERGE_PENDING=0
PRE_CMD='sh "$CLAUDE_PROJECT_DIR/.claude/hooks/hook-pre-write.sh"'
STOP_CMD='sh "$CLAUDE_PROJECT_DIR/.claude/hooks/hook-stop-progress.sh"'
POST_CMD='sh "$CLAUDE_PROJECT_DIR/.claude/hooks/hook-post-progress.sh"'
GIT_CMD='sh "$CLAUDE_PROJECT_DIR/.claude/hooks/hook-pre-git.sh"'

wire_settings() {
    # wire_settings <git:0|1> : écrit un settings.json frais, ou fusionne les hooks
    # manquants dans celui qui existe (python3), sans jamais écraser le reste.
    _git=$1
    _settings="$TARGET/.claude/settings.json"
    _git_line=""
    [ "$_git" -eq 1 ] && _git_line='      { "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "sh \"$CLAUDE_PROJECT_DIR/.claude/hooks/hook-pre-git.sh\"" }] },
'
    _block=$(cat <<EOF
{
  "hooks": {
    "PreToolUse": [
${_git_line}      { "matcher": "Write",
        "hooks": [{ "type": "command", "command": "sh \"\$CLAUDE_PROJECT_DIR/.claude/hooks/hook-pre-write.sh\"" }] }
    ],
    "PostToolUse": [
      { "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "sh \"\$CLAUDE_PROJECT_DIR/.claude/hooks/hook-post-progress.sh\"" }] }
    ],
    "Stop": [
      { "matcher": "",
        "hooks": [{ "type": "command", "command": "sh \"\$CLAUDE_PROJECT_DIR/.claude/hooks/hook-stop-progress.sh\"" }] }
    ]
  }
}
EOF
)
    if [ ! -e "$_settings" ]; then
        mkdir -p "$TARGET/.claude"
        printf '%s\n' "$_block" > "$_settings"
        echo "  + .claude/settings.json (hooks enforcement câblés)"
        return
    fi
    if command -v python3 >/dev/null 2>&1; then
        python3 - "$_settings" "$PRE_CMD" "$STOP_CMD" "$POST_CMD" "$([ "$_git" -eq 1 ] && printf '%s' "$GIT_CMD")" <<'PY'
import json, sys
path, pre, stop, post = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
git = sys.argv[5] if len(sys.argv) > 5 and sys.argv[5] else None
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
ensure("PostToolUse", "Write|Edit", post)
ensure("Stop", "", stop)
if git:
    ensure("PreToolUse", "Bash", git)
with open(path, "w") as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY
        echo "  ~ .claude/settings.json (hooks fusionnés sans écraser l'existant)"
    else
        HOOKS_MERGE_PENDING=1
        echo "" >&2
        echo "python3 absent : fusion automatique impossible. Colle ce bloc hooks à la main dans $_settings :" >&2
        echo "$_block" >&2
    fi
}

ver_lt() {
    # ver_lt <a> <b> : vrai (exit 0) si version X.Y.Z <a> < <b>, comparaison entière par composant.
    _i=1
    while [ "$_i" -le 3 ]; do
        _fa=$(printf '%s' "$1" | cut -d. -f"$_i" | tr -dc '0-9'); [ -n "$_fa" ] || _fa=0
        _fb=$(printf '%s' "$2" | cut -d. -f"$_i" | tr -dc '0-9'); [ -n "$_fb" ] || _fb=0
        if [ "$_fa" -lt "$_fb" ]; then return 0; fi
        if [ "$_fa" -gt "$_fb" ]; then return 1; fi
        _i=$((_i + 1))
    done
    return 1
}

# --- Skills du projet : source unique 98_configuration/skills/, liens par agent -
# Contrat d'un agent (DEC-0052, §1 du plan de consolidation) : la skill assistant
# n'est plus une copie physique dans le dossier d'un seul agent, mais un lien
# symbolique relatif vers la source unique du catalogue, posé pour tout agent
# connu, présent ou non.
link_skill_dir() {
    # link_skill_dir <chemin-relatif-du-lien> : idempotent.
    # Dossier réel vide (reliquat d'une ancienne copie déjà retirée) -> rmdir puis
    # lien. Lien déjà correct -> rien. Dossier réel non vide -> signalé, non touché.
    _rel=$1
    _full="$TARGET/$_rel"
    if [ -L "$_full" ]; then
        echo "  = $_rel (déjà présent, conservé)"
        return
    fi
    if [ -d "$_full" ]; then
        if [ -z "$(ls -A "$_full" 2>/dev/null)" ]; then
            rmdir "$_full"
        else
            echo "  ! $_rel : dossier réel non vide, lien non posé (migration à finir à la main)" >&2
            return
        fi
    fi
    mkdir -p "$(dirname -- "$_full")"
    ln -s ../../98_configuration/skills/my-project-os "$_full"
    echo "  + $_rel -> 98_configuration/skills/my-project-os"
}

link_myprojectos_skill_dirs() {
    link_skill_dir ".claude/skills/my-project-os"
    link_skill_dir ".agents/skills/my-project-os"
}

migrate_old_skill_copy() {
    # --into-existing sur un projet où la skill assistant était une copie physique
    # (avant le lot 2 de T-PLAN-14) : même migration que --update-method, en une
    # fois, pour ne pas laisser le lien bloqué par un dossier réel non vide.
    [ "$WANT_MERGE" -eq 1 ] || return 0
    for _d in .claude/skills/my-project-os .agents/skills/my-project-os; do
        _f="$TARGET/$_d/SKILL.md"
        if [ -f "$_f" ] && [ ! -L "$TARGET/$_d" ]; then
            mkdir -p "$TARGET/99_archive/methode-avant-migration-skills/$_d"
            cp "$_f" "$TARGET/99_archive/methode-avant-migration-skills/$_d/SKILL.md"
            rm -f "$_f"
            echo "  - $_d/SKILL.md (ancienne copie, sauvegardée dans 99_archive/methode-avant-migration-skills/ puis retirée)"
        fi
    done
}

install_myprojectos_skill_source() {
    _dst="$TARGET/98_configuration/skills/my-project-os/SKILL.md"
    if [ "$WANT_MERGE" -eq 1 ] && [ -e "$_dst" ]; then
        echo "  = 98_configuration/skills/my-project-os/SKILL.md (déjà présente, conservée)"
    else
        mkdir -p "$TARGET/98_configuration/skills/my-project-os"
        cp "$REPO/templates/skills/my-project-os/SKILL.md" "$_dst"
        echo "  + 98_configuration/skills/my-project-os/SKILL.md (skill assistant installée, source unique du catalogue)"
    fi
}

create_gouvernance_readme() {
    # 97_gouvernance/README.md : hors manifest, jamais recréé une fois supprimé
    # par l'utilisateur (Q7/Q9, DEC-0052) — appelant à ne l'invoquer que si le
    # dossier est absent.
    _dst="$TARGET/97_gouvernance/README.md"
    if [ -e "$_dst" ]; then
        echo "  = 97_gouvernance/README.md (déjà présent, conservé)"
        return
    fi
    mkdir -p "$TARGET/97_gouvernance"
    cp "$REPO/templates/configuration/README_GOUVERNANCE.md" "$_dst"
    echo "  + 97_gouvernance/README.md (droit local du projet, supprimable)"
}

# --- Mode mise à jour : rafraîchir les artefacts méthode, rien d'autre ---------
if [ "$WANT_UPDATE" -eq 1 ]; then
    if [ ! -f "$TARGET/PROJECT.md" ]; then
        echo "Pas de PROJECT.md dans '$TARGET' : --update-method s'applique à un projet MyProjectOS existant." >&2
        exit 1
    fi
    OLD=""
    if [ -f "$TARGET/$MANIFEST_REL" ]; then
        OLD=$(sed -n 's/^version=//p' "$TARGET/$MANIFEST_REL" | head -n 1 | tr -d '[:space:]')
    fi
    if [ -z "$OLD" ]; then
        OLD=$(sed -n 's/^version_methode:[[:space:]]*//p' "$TARGET/PROJECT.md" | head -n 1 | tr -d '[:space:]')
        [ -n "$OLD" ] && [ "$OLD" != "<VERSION>" ] || OLD="inconnue"
    fi
    BACKUP_REL="99_archive/methode-avant-v$OLD"
    echo "Mise à jour des artefacts méthode : v$OLD -> v$OS_VERSION"
    echo "Sauvegarde des artefacts remplacés dans $BACKUP_REL/ :"
    while IFS= read -r _a; do
        [ -n "$_a" ] || continue
        if [ -f "$TARGET/$_a" ]; then
            mkdir -p "$TARGET/$BACKUP_REL/$(dirname -- "$_a")"
            cp "$TARGET/$_a" "$TARGET/$BACKUP_REL/$_a"
            echo "  > $_a"
        fi
    done <<EOF_BACKUP
$ARTEFACTS
EOF_BACKUP
    echo "Artefacts rafraîchis :"
    while IFS= read -r _a; do
        [ -n "$_a" ] || continue
        _srcf=$(artefact_source "$_a")
        [ -f "$_srcf" ] || continue
        mkdir -p "$TARGET/$(dirname -- "$_a")"
        cp "$_srcf" "$TARGET/$_a"
        case "$_a" in *.sh) chmod +x "$TARGET/$_a" ;; esac
        echo "  ~ $_a"
    done <<EOF_REFRESH
$ARTEFACTS
EOF_REFRESH
    # Artefacts orphelins : présents dans l'ancien manifest, absents du nouveau
    # (retirés de la méthode entre deux versions). Sauvegardés puis supprimés,
    # jamais laissés en place sans être suivis par aucun manifest.
    if [ -f "$TARGET/$MANIFEST_REL" ]; then
        OLD_ARTEFACTS=$(grep -v '^#' "$TARGET/$MANIFEST_REL" | grep -v '^version=')
    else
        OLD_ARTEFACTS=""
    fi
    if [ -n "$OLD_ARTEFACTS" ]; then
        printf '%s\n' "$OLD_ARTEFACTS" | while IFS= read -r _o; do
            [ -n "$_o" ] || continue
            printf '%s\n' "$ARTEFACTS" | grep -Fxq "$_o" && continue
            [ -f "$TARGET/$_o" ] || continue
            mkdir -p "$TARGET/$BACKUP_REL/$(dirname -- "$_o")"
            cp "$TARGET/$_o" "$TARGET/$BACKUP_REL/$_o"
            rm -f "$TARGET/$_o"
            echo "  - $_o (retiré de la méthode, sauvegardé puis supprimé)"
        done
    fi
    echo "Skills du projet (source unique + liens par agent) :"
    link_myprojectos_skill_dirs
    # 97_gouvernance/ : migration unique par seuil de version (Q9, DEC-0052).
    # Un projet déjà en 0.29.0 ou plus a connu le dossier ; son absence ensuite
    # est un choix de l'utilisateur, jamais recréé.
    if ver_lt "$OLD" "0.29.0"; then
        create_gouvernance_readme
    fi
    # Un hook arrivé avec une version doit être câblé sur le projet existant, pas
    # seulement copié (sinon check-project le signale « présent mais non câblé »).
    echo "Câblage des hooks :"
    _git_present=0
    [ -f "$TARGET/.claude/hooks/hook-pre-git.sh" ] && _git_present=1
    wire_settings "$_git_present"
    sed "s#^version_methode:.*#version_methode: $OS_VERSION#" "$TARGET/PROJECT.md" > "$TARGET/PROJECT.md.tmp" \
        && mv "$TARGET/PROJECT.md.tmp" "$TARGET/PROJECT.md"
    write_manifest
    echo "  ~ PROJECT.md (version_methode: $OS_VERSION) + $MANIFEST_REL"
    echo ""
    echo "Fait. Aucun fichier de contenu touché. À faire ensuite :"
    echo "  1. consigner la migration dans le CHANGELOG.md du projet (entrée CHG-) ;"
    echo "  2. lancer sh scripts/check-project.sh pour vérifier la cohérence."
    [ "$HOOKS_MERGE_PENDING" -eq 0 ] || exit 1
    exit 0
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

append_code_agents() {
    # append_code_agents <src> <dst> : ajoute la section Code à AGENTS.md, une seule fois.
    _src=$1
    _dst=$2
    if [ -e "$_dst" ] && grep -q '^## Extension Code$' "$_dst" 2>/dev/null; then
        echo "  = AGENTS.md (section Extension Code déjà présente, conservée)"
        return
    fi
    _tmp="$_dst.append"
    cp "$_src" "$_tmp"
    subst "$_tmp"
    { printf '\n'; cat "$_tmp"; } >> "$_dst"
    rm -f "$_tmp"
    echo "  ~ AGENTS.md (section Extension Code ajoutée)"
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

echo "Instructions agent :"
copy_template "$REPO/templates/core/AGENTS.md" "$TARGET/AGENTS.md"
copy_template "$REPO/templates/core/CLAUDE.md" "$TARGET/CLAUDE.md"

if [ "$WANT_LIFE" -eq 1 ]; then
    echo "Extension Life :"
    for f in PREUVES ECHEANCES CORRESPONDANCES; do
        copy_template "$REPO/templates/extensions/life/$f.md" "$TARGET/$f.md"
    done
fi

if [ "$WANT_CODE" -eq 1 ]; then
    echo "Extension Code :"
    for f in CONSTITUTION STACK_VALIDATION ARCHITECTURE SPECS TEST_PLAN IMPACT_ANALYSIS RELEASE; do
        copy_template "$REPO/templates/extensions/code/$f.md" "$TARGET/$f.md"
    done
    append_code_agents "$REPO/templates/extensions/code/AGENTS.md" "$TARGET/AGENTS.md"
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

# --- Auto-vérification, sans dépendre du repo MyProjectOS --------------------
# check-project.sh lit VERSION à côté de lui (dirname/..) : les deux sont copiés
# ensemble pour que le projet reste vérifiable même si MyProjectOS a disparu
# (install.sh en mode jetable). VERSION est une empreinte figée à la création ;
# check-update.sh compare cette empreinte à la dernière version publiée.
mkdir -p "$TARGET/scripts"
for _s in check-project.sh check-update.sh check-secrets.sh check-iteration.sh sync-progress.sh sujet.sh; do
    if [ "$WANT_MERGE" -eq 1 ] && [ -e "$TARGET/scripts/$_s" ]; then
        echo "  = scripts/$_s (déjà présent, conservé ; --update-method pour rafraîchir)"
    else
        cp "$REPO/scripts/$_s" "$TARGET/scripts/$_s"
        chmod +x "$TARGET/scripts/$_s"
        echo "  + scripts/$_s"
    fi
done
if [ "$WANT_MERGE" -eq 1 ] && [ -e "$TARGET/VERSION" ]; then
    echo "  = VERSION (déjà présente, conservée)"
else
    printf '%s\n' "$OS_VERSION" > "$TARGET/VERSION"
    echo "  + VERSION (empreinte $OS_VERSION, projet auto-vérifiable)"
fi
if [ "$WANT_MERGE" -eq 1 ] && [ -e "$TARGET/$MANIFEST_REL" ]; then
    echo "  = $MANIFEST_REL (déjà présent, conservé)"
else
    write_manifest
    echo "  + $MANIFEST_REL (liste des artefacts méthode, base de --update-method)"
fi

# --- Copie des hooks (câblage : wire_settings, plus bas) ---------------------
# Pour mettre à jour les hooks, relancer l'init avec --update-method.
mkdir -p "$TARGET/.claude/hooks"
for _h in _lib.sh hook-pre-write.sh hook-stop-progress.sh hook-post-progress.sh; do
    if [ "$WANT_MERGE" -eq 1 ] && [ -e "$TARGET/.claude/hooks/$_h" ]; then
        echo "  = .claude/hooks/$_h (déjà présent, conservé ; --update-method pour rafraîchir)"
        continue
    fi
    cp "$REPO/scripts/hooks/$_h" "$TARGET/.claude/hooks/$_h"
    chmod +x "$TARGET/.claude/hooks/$_h"
    echo "  + .claude/hooks/$_h"
done

# Garde-fou Git destructif (A1) : optionnel, projets Code/Hybrid uniquement.
GIT_HOOK_WIRED=0
if [ "$TYPE" = "Code" ] || [ "$TYPE" = "Hybrid" ]; then
    GIT_HOOK_WIRED=1
    if [ "$WANT_MERGE" -eq 1 ] && [ -e "$TARGET/.claude/hooks/hook-pre-git.sh" ]; then
        echo "  = .claude/hooks/hook-pre-git.sh (déjà présent, conservé ; --update-method pour rafraîchir)"
    else
        cp "$REPO/scripts/hooks/hook-pre-git.sh" "$TARGET/.claude/hooks/hook-pre-git.sh"
        chmod +x "$TARGET/.claude/hooks/hook-pre-git.sh"
        echo "  + .claude/hooks/hook-pre-git.sh (garde-fou Git destructif, Code/Hybrid)"
    fi
fi

# --- Skills du projet : source unique 98_configuration/skills/, liens par agent
# Contrat d'un agent (DEC-0052) : toutes les skills du projet, la skill assistant
# comprise, vivent en 98_configuration/skills/<skill>/ ; Claude Code et Codex y
# accèdent par lien symbolique relatif, posé pour tout agent connu.
migrate_old_skill_copy
install_myprojectos_skill_source
link_myprojectos_skill_dirs

# --- 97_gouvernance/ : droit local du projet, présent dès la création (Q7) ----
create_gouvernance_readme

wire_settings "$GIT_HOOK_WIRED"

if [ "$WANT_MERGE" -eq 1 ]; then
    echo ""
    echo "Résumé de la greffe :"
    [ -n "$CREATED" ] && echo "  créés :$CREATED"
    [ -n "$KEPT" ] && echo "  conservés (à relire pour cohérence) :$KEPT"
fi

echo ""
echo "Fait. Prochaine étape : renseigner PROJECT.md (pourquoi, périmètre, objectifs, critères de réussite)."

if [ "$HOOKS_MERGE_PENDING" -eq 1 ]; then
    exit 1
fi
