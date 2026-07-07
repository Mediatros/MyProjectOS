#!/bin/sh
# hook-stop-progress.sh — Stop.
# Avertit (sans bloquer) si du travail a eu lieu sans mise à jour de PROGRESS.md.

DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
. "$DIR/_lib.sh"

read_payload

PROJECT_DIR=$(project_dir)
is_project_os "$PROJECT_DIR" || exit 0
[ -f "$PROJECT_DIR/PROGRESS.md" ] || exit 0

# Signal de "travail effectué" = changements non committés. Sans git, on ne juge pas.
command -v git >/dev/null 2>&1 || exit 0
git -C "$PROJECT_DIR" rev-parse --git-dir >/dev/null 2>&1 || exit 0

CHANGES=$(git -C "$PROJECT_DIR" status --porcelain 2>/dev/null)
[ -n "$CHANGES" ] || exit 0

# PROGRESS.md à la racine fait-il partie des fichiers touchés ?
# Format porcelain : deux caractères de statut, un espace, puis le chemin.
# On exige le chemin exact "PROGRESS.md" (racine) pour ne pas être satisfait
# par un templates/core/PROGRESS.md ou autre copie dans un sous-dossier.
if printf '%s\n' "$CHANGES" | grep -qE '^.. PROGRESS\.md$|-> PROGRESS\.md$'; then
    exit 0
fi

warn "MyProjectOS : des changements sont en cours mais PROGRESS.md n'a pas été mis à jour cette session. Pense à refléter l'état actuel et le bloc d'en-tête (derniere_maj, prochaine_action) avant de t'arrêter."
