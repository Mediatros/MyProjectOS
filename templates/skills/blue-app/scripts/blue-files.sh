#!/bin/sh
# Fichiers Blue : upload et download via le flux presigné REST (vérifié le 2026-07-12).
# Les mutations GraphQL uploadFile/uploadFiles exigent un multipart (scalar Upload)
# inutilisable via blue-gql.sh : la voie fiable est GET /uploads → PUT presigné → createFile.
# Usage : blue-files.sh upload   <fichier> -w <ws_id> [-o <org>] [-n <nom distant>]
#         blue-files.sh download <uid>     -w <ws_id> [-o <org>] [-O <fichier de sortie>]
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/blue-secrets.sh"

api="https://api.blue.app"

usage() {
    echo "Usage : blue-files.sh upload <fichier> -w <ws_id> [-o <org>] [-n <nom distant>]" >&2
    echo "        blue-files.sh download <uid> -w <ws_id> [-o <org>] [-O <fichier de sortie>]" >&2
    exit 1
}

[ $# -ge 2 ] || usage
mode="$1"
target="$2"
shift 2

workspace_id=""
org_id="${BLUE_ORG:-}"
remote_name=""
out_file=""

while [ $# -gt 0 ]; do
    case "$1" in
        -w) workspace_id="$2"; shift 2 ;;
        -o) org_id="$2"; shift 2 ;;
        -n) remote_name="$2"; shift 2 ;;
        -O) out_file="$2"; shift 2 ;;
        *) usage ;;
    esac
done

if [ -z "$org_id" ]; then
    echo "blue-files: organisation manquante (utiliser -o <org> ou poser BLUE_ORG)." >&2
    exit 1
fi
if [ -z "$workspace_id" ]; then
    echo "blue-files: workspace manquant (-w <ws_id>)." >&2
    exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
    echo "blue-files: la commande 'jq' est requise mais introuvable." >&2
    exit 1
fi

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

case "$mode" in
upload)
    if [ ! -f "$target" ]; then
        echo "blue-files: fichier introuvable : $target" >&2
        exit 1
    fi
    name="${remote_name:-$(basename -- "$target")}"
    size=$(wc -c < "$target" | tr -d ' ')

    # 1. Credentials presignés (X-Key = futur uid du fichier).
    encoded=$(jq -rn --arg s "$name" '$s|@uri')
    code=$(curl -sS --max-time 30 -o "$tmp" -w '%{http_code}' \
        -H "blue-token-id: $BLUE_TOKEN_ID" \
        -H "blue-token-secret: $BLUE_TOKEN_SECRET" \
        -H "blue-org-id: $org_id" \
        -H "blue-workspace-id: $workspace_id" \
        "$api/uploads?filename=$encoded")
    if [ "$code" != "200" ]; then
        echo "blue-files: GET /uploads a échoué (HTTP $code)." >&2
        exit 1
    fi
    put_url=$(jq -r '.url // empty' "$tmp")
    mime=$(jq -r '.headers["Content-Type"] // .fields["Content-Type"] // "application/octet-stream"' "$tmp")
    uid=$(jq -r '.fields["X-Key"] // empty' "$tmp")
    if [ -z "$put_url" ] || [ -z "$uid" ]; then
        echo "blue-files: réponse /uploads sans url ou X-Key." >&2
        exit 1
    fi

    # 2. PUT du binaire (URL presignée temporaire, aucun credential Blue dedans).
    put_code=$(curl -sS --max-time 300 -o /dev/null -w '%{http_code}' \
        -X PUT -H "Content-Type: $mime" --data-binary @"$target" "$put_url")
    if [ "$put_code" != "200" ]; then
        echo "blue-files: PUT presigné a échoué (HTTP $put_code)." >&2
        exit 1
    fi

    # 3. Enregistrement côté Blue. companyId = ID d'organisation, pas le slug
    #    (le slug est refusé par createFile) ; surchargeable par BLUE_COMPANY_ID.
    company_id="${BLUE_COMPANY_ID:-}"
    if [ -z "$company_id" ]; then
        company_id=$("$script_dir/blue-gql.sh" -o "$org_id" \
            'query { organizations { items { id slug } } }' \
            | jq -r --arg slug "$org_id" \
                '.organizations.items[] | select(.slug == $slug or .id == $slug) | .id' \
            | head -n 1)
    fi
    if [ -z "$company_id" ]; then
        echo "blue-files: impossible de résoudre l'ID d'organisation pour « $org_id »." >&2
        exit 1
    fi

    ext="${name##*.}"
    if [ "$ext" = "$name" ]; then
        ext=""
    fi
    vars=$(jq -n --arg uid "$uid" --arg name "$name" --argjson size "$size" \
        --arg type "$mime" --arg ext "$ext" --arg pid "$workspace_id" --arg cid "$company_id" \
        '{input: {uid: $uid, name: $name, size: $size, type: $type, extension: $ext, projectId: $pid, companyId: $cid}}')
    "$script_dir/blue-gql.sh" -w "$workspace_id" -o "$org_id" -v "$vars" \
        'mutation CreateFile($input: CreateFileInput!) { createFile(input: $input) { id uid name size status } }'
    ;;
download)
    dest="${out_file:-$target}"
    # GET /uploads/<uid> répond 302 vers une URL presignée de lecture ; on la suit
    # en deux temps pour ne pas rejouer les headers d'auth vers l'hôte de stockage.
    redirect=$(curl -sS --max-time 30 -o /dev/null -w '%{redirect_url}' \
        -H "blue-token-id: $BLUE_TOKEN_ID" \
        -H "blue-token-secret: $BLUE_TOKEN_SECRET" \
        -H "blue-org-id: $org_id" \
        -H "blue-workspace-id: $workspace_id" \
        "$api/uploads/$target")
    if [ -z "$redirect" ]; then
        echo "blue-files: pas de redirection presignée pour l'uid « $target » (fichier inconnu ?)." >&2
        exit 1
    fi
    get_code=$(curl -sS --max-time 300 -o "$dest" -w '%{http_code}' "$redirect")
    if [ "$get_code" != "200" ]; then
        rm -f "$dest"
        echo "blue-files: téléchargement presigné a échoué (HTTP $get_code)." >&2
        exit 1
    fi
    echo "OK — $dest ($(wc -c < "$dest" | tr -d ' ') octets)"
    ;;
*)
    usage
    ;;
esac
