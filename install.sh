#!/bin/sh
# install.sh — installe MyProjectOS sur un projet, sans laisser de trace du dépôt.
#
# Usage (depuis le lien GitHub, rien à cloner à la main) :
#   curl -fsSL https://raw.githubusercontent.com/Mediatros/MyProjectOS/main/install.sh \
#     | sh -s -- <chemin-projet> [--life] [--code] [--knowledge] [--into-existing] [--update-method]
#
# Usage (copie locale du script) :
#   sh install.sh <chemin-projet> [flags]
#
# Le dépôt est cloné dans un dossier temporaire, init-project.sh est lancé avec
# les arguments fournis, puis le clone est supprimé. Le projet final est
# autonome : les hooks sont copiés dans .claude/hooks/ et ne dépendent plus du
# dépôt MyProjectOS.
#
# Variables d'environnement (optionnelles) :
#   MYPROJECTOS_REPO_URL  source du dépôt (défaut : GitHub public)
#   MYPROJECTOS_REF       branche ou tag à cloner (défaut : main)
# POSIX sh.

set -eu

REPO_URL="${MYPROJECTOS_REPO_URL:-https://github.com/Mediatros/MyProjectOS.git}"
REPO_REF="${MYPROJECTOS_REF:-main}"

if [ "$#" -eq 0 ]; then
    echo "Usage : install.sh <chemin-projet> [--life] [--code] [--knowledge] [--into-existing] [--update-method]" >&2
    exit 1
fi

command -v git >/dev/null 2>&1 || { echo "git est requis pour installer MyProjectOS." >&2; exit 1; }

TMP=$(mktemp -d 2>/dev/null || mktemp -d -t mpos)
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT INT TERM

echo "Récupération de MyProjectOS ($REPO_REF) depuis $REPO_URL..."
if ! git clone --depth 1 --branch "$REPO_REF" "$REPO_URL" "$TMP/MyProjectOS" >/dev/null 2>&1; then
    # Repli si la ref n'est pas une branche (ou clone par ref non supporté).
    git clone --depth 1 "$REPO_URL" "$TMP/MyProjectOS" >/dev/null 2>&1 \
        || { echo "Clone impossible depuis $REPO_URL (réseau, accès ou URL)." >&2; exit 1; }
fi

INIT="$TMP/MyProjectOS/scripts/init-project.sh"
[ -f "$INIT" ] || { echo "Dépôt cloné mais scripts/init-project.sh introuvable." >&2; exit 1; }

# --sync est inutile ici (le clone est déjà frais) : on le retire s'il est passé.
ARGS=""
for a in "$@"; do
    [ "$a" = "--sync" ] && continue
    ARGS="$ARGS \"$a\""
done

eval "sh \"\$INIT\" $ARGS"

echo "MyProjectOS installé. Le projet est autonome (hooks dans .claude/hooks/)."
