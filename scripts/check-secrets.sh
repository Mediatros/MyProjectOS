#!/bin/sh
# check-secrets.sh — détection locale de secrets (A2, plan Pro Workflow, DEC-0045).
# Usage : check-secrets.sh [chemin-projet]   (défaut : dossier courant)
# Deux niveaux :
#   BLOQUE  : formes certaines — clés privées PEM, tokens à préfixe connu
#             (GitHub, OpenAI, Anthropic, AWS, Slack, Google, Stripe).
#   AVERTIT : affectations suspectes (password=, api_key=...) et fichiers à
#             risque (.env, .pem, .key suivis par git).
# Ne jamais afficher la valeur : type de secret, fichier, ligne masquée.
# Exclusions : .myprojectos/secrets-allow (un chemin par ligne, relatif au projet).
# POSIX sh.

set -u

TARGET=${1:-.}
cd "$TARGET" || exit 1

BLOCKS=0
WARNS=0

allow_file=".myprojectos/secrets-allow"
is_allowed() {
    [ -f "$allow_file" ] && grep -qxF "$1" "$allow_file"
}

# Fichiers à examiner : tout sauf zones d'exclusion standard.
FILES=$(git ls-files --cached --others --exclude-standard 2>/dev/null || find . -type f -not -path './.git/*' -not -path './99_archive/*' -not -path './node_modules/*' | sed 's|^\./||')

for f in $FILES; do
    # Binaires ignorés.
    case "$f" in
        *.png|*.jpg|*.jpeg|*.gif|*.zip|*.pdf|*.docx|*.xlsx|*.pptx|*.ico|*.woff*|*.mp4|*.mp3) continue ;;
    esac
    [ -f "$f" ] || continue

    is_allowed "$f" && continue

    # --- Niveau bloquant : formes certaines -----------------------------------
    _hits=$(grep -nE \
        -e '-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----' \
        -e 'ghp_[A-Za-z0-9]{36}' \
        -e 'gho_[A-Za-z0-9]{36}' \
        -e 'ghs_[A-Za-z0-9]{36}' \
        -e 'sk-(proj-)?[A-Za-z0-9_-]{20,}' \
        -e 'AKIA[0-9A-Z]{16}' \
        -e 'xox[baprs]-[A-Za-z0-9-]{10,}' \
        -e 'AIza[0-9A-Za-z_-]{35}' \
        -e '(sk|rk)_live_[0-9a-zA-Z]{16,}' \
        "$f" 2>/dev/null)
    if [ -n "$_hits" ]; then
        printf '%s\n' "$_hits" | while IFS=: read -r ln rest; do
            echo "  [X]    $f:$ln — secret certain détecté (jamais committé ; révocation nécessaire si déjà poussé)"
        done
        BLOCKS=$((BLOCKS + 1))
        continue
    fi

    # --- Niveau avertissement : suspect mais incertain -------------------------
    _sus=$(grep -nEi \
        -e '(password|passwd|secret|api[_-]?key|token)[[:space:]]*[=:][[:space:]]*[\"'"'"']?[A-Za-z0-9+/_-]{8,}' \
        "$f" 2>/dev/null | head -n 3)
    if [ -n "$_sus" ]; then
        printf '%s\n' "$_sus" | while IFS=: read -r ln rest; do
            echo "  [!]    $f:$ln — affectation sensible suspecte (à vérifier)"
        done
        WARNS=$((WARNS + 1))
    fi

    # --- Niveau avertissement : fichiers à risque suivis ------------------------
    case "$f" in
        .env|.env.*|*.env|*.pem|*.key)
            echo "  [!]    $f — fichier à risque suivi par git (préferer le hors-git + gestionnaire de secrets)"
            WARNS=$((WARNS + 1))
            ;;
    esac
done

echo ""
if [ "$BLOCKS" -gt 0 ]; then
    echo "Bilan : $BLOCKS secret(s) certain(s) — NE COMMITTEZ PAS. Corriger puis relancer."
    exit 1
fi
if [ "$WARNS" -gt 0 ]; then
    echo "Bilan : aucun secret certain, $WARNS point(s) à vérifier."
    exit 0
fi
echo "Bilan : aucun secret détecté."
exit 0
