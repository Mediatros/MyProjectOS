#!/bin/sh
# sync-progress.sh — projette l'état des sujets dans le PROGRESS.md racine (DEC-0053).
# Usage : sh scripts/sync-progress.sh [--check] [chemin-projet]   (défaut : dossier courant)
#   sans option : recalcule le bloc « sujets » du parent et l'écrit s'il diffère ;
#                 silencieux et sans écriture quand rien n'a changé.
#   --check     : ne modifie rien ; code 1 si le parent est en retard sur les sujets.
# Codes : 0 à jour (ou écrit), 1 parent désynchronisé (--check), 2 marqueurs absents.
#
# Principe : la ligne d'un sujet ne dépend que du frontmatter de son
# 02_*/Sxx_*/PROGRESS.md (sujet, titre, statut, derniere_maj, etat,
# prochaine_action, prochaine_echeance), jamais de sa prose. Même entrée,
# même sortie à l'octet près : plusieurs déclencheurs (hook, rituel, cron)
# sur plusieurs machines produisent le même contenu, donc aucune écriture
# différente à faire converger. Le script ne possède que la zone entre les
# marqueurs « sujets:debut » / « sujets:fin » du parent ; le reste du
# fichier n'est jamais touché, sauf derniere_maj (date du jour si le bloc
# a changé) et prochaine_echeance (la plus proche des échéances des sujets
# non clos).
# POSIX sh + awk, aucune dépendance. Copié dans scripts/ de chaque projet.

set -u

CHECK=0
TARGET="."
for arg in "$@"; do
    case "$arg" in
        --check) CHECK=1 ;;
        -*) echo "Option inconnue : $arg" >&2; exit 1 ;;
        *) TARGET=$arg ;;
    esac
done

[ -d "$TARGET" ] || { echo "Dossier introuvable : $TARGET" >&2; exit 1; }
[ -f "$TARGET/PROJECT.md" ] || exit 0
PARENT="$TARGET/PROGRESS.md"
[ -f "$PARENT" ] || exit 0

TODAY=$(date +%Y-%m-%d)
MARK_BEGIN='<!-- sujets:debut'
MARK_END='<!-- sujets:fin'

# fm_field <fichier> <clé> : valeur d'un champ du frontmatter (bloc --- initial),
# vide si absent. Un placeholder de gabarit (<...>) vaut vide.
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

is_date() {
    case "$1" in
        [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) return 0 ;;
        *) return 1 ;;
    esac
}

TMPD=$(mktemp -d 2>/dev/null || mktemp -d -t myprojectos-sync)
trap 'rm -rf "$TMPD"' EXIT INT TERM
BLOCKF="$TMPD/block"
: > "$BLOCKF"

FOUND=0
CLOS=""
ECHEANCES=""

for _d in "$TARGET"/02_*/S[0-9][0-9]_*/; do
    [ -d "$_d" ] || continue
    FOUND=1
    _rel=${_d#"$TARGET"/}; _rel=${_rel%/}
    _name=${_rel##*/}
    _id=${_name%%_*}
    _local="${_d}PROGRESS.md"

    if [ ! -f "$_local" ]; then
        printf -- '- **%s** · progrès local absent · `%s/`\n' "$_id" "$_rel" >> "$BLOCKF"
        continue
    fi

    _sujet=$(fm_field "$_local" sujet)
    _titre=$(fm_field "$_local" titre)
    _statut=$(fm_field "$_local" statut)
    _maj=$(fm_field "$_local" derniere_maj)
    _etat=$(fm_field "$_local" etat)
    _action=$(fm_field "$_local" prochaine_action)
    _ech=$(fm_field "$_local" prochaine_echeance)

    _why=""
    if [ "$_sujet" != "$_id" ]; then
        _why="champ sujet « $_sujet » différent du dossier $_id"
    else
        case "$_statut" in
            actif|"en pause"|clos) ;;
            *) _why="statut « $_statut » hors actif / en pause / clos" ;;
        esac
    fi
    [ -n "$_why" ] || is_date "$_maj" || _why="derniere_maj absente ou hors YYYY-MM-DD"
    if [ -n "$_why" ]; then
        echo "sync-progress : $_rel/PROGRESS.md : $_why" >&2
        printf -- '- **%s** · progrès local invalide (%s) · `%s/PROGRESS.md`\n' "$_id" "$_why" "$_rel" >> "$BLOCKF"
        continue
    fi

    if [ -z "$_titre" ]; then
        _titre=$(printf '%s' "${_name#*_}" | tr '_' ' ')
    fi

    if [ "$_statut" = "clos" ]; then
        CLOS="${CLOS}${CLOS:+, }$_id · $_titre ($_maj)"
        continue
    fi

    [ -n "$_etat" ] || _etat="(non renseigné)"
    [ -n "$_action" ] || _action="(non renseignée)"
    _echtxt=""
    if is_date "$_ech"; then
        _echtxt=" · échéance $_ech"
        ECHEANCES="$ECHEANCES $_ech"
    fi
    printf -- '- **%s · %s** · %s · maj %s%s · état : %s · prochaine action : %s · `%s/PROGRESS.md`\n' \
        "$_id" "$_titre" "$_statut" "$_maj" "$_echtxt" "$_etat" "$_action" "$_rel" >> "$BLOCKF"
