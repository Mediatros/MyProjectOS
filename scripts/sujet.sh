#!/bin/sh
# sujet.sh — crée ou archive un sujet d'un projet organisé par sujets (DEC-0053).
# Usage : sh scripts/sujet.sh new [Sxx] "<Titre du sujet>" [chemin-projet]
#         sh scripts/sujet.sh archive Sxx [chemin-projet]
#   new     : pose 02_sujets/Sxx_Titre_Du_Sujet/PROGRESS.md (gabarit ci-dessous, en-tête
#             renseigné), la ligne du sujet dans 02_sujets/INDEX.md (objet à compléter),
#             puis projette le parent (sync-progress.sh). Numéro proposé si omis.
#   archive : déplace un sujet « clos » vers 99_archive/02_sujets/, retire sa ligne
#             d'INDEX.md, puis projette le parent. Refuse un sujet non clos.
# Le dossier des sujets est 02_sujets/ ou tout dossier 02_<nom> déjà présent (DEC-0033).
# Le gabarit embarqué est celui de templates/extensions/life/02_sujets/ (test en CI).
# POSIX sh. Copié dans scripts/ de chaque projet par init-project.sh.

set -u

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
TODAY=$(date +%Y-%m-%d)

usage() {
    echo "Usage : sh scripts/sujet.sh new [Sxx] \"<Titre du sujet>\" [chemin-projet]" >&2
    echo "        sh scripts/sujet.sh archive Sxx [chemin-projet]" >&2
    exit 1
}

VERB=${1:-}
[ -n "$VERB" ] || usage
shift

ID=""
TITLE=""
TARGET="."
case "$VERB" in
    new)
        case "${1:-}" in
            S[0-9][0-9]) ID=$1; shift ;;
        esac
        TITLE=${1:-}
        [ -n "$TITLE" ] || usage
        TARGET=${2:-.}
        ;;
    archive)
        ID=${1:-}
        case "$ID" in S[0-9][0-9]) ;; *) usage ;; esac
        TARGET=${2:-.}
        ;;
    *) usage ;;
esac

[ -d "$TARGET" ] || { echo "Dossier introuvable : $TARGET" >&2; exit 1; }
[ -f "$TARGET/PROJECT.md" ] || { echo "Pas de PROJECT.md dans '$TARGET' : ce n'est pas un projet MyProjectOS." >&2; exit 1; }

fm_field() {
    awk -v k="$2" '
        NR == 1 { if ($0 != "---") exit; next }
        $0 == "---" { exit }
        index($0, k ":") == 1 {
            v = substr($0, length(k) + 2)
            sub(/^[[:space:]]+/, "", v); sub(/[[:space:]]+$/, "", v)
            if (v ~ /^<.*>$/) v = ""
            print v; exit
        }' "$1"
}

NAME=$(fm_field "$TARGET/PROJECT.md" projet)
[ -n "$NAME" ] || NAME=$(basename -- "$(cd "$TARGET" && pwd)")

# Dossier des sujets : le 02_* existant (hors 02_work), 02_sujets/ à défaut.
SUBJ_DIR=""
_n=0
for _d in "$TARGET"/02_*/; do
    [ -d "$_d" ] || continue
    [ "$(basename -- "$_d")" = "02_work" ] && continue
    SUBJ_DIR=${_d%/}
    _n=$((_n + 1))
done
if [ "$_n" -gt 1 ]; then
    echo "Plusieurs dossiers 02_* à la racine : un seul doit porter les sujets (structures/life-tree.md)." >&2
    exit 1
