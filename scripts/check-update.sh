#!/bin/sh
# check-update.sh — signale si une version plus récente de la méthode MyProjectOS existe.
# Usage : check-update.sh [chemin-projet]   (défaut : dossier courant)
# Informe seulement : ne télécharge rien dans le projet, ne modifie rien.
# Codes de sortie : 0 = à jour ou indéterminable, 10 = mise à jour disponible, 1 = erreur.
#
# Source de la version distante, dans l'ordre :
#   1. MYPROJECTOS_REPO_URL, si la valeur est un dossier local (clone du repo méthode, tests) ;
#   2. curl sur MYPROJECTOS_RAW_URL (défaut : dépôt GitHub public, branche main) ;
#   3. git ls-remote --tags sur MYPROJECTOS_REPO_URL (repli sans curl, versions seulement).
# POSIX sh. Copié dans chaque projet par init-project.sh, à côté de check-project.sh.

set -u

TARGET=${1:-.}
REPO_URL="${MYPROJECTOS_REPO_URL:-https://github.com/Mediatros/MyProjectOS.git}"
RAW_BASE="${MYPROJECTOS_RAW_URL:-https://raw.githubusercontent.com/Mediatros/MyProjectOS/main}"
MANIFEST="$TARGET/.myprojectos/manifest"

# Comparaison de versions X.Y.Z, portable. Échos : lt | eq | gt (pour $1 vs $2).
ver_cmp() {
    _i=1
    while [ "$_i" -le 3 ]; do
        _fa=$(printf '%s' "$1" | cut -d. -f"$_i" | tr -dc '0-9'); [ -n "$_fa" ] || _fa=0
        _fb=$(printf '%s' "$2" | cut -d. -f"$_i" | tr -dc '0-9'); [ -n "$_fb" ] || _fb=0
        if [ "$_fa" -lt "$_fb" ]; then echo lt; return; fi
        if [ "$_fa" -gt "$_fb" ]; then echo gt; return; fi
        _i=$((_i + 1))
    done
    echo eq
}

if [ ! -f "$TARGET/PROJECT.md" ]; then
    echo "Pas de PROJECT.md dans '$TARGET' : ce n'est pas un projet MyProjectOS." >&2
    exit 1
fi

# --- Version du projet ---------------------------------------------------------
PRJ=$(sed -n 's/^version_methode:[[:space:]]*//p' "$TARGET/PROJECT.md" | head -n 1 | tr -d '[:space:]')
if [ -z "$PRJ" ] || [ "$PRJ" = "<VERSION>" ]; then
    PRJ=$(head -n 1 "$TARGET/VERSION" 2>/dev/null | tr -d '[:space:]')
fi
if [ -z "$PRJ" ]; then
    echo "[!] Projet sans empreinte de version (créé avant le versionnement)."
    echo "    Suivre le runbook de migration : docs/versioning.md du repo méthode."
    PRJ="0.0.0"
fi

# --- Version distante et CHANGELOG distant --------------------------------------
TMP=$(mktemp -d 2>/dev/null || mktemp -d -t mposcu)
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT INT TERM

LATEST=""
REMOTE_CHANGELOG=""

if [ -d "$REPO_URL" ]; then
    # Cas 1 : copie locale du repo méthode (clone à demeure ou tests).
    LATEST=$(head -n 1 "$REPO_URL/VERSION" 2>/dev/null | tr -d '[:space:]')
    [ -f "$REPO_URL/CHANGELOG.md" ] && REMOTE_CHANGELOG="$REPO_URL/CHANGELOG.md"
elif command -v curl >/dev/null 2>&1; then
    # Cas 2 : dépôt public, lecture directe des fichiers bruts.
    LATEST=$(curl -fsSL "$RAW_BASE/VERSION" 2>/dev/null | head -n 1 | tr -d '[:space:]')
    if [ -n "$LATEST" ] && curl -fsSL "$RAW_BASE/CHANGELOG.md" > "$TMP/CHANGELOG.md" 2>/dev/null; then
        REMOTE_CHANGELOG="$TMP/CHANGELOG.md"
    fi
fi

if [ -z "$LATEST" ] && command -v git >/dev/null 2>&1; then
    # Cas 3 : repli sur les tags git (fonctionne aussi en accès authentifié SSH).
    LATEST=$(git ls-remote --tags "$REPO_URL" 2>/dev/null \
        | sed -n 's#.*refs/tags/v\([0-9][0-9.]*\)$#\1#p' \
        | sort -t. -k1,1n -k2,2n -k3,3n | tail -n 1)
fi

if [ -z "$LATEST" ]; then
    echo "[!] Version distante introuvable (réseau, accès au dépôt, ou curl/git absents)."
    echo "    Dépôt interrogé : $REPO_URL"
    exit 0
fi

# --- Verdict --------------------------------------------------------------------
case "$(ver_cmp "$PRJ" "$LATEST")" in
    eq|gt)
        echo "[ok] Projet en v$PRJ : à jour avec la méthode (dernière version publiée : v$LATEST)."
        exit 0
        ;;
esac

echo "[!] Mise à jour disponible : projet en v$PRJ, méthode en v$LATEST."
echo ""

# Ce que les nouvelles versions apportent (section Releases du CHANGELOG distant).
if [ -n "$REMOTE_CHANGELOG" ]; then
    echo "Apports des versions plus récentes que la vôtre :"
    grep -E '^- \*\*v[0-9]+\.[0-9]+\.[0-9]+\*\*' "$REMOTE_CHANGELOG" 2>/dev/null \
    | while IFS= read -r _line; do
        _v=$(printf '%s' "$_line" | sed -n 's/^- \*\*v\([0-9.]*\)\*\*.*/\1/p')
        [ -n "$_v" ] || continue
        if [ "$(ver_cmp "$_v" "$PRJ")" = "gt" ]; then
            printf '  %s\n' "$_line"
        fi
    done
    echo ""
else
    echo "Détail des changements : section Releases du CHANGELOG du dépôt méthode."
    echo ""
fi

# Ce qui serait remplacé par la mise à jour (artefacts méthode, jamais le contenu).
echo "Artefacts méthode qui seraient remplacés (le contenu du projet n'est jamais touché) :"
if [ -f "$MANIFEST" ]; then
    grep -v '^#' "$MANIFEST" | grep -v '^version=' | while IFS= read -r _a; do
        [ -n "$_a" ] || continue
        [ -f "$TARGET/$_a" ] && printf '  %s\n' "$_a"
    done
else
    # Projet créé avant le manifest (méthode < 0.5.0) : liste par défaut.
    for _a in .claude/hooks/_lib.sh .claude/hooks/hook-pre-write.sh \
              .claude/hooks/hook-stop-progress.sh \
              .claude/skills/my-project-os/SKILL.md \
              scripts/check-project.sh VERSION; do
        [ -f "$TARGET/$_a" ] && printf '  %s\n' "$_a"
    done
fi
echo ""
echo "Pour appliquer (après validation humaine) :"
echo "  curl -fsSL $RAW_BASE/install.sh | sh -s -- \"$TARGET\" --update-method"
echo "Les anciens artefacts sont sauvegardés dans 99_archive/methode-avant-v$PRJ/ avant remplacement."
exit 10
