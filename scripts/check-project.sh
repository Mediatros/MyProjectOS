#!/bin/sh
# check-project.sh — vérifie la cohérence d'un projet MyProjectOS.
# Usage : check-project.sh [chemin-projet]   (défaut : dossier courant)
# Signale sans bloquer : fichiers sacrés manquants, extensions incomplètes,
# PROGRESS périmé, placeholders non substitués, références DEC-/CHG- cassées.
# POSIX sh. Aucune dépendance obligatoire (git facultatif).
# Code de sortie : 0 si aucun problème, 1 si au moins un FAIL, 0 si seulement des WARN.

set -u

TARGET=${1:-.}
STALE_DAYS=14
REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

FAILS=0
WARNS=0

ok()   { printf '  [ok]   %s\n' "$1"; }
warn() { printf '  [!]    %s\n' "$1"; WARNS=$((WARNS + 1)); }
fail() { printf '  [X]    %s\n' "$1"; FAILS=$((FAILS + 1)); }

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

if [ ! -d "$TARGET" ]; then
    echo "Dossier introuvable : $TARGET" >&2
    exit 1
fi

if [ ! -f "$TARGET/PROJECT.md" ]; then
    echo "Pas de PROJECT.md dans '$TARGET' : ce n'est pas un projet MyProjectOS." >&2
    exit 1
fi

# Type du projet, lu dans le frontmatter de PROJECT.md.
TYPE=$(sed -n 's/^type:[[:space:]]*//p' "$TARGET/PROJECT.md" | head -n 1)
[ -n "$TYPE" ] || TYPE="(inconnu)"
echo "Projet : $(basename -- "$(cd "$TARGET" && pwd)")  —  type déclaré : $TYPE"

# --- 0. Alignement avec la version de la méthode -----------------------------
echo "Version de la méthode :"
CUR=$(head -n 1 "$REPO/VERSION" 2>/dev/null | tr -d '[:space:]')
PRJ=$(sed -n 's/^version_methode:[[:space:]]*//p' "$TARGET/PROJECT.md" | head -n 1 | tr -d '[:space:]')
if [ -z "$CUR" ]; then
    warn "version courante introuvable ($REPO/VERSION absent)"
elif [ -z "$PRJ" ] || [ "$PRJ" = "<VERSION>" ]; then
    warn "projet sans empreinte de version (créé avant le versionnement) ; version courante v$CUR"
else
    case "$(ver_cmp "$PRJ" "$CUR")" in
        eq) ok "suit MyProjectOS v$PRJ (version courante)" ;;
        lt) warn "suit MyProjectOS v$PRJ, version courante v$CUR : voir les changements dans le CHANGELOG de la méthode" ;;
        gt) warn "déclare v$PRJ, plus récent que la version installée v$CUR : mets à jour MyProjectOS" ;;
    esac
fi

# --- 1. Fichiers sacrés Core -------------------------------------------------
echo "Fichiers sacrés Core :"
for f in PROJECT PROGRESS CHANGELOG TASKS DECISIONS; do
    if [ -f "$TARGET/$f.md" ]; then ok "$f.md"; else fail "$f.md manquant"; fi
done

# --- 2. Extensions selon le type ---------------------------------------------
case "$TYPE" in
    *Life*|*Hybrid*)
        echo "Extension Life :"
        for f in PREUVES ECHEANCES CORRESPONDANCES; do
            if [ -f "$TARGET/$f.md" ]; then ok "$f.md"; else fail "$f.md manquant (type $TYPE)"; fi
        done
        ;;
esac
case "$TYPE" in
    *Code*|*Hybrid*)
        echo "Extension Code :"
        for f in AGENTS CONSTITUTION STACK_VALIDATION ARCHITECTURE SPECS TEST_PLAN IMPACT_ANALYSIS RELEASE; do
            if [ -f "$TARGET/$f.md" ]; then ok "$f.md"; else fail "$f.md manquant (type $TYPE)"; fi
        done
        ;;
