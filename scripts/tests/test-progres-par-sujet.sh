#!/bin/sh
# test-progres-par-sujet.sh — teste la projection des progrès de sujet dans le
# PROGRESS.md racine (scripts/sync-progress.sh), la gestion des sujets
# (scripts/sujet.sh), le hook PostToolUse (scripts/hooks/hook-post-progress.sh),
# les contrôles de check-project.sh et check-iteration.sh (DEC-0053).
# POSIX sh. Rejoué en CI.
set -u

REPO=$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd)
TMPDIR=$(mktemp -d 2>/dev/null || mktemp -d -t myprojectos-sujets)
cleanup() { rm -rf "$TMPDIR"; }
trap cleanup EXIT INT TERM

P="$TMPDIR/p-life"
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

block() { awk 'index($0,"<!-- sujets:debut")==1{b=1;next} index($0,"<!-- sujets:fin")==1{b=0} b' "$P/PROGRESS.md"; }
set_fm() {
    # set_fm <fichier> <clé> <valeur> : remplace un champ du frontmatter.
    sed "s|^$2:.*|$2: $3|" "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

TODAY=$(date +%Y-%m-%d)

# --- Projet Life neuf ---------------------------------------------------------
sh "$REPO/scripts/init-project.sh" "$P" --life >/dev/null 2>&1
check "init : scripts sync-progress.sh et sujet.sh posés" "test -f '$P/scripts/sync-progress.sh' && test -f '$P/scripts/sujet.sh'"
check "init : hook-post-progress.sh copié et câblé (PostToolUse)" "test -f '$P/.claude/hooks/hook-post-progress.sh' && grep -q 'PostToolUse' '$P/.claude/settings.json' && grep -q 'hook-post-progress' '$P/.claude/settings.json'"
check "init : manifest liste les trois nouveaux artefacts" "grep -qx 'scripts/sync-progress.sh' '$P/.myprojectos/manifest' && grep -qx 'scripts/sujet.sh' '$P/.myprojectos/manifest' && grep -qx '.claude/hooks/hook-post-progress.sh' '$P/.myprojectos/manifest'"
check "gabarit Core : marqueurs présents dans PROGRESS.md" "grep -q '^<!-- sujets:debut' '$P/PROGRESS.md' && grep -q '^<!-- sujets:fin' '$P/PROGRESS.md'"
check "sans sujet : sync silencieux, code 0" "out=\$(sh '$P/scripts/sync-progress.sh' '$P' 2>&1); test \$? -eq 0 && test -z \"\$out\""
check "sans sujet : --check code 0" "sh '$P/scripts/sync-progress.sh' --check '$P'"

# --- Création de sujets ---------------------------------------------------------
sh "$P/scripts/sujet.sh" new "Succession" "$P" >/dev/null 2>&1
check "sujet.sh new : dossier S01_Succession et PROGRESS.md posés" "test -f '$P/02_sujets/S01_Succession/PROGRESS.md'"
check "sujet.sh new : en-tête renseigné (sujet, titre, statut actif, date du jour)" "grep -q '^sujet: S01\$' '$P/02_sujets/S01_Succession/PROGRESS.md' && grep -q '^titre: Succession\$' '$P/02_sujets/S01_Succession/PROGRESS.md' && grep -q '^statut: actif\$' '$P/02_sujets/S01_Succession/PROGRESS.md' && grep -q \"^derniere_maj: $TODAY\$\" '$P/02_sujets/S01_Succession/PROGRESS.md'"
check "sujet.sh new : INDEX.md créé avec la ligne S01" "grep -q '^| \`S01_Succession\`' '$P/02_sujets/INDEX.md'"
check "sujet.sh new : parent projeté (ligne S01)" "block | grep -q '^- \*\*S01 · Succession\*\* · actif'"
sh "$P/scripts/sujet.sh" new "Vente du bien à Nîmes" "$P" >/dev/null 2>&1
check "sujet.sh new : accents retirés du nom de dossier, numéro suivant" "test -d '$P/02_sujets/S02_Vente_du_bien_a_Nimes'"
check "sujet.sh new : identifiant déjà pris refusé" "! sh '$P/scripts/sujet.sh' new S01 'Doublon' '$P'"

# Le gabarit embarqué dans sujet.sh est celui de templates/extensions/life/ (anti-dérive).
sed -e "s#<NomDuProjet>#p-life#g" -e "s#<TitreDuSujet>#Succession#g" -e "s#^sujet: Sxx\$#sujet: S01#" \
    -e "s|^# PROGRESS.md — Sxx |# PROGRESS.md — S01 |" -e "s#^statut: actif | en pause | clos\$#statut: actif#" \
    -e "s#^derniere_maj: YYYY-MM-DD\$#derniere_maj: $TODAY#" -e "s#^etat: <.*>\$#etat: Sujet créé, à cadrer.#" \
    -e "s#^prochaine_action: <.*>\$#prochaine_action: Renseigner l'objet du sujet dans INDEX.md, puis son état et sa prochaine action ici.#" \
    -e "s#^prochaine_echeance: <.*>\$#prochaine_echeance:#" \
    "$REPO/templates/extensions/life/02_sujets/Sxx_NomDuSujet/PROGRESS.md" > "$TMPDIR/attendu.md"
check "sujet.sh new : gabarit embarqué identique à templates/extensions/life/02_sujets/" "cmp -s '$TMPDIR/attendu.md' '$P/02_sujets/S01_Succession/PROGRESS.md'"

# --- Projection déterministe ----------------------------------------------------
F1="$P/02_sujets/S01_Succession/PROGRESS.md"
set_fm "$F1" etat "Acte de notoriété signé, attente du notaire."
set_fm "$F1" prochaine_action "Relancer le notaire si silence au 2026-10-01."
set_fm "$F1" prochaine_echeance "2026-10-01"
set_fm "$F1" statut "en pause"
check "--check détecte le retard (code 1)" "rc=0; sh '$P/scripts/sync-progress.sh' --check '$P' >/dev/null 2>&1 || rc=\$?; test \$rc -eq 1"
check "--check n'écrit rien" "! block | grep -q 'notoriété'"
sh "$P/scripts/sync-progress.sh" "$P"
check "sync : ligne S01 projetée depuis le frontmatter (statut, échéance, état, action)" "block | grep -q '^- \*\*S01 · Succession\*\* · en pause · maj $TODAY · échéance 2026-10-01 · état : Acte de notoriété signé, attente du notaire. · prochaine action : Relancer le notaire si silence au 2026-10-01. · \`02_sujets/S01_Succession/PROGRESS.md\`\$'"
check "sync : prochaine_echeance du parent dérivée (plus proche des sujets)" "grep -q '^prochaine_echeance: 2026-10-01\$' '$P/PROGRESS.md'"
check "sync : derniere_maj du parent datée du jour" "grep -q \"^derniere_maj: $TODAY\$\" '$P/PROGRESS.md'"
c1=$(cksum "$P/PROGRESS.md")
sh "$P/scripts/sync-progress.sh" "$P"
c2=$(cksum "$P/PROGRESS.md")
check "sync : idempotent (second passage, zéro écriture)" "test '$c1' = '$c2'"
check "sync : --check code 0 une fois à jour" "sh '$P/scripts/sync-progress.sh' --check '$P'"
printf '\n## Contexte utile\n\n- note manuscrite hors bloc\n' >> "$P/PROGRESS.md"
set_fm "$F1" etat "Notaire relancé."
sh "$P/scripts/sync-progress.sh" "$P"
check "sync : la partie manuscrite du parent est préservée" "grep -q 'note manuscrite hors bloc' '$P/PROGRESS.md' && block | grep -q 'Notaire relancé'"

# --- Sujet clos et archivage ----------------------------------------------------
F2="$P/02_sujets/S02_Vente_du_bien_a_Nimes/PROGRESS.md"
set_fm "$F2" statut "clos"
set_fm "$F2" derniere_maj "2026-07-01"
sh "$P/scripts/sync-progress.sh" "$P"
check "sync : sujet clos regroupé sur la ligne finale, hors liste" "block | grep -q '^Sujets clos : S02 · Vente du bien à Nîmes (2026-07-01)\$' && ! block | grep -q '^- \*\*S02'"
check "sync : échéance dérivée ignore les sujets clos" "grep -q '^prochaine_echeance: 2026-10-01\$' '$P/PROGRESS.md'"
check "check-project : sujet clos ancien signalé à archiver" "sh '$REPO/scripts/check-project.sh' '$P' | grep -q 'clos depuis .* jours : à archiver'"
check "check-project : objet resté à compléter signalé" "sh '$REPO/scripts/check-project.sh' '$P' | grep -q 'resté « à compléter »'"
check "sujet.sh archive : refuse un sujet non clos" "! sh '$P/scripts/sujet.sh' archive S01 '$P'"
sh "$P/scripts/sujet.sh" archive S02 "$P" >/dev/null 2>&1
check "sujet.sh archive : dossier déplacé vers 99_archive/02_sujets/" "test -d '$P/99_archive/02_sujets/S02_Vente_du_bien_a_Nimes' && ! test -d '$P/02_sujets/S02_Vente_du_bien_a_Nimes'"
check "sujet.sh archive : ligne retirée d'INDEX.md, parent resynchronisé" "! grep -q 'S02_' '$P/02_sujets/INDEX.md' && ! block | grep -q 'S02'"

# --- Hook PostToolUse ----------------------------------------------------------
set_fm "$F1" etat "Déclaration déposée."
payload="{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$F1\"}}"
out=$(printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$P" sh "$P/.claude/hooks/hook-post-progress.sh" 2>&1)
check "hook : projette le parent après l'écriture d'un progrès de sujet, sans rien émettre" "test -z \"$out\" && block | grep -q 'Déclaration déposée'"
payload="{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$P/00_inbox/note.md\"}}"
c1=$(cksum "$P/PROGRESS.md")
printf '%s' "$payload" | CLAUDE_PROJECT_DIR="$P" sh "$P/.claude/hooks/hook-post-progress.sh" >/dev/null 2>&1
c2=$(cksum "$P/PROGRESS.md")
check "hook : ignore un fichier hors progrès" "test '$c1' = '$c2'"

# --- Cas dégradés ----------------------------------------------------------------
set_fm "$F1" statut "standby"
sh "$P/scripts/sync-progress.sh" "$P" 2>/dev/null
check "sync : statut inconnu rendu « progrès local invalide », les autres sujets continuent" "block | grep -q '^- \*\*S01\*\* · progrès local invalide (statut « standby »'"
check "check-project : statut hors vocabulaire signalé" "sh '$REPO/scripts/check-project.sh' '$P' | grep -q 'hors actif / en pause / clos'"
set_fm "$F1" statut "actif"
set_fm "$F1" derniere_maj "2026-01-01"
check "check-project : sujet actif périmé signalé" "sh '$REPO/scripts/check-project.sh' '$P' | grep -q 'sujet actif non mis à jour'"
set_fm "$F1" statut "en pause"
check "check-project : sujet en pause ancien non signalé" "! sh '$REPO/scripts/check-project.sh' '$P' | grep -q 'non mis à jour depuis'"
set_fm "$F1" derniere_maj "$TODAY"
mkdir -p "$P/02_sujets/S03_Sans_progres"
sh "$P/scripts/sync-progress.sh" "$P"
check "sync : dossier de sujet sans PROGRESS.md rendu « progrès local absent »" "block | grep -q '^- \*\*S03\*\* · progrès local absent · \`02_sujets/S03_Sans_progres/\`\$'"
check "check-project : sujet sans PROGRESS.md signalé" "sh '$REPO/scripts/check-project.sh' '$P' | grep -q 'S03_Sans_progres/ sans PROGRESS.md'"
rmdir "$P/02_sujets/S03_Sans_progres"
sh "$P/scripts/sync-progress.sh" "$P"
grep -v 'sujets:' "$P/PROGRESS.md" > "$P/PROGRESS.md.tmp" && mv "$P/PROGRESS.md.tmp" "$P/PROGRESS.md"
check "sync : marqueurs absents, code 2, rien d'inséré à l'aveugle" "rc=0; sh '$P/scripts/sync-progress.sh' '$P' 2>/dev/null || rc=\$?; test \$rc -eq 2 && ! grep -q 'sujets:debut' '$P/PROGRESS.md'"
check "check-project : parent sans zone sujets signalé" "sh '$REPO/scripts/check-project.sh' '$P' | grep -q 'sans zone « sujets »'"

# --- check-iteration : fichier d'un sujet cité dans le progrès du sujet ----------
if command -v git >/dev/null 2>&1; then
    printf '\n## État actuel\n\n<!-- sujets:debut -->\n<!-- sujets:fin -->\n' >> "$P/PROGRESS.md"
    sh "$P/scripts/sync-progress.sh" "$P"
    (cd "$P" && git init -q && git add -A >/dev/null 2>&1 && git -c user.name=t -c user.email=t@t commit -qm init >/dev/null 2>&1)
    printf 'brouillon\n' > "$P/02_sujets/S01_Succession/brouillon-partage.md"
    check "check-iteration : fichier de sujet non cité nulle part = bloquant" "! sh '$REPO/scripts/check-iteration.sh' '$P' | grep -q 'changements reflétés'"
    printf -- '- brouillon-partage.md : projet de partage\n' >> "$F1"
    check "check-iteration : fichier de sujet cité dans le PROGRESS.md du sujet = accepté" "sh '$REPO/scripts/check-iteration.sh' '$P' | grep -q 'changements reflétés'"
fi

# --- --update-method câble le hook sur un projet existant --------------------------
P2="$TMPDIR/p-old"
sh "$REPO/scripts/init-project.sh" "$P2" --life >/dev/null 2>&1
rm -f "$P2/.claude/hooks/hook-post-progress.sh" "$P2/scripts/sync-progress.sh" "$P2/scripts/sujet.sh"
printf '{"hooks":{"PreToolUse":[{"matcher":"Write","hooks":[{"type":"command","command":"sh \\"$CLAUDE_PROJECT_DIR/.claude/hooks/hook-pre-write.sh\\""}]}]},"permissions":{"allow":["Bash(ls:*)"]}}\n' > "$P2/.claude/settings.json"
sh "$REPO/scripts/init-project.sh" "$P2" --update-method >/dev/null 2>&1
check "--update-method : hook post-progress copié, câblé, permissions existantes conservées" "test -f '$P2/.claude/hooks/hook-post-progress.sh' && grep -q 'hook-post-progress' '$P2/.claude/settings.json' && grep -q 'Bash(ls:\*)' '$P2/.claude/settings.json' && test -f '$P2/scripts/sync-progress.sh' && test -f '$P2/scripts/sujet.sh'"

echo ""
echo "Bilan : $TOTAL cas, $FAIL échec(s)."
[ "$FAIL" -eq 0 ]
