#!/bin/sh
# Ajout (ou remplacement) d'un secret dans la boîte chiffrée SOPS + age, en deux questions.
# Conçu pour un utilisateur non technique : aucune option à retenir.
#   sh scripts/ajout-secret.sh [chemin-boite]
# Boîte par défaut : $SECRETS_BOX, sinon ~/.config/secrets/secrets.env (celle du backend `sops` de secrets.sh).
# La valeur est saisie masquée : rien à l'écran, rien dans l'historique du shell, jamais de fichier en clair.
# Au premier usage, propose de générer la clé age et crée la boîte.
# Limite connue : `sops set` reçoit la valeur en argument, brièvement visible dans `ps` (machine mono-utilisateur : acceptable).
set -eu

box="${1:-${SECRETS_BOX:-$HOME/.config/secrets/secrets.env}}"
keyfile="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

if ! command -v sops >/dev/null 2>&1; then
    echo "ajout-secret: la commande 'sops' est introuvable (brew install sops / apt install sops)." >&2
    exit 1
fi

case "$box" in
    *.env) ;;
    *)
        echo "ajout-secret: la boîte doit se terminer par .env (format dotenv attendu par sops) : $box" >&2
        exit 1
        ;;
esac

# Premier usage : clé age puis boîte, créées à la demande.
if [ ! -f "$box" ]; then
    if [ ! -f "$keyfile" ]; then
        if ! command -v age-keygen >/dev/null 2>&1; then
            echo "ajout-secret: pas de clé age ($keyfile) et 'age-keygen' introuvable (brew install age / apt install age)." >&2
            exit 1
        fi
        printf 'Aucune clé age (%s). La générer maintenant ? [o/N] ' "$keyfile"
        IFS= read -r rep
        case "$rep" in
            o|O|oui) ;;
            *) echo "ajout-secret: abandon (pas de clé)." >&2; exit 1 ;;
        esac
        mkdir -p "$(dirname "$keyfile")"
        age-keygen -o "$keyfile"
        chmod 600 "$keyfile"
        echo "Clé créée : $keyfile (à sauvegarder en lieu sûr : c'est le seul secret racine)."
    fi
    recipient=$(age-keygen -y "$keyfile")
    printf 'Boîte inexistante (%s). La créer ? [o/N] ' "$box"
    IFS= read -r rep
    case "$rep" in
        o|O|oui) ;;
        *) echo "ajout-secret: abandon (pas de boîte)." >&2; exit 1 ;;
    esac
    mkdir -p "$(dirname "$box")"
    printf 'SOPS_BOX_INIT=1\n' | sops -e --input-type dotenv --output-type dotenv --age "$recipient" /dev/stdin > "$box"
    echo "Boîte créée : $box"
fi

# Question 1 : le nom (normalisé, validé, re-demandé tant qu'invalide).
name=""
while [ -z "$name" ]; do
    printf 'Nom du secret (ex. BLUE_TOKEN_ID) : '
    IFS= read -r saisie
    propre=$(printf '%s' "$saisie" | tr 'a-z-' 'A-Z_' | tr -d ' ')
    case "$propre" in
        [A-Z]*) if [ -z "$(printf '%s' "$propre" | tr -d 'A-Z0-9_')" ]; then name="$propre"; fi ;;
    esac
    if [ -z "$name" ]; then
        echo "Nom invalide : majuscules, chiffres et _ uniquement, commence par une lettre."
    elif [ "$name" != "$saisie" ]; then
        printf 'Nom normalisé en %s. OK ? [O/n] ' "$name"
        IFS= read -r rep
        case "$rep" in n|N|non) name="" ;; esac
    fi
done

# Secret déjà présent ? On demande avant de remplacer.
if sops -d "$box" | grep -q "^${name}="; then
    printf '%s existe déjà. Remplacer sa valeur ? [o/N] ' "$name"
    IFS= read -r rep
    case "$rep" in
        o|O|oui) ;;
        *) echo "ajout-secret: rien n'a été modifié." ; exit 0 ;;
    esac
fi

# Question 2 : la valeur, saisie masquée (restauration de l'écho garantie en sortie).
# Hors terminal (stdin non-tty), stty est sans effet : l'appelant assume l'écho.
trap 'stty echo 2>/dev/null || true' EXIT INT TERM
printf 'Valeur (saisie invisible, collez puis Entrée) : '
stty -echo 2>/dev/null || true
IFS= read -r value
stty echo 2>/dev/null || true
echo
if [ -z "$value" ]; then
    echo "ajout-secret: valeur vide, rien n'a été modifié." >&2
    exit 1
fi

# Échappement JSON minimal pour `sops set` (valeur mono-ligne).
esc=$(printf '%s' "$value" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')
sops set "$box" "[\"$name\"]" "\"$esc\""
value=""
esc=""

total=$(sops -d "$box" | grep -v '^SOPS_BOX_INIT=' | grep -c '^[A-Z].*=' || true)
echo "Secret $name enregistré. $total entrée(s) dans la boîte."
