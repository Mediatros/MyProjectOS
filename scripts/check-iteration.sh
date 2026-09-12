#!/bin/sh
# check-iteration.sh — clôture déterministe d'une itération (A4, plan Pro Workflow, DEC-0046).
# Usage : sh scripts/check-iteration.sh [chemin-projet]   (défaut : dossier courant)
# Lancé explicitement par l'agent en fin d'itération Code/Hybrid. Jamais branché
# au hook Stop sans RETEX démontrant que ce n'est pas trop bruyant.
# Tout est informatif sauf deux cas bloquants (arbitrage humain, DEC-0046) :
#   - fichiers modifiés non consignés dans PROGRESS.md ;
#   - PROGRESS.md périmé (> 14 jours).
# Sortie lisible par un non-développeur. Code 1 seulement si bloquant.
# POSIX sh.

set -u

TARGET=${1:-.}
STALE_DAYS=14
cd "$TARGET" || exit 1

FAILS=0
ok()   { printf '  [ok]   %s\n' "$1"; }
warn() { printf '  [!]    %s\n' "$1"; }
fail() { printf '  [X]    %s\n' "$1"; FAILS=$((FAILS + 1)); }

echo "Clôture d'itération :"

# --- 1. État Git ---------------------------------------------------------------
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    _dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$_dirty" -gt 0 ]; then
        warn "$_dirty fichier(s) modifié(s) non commités — committer ou stasher avant de clore"
    else
        ok "dépôt propre, aucun changement non commité"
    fi

    # --- 2. Fichiers modifiés consignés dans PROGRESS.md (bloquant) ------------
    # Le chemin commence à la 4e colonne du format porcelain (2 caractères d'état
    # + une espace) : le découper ainsi plutôt que par le dernier champ, sinon un
    # chemin contenant une espace est tronqué à son dernier mot.
    _modified=$(git status --porcelain 2>/dev/null | cut -c4- | grep -v '^\.claude' || true)
    if [ -n "$_modified" ] && [ -f PROGRESS.md ]; then
        _unconsigned=0
        # Lecture ligne par ligne (et non mot par mot) pour la même raison.
        # Here-document et non pipe : le compteur doit vivre dans le shell courant.
        while IFS= read -r f; do
            [ -n "$f" ] || continue
            # Un renommage s'écrit « ancien -> nouveau » : c'est le nouveau qui compte.
            case "$f" in *" -> "*) f=${f##* -> } ;; esac
            # git entoure de guillemets un chemin contenant une espace ou un
            # caractère non ASCII : les retirer, sinon le nom cherché dans
            # PROGRESS.md porte un guillemet et ne correspond jamais.
            case "$f" in \"*\") f=${f#\"}; f=${f%\"} ;; esac
            grep -qF "$(basename -- "$f")" PROGRESS.md || { fail "$(basename -- "$f") modifié mais absent de PROGRESS.md — mets l'état à jour"; _unconsigned=1; }
        done <<EOF_MOD
$_modified
EOF_MOD
        [ "$_unconsigned" -eq 0 ] && ok "changements reflétés dans PROGRESS.md"
    fi
else
    echo "  [i]    hors dépôt git : contrôle d'état git ignoré"
fi

# --- 3. Fraîcheur de PROGRESS.md (bloquant) -------------------------------------
if [ -f PROGRESS.md ]; then
    _maj=$(sed -n 's/^derniere_maj:[[:space:]]*//p' PROGRESS.md | head -n 1 | tr -d '[:space:]')
    case "$_maj" in
        [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])
            _today=$(date +%Y-%m-%d)
            _age=$(( ( $(date -u -d "$_today" +%s 2>/dev/null || date -j -f %Y-%m-%d "$_today" +%s 2>/dev/null || echo 0) - $(date -u -d "$_maj" +%s 2>/dev/null || date -j -f %Y-%m-%d "$_maj" +%s 2>/dev/null || echo 0) ) / 86400 ))
            if [ "$_age" -gt "$STALE_DAYS" ]; then
                fail "PROGRESS.md n'est pas à jour depuis $_age jours — mets-le à jour avant de clore"
            else
                ok "PROGRESS.md à jour ($_maj)"
            fi
            ;;
        *)
            fail "PROGRESS.md : champ derniere_maj absent ou illisible"
            ;;
    esac

    # --- 4. Prochaine action déclarée ------------------------------------------
    _next=$(sed -n 's/^prochaine_action:[[:space:]]*//p' PROGRESS.md | head -n 1)
    if [ -n "$_next" ]; then
        ok "prochaine action déclarée : $(printf '%s' "$_next" | cut -c1-60)…"
    else
        warn "aucune prochaine action dans PROGRESS.md — la reprise à froid sera plus difficile"
    fi
else
    echo "  [i]    pas de PROGRESS.md : hors périmètre MyProjectOS, rien à vérifier"
    exit 0
fi

# --- 5. Tests déclarés (TEST_PLAN.md si présent) ---------------------------------
if [ -f TEST_PLAN.md ]; then
    _cmds=$(grep -E '^\s*(-|[0-9]+[.)])\s*(`|sh |python|make|npm|pytest|cargo)' TEST_PLAN.md | head -n 5)
    if [ -n "$_cmds" ]; then
        echo ""
        echo "Commandes de validation déclarées dans TEST_PLAN.md (à exécuter avant de clore) :"
        printf '%s\n' "$_cmds" | sed 's/^/    /'
        warn "exécution des tests non prouvée par ce script — lance-les et consigne le résultat"
    else
        ok "TEST_PLAN.md présent, aucune commande explicite à relire"
    fi
fi

echo ""
if [ "$FAILS" -gt 0 ]; then
    echo "Bilan : itération PAS PRÊTE à être close ($FAILS bloquant(s)). Corrige puis relance."
    exit 1
fi
echo "Bilan : itération close proprement, état prêt pour une reprise à froid."
exit 0
