#!/bin/sh
# Wrapper de la CLI blue : résout les secrets, régénère ~/.config/blue/config.env
# le temps de l'exécution, puis le supprime (trap EXIT).
# Usage : blue-cli.sh <args blue...>
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/blue-secrets.sh"

: "${BLUE_ORG:?blue-cli: BLUE_ORG doit être posée (organisation Blue cible).}"

# Mitigation issue MyProjectOS#2 : la CLI blue REMPLACE la liste de tags du
# record sur `tags add` au lieu de la compléter. On fusionne donc les tags
# existants avec ceux demandés avant de transmettre l'appel. En cas d'échec de
# lecture des tags existants, on annule plutôt que de laisser l'appel les écraser.
if [ "${1:-}" = "tags" ] && [ "${2:-}" = "add" ]; then
    record_id="" ws_id="" tag_ids="" prev=""
    for arg in "$@"; do
        case "$prev" in
            -r|--record) record_id="$arg" ;;
            -w|--workspace) ws_id="$arg" ;;
            --tag-ids) tag_ids="$arg" ;;
        esac
        prev="$arg"
    done
    if [ -n "$record_id" ] && [ -n "$tag_ids" ]; then
        record_json=$("$script_dir/blue-gql.sh" -o "$BLUE_ORG" ${ws_id:+-w "$ws_id"} \
            -v "{\"id\":\"$record_id\"}" \
            'query($id: String!) { record(id: $id) { tags { id } } }') || {
            echo "blue-cli: lecture des tags existants du record $record_id impossible, appel annulé (ils auraient été remplacés — issue MyProjectOS#2)." >&2
            exit 1
        }
        existing=$(printf '%s' "$record_json" | jq -er \
            'if .record == null then error("record introuvable") else [.record.tags[].id] | join(",") end') || {
            echo "blue-cli: record $record_id introuvable, appel annulé." >&2
            exit 1
        }
        merged=$(printf '%s,%s' "$existing" "$tag_ids" | tr ',' '\n' | awk 'NF && !seen[$0]++' | paste -sd, -)
        n=$#
        i=0
        was_tag_ids=0
        while [ "$i" -lt "$n" ]; do
            arg="$1"
            shift
            if [ "$was_tag_ids" -eq 1 ]; then
                set -- "$@" "$merged"
                was_tag_ids=0
            elif [ "$arg" = "--tag-ids" ]; then
                set -- "$@" "$arg"
                was_tag_ids=1
            else
                set -- "$@" "$arg"
            fi
            i=$((i+1))
        done
    fi
fi

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
