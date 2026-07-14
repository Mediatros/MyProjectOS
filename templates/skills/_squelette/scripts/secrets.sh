#!/bin/sh
# Résolution générique de secrets multi-backend pour une skill MyProjectOS.
# À sourcer, jamais exécuter seul :
#   SECRETS_PREFIX="MONOUTIL" SECRETS_KEYS="TOKEN_ID TOKEN_SECRET" . secrets.sh
# Produit et exporte les variables <PREFIXE>_<CLE> (ex. MONOUTIL_TOKEN_ID).
# Ordre de résolution : variables déjà posées > <PREFIXE>_SECRET_BACKEND (keychain|sops|bws|infisical|file).
# Conventions par backend :
#   keychain  : trousseau macOS, service = <prefixe minuscule> (surchargable : <PREFIXE>_KEYCHAIN_SERVICE),
#               compte = <cle minuscule>
#   sops      : boîte à secrets chiffrée SOPS + age (recommandé sur VPS), format dotenv,
#               défaut ~/.config/secrets/secrets.env, surchargable : <PREFIXE>_SOPS_FILE ;
#               la clé age est lue par sops lui-même (SOPS_AGE_KEY_FILE, défaut ~/.config/sops/age/keys.txt) ;
#               le fichier déchiffré définit <PREFIXE>_<CLE>=valeur (valeurs brutes, sans guillemets)
#   bws       : Bitwarden Secrets Manager ; BWS_ACCESS_TOKEN + <PREFIXE>_BWS_<CLE>_UUID
#   infisical : CLI infisical authentifiée (login ou INFISICAL_TOKEN) ; nom du secret = <PREFIXE>_<CLE> ;
#               <PREFIXE>_INFISICAL_PROJECT_ID (optionnel si lié par 'infisical init'),
#               <PREFIXE>_INFISICAL_ENV (défaut : prod)
#   file      : fichier chmod 600 HORS du dossier projet, défaut ~/.config/<prefixe minuscule>/secrets.env,
#               surchargable : <PREFIXE>_SECRETS_FILE ; définit directement les variables <PREFIXE>_<CLE>
# Ne jamais afficher une valeur de secret.
set -eu

if [ -z "${SECRETS_PREFIX:-}" ] || [ -z "${SECRETS_KEYS:-}" ]; then
    echo "secrets.sh: SECRETS_PREFIX et SECRETS_KEYS doivent être posées avant de sourcer." >&2
    exit 1
fi

sp="$SECRETS_PREFIX"
sp_lc=$(printf '%s' "$sp" | tr 'A-Z' 'a-z')

secrets_missing=""
for k in $SECRETS_KEYS; do
    eval "v=\${${sp}_${k}:-}"
    if [ -z "$v" ]; then
        secrets_missing="$secrets_missing $k"
    fi
done

