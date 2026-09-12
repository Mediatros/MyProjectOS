#!/bin/sh
# hook-pre-git.sh — PreToolUse (Bash) : garde-fou Git destructif (A1, plan Pro Workflow).
# Bloque les commandes Git irréversibles listées dans la matrice DEC-0044.
# Dérogation ponctuelle : validation humaine en session, puis réexécution avec
# MYPROJECTOS_GIT_OVERRIDE=1 ; l'agent consigne ensuite une entrée CHG- dans
# CHANGELOG.md. Sans python3 ni jq, le hook ne bloque rien (dégradation silencieuse).
# POSIX sh.

DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
. "$DIR/_lib.sh"

read_payload

PROJECT_DIR=$(project_dir)
is_project_os "$PROJECT_DIR" || exit 0

CMD=$(json_field "tool_input.command")
[ -n "$CMD" ] || exit 0

# Règle immuable (DEC-0049), sans dérogation : l'identité de contribution est
# celle du titulaire du dépôt. Un message de commit qui porte un trailer ou une
# mention d'agent est refusé. Limite connue : un message passé par -F <fichier>
# n'est pas inspecté.
case "$CMD" in
    *git*commit*)
        case "$CMD" in
            *[Cc]o-[Aa]uthored-[Bb]y*|*Claude-Session*|*noreply@anthropic.com*|*claude.ai/code/session*)
                deny "MyProjectOS : commit refusé, le message porte un trailer ou une mention d'agent (Co-Authored-By, Claude-Session). Règle immuable DEC-0049 : tout commit porte l'identité du titulaire du dépôt. Retire le trailer et relance ; aucune dérogation." ;;
        esac
        ;;
esac

# Dérogation explicite : l'humain a validé dans la session.
case "$MYPROJECTOS_GIT_OVERRIDE" in
    1)
        printf '%s' '{"systemMessage":"MyProjectOS : dérogation Git acceptée (MYPROJECTOS_GIT_OVERRIDE=1). Consigne-la dans CHANGELOG.md (entrée CHG-)."}'
        exit 0
        ;;
esac

