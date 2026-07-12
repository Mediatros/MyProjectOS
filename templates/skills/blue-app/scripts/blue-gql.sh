#!/bin/sh
# Client GraphQL Blue (https://api.blue.app/graphql).
# Usage : blue-gql.sh [-w <workspace_id>] [-o <org>] [-v '<json variables>']
#                      [-f <fichier.graphql>] [--check] [<query>]
# Sans -f ni query en argument, la query est lue sur stdin.
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/blue-secrets.sh"

endpoint="https://api.blue.app/graphql"

workspace_id=""
org_id="${BLUE_ORG:-}"
variables_json=""
query_file=""
check_mode=0
query_arg=""

while [ $# -gt 0 ]; do
    case "$1" in
        -w)
            workspace_id="$2"
            shift 2
            ;;
        -o)
            org_id="$2"
            shift 2
            ;;
        -v)
            variables_json="$2"
            shift 2
            ;;
        -f)
            query_file="$2"
            shift 2
            ;;
        --check)
            check_mode=1
            shift
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "blue-gql: option inconnue : $1" >&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

if [ $# -gt 0 ]; then
    query_arg="$1"
fi

if [ -z "$org_id" ]; then
    echo "blue-gql: organisation manquante (utiliser -o <org> ou poser BLUE_ORG)." >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "blue-gql: la commande 'jq' est requise mais introuvable." >&2
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "blue-gql: la commande 'curl' est requise mais introuvable." >&2
    exit 1
fi

if [ "$check_mode" -eq 1 ]; then
    query="{ workspaceList(filter: { companyIds: [\"$org_id\"] }) { items { id name } } }"
    variables_json=""
elif [ -n "$query_file" ]; then
    query=$(cat "$query_file")
elif [ -n "$query_arg" ]; then
    query="$query_arg"
else
    query=$(cat)
fi

if [ -n "$variables_json" ]; then
    body=$(jq -n --arg q "$query" --argjson vars "$variables_json" '{query: $q, variables: $vars}') || {
        echo "blue-gql: variables JSON invalides (-v)." >&2
        exit 1
    }
else
    body=$(jq -n --arg q "$query" '{query: $q}')
fi

set -- -sS --max-time 30 \
    -H "Content-Type: application/json" \
    -H "blue-token-id: $BLUE_TOKEN_ID" \
    -H "blue-token-secret: $BLUE_TOKEN_SECRET" \
    -H "blue-org-id: $org_id"

if [ -n "$workspace_id" ]; then
    set -- "$@" -H "blue-workspace-id: $workspace_id"
fi

response=$(curl "$@" -X POST -d "$body" "$endpoint") || {
    echo "blue-gql: échec de la requête HTTP vers $endpoint." >&2
    exit 1
}

errors_count=$(printf '%s' "$response" | jq '(.errors // []) | length' 2>/dev/null) || {
    echo "blue-gql: réponse invalide (JSON non parsable)." >&2
    exit 1
}

if [ "$errors_count" -gt 0 ]; then
    printf '%s' "$response" | jq -r '.errors[].message' >&2
    exit 1
fi

if [ "$check_mode" -eq 1 ]; then
    count=$(printf '%s' "$response" | jq '.data.workspaceList.items | length')
    echo "OK — $count workspace(s)"
    exit 0
fi

printf '%s' "$response" | jq '.data'
