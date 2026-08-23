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

# Dérogation explicite : l'humain a validé dans la session.
case "$MYPROJECTOS_GIT_OVERRIDE" in
    1)
        printf '%s' '{"systemMessage":"MyProjectOS : dérogation Git acceptée (MYPROJECTOS_GIT_OVERRIDE=1). Consigne-la dans CHANGELOG.md (entrée CHG-)."}'
        exit 0
        ;;
esac

# Extraction des segments git de la commande (peut être un pipeline/composée).
# On évalue chaque segment séparément.
_seg=1
while :; do
    SEGMENT=$(printf '%s' "$CMD" | awk -v s="$_seg" -F'[&][&]|[|]|;' '{ print $s; exit }')
    [ -n "$SEGMENT" ] || break

    # Normalisation : retirer les espaces initiaux, variables d'env préfixées,
    # et sous-shells triviaux. Ne vise pas l'exhaustivité : c'est un garde-fou,
    # pas un parser shell complet.
    NORM=$(printf '%s' "$SEGMENT" | sed 's/^[[:space:]]*//')
    ARGS=""

    case "$NORM" in
        git*)
            # Retirer « git », les options globales courantes, et -C <path>.
            ARGS=$(printf '%s' "$NORM" | sed 's/^git[[:space:]]*//' \
                | sed 's/^--no-pager[[:space:]]*//' \
                | sed 's/^-c[[:space:]][^[:space:]]*[[:space:]]*//' \
                | sed 's/^-C[[:space:]][^[:space:]]*[[:space:]]*//')
            ;;
    esac

    SUB=$(printf '%s' "$ARGS" | cut -d' ' -f1)

    case "$SUB" in
        push)
            REST=$(printf '%s' "$ARGS" | cut -s -d' ' -f2-)
            case "$REST" in
                *"--force"*|*-f*)
                    deny "MyProjectOS : 'git push --force' est bloqué (réécrit l'historique distant). Alternative : 'git push --force-with-lease'. Si la dérogation est vraiment voulue, demande la validation humaine puis relance avec MYPROJECTOS_GIT_OVERRIDE=1 et consigne une entrée CHG-." ;;
                *) : ;;
            esac
            ;;
        reset)
            REST=$(printf '%s' "$ARGS" | cut -s -d' ' -f2-)
            case "$REST" in
                *"--hard"*)
                    deny "MyProjectOS : 'git reset --hard' est bloqué (perte irréversible du travail non committé). Alternative : 'git stash' ou commit avant reset. Si la dérogation est vraiment voulue, demande la validation humaine puis relance avec MYPROJECTOS_GIT_OVERRIDE=1 et consigne une entrée CHG-." ;;
                *) : ;;
            esac
            ;;
        clean)
            REST=$(printf '%s' "$ARGS" | cut -s -d' ' -f2-)
            case "$REST" in
                *"-fd"*|*"--force -d"*|*"-df"*|*"-x"*|*"-fx"*|*"-xf"*|*"-fdx"*|*"-xdf"*)
                    deny "MyProjectOS : 'git clean -fd/-x' est bloqué (suppression irréversible de fichiers non suivis). Alternative : 'git clean -nd' pour prévisualiser. Si la dérogation est vraiment voulue, demande la validation humaine puis relance avec MYPROJECTOS_GIT_OVERRIDE=1, après sauvegarde, et consigne une entrée CHG-." ;;
                *) : ;;
            esac
            ;;
        branch)
            REST=$(printf '%s' "$ARGS" | cut -s -d' ' -f2-)
            case "$REST" in
                "-D "*|"-D")
                    deny "MyProjectOS : 'git branch -D' est bloqué (suppression forcée sans vérification de fusion). Alternative : 'git branch -d' qui refuse si non fusionnée. Si la dérogation est vraiment voulue, demande la validation humaine puis relance avec MYPROJECTOS_GIT_OVERRIDE=1 et consigne une entrée CHG-."
                    ;;
            esac
            ;;
        rebase)
            REST=$(printf '%s' "$ARGS" | cut -s -d' ' -f2-)
            case "$ARGS" in
                *"--onto"*|*"-i"*|"--interactive")
                    # rebase interactif ou --onto : hors matrice (jugement).
                    : ;;
                *)
                    # Rebase simple sur branche potentiellement partagée : bloqué
                    # sauf si la branche est locale-only (vérification légère).
                    BRANCH=$(printf '%s' "$REST" | awk '{print $1}')
                    if [ -n "$BRANCH" ] && git -C "$PROJECT_DIR" rev-parse --verify --quiet "origin/$BRANCH" >/dev/null 2>&1; then
                        deny "MyProjectOS : rebase sur '$BRANCH' (branche distante) est bloqué (réécriture d'historique partagé). Alternative : 'git merge'. Si la dérogation est vraiment voulue, demande la validation humaine puis relance avec MYPROJECTOS_GIT_OVERRIDE=1 et consigne une entrée rebase CHG-."
                    fi ;;
            esac
            ;;
    esac

    _seg=$((_seg + 1))
done

exit 0