esac
if [ -f "$TARGET/docs/INDEX.md" ]; then
    echo "Extension Knowledge :"
    for f in docs/INDEX.md docs/kb_governance.md; do
        if [ -f "$TARGET/$f" ]; then ok "$f"; else warn "$f manquant alors que Knowledge semble actif"; fi
    done
fi

# --- 3. Fraîcheur de PROGRESS.md ---------------------------------------------
echo "Fraîcheur :"
if [ -f "$TARGET/PROGRESS.md" ]; then
    MAJ=$(sed -n 's/^derniere_maj:[[:space:]]*//p' "$TARGET/PROGRESS.md" | head -n 1)
    if [ -z "$MAJ" ] || [ "$MAJ" = "YYYY-MM-DD" ]; then
        warn "PROGRESS.md : champ derniere_maj absent ou non renseigné"
    else
        TS=""
        if date -j -f "%Y-%m-%d" "$MAJ" +%s >/dev/null 2>&1; then
            TS=$(date -j -f "%Y-%m-%d" "$MAJ" +%s)        # BSD / macOS
        elif date -d "$MAJ" +%s >/dev/null 2>&1; then
            TS=$(date -d "$MAJ" +%s)                       # GNU / Linux
        fi
        if [ -z "$TS" ]; then
            warn "PROGRESS.md : derniere_maj='$MAJ' illisible (format attendu YYYY-MM-DD)"
        else
            AGE=$(( ( $(date +%s) - TS ) / 86400 ))
            if [ "$AGE" -lt 0 ]; then
                warn "PROGRESS.md : derniere_maj='$MAJ' est dans le futur"
            elif [ "$AGE" -gt "$STALE_DAYS" ]; then
                warn "PROGRESS.md non mis à jour depuis $AGE jours (seuil $STALE_DAYS)"
            else
                ok "PROGRESS.md à jour ($AGE j)"
            fi
        fi
    fi
fi

# --- 4. Placeholders résiduels -----------------------------------------------
echo "Substitution des gabarits :"
PH=$(grep -rl "<NomDuProjet>" "$TARGET" --include="*.md" 2>/dev/null)
if [ -n "$PH" ]; then
    printf '%s\n' "$PH" | while IFS= read -r p; do warn "placeholder <NomDuProjet> dans ${p#"$TARGET"/}"; done
    WARNS=$((WARNS + 1))
else
    ok "aucun <NomDuProjet> résiduel"
fi

# --- 5. Références croisées DEC- / CHG- --------------------------------------
echo "Références croisées :"
check_refs() {
    # check_refs <regex-id> <fichier-registre> <motif-définition>
    _re=$1; _reg=$2; _defprefix=$3
    [ -f "$TARGET/$_reg" ] || { warn "$_reg absent : références non vérifiables"; return; }
    _defined=$(grep -hoE "$_re" "$TARGET/$_reg" 2>/dev/null | sort -u)
    _cited=$(grep -rhoE "$_re" "$TARGET" --include="*.md" 2>/dev/null | sort -u)
    _missing=0
    for id in $_cited; do
        if ! printf '%s\n' "$_defined" | grep -qx "$id"; then
            warn "$id cité mais non défini dans $_reg"
            _missing=1
        fi
    done
    [ "$_missing" -eq 0 ] && ok "toutes les références $_defprefix pointent vers une entrée existante"
}
check_refs 'DEC-[0-9]{4}' DECISIONS.md DEC-
check_refs 'CHG-[0-9]{8}-[0-9]{4}' CHANGELOG.md CHG-

# --- Bilan -------------------------------------------------------------------
echo ""
if [ "$FAILS" -eq 0 ] && [ "$WARNS" -eq 0 ]; then
    echo "Bilan : cohérent, aucun problème détecté."
    exit 0
fi
echo "Bilan : $FAILS bloquant(s), $WARNS avertissement(s)."
[ "$FAILS" -gt 0 ] && exit 1
exit 0
