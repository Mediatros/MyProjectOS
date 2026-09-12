#!/bin/sh
# test-hook-pre-git.sh — teste la matrice de blocage du garde-fou Git
# (scripts/hooks/hook-pre-git.sh, DEC-0044/DEC-0049). POSIX sh. Aucune
# dépendance externe autre que celles déjà exigées par le hook (python3 ou jq).
set -u

REPO=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd)
HOOK="$REPO/scripts/hooks/hook-pre-git.sh"

TMPDIR=$(mktemp -d 2>/dev/null || mktemp -d -t myprojectos-hook-test)
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT INT TERM

# Projet MyProjectOS jetable : is_project_os() (scripts/hooks/_lib.sh) ne teste
# que la présence de PROJECT.md, inutile de poser un projet complet ici.
printf 'projet: test-hook\n' > "$TMPDIR/PROJECT.md"

TOTAL=0
FAIL=0

json_escape() {
    printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

# run_case <libellé> <commande> <allow|deny> [override:0|1]
run_case() {
    _label=$1
    _cmd=$2
    _expect=$3
    _override=${4:-0}

    _esc=$(json_escape "$_cmd")
    _payload="{\"tool_input\":{\"command\":\"$_esc\"}}"

    if [ "$_override" -eq 1 ]; then
        _out=$(printf '%s' "$_payload" | CLAUDE_PROJECT_DIR="$TMPDIR" MYPROJECTOS_GIT_OVERRIDE=1 sh "$HOOK" 2>&1)
    else
        _out=$(printf '%s' "$_payload" | CLAUDE_PROJECT_DIR="$TMPDIR" sh "$HOOK" 2>&1)
    fi

    case "$_out" in
        *'"permissionDecision":"deny"'*) _result=deny ;;
        *) _result=allow ;;
    esac

    TOTAL=$((TOTAL + 1))
    if [ "$_result" = "$_expect" ]; then
        echo "OK - $_label"
    else
        echo "ECHEC - $_label (attendu=$_expect obtenu=$_result sortie=$_out)"
        FAIL=$((FAIL + 1))
    fi
}

# --- Cas qui doivent PASSER --------------------------------------------------
run_case "git status" "git status" allow
run_case "git add ." "git add ." allow
run_case "git commit simple" 'git commit -m "feat: x"' allow
run_case "git push origin main" "git push origin main" allow
run_case "git pull" "git pull" allow
run_case "push --force-with-lease" "git push --force-with-lease origin main" allow
run_case "push branche 'release-final' (B1)" "git push origin release-final" allow
run_case "clean -nd (prévisualisation)" "git clean -nd" allow
run_case "clean -nx (prévisualisation, défaut annexe)" "git clean -nx" allow
run_case "clean -n -x (prévisualisation, défaut annexe)" "git clean -n -x" allow
run_case "branch -d (non forcé)" "git branch -d vieille-branche" allow
run_case "git add *.md (glob non développé)" "git add *.md" allow
run_case "git stash" "git stash" allow
run_case "git checkout -- ." "git checkout -- ." allow

# --- Cas qui doivent être BLOQUÉS --------------------------------------------
run_case "push --force" "git push --force origin main" deny
run_case "push -f" "git push -f origin main" deny
run_case "reset --hard" "git reset --hard HEAD~1" deny
run_case "clean -fd" "git clean -fd" deny
run_case "clean -xdf" "git clean -xdf" deny
run_case "branch -D" "git branch -D ma-branche" deny
run_case "sh -c push --force (B2)" 'sh -c "git push --force origin main"' deny
run_case "bash -c reset --hard (B2)" "bash -c 'git reset --hard'" deny
run_case "préfixe env FOO=bar (B3)" "FOO=bar git reset --hard" deny
run_case "env FOO=bar (B3)" "env FOO=bar git push --force origin main" deny
run_case "cd && reset --hard" "cd /tmp && git reset --hard" deny
# Profondeur de dépliage constante d'un segment à l'autre : sans cela, à partir
# du 4e segment enveloppé, « sh -c » n'était plus déplié et la commande passait.
run_case "4 segments sh -c, reset --hard en dernier" 'sh -c "git status" && sh -c "git fetch" && sh -c "git log" && sh -c "git reset --hard"' deny
run_case "5 segments sh -c, push --force en dernier" 'sh -c "git status" && sh -c "git fetch" && sh -c "git log" && sh -c "git diff" && sh -c "git push --force origin main"' deny
run_case "5 segments simples, clean -fd en dernier" "git status ; git fetch ; git log ; git diff ; git clean -fd" deny

# --- Dérogation ---------------------------------------------------------------
run_case "dérogation MYPROJECTOS_GIT_OVERRIDE=1" "git push --force origin main" allow 1

# --- DEC-0049 : trailer d'agent dans un message de commit --------------------
run_case "DEC-0049 : trailer Co-Authored-By" 'git commit -m "fix: x" -m "Co-Authored-By: Machin <a@b.c>"' deny

echo ""
echo "Récapitulatif : $((TOTAL - FAIL))/$TOTAL cas passés."

if [ "$FAIL" -eq 0 ]; then
    exit 0
fi
exit 1