# Analyse d'une commande (ou sous-commande dépliée) : la découpe en segments sur
# &&, ||, ; et |, puis évalue chaque segment. $1 = commande, $2 = profondeur de
# récursion (0 au premier appel). Les paramètres positionnels sont propres à
# chaque appel de fonction (POSIX) : la récursion via analyze_segment ne peut
# donc pas corrompre la boucle « for » ci-dessous.
analyze_command() {
    _ac_cmd=$1

    _ac_lines=$(printf '%s' "$_ac_cmd" | sed -E 's/(&&|\|\||;|\|)/\
/g')
    _ac_oldifs=$IFS
    IFS='
'
    set -f
    # shellcheck disable=SC2086
    set -- "$2" $_ac_lines
    set +f
    IFS=$_ac_oldifs

    # La profondeur voyage en tête des paramètres positionnels et non dans une
    # variable : un appel récursif ne peut donc pas la corrompre pour les
    # segments suivants du même niveau (sinon, au 4e segment enveloppé, le
    # dépliage « sh -c » cessait et la commande passait).
    while [ $# -gt 1 ]; do
        _ac_depth=$1
        _ac_seg=$2
        shift 2
        set -- "$_ac_depth" "$@"
        _ac_check=$(printf '%s' "$_ac_seg" | tr -d '[:space:]')
        [ -n "$_ac_check" ] && analyze_segment "$_ac_seg" "$_ac_depth"
    done
}

# Normalise puis évalue un segment de commande. $1 = segment, $2 = profondeur.
# Normalisation par tokens (pas par sous-chaîne) : espaces et parenthèses/
# accolades ouvrantes en tête, affectations d'env en boucle, enveloppes
# env/command/exec/nohup/time/sudo, puis dépliage de « sh -c "…" » (et bash/
# zsh/dash, chemin optionnel) avec réanalyse récursive du contenu (profondeur
# max 3, garde-fou anti-boucle).
analyze_segment() {
    _as_seg=$1
    _as_depth=$2

    _as_norm=$(printf '%s' "$_as_seg" | sed -E 's/^[[:space:]]*[({]*[[:space:]]*//')

    _as_iter=0
    while [ "$_as_iter" -lt 20 ]; do
        _as_new=$(printf '%s' "$_as_norm" | sed -E 's/^[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+//')
        [ "$_as_new" = "$_as_norm" ] && break
        _as_norm=$_as_new
        _as_iter=$((_as_iter + 1))
    done

    _as_iter=0
    while [ "$_as_iter" -lt 20 ]; do
        _as_iter=$((_as_iter + 1))
        _as_before=$_as_norm
        case "$_as_norm" in
            env\ -i\ *) _as_norm=${_as_norm#env -i } ;;
            env\ *) _as_norm=${_as_norm#env } ;;
            command\ *) _as_norm=${_as_norm#command } ;;
            exec\ *) _as_norm=${_as_norm#exec } ;;
            nohup\ *) _as_norm=${_as_norm#nohup } ;;
            time\ *) _as_norm=${_as_norm#time } ;;
            sudo\ *) _as_norm=${_as_norm#sudo } ;;
        esac
        _as_norm=$(printf '%s' "$_as_norm" | sed -E 's/^[[:space:]]*//')
        _as_iter2=0
        while [ "$_as_iter2" -lt 20 ]; do
            _as_new=$(printf '%s' "$_as_norm" | sed -E 's/^[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+//')
            [ "$_as_new" = "$_as_norm" ] && break
            _as_norm=$_as_new
            _as_iter2=$((_as_iter2 + 1))
        done
        [ "$_as_norm" = "$_as_before" ] && break
    done

    _as_head=$(printf '%s' "$_as_norm" | awk '{print $1}')
    _as_head_base=$(basename -- "$_as_head" 2>/dev/null)
    [ -n "$_as_head_base" ] || _as_head_base=$_as_head
    _as_second=$(printf '%s' "$_as_norm" | awk '{print $2}')

    case "$_as_head_base" in
        sh|bash|zsh|dash)
            if [ "$_as_second" = "-c" ] && [ "$_as_depth" -lt 3 ]; then
                _as_inner=$(printf '%s' "$_as_norm" | sed -E 's/^[^[:space:]]+[[:space:]]+-c[[:space:]]+//')
                case "$_as_inner" in
                    \"*\") _as_inner=${_as_inner#\"}; _as_inner=${_as_inner%\"} ;;
                    \'*\') _as_inner=${_as_inner#\'}; _as_inner=${_as_inner%\'} ;;
                esac
                analyze_command "$_as_inner" "$((_as_depth + 1))"
                return 0
            fi
            ;;
    esac

    case "$_as_norm" in
        git*) : ;;
        *) return 0 ;;
    esac

    # Retirer « git », les options globales courantes, et -C <path>.
    _as_args=$(printf '%s' "$_as_norm" | sed 's/^git[[:space:]]*//' \
        | sed 's/^--no-pager[[:space:]]*//' \
        | sed 's/^-c[[:space:]][^[:space:]]*[[:space:]]*//' \
        | sed 's/^-C[[:space:]][^[:space:]]*[[:space:]]*//')

    set -f
    # shellcheck disable=SC2086
    set -- $_as_args
    set +f
    _as_sub=${1:-}
    [ $# -gt 0 ] && shift

    apply_matrix "$_as_sub" "$@"
}