done

if [ -n "$CLOS" ]; then
    [ -s "$BLOCKF" ] && printf '\n' >> "$BLOCKF"
    printf 'Sujets clos : %s\n' "$CLOS" >> "$BLOCKF"
fi

# Marqueurs : exactement un de chaque dans le parent.
_nb=$(grep -c "^$MARK_BEGIN" "$PARENT" 2>/dev/null | tr -d ' ')
_ne=$(grep -c "^$MARK_END" "$PARENT" 2>/dev/null | tr -d ' ')
if [ "${_nb:-0}" -ne 1 ] || [ "${_ne:-0}" -ne 1 ]; then
    # Projet sans sujets et sans zone : rien à projeter, aucun défaut.
    [ "$FOUND" -eq 1 ] || exit 0
    echo "sync-progress : PROGRESS.md sans zone « sujets » (marqueurs <!-- sujets:debut --> / <!-- sujets:fin --> absents ou multiples) : poser les marqueurs dans la section État actuel (gabarit templates/core/PROGRESS.md)" >&2
    exit 2
fi

# Bloc actuel du parent (lignes strictement entre les marqueurs).
CURF="$TMPD/current"
awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
    index($0, b) == 1 { inb = 1; next }
    index($0, e) == 1 { inb = 0 }
    inb { print }' "$PARENT" > "$CURF"

if cmp -s "$BLOCKF" "$CURF"; then
    exit 0
fi

if [ "$CHECK" -eq 1 ]; then
    echo "sync-progress : PROGRESS.md en retard sur les sujets : lancer sh scripts/sync-progress.sh"
    exit 1
fi

MIN_ECH=""
if [ -n "$ECHEANCES" ]; then
    # shellcheck disable=SC2086 # liste de dates séparées par des espaces, voulue
    MIN_ECH=$(printf '%s\n' $ECHEANCES | sort | head -n 1)
fi

OUTF="$TMPD/parent"
awk -v b="$MARK_BEGIN" -v e="$MARK_END" -v blk="$BLOCKF" -v today="$TODAY" -v ech="$MIN_ECH" '
    NR == 1 && $0 == "---" { fm = 1; print; next }
    fm == 1 && $0 == "---" { fm = 2; print; next }
    fm == 1 && index($0, "derniere_maj:") == 1 { print "derniere_maj: " today; next }
    fm == 1 && index($0, "prochaine_echeance:") == 1 {
        if (ech == "") print "prochaine_echeance:"; else print "prochaine_echeance: " ech
        next
    }
    index($0, b) == 1 {
        print
        while ((getline line < blk) > 0) print line
        close(blk)
        skip = 1; next
    }
    index($0, e) == 1 { skip = 0 }
    skip { next }
    { print }' "$PARENT" > "$OUTF" || { echo "sync-progress : écriture impossible" >&2; exit 1; }

# Écriture atomique : le parent est remplacé d'un coup, jamais tronqué.
cp "$OUTF" "$PARENT.sync.$$" && mv "$PARENT.sync.$$" "$PARENT"
exit 0
