#!/bin/sh
# Wrapper de la CLI blue : résout les secrets, régénère ~/.config/blue/config.env
# le temps de l'exécution, puis le supprime (trap EXIT).
# Usage : blue-cli.sh <args blue...>
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/blue-secrets.sh"

: "${BLUE_ORG:?blue-cli: BLUE_ORG doit être posée (organisation Blue cible).}"

config_dir="$HOME/.config/blue"
config_file="$config_dir/config.env"
mkdir -p "$config_dir"
trap 'rm -f "$config_file"' EXIT

cat > "$config_file" <<EOF
CLIENT_ID=$BLUE_TOKEN_ID
AUTH_TOKEN=$BLUE_TOKEN_SECRET
COMPANY_ID=$BLUE_ORG
EOF
chmod 600 "$config_file"

blue "$@"