if [ -n "$secrets_missing" ]; then
    eval "backend=\${${sp}_SECRET_BACKEND:-}"
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
                echo "secrets.sh: backend keychain demandé mais la commande 'security' est introuvable." >&2
                exit 1
            fi
            eval "service=\${${sp}_KEYCHAIN_SERVICE:-$sp_lc}"
            for k in $secrets_missing; do
                k_lc=$(printf '%s' "$k" | tr 'A-Z' 'a-z')
                val=$(security find-generic-password -a "$k_lc" -s "$service" -w 2>/dev/null) || {
                    echo "secrets.sh: impossible de lire '$k_lc' dans le trousseau (service $service)." >&2
                    exit 1
                }
                eval "${sp}_${k}=\$val"
            done
            ;;
        sops)
            if ! command -v sops >/dev/null 2>&1; then
                echo "secrets.sh: backend sops demandé mais la commande 'sops' est introuvable." >&2
                exit 1
            fi
            eval "sops_file=\${${sp}_SOPS_FILE:-$HOME/.config/secrets/secrets.env}"
            if [ ! -f "$sops_file" ]; then
                echo "secrets.sh: boîte à secrets introuvable : $sops_file" >&2
                exit 1
            fi
            sops_plain=$(sops -d "$sops_file") || {
                echo "secrets.sh: échec de déchiffrement de $sops_file (clé age absente ou illisible ?)." >&2
                exit 1
            }
            for k in $secrets_missing; do
                val=$(printf '%s\n' "$sops_plain" | sed -n "s/^${sp}_${k}=//p" | head -n 1)
                if [ -z "$val" ]; then
                    sops_plain=""
                    echo "secrets.sh: $sops_file ne définit pas ${sp}_${k}." >&2
                    exit 1
                fi
                eval "${sp}_${k}=\$val"
            done
            sops_plain=""
            ;;
        bws)
            for c in bws jq; do
                if ! command -v "$c" >/dev/null 2>&1; then
                    echo "secrets.sh: backend bws demandé mais la commande '$c' est introuvable." >&2
                    exit 1
                fi
            done
            if [ -z "${BWS_ACCESS_TOKEN:-}" ]; then
                echo "secrets.sh: backend bws demandé mais BWS_ACCESS_TOKEN n'est pas posée." >&2
                exit 1
            fi
            for k in $secrets_missing; do
                eval "uuid=\${${sp}_BWS_${k}_UUID:-}"
                if [ -z "$uuid" ]; then
                    echo "secrets.sh: ${sp}_BWS_${k}_UUID doit être posée pour le backend bws." >&2
                    exit 1
                fi
                val=$(bws secret get "$uuid" | jq -r .value) || {
                    echo "secrets.sh: échec de lecture du secret ${sp}_${k} via bws." >&2
                    exit 1
                }
                eval "${sp}_${k}=\$val"
            done
            ;;
        infisical)
            if ! command -v infisical >/dev/null 2>&1; then
                echo "secrets.sh: backend infisical demandé mais la commande 'infisical' est introuvable." >&2
                exit 1
            fi
            eval "inf_project=\${${sp}_INFISICAL_PROJECT_ID:-}"
            eval "inf_env=\${${sp}_INFISICAL_ENV:-prod}"
            for k in $secrets_missing; do
                if [ -n "$inf_project" ]; then
                    val=$(infisical secrets get "${sp}_${k}" --plain --projectId "$inf_project" --env "$inf_env" 2>/dev/null)
                else
                    val=$(infisical secrets get "${sp}_${k}" --plain --env "$inf_env" 2>/dev/null)
                fi
                if [ -z "$val" ]; then
                    echo "secrets.sh: échec de lecture du secret ${sp}_${k} via infisical (env $inf_env)." >&2
                    exit 1
                fi
                eval "${sp}_${k}=\$val"
            done
            ;;
        file)
            eval "secrets_file=\${${sp}_SECRETS_FILE:-$HOME/.config/$sp_lc/secrets.env}"
            if [ ! -f "$secrets_file" ]; then
                echo "secrets.sh: fichier de secrets introuvable : $secrets_file" >&2
                exit 1
            fi
            perm=$(stat -c '%a' "$secrets_file" 2>/dev/null) || perm=$(stat -f '%Lp' "$secrets_file" 2>/dev/null) || perm=""
            if [ "$perm" != "600" ]; then
                echo "secrets.sh: permissions de $secrets_file incorrectes (attendu 600, obtenu ${perm:-inconnu}). Corriger avec : chmod 600 $secrets_file" >&2
                exit 1
            fi
            . "$secrets_file"
            for k in $secrets_missing; do
                eval "v=\${${sp}_${k}:-}"
                if [ -z "$v" ]; then
                    echo "secrets.sh: $secrets_file ne définit pas ${sp}_${k}." >&2
                    exit 1
                fi
            done
            ;;
        *)
            echo "secrets.sh: backend inconnu : $backend (attendu keychain, sops, bws, infisical ou file)." >&2
            exit 1
            ;;
    esac
fi

for k in $SECRETS_KEYS; do
    eval "export ${sp}_${k}"
done
