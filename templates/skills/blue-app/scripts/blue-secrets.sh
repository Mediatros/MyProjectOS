#!/bin/sh
# Résolution des secrets Blue (BLUE_TOKEN_ID / BLUE_TOKEN_SECRET) multi-backend.
# À sourcer : . blue-secrets.sh
# Ordre de résolution : variables déjà posées > BLUE_SECRET_BACKEND (keychain|bws|file).
# Ne jamais afficher une valeur de secret.
set -eu

if [ "${BLUE_TOKEN_ID:-}" != "" ] && [ "${BLUE_TOKEN_SECRET:-}" != "" ]; then
    : # déjà posées dans l'environnement, rien à faire
else
    backend="${BLUE_SECRET_BACKEND:-}"
    if [ -z "$backend" ]; then
        if command -v security >/dev/null 2>&1; then
            backend="keychain"
        else
            backend="file"
        fi
    fi

    case "$backend" in
        keychain)
            if ! command -v security >/dev/null 2>&1; then
                echo "blue-secrets: backend keychain demandé mais la commande 'security' est introuvable." >&2
                exit 1
            fi
            BLUE_TOKEN_ID=$(security find-generic-password -a "client_id" -s "blue-cli" -w 2>/dev/null) || {
                echo "blue-secrets: impossible de lire client_id dans le trousseau (service blue-cli)." >&2
                exit 1
            }
            BLUE_TOKEN_SECRET=$(security find-generic-password -a "auth_token" -s "blue-cli" -w 2>/dev/null) || {
                echo "blue-secrets: impossible de lire auth_token dans le trousseau (service blue-cli)." >&2
                exit 1
            }
            ;;
        bws)
            if ! command -v bws >/dev/null 2>&1; then
                echo "blue-secrets: backend bws demandé mais la commande 'bws' est introuvable." >&2
                exit 1
            fi
            if ! command -v jq >/dev/null 2>&1; then
                echo "blue-secrets: backend bws demandé mais la commande 'jq' est introuvable." >&2
                exit 1
            fi
            if [ -z "${BWS_ACCESS_TOKEN:-}" ]; then
                echo "blue-secrets: backend bws demandé mais BWS_ACCESS_TOKEN n'est pas posée." >&2
                exit 1
            fi
            if [ -z "${BLUE_BWS_TOKEN_ID_UUID:-}" ] || [ -z "${BLUE_BWS_TOKEN_SECRET_UUID:-}" ]; then
                echo "blue-secrets: BLUE_BWS_TOKEN_ID_UUID et BLUE_BWS_TOKEN_SECRET_UUID doivent être posées." >&2
                exit 1
            fi
            BLUE_TOKEN_ID=$(bws secret get "$BLUE_BWS_TOKEN_ID_UUID" | jq -r .value) || {
                echo "blue-secrets: échec de lecture du secret BLUE_TOKEN_ID via bws." >&2
                exit 1
            }
            BLUE_TOKEN_SECRET=$(bws secret get "$BLUE_BWS_TOKEN_SECRET_UUID" | jq -r .value) || {
                echo "blue-secrets: échec de lecture du secret BLUE_TOKEN_SECRET via bws." >&2
                exit 1
            }
            ;;
        file)
            secrets_file="${BLUE_SECRETS_FILE:-$HOME/.config/blue/secrets.env}"
            if [ ! -f "$secrets_file" ]; then
                echo "blue-secrets: fichier de secrets introuvable : $secrets_file" >&2
                exit 1
            fi
            perm=$(stat -c '%a' "$secrets_file" 2>/dev/null) || perm=$(stat -f '%Lp' "$secrets_file" 2>/dev/null) || perm=""
            if [ "$perm" != "600" ]; then
                echo "blue-secrets: permissions de $secrets_file incorrectes (attendu 600, obtenu ${perm:-inconnu}). Corriger avec : chmod 600 $secrets_file" >&2
                exit 1
            fi
            BLUE_TOKEN_ID=""
            BLUE_TOKEN_SECRET=""
            . "$secrets_file"
            if [ -z "$BLUE_TOKEN_ID" ] || [ -z "$BLUE_TOKEN_SECRET" ]; then
                echo "blue-secrets: $secrets_file ne définit pas BLUE_TOKEN_ID et BLUE_TOKEN_SECRET." >&2
                exit 1
            fi
            ;;
        *)
            echo "blue-secrets: backend inconnu : $backend (attendu keychain, bws ou file)." >&2
            exit 1
            ;;
    esac
fi

export BLUE_TOKEN_ID BLUE_TOKEN_SECRET
