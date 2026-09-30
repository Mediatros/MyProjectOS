#!/bin/sh
# test-socle-agent.sh — teste la règle de la paire AGENTS.md + CLAUDE.md
# (DEC-0055) : gabarit posé par init-project.sh et contrôle de dérive de
# check-project.sh §1bis, à la racine et dans les dossiers de zone (DEC-0054).
# POSIX sh. Rejoué en CI.
# shellcheck disable=SC2034 # $out est lu dans les chaînes évaluées par check.
set -u

REPO=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd)
TMPDIR=$(mktemp -d 2>/dev/null || mktemp -d -t myprojectos-socle)
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT INT TERM

P="$TMPDIR/p-socle"
TOTAL=0
FAIL=0

check() {
    # check <libellé> <commande shell évaluée>
    TOTAL=$((TOTAL + 1))
    if eval "$2" >/dev/null 2>&1; then
        echo "OK - $1"
    else
        echo "ECHEC - $1"
        FAIL=$((FAIL + 1))
    fi
}

# socle : sortie de la seule section « Socle agent » de check-project.sh.
socle() { sh "$REPO/scripts/check-project.sh" "$P" 2>/dev/null | awk '/^Socle agent/{s=1;next} /^[^ ]/{s=0} s'; }
pair() { mkdir -p "$P/$1" && echo "# Zone" > "$P/$1/AGENTS.md" && echo "@AGENTS.md" > "$P/$1/CLAUDE.md"; }

sh "$REPO/scripts/init-project.sh" "$P" --life --code >/dev/null 2>&1

check "gabarit : CLAUDE.md réduit à @AGENTS.md" "test \"\$(cat '$P/CLAUDE.md')\" = '@AGENTS.md'"
check "gabarit : AGENTS.md porte la section Paire d'instructions" "grep -q '^## Paire d.instructions' '$P/AGENTS.md'"
check "projet neuf : paire conforme, aucun avertissement" "socle | grep -q '\[ok\].*paire' && ! socle | grep -q '\[!\]'"

pair "05_specs"
pair "02_sujets/S01_Test"
check "zones avec paire (05_specs, 02_sujets/S01_Test) : conformes" "! socle | grep -q '\[!\]'"

rm "$P/05_specs/CLAUDE.md"
check "zone sans CLAUDE.md : paire incomplète signalée" "socle | grep -q '05_specs : CLAUDE.md manquant'"
echo "@AGENTS.md" > "$P/05_specs/CLAUDE.md"

rm "$P/05_specs/AGENTS.md"
check "zone sans AGENTS.md : signalée" "socle | grep -q '05_specs : AGENTS.md manquant'"
echo "# Zone" > "$P/05_specs/AGENTS.md"

printf '@AGENTS.md\n\n## Claude Code\nConsigne ajoutée.\n' > "$P/CLAUDE.md"
check "CLAUDE.md racine qui porte du contenu : dérive signalée" "socle | grep -q 'racine : CLAUDE.md porte autre chose'"
printf '\n  @AGENTS.md  \n\n' > "$P/CLAUDE.md"
check "CLAUDE.md = @AGENTS.md entouré de blancs : conforme" "! socle | grep -q 'racine : CLAUDE.md'"
echo "@AGENTS.md" > "$P/CLAUDE.md"

cp "$P/AGENTS.md" "$TMPDIR/AGENTS.sauve"
printf '## Règle absolue\nLa source de vérité du projet est `CLAUDE.md`.\n' >> "$P/AGENTS.md"
check "AGENTS.md qui désigne CLAUDE.md comme source : sens inversé signalé" "socle | grep -q 'sens inversé'"
cp "$TMPDIR/AGENTS.sauve" "$P/AGENTS.md"

rm "$P/CLAUDE.md"
check "CLAUDE.md racine absent : signalé" "socle | grep -q 'racine : CLAUDE.md manquant'"
mv "$P/AGENTS.md" "$TMPDIR/AGENTS.retire"
check "ni AGENTS.md ni CLAUDE.md à la racine : un seul avertissement" "test \"\$(socle | grep -c 'racine :')\" -eq 1 && socle | grep -q 'racine : aucune instruction'"
mv "$TMPDIR/AGENTS.retire" "$P/AGENTS.md"
echo "@AGENTS.md" > "$P/CLAUDE.md"

pair "src/module"
check "zone trop profonde (src/module) : signalée" "socle | grep -q 'src/module : fichier d.instructions trop profond'"
rm -r "$P/src/module"

pair "02_sujets"
check "fichier dans 02_sujets/ lui-même : signalé" "socle | grep -q '02_sujets : pas de fichier'"
rm "$P/02_sujets/AGENTS.md" "$P/02_sujets/CLAUDE.md"

pair "99_archive/ancien"
pair ".cache/outil"
check "99_archive/ et dossiers cachés : hors périmètre" "! socle | grep -q '\[!\]'"

# --- init-project.sh : greffe et --update-method --------------------------------
printf '# CLAUDE.md\n\nRègles épaisses écrites à la main.\n' > "$P/CLAUDE.md"
out=$(sh "$REPO/scripts/init-project.sh" "$P" --life --code --into-existing 2>&1)
check "greffe : CLAUDE.md épais conservé mais signalé" "printf '%s' \"\$out\" | grep -q '! CLAUDE.md (déjà présent, conservé) : non conforme' && grep -q 'Règles épaisses' '$P/CLAUDE.md'"

out=$(sh "$REPO/scripts/init-project.sh" "$P" --update-method 2>&1)
check "update-method : CLAUDE.md épais jamais réécrit, signalé" "printf '%s' \"\$out\" | grep -q '! CLAUDE.md non conforme' && grep -q 'Règles épaisses' '$P/CLAUDE.md'"