fi
[ -n "$SUBJ_DIR" ] || SUBJ_DIR="$TARGET/02_sujets"
SUBJ_REL=${SUBJ_DIR#"$TARGET"/}

sync_parent() {
    if [ -f "$SCRIPT_DIR/sync-progress.sh" ]; then
        sh "$SCRIPT_DIR/sync-progress.sh" "$TARGET" || true
    else
        echo "  ! scripts/sync-progress.sh absent : lancer la projection du parent à la main" >&2
    fi
}

# --- new -----------------------------------------------------------------------
if [ "$VERB" = "new" ]; then
    if [ -z "$ID" ]; then
        _i=1
        while [ "$_i" -le 99 ]; do
            _cand=$(printf 'S%02d' "$_i")
            _taken=0
            for _e in "$SUBJ_DIR/${_cand}_"*/; do [ -d "$_e" ] && _taken=1; done
            if [ "$_taken" -eq 0 ]; then ID=$_cand; break; fi
            _i=$((_i + 1))
        done
        [ -n "$ID" ] || { echo "Aucun identifiant S01..S99 libre." >&2; exit 1; }
    else
        for _e in "$SUBJ_DIR/${ID}_"*/; do
            [ -d "$_e" ] && { echo "Identifiant $ID déjà pris : $(basename -- "$_e")" >&2; exit 1; }
        done
    fi

    # Nom de dossier : accents retirés (python3 de préférence, iconv sinon), le
    # reste ramené à A-Za-z0-9 et underscores.
    _slug=""
    if command -v python3 >/dev/null 2>&1; then
        _slug=$(printf '%s' "$TITLE" | python3 -c 'import sys,unicodedata; print(unicodedata.normalize("NFKD", sys.stdin.read()).encode("ascii","ignore").decode())' 2>/dev/null)
    fi
    if [ -z "$_slug" ] && command -v iconv >/dev/null 2>&1; then
        _slug=$(printf '%s' "$TITLE" | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null)
    fi
    [ -n "$_slug" ] || _slug=$TITLE
    _slug=$(printf '%s' "$_slug" | LC_ALL=C tr -c 'A-Za-z0-9' '_' | tr -s '_' | sed 's/^_//; s/_$//')
    [ -n "$_slug" ] || { echo "Titre « $TITLE » ne donne aucun nom de dossier utilisable." >&2; exit 1; }

    FOLDER="$SUBJ_DIR/${ID}_${_slug}"
    mkdir -p "$FOLDER"
    if [ "$SUBJ_DIR" = "$TARGET/02_sujets" ] && [ "$_n" -eq 0 ]; then
        echo "  + $SUBJ_REL/ (organisation par sujets activée)"
    fi

    # Gabarit du progrès de sujet : identique à
    # templates/extensions/life/02_sujets/Sxx_NomDuSujet/PROGRESS.md (contrôlé en CI).
    cat > "$FOLDER/PROGRESS.md" <<'EOF_PROGRESS'
---
projet: <NomDuProjet>
sujet: Sxx
titre: <TitreDuSujet>
statut: actif | en pause | clos
derniere_maj: YYYY-MM-DD
etat: <une phrase : où en est le sujet aujourd'hui>
prochaine_action: <une phrase : la prochaine action concrète, ou la condition attendue>
prochaine_echeance: <YYYY-MM-DD ou vide>
---

# PROGRESS.md — Sxx <TitreDuSujet>

> Photo de l'instant du sujet, jamais un journal. Le détail vit ici ; seul l'en-tête remonte dans le `PROGRESS.md` racine (`etat` et `prochaine_action`, une phrase chacun, 200 caractères au plus).
> Règle immuable : toute mise à jour de ce fichier met aussi à jour le bloc d'en-tête ci-dessus. Statuts : `actif` (travail en cours), `en pause` (rien à faire pour l'instant, la raison se lit dans `prochaine_action`), `clos` (réglé, à archiver ensuite).
> Frontière : l'objet du sujet vit dans `../INDEX.md`, l'historique daté dans `CHANGELOG.md`, les tâches dans `TASKS.md`, les analyses dans `NOTES.md` du sujet s'il existe.

## Objectif du sujet

<Une ligne. Le pourquoi et le périmètre vivent dans `../INDEX.md`.>

## Contexte utile

- <ce qu'il faut savoir pour reprendre ce sujet sans historique de conversation>

## État actuel

<Où en est le sujet aujourd'hui, en quelques phrases. Pas d'historique.>

## Travail en cours

- <ce qui est activement en train d'être fait sur ce sujet>

## Problèmes ouverts / points de vigilance

- <ce qui bloque, ce qui reste incertain, ce qui demande une décision>

## Prochaines étapes

1. <prochaine action concrète>
2. <puis>

## Références utiles

- <fichiers, tâches `Tx.y`, preuves `P-XXXX`, correspondances `C-XXXX` du sujet>

## Contraintes importantes / À ne pas faire