# Applique la matrice DEC-0044 par tokens. $1 = sous-commande git, le reste =
# ses arguments déjà séparés (pas de test de sous-chaîne libre).
apply_matrix() {
    _mx_sub=$1
    shift

    case "$_mx_sub" in
        push)
            _mx_blocked=0
            for _mx_tok in "$@"; do
                case "$_mx_tok" in
                    --force-with-lease|--force-with-lease=*|--force-if-includes) : ;;
                    --force) _mx_blocked=1 ;;
                    -[!-]*)
                        case "$_mx_tok" in *f*) _mx_blocked=1 ;; esac ;;
                esac
            done
            [ "$_mx_blocked" -eq 1 ] && deny "MyProjectOS : 'git push --force' est bloqué (réécrit l'historique distant). Alternative : 'git push --force-with-lease'. Si la dérogation est vraiment voulue, demande la validation humaine puis relance avec MYPROJECTOS_GIT_OVERRIDE=1 et consigne une entrée CHG-."
            ;;
        reset)
            for _mx_tok in "$@"; do
                case "$_mx_tok" in
                    --hard) deny "MyProjectOS : 'git reset --hard' est bloqué (perte irréversible du travail non committé). Alternative : 'git stash' ou commit avant reset. Si la dérogation est vraiment voulue, demande la validation humaine puis relance avec MYPROJECTOS_GIT_OVERRIDE=1 et consigne une entrée CHG-." ;;
                esac
            done
            ;;
        clean)
            _mx_force=0
            _mx_destr=0
            _mx_dry=0
            for _mx_tok in "$@"; do
                case "$_mx_tok" in
                    --dry-run) _mx_dry=1 ;;
                    --force) _mx_force=1 ;;
                    --directory) _mx_destr=1 ;;
                    -[!-]*)
                        case "$_mx_tok" in *n*) _mx_dry=1 ;; esac
                        case "$_mx_tok" in *f*) _mx_force=1 ;; esac
                        case "$_mx_tok" in *[dxX]*) _mx_destr=1 ;; esac
                        ;;
                esac
            done
            if [ "$_mx_dry" -eq 0 ] && [ "$_mx_force" -eq 1 ] && [ "$_mx_destr" -eq 1 ]; then
                deny "MyProjectOS : 'git clean -fd/-x' est bloqué (suppression irréversible de fichiers non suivis). Alternative : 'git clean -nd' pour prévisualiser. Si la dérogation est vraiment voulue, demande la validation humaine puis relance avec MYPROJECTOS_GIT_OVERRIDE=1, après sauvegarde, et consigne une entrée CHG-."
            fi
            ;;
        branch)
            _mx_capd=0
            _mx_del=0
            _mx_force=0
            for _mx_tok in "$@"; do
                case "$_mx_tok" in
                    -D) _mx_capd=1 ;;
                    --delete) _mx_del=1 ;;
                    --force) _mx_force=1 ;;
                    -[!-]*)
                        case "$_mx_tok" in *D*) _mx_capd=1 ;; esac
                        case "$_mx_tok" in *d*) _mx_del=1 ;; esac
                        case "$_mx_tok" in *f*) _mx_force=1 ;; esac
                        ;;
                esac
            done
            if [ "$_mx_capd" -eq 1 ] || { [ "$_mx_del" -eq 1 ] && [ "$_mx_force" -eq 1 ]; }; then
                deny "MyProjectOS : 'git branch -D' est bloqué (suppression forcée sans vérification de fusion). Alternative : 'git branch -d' qui refuse si non fusionnée. Si la dérogation est vraiment voulue, demande la validation humaine puis relance avec MYPROJECTOS_GIT_OVERRIDE=1 et consigne une entrée CHG-."
            fi
            ;;
        rebase)
            _mx_skip=0
            for _mx_tok in "$@"; do
                case "$_mx_tok" in
                    --onto|--interactive|-i) _mx_skip=1 ;;
                esac
            done
            if [ "$_mx_skip" -eq 0 ]; then
                _mx_branch=""
                for _mx_tok in "$@"; do
                    case "$_mx_tok" in
                        -*) : ;;
                        *) _mx_branch=$_mx_tok; break ;;
                    esac
                done
                if [ -n "$_mx_branch" ] && git -C "$PROJECT_DIR" rev-parse --verify --quiet "origin/$_mx_branch" >/dev/null 2>&1; then
                    deny "MyProjectOS : rebase sur '$_mx_branch' (branche distante) est bloqué (réécriture d'historique partagé). Alternative : 'git merge'. Si la dérogation est vraiment voulue, demande la validation humaine puis relance avec MYPROJECTOS_GIT_OVERRIDE=1 et consigne une entrée rebase CHG-."
                fi
            fi
            ;;
    esac
}

analyze_command "$CMD" 0

exit 0