cat > "$P/CLAUDE.md" <<'EOF_ANCIEN'
# CLAUDE.md — p-socle

Instructions d'opération pour Claude Code sur ce projet : voir `AGENTS.md` à la racine.

`AGENTS.md` est la source unique des instructions agent (rituels de session, fichiers sacrés, garde-fous, extensions actives). Ce fichier existe pour que Claude Code le charge automatiquement ; il ne duplique pas le contenu.
EOF_ANCIEN
sh "$REPO/scripts/init-project.sh" "$P" --update-method >/dev/null 2>&1
check "update-method : ancien renvoi en prose remplacé par @AGENTS.md" "test \"\$(cat '$P/CLAUDE.md')\" = '@AGENTS.md'"
check "update-method : ancien renvoi sauvegardé dans 99_archive/" "ls '$P'/99_archive/methode-avant-v*/CLAUDE.md"
out=$(sh "$REPO/scripts/init-project.sh" "$P" --update-method 2>&1)
check "update-method : idempotent sur un CLAUDE.md conforme" "printf '%s' \"\$out\" | grep -q '= CLAUDE.md (déjà réduit'"

# --- --socle : rituel de reprise, refus mémorisé par version (DEC-0056) ----------
Q="$TMPDIR/p-refus"
sh "$REPO/scripts/init-project.sh" "$Q" >/dev/null 2>&1
rc() { sh "$Q/scripts/check-project.sh" --socle "$Q" >/dev/null 2>&1; echo $?; }
check "--socle : paire conforme, code 0" "test \"\$(rc)\" -eq 0"
printf '@AGENTS.md\nConsigne ajoutée.\n' > "$Q/CLAUDE.md"
check "--socle : écart sans refus, code 2" "test \"\$(rc)\" -eq 2"
printf '%s\n' "autre-cle=9.9.9" > "$TMPDIR/prefs.init" && mkdir -p "$Q/.myprojectos" && cp "$TMPDIR/prefs.init" "$Q/.myprojectos/preferences"
sh "$Q/scripts/check-project.sh" --socle-refus "$Q" >/dev/null 2>&1
check "--socle-refus : refus consigné à la version installée, autres préférences gardées" "grep -qx \"alignement-socle-agent=\$(cat '$Q/VERSION')\" '$Q/.myprojectos/preferences' && grep -qx 'autre-cle=9.9.9' '$Q/.myprojectos/preferences'"
check "--socle : écart refusé pour cette version, code 3" "test \"\$(rc)\" -eq 3"
sh "$Q/scripts/check-project.sh" --socle-refus "$Q" >/dev/null 2>&1
check "--socle-refus répété : une seule ligne" "test \"\$(grep -c '^alignement-socle-agent=' '$Q/.myprojectos/preferences')\" -eq 1"
echo "99.0.0" > "$Q/VERSION"
check "nouvelle version de la méthode : le refus tombe, code 2" "test \"\$(rc)\" -eq 2"

# --- Cas limites : adoption et mise à jour avec un seul des deux fichiers ------
A="$TMPDIR/p-agents-seul"; mkdir -p "$A"; printf '# Mes règles\nToujours répondre en anglais.\n' > "$A/AGENTS.md"
out=$(sh "$REPO/scripts/init-project.sh" "$A" --into-existing 2>&1)
check "greffe, AGENTS.md étranger seul : conservé, sans rituels signalé, CLAUDE.md d'import créé" "printf '%s' \"\$out\" | grep -q '! AGENTS.md (déjà présent, conservé) : sans les rituels' && test \"\$(cat '$A/CLAUDE.md')\" = '@AGENTS.md' && grep -q 'anglais' '$A/AGENTS.md'"
check "contrôle : AGENTS.md sans rituels signalé" "sh '$REPO/scripts/check-project.sh' --socle '$A' | grep -q 'sans la section « Rituels de session »'"

B="$TMPDIR/p-claude-seul"; mkdir -p "$B"; printf '# CLAUDE.md\nRègles épaisses.\n' > "$B/CLAUDE.md"
out=$(sh "$REPO/scripts/init-project.sh" "$B" --into-existing 2>&1)
check "greffe, CLAUDE.md épais seul : conservé et signalé, AGENTS.md posé" "printf '%s' \"\$out\" | grep -q '! CLAUDE.md (déjà présent, conservé)' && test -f '$B/AGENTS.md' && grep -q 'Règles épaisses' '$B/CLAUDE.md'"

C="$TMPDIR/p-maj-sans-claude"
sh "$REPO/scripts/init-project.sh" "$C" >/dev/null 2>&1; rm "$C/CLAUDE.md"
sh "$REPO/scripts/init-project.sh" "$C" --update-method >/dev/null 2>&1
check "update-method sans CLAUDE.md : créé avec @AGENTS.md" "test \"\$(cat '$C/CLAUDE.md')\" = '@AGENTS.md'"

D="$TMPDIR/p-maj-sans-agents"
sh "$REPO/scripts/init-project.sh" "$D" >/dev/null 2>&1; rm "$D/AGENTS.md"; printf '# CLAUDE.md\nRègles épaisses.\n' > "$D/CLAUDE.md"
out=$(sh "$REPO/scripts/init-project.sh" "$D" --update-method 2>&1)
check "update-method, CLAUDE.md épais sans AGENTS.md : signalé explicitement, rien réécrit" "printf '%s' \"\$out\" | grep -q '! AGENTS.md absent et CLAUDE.md porte les instructions' && test ! -f '$D/AGENTS.md' && grep -q 'Règles épaisses' '$D/CLAUDE.md'"

echo ""
echo "$((TOTAL - FAIL))/$TOTAL vérifications passées."
[ "$FAIL" -eq 0 ]