- <gardes-fous propres à ce sujet, actions nécessitant validation humaine>
EOF_PROGRESS
    _t=$(printf '%s' "$TITLE" | sed 's/[#&\\]/\\&/g')
    _p=$(printf '%s' "$NAME" | sed 's/[#&\\]/\\&/g')
    sed \
        -e "s#<NomDuProjet>#$_p#g" \
        -e "s#<TitreDuSujet>#$_t#g" \
        -e "s#^sujet: Sxx\$#sujet: $ID#" \
        -e "s|^# PROGRESS.md — Sxx |# PROGRESS.md — $ID |" \
        -e "s#^statut: actif | en pause | clos\$#statut: actif#" \
        -e "s#^derniere_maj: YYYY-MM-DD\$#derniere_maj: $TODAY#" \
        -e "s#^etat: <.*>\$#etat: Sujet créé, à cadrer.#" \
        -e "s#^prochaine_action: <.*>\$#prochaine_action: Renseigner l'objet du sujet dans INDEX.md, puis son état et sa prochaine action ici.#" \
        -e "s#^prochaine_echeance: <.*>\$#prochaine_echeance:#" \
        "$FOLDER/PROGRESS.md" > "$FOLDER/PROGRESS.md.tmp" && mv "$FOLDER/PROGRESS.md.tmp" "$FOLDER/PROGRESS.md"
    echo "  + $SUBJ_REL/${ID}_${_slug}/PROGRESS.md"

    INDEX="$SUBJ_DIR/INDEX.md"
    if [ ! -f "$INDEX" ]; then
        cat > "$INDEX" <<'EOF_INDEX'
# INDEX — 02_sujets/ de <NomDuProjet>

> Carte des sujets : de quoi traite chaque dossier `Sxx_NomDuSujet/`, pas où il en est.
> L'état d'un sujet vit dans son `PROGRESS.md` ; la vue d'ensemble, dans le bloc « sujets » du `PROGRESS.md` racine, généré par `scripts/sync-progress.sh`.
> Convention : `structures/life-tree.md` du dépôt méthode. Un sujet se crée par `sh scripts/sujet.sh new "Titre"` et s'archive par `sh scripts/sujet.sh archive Sxx`.

| Sous-dossier | Objet | Hors périmètre / voir aussi |
|---|---|---|
EOF_INDEX
        sed -e "s#<NomDuProjet>#$_p#g" -e "s#02_sujets/ de#$(basename -- "$SUBJ_DIR")/ de#" "$INDEX" > "$INDEX.tmp" && mv "$INDEX.tmp" "$INDEX"
        echo "  + $SUBJ_REL/INDEX.md"
    fi
    printf '| `%s_%s` | <à compléter : de quoi il s'"'"'agit, pour qui, quel résultat attendu> | |\n' "$ID" "$_slug" >> "$INDEX"
    echo "  ~ $SUBJ_REL/INDEX.md (ligne $ID ajoutée, objet à compléter)"

    sync_parent
    echo ""
    echo "Sujet $ID « $TITLE » créé. À faire ensuite :"
    echo "  1. renseigner l'objet du sujet dans $SUBJ_REL/INDEX.md ;"
    echo "  2. renseigner etat et prochaine_action dans $SUBJ_REL/${ID}_${_slug}/PROGRESS.md (le parent se met à jour seul)."
    exit 0
fi

# --- archive -------------------------------------------------------------------
FOLDER=""
for _e in "$SUBJ_DIR/${ID}_"*/; do
    [ -d "$_e" ] || continue
    [ -z "$FOLDER" ] || { echo "Plusieurs dossiers pour $ID dans $SUBJ_REL/ : trancher à la main." >&2; exit 1; }
    FOLDER=${_e%/}
done
[ -n "$FOLDER" ] || { echo "Aucun sujet $ID dans $SUBJ_REL/." >&2; exit 1; }
_base=$(basename -- "$FOLDER")

_statut=""
[ -f "$FOLDER/PROGRESS.md" ] && _statut=$(fm_field "$FOLDER/PROGRESS.md" statut)
if [ "$_statut" != "clos" ]; then
    echo "Sujet $ID ($_base) : statut « ${_statut:-absent} », pas « clos ». Passer d'abord le statut à clos dans son PROGRESS.md (décision humaine), puis relancer." >&2
    exit 1
fi

DEST_DIR="$TARGET/99_archive/$(basename -- "$SUBJ_DIR")"
if [ -e "$DEST_DIR/$_base" ]; then
    echo "Destination déjà occupée : 99_archive/$(basename -- "$SUBJ_DIR")/$_base" >&2
    exit 1
fi
mkdir -p "$DEST_DIR"
mv "$FOLDER" "$DEST_DIR/$_base"
echo "  > $SUBJ_REL/$_base/ -> 99_archive/$(basename -- "$SUBJ_DIR")/$_base/"

INDEX="$SUBJ_DIR/INDEX.md"
if [ -f "$INDEX" ]; then
    grep -v "^| \`${ID}_" "$INDEX" > "$INDEX.tmp" && mv "$INDEX.tmp" "$INDEX"
    echo "  ~ $SUBJ_REL/INDEX.md (ligne $ID retirée)"
fi

sync_parent
echo ""
echo "Sujet $ID archivé. Consigner l'archivage dans CHANGELOG.md (entrée CHG-)."
exit 0
