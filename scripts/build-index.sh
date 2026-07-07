#!/bin/sh
# build-index.sh — génère un index global multi-projets.
# Usage : build-index.sh [racine]   (défaut : dossier courant)
# Scanne les sous-dossiers directs de <racine> et, pour chacun qui contient un
# PROGRESS.md, lit le frontmatter (projet, type, statut, derniere_maj,
# prochaine_action, prochaine_echeance). Écrit <racine>/INDEX.md.
# POSIX sh + awk (présent sur Mac et Linux). N'écrit rien dans les projets.

set -u

ROOT=${1:-.}
if [ ! -d "$ROOT" ]; then
    echo "Dossier introuvable : $ROOT" >&2
    exit 1
fi
ROOT=$(CDPATH='' cd -- "$ROOT" && pwd)
OUT="$ROOT/INDEX.md"

# fm_field <fichier> <clé> : valeur d'un champ du frontmatter YAML (entre les --- ).
fm_field() {
    awk -v key="$2" '
        NR==1 && $0=="---" { infm=1; next }
        infm && $0=="---"  { exit }
        infm {
            i = index($0, ":")
            if (i > 0) {
                k = substr($0, 1, i-1); gsub(/^[ \t]+|[ \t]+$/, "", k)
                if (k == key) {
                    v = substr($0, i+1); gsub(/^[ \t]+|[ \t]+$/, "", v)
                    print v; exit
                }
            }
        }
    ' "$1"
}

# Nettoie une cellule de tableau : neutralise les | et borne la longueur.
cell() {
    printf '%s' "$1" | tr '\n' ' ' | sed 's/|/\//g' | cut -c1-80
}

# Collecte les lignes dans un fichier temporaire pour pouvoir trier.
TMP=$(mktemp 2>/dev/null || printf '%s' "${TMPDIR:-/tmp}/posai-index.$$")
: > "$TMP"
COUNT=0

for dir in "$ROOT"/*/; do
    [ -d "$dir" ] || continue
    progress="${dir}PROGRESS.md"
    [ -f "$progress" ] || continue

    name=$(fm_field "$progress" projet);              [ -n "$name" ] || name=$(basename -- "$dir")
    type=$(fm_field "$progress" type)
    statut=$(fm_field "$progress" statut)
    maj=$(fm_field "$progress" derniere_maj)
    action=$(fm_field "$progress" prochaine_action)
    echeance=$(fm_field "$progress" prochaine_echeance)

    # Clé de tri = derniere_maj (récent en haut) ; projets sans date en bas.
    sortkey=${maj:-0000-00-00}
    printf '%s\t| %s | %s | %s | %s | %s | %s |\n' \
        "$sortkey" \
        "$(cell "$name")" "$(cell "${type:--}")" "$(cell "${statut:--}")" \
        "$(cell "${maj:--}")" "$(cell "${action:--}")" "$(cell "${echeance:--}")" \
        >> "$TMP"
    COUNT=$((COUNT + 1))
done

{
    echo "# INDEX — Projets"
    echo ""
    echo "_Généré le $(date +%Y-%m-%d) par \`scripts/build-index.sh\`. Vue d'ensemble régénérable, ne pas éditer à la main._"
    echo ""
    if [ "$COUNT" -eq 0 ]; then
        echo "Aucun projet trouvé sous \`$ROOT\` (un projet = un sous-dossier avec un \`PROGRESS.md\`)."
    else
        echo "| Projet | Type | Statut | Dernière maj | Prochaine action | Échéance |"
        echo "|---|---|---|---|---|---|"
        sort -r "$TMP" | cut -f2-
    fi
} > "$OUT"

rm -f "$TMP"
echo "Index écrit : $OUT  ($COUNT projet(s))"
