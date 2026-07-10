#!/bin/sh
# check-project.sh — vérifie la cohérence d'un projet MyProjectOS.
# Usage : check-project.sh [chemin-projet]   (défaut : dossier courant)
# Signale sans bloquer : fichiers sacrés manquants, extensions incomplètes,
# PROGRESS périmé, placeholders non substitués, références DEC-/CHG- cassées.
# POSIX sh. Aucune dépendance obligatoire (git facultatif).
# Code de sortie : 0 si aucun problème, 1 si au moins un FAIL, 0 si seulement des WARN.

set -u

TARGET=${1:-.}
STALE_DAYS=14
REPO=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

FAILS=0
WARNS=0

ok()   { printf '  [ok]   %s\n' "$1"; }
warn() { printf '  [!]    %s\n' "$1"; WARNS=$((WARNS + 1)); }
fail() { printf '  [X]    %s\n' "$1"; FAILS=$((FAILS + 1)); }

# Normalise un nom de dossier racine pour la détection de quasi-doublons :
# accents translittérés (si iconv présent), minuscules, tirets -> underscores,
# 's' final retiré. Même logique que normalize_root_name dans scripts/hooks/_lib.sh
# (dupliquée : ce script est copié seul dans les projets, sans les hooks).
norm_dirname() {
    _n=$1
    if command -v iconv >/dev/null 2>&1; then
        _n=$(printf '%s' "$_n" | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null || printf '%s' "$_n")
    fi
    printf '%s' "$_n" | LC_ALL=C tr '[:upper:]' '[:lower:]' | tr '-' '_' | sed 's/s$//'
}

# Comparaison de versions X.Y.Z, portable. Échos : lt | eq | gt (pour $1 vs $2).
ver_cmp() {
    _i=1
    while [ "$_i" -le 3 ]; do
        _fa=$(printf '%s' "$1" | cut -d. -f"$_i" | tr -dc '0-9'); [ -n "$_fa" ] || _fa=0
        _fb=$(printf '%s' "$2" | cut -d. -f"$_i" | tr -dc '0-9'); [ -n "$_fb" ] || _fb=0
        if [ "$_fa" -lt "$_fb" ]; then echo lt; return; fi
        if [ "$_fa" -gt "$_fb" ]; then echo gt; return; fi
        _i=$((_i + 1))
    done
    echo eq
}

if [ ! -d "$TARGET" ]; then
    echo "Dossier introuvable : $TARGET" >&2
    exit 1
fi

if [ ! -f "$TARGET/PROJECT.md" ]; then
    echo "Pas de PROJECT.md dans '$TARGET' : ce n'est pas un projet MyProjectOS." >&2
    exit 1
fi

# Type du projet, lu dans le frontmatter de PROJECT.md.
TYPE=$(sed -n 's/^type:[[:space:]]*//p' "$TARGET/PROJECT.md" | head -n 1)
[ -n "$TYPE" ] || TYPE="(inconnu)"
echo "Projet : $(basename -- "$(cd "$TARGET" && pwd)")  —  type déclaré : $TYPE"

# Le repo méthode lui-même contient des gabarits (templates/), des exemples
# (examples/), des documents de travail (PLAN/) et une spec de formats
# (NAMING-CONVENTIONS.md) volontairement non conformes aux scans de contenu :
# on les exclut pour que le dogfooding reste propre. Un projet normal n'a pas
# ces dossiers, l'exclusion ne s'applique donc qu'au repo méthode.
EXCLUDES=""
if [ -d "$TARGET/templates/core" ] && [ -f "$TARGET/structures/core-tree.md" ]; then
    EXCLUDES="--exclude-dir=templates --exclude-dir=examples --exclude-dir=PLAN --exclude=NAMING-CONVENTIONS.md"
    echo "  (repo méthode détecté : gabarits, exemples et PLAN/ exclus des scans de contenu)"
fi

# --- 0. Alignement avec la version de la méthode -----------------------------
echo "Version de la méthode :"
CUR=$(head -n 1 "$REPO/VERSION" 2>/dev/null | tr -d '[:space:]')
PRJ=$(sed -n 's/^version_methode:[[:space:]]*//p' "$TARGET/PROJECT.md" | head -n 1 | tr -d '[:space:]')
if [ -z "$CUR" ]; then
    warn "version courante introuvable ($REPO/VERSION absent)"
elif [ -z "$PRJ" ] || [ "$PRJ" = "<VERSION>" ]; then
    warn "projet sans empreinte de version (créé avant le versionnement) ; version courante v$CUR"
else
    case "$(ver_cmp "$PRJ" "$CUR")" in
        eq) ok "suit MyProjectOS v$PRJ (version courante)" ;;
        lt) warn "suit MyProjectOS v$PRJ, version courante v$CUR : voir les changements dans le CHANGELOG de la méthode" ;;
        gt) warn "déclare v$PRJ, plus récent que la version installée v$CUR : mets à jour MyProjectOS" ;;
    esac
fi

# --- 1. Fichiers sacrés Core -------------------------------------------------
echo "Fichiers sacrés Core :"
for f in PROJECT PROGRESS CHANGELOG TASKS DECISIONS; do
    if [ -f "$TARGET/$f.md" ]; then ok "$f.md"; else fail "$f.md manquant"; fi
done

# --- 1bis. Socle agent (AGENTS.md/CLAUDE.md), tous types ---------------------
# Posés par init-project.sh pour Core/Life/Code/Hybrid (DEC-0019) : garantissent
# que Codex et Hermès Agent (qui ne lisent pas la config Claude Code) trouvent
# des instructions à la racine. Pas des fichiers sacrés (pas de registre), donc
# avertissement plutôt que blocage.
echo "Socle agent (AGENTS.md/CLAUDE.md) :"
for f in AGENTS.md CLAUDE.md; do
    if [ -f "$TARGET/$f" ]; then ok "$f"; else warn "$f manquant : Codex et Hermès Agent n'auront aucune instruction à la racine"; fi
done

# --- 2. Extensions selon le type ---------------------------------------------
case "$TYPE" in
    *Life*|*Hybrid*)
        echo "Extension Life :"
        for f in PREUVES ECHEANCES CORRESPONDANCES; do
            if [ -f "$TARGET/$f.md" ]; then ok "$f.md"; else fail "$f.md manquant (type $TYPE)"; fi
        done
        ;;
esac
case "$TYPE" in
    *Code*|*Hybrid*)
        echo "Extension Code :"
        for f in CONSTITUTION STACK_VALIDATION ARCHITECTURE SPECS TEST_PLAN IMPACT_ANALYSIS RELEASE; do
            if [ -f "$TARGET/$f.md" ]; then ok "$f.md"; else fail "$f.md manquant (type $TYPE)"; fi
        done
        ;;
esac
if [ -f "$TARGET/docs/INDEX.md" ]; then
    echo "Extension Knowledge :"
    for f in docs/INDEX.md docs/kb_governance.md; do
        if [ -f "$TARGET/$f" ]; then ok "$f"; else warn "$f manquant alors que Knowledge semble actif"; fi
    done
    if [ -f "$TARGET/SUJETS.md" ]; then
        if grep -q '<sujet-canonique>' "$TARGET/SUJETS.md" 2>/dev/null; then
            warn "SUJETS.md présent mais resté en gabarit (<sujet-canonique>) : le remplir ou le retirer"
        else
            ok "SUJETS.md (routeur métier)"
        fi
    else
        warn "SUJETS.md absent : recommandé pour router les demandes métier (alias -> sujet -> source fraîche)"
    fi
fi

# --- 3. Fraîcheur de PROGRESS.md ---------------------------------------------
echo "Fraîcheur :"
if [ -f "$TARGET/PROGRESS.md" ]; then
    MAJ=$(sed -n 's/^derniere_maj:[[:space:]]*//p' "$TARGET/PROGRESS.md" | head -n 1)
    if [ -z "$MAJ" ] || [ "$MAJ" = "YYYY-MM-DD" ]; then
        warn "PROGRESS.md : champ derniere_maj absent ou non renseigné"
    else
        TS=""
        if date -j -f "%Y-%m-%d" "$MAJ" +%s >/dev/null 2>&1; then
            TS=$(date -j -f "%Y-%m-%d" "$MAJ" +%s)        # BSD / macOS
        elif date -d "$MAJ" +%s >/dev/null 2>&1; then
            TS=$(date -d "$MAJ" +%s)                       # GNU / Linux
        fi
        if [ -z "$TS" ]; then
            warn "PROGRESS.md : derniere_maj='$MAJ' illisible (format attendu YYYY-MM-DD)"
        else
            AGE=$(( ( $(date +%s) - TS ) / 86400 ))
            if [ "$AGE" -lt 0 ]; then
                warn "PROGRESS.md : derniere_maj='$MAJ' est dans le futur"
            elif [ "$AGE" -gt "$STALE_DAYS" ]; then
                warn "PROGRESS.md non mis à jour depuis $AGE jours (seuil $STALE_DAYS)"
            else
                ok "PROGRESS.md à jour ($AGE j)"
            fi
        fi
    fi
fi

# --- 4. Placeholders résiduels -----------------------------------------------
echo "Substitution des gabarits :"
# NB : $EXCLUDES après --include (BSD grep applique la dernière option qui matche).
# shellcheck disable=SC2086 # EXCLUDES volontairement éclaté en mots
PH=$(grep -rl "<NomDuProjet>" "$TARGET" --include="*.md" $EXCLUDES 2>/dev/null)
if [ -n "$PH" ]; then
    # Boucle sans pipe : le compteur WARNS doit s'incrémenter dans le shell courant.
    while IFS= read -r p; do
        [ -n "$p" ] || continue
        warn "placeholder <NomDuProjet> dans ${p#"$TARGET"/}"
    done <<EOF_PH
$PH
EOF_PH
else
    ok "aucun <NomDuProjet> résiduel"
fi

# --- 5. Références croisées DEC- / CHG- --------------------------------------
echo "Références croisées :"
check_refs() {
    # check_refs <regex-id> <fichier-registre> <motif-définition>
    _re=$1; _reg=$2; _defprefix=$3
    [ -f "$TARGET/$_reg" ] || { warn "$_reg absent : références non vérifiables"; return; }
    _defined=$(grep -hoE "$_re" "$TARGET/$_reg" 2>/dev/null | sort -u)
    # shellcheck disable=SC2086
    _cited=$(grep -rhoE "$_re" "$TARGET" --include="*.md" $EXCLUDES 2>/dev/null | sort -u)
    _missing=0
    for id in $_cited; do
        if ! printf '%s\n' "$_defined" | grep -qx "$id"; then
            warn "$id cité mais non défini dans $_reg"
            _missing=1
        fi
    done
    [ "$_missing" -eq 0 ] && ok "toutes les références $_defprefix pointent vers une entrée existante"
}
check_refs 'DEC-[0-9]{4}' DECISIONS.md DEC-
check_refs 'CHG-[0-9]{8}-[0-9]{4}' CHANGELOG.md CHG-

# --- 6. Format de date (convention YYYY-MM-DD) -------------------------------
echo "Format de date :"
_bad_date=0

# 6a. Champs de frontmatter datés : doivent être en YYYY-MM-DD.
for pair in "PROJECT.md:cree_le" "PROGRESS.md:derniere_maj" "PROGRESS.md:cree_le"; do
    _file=${pair%%:*}; _field=${pair#*:}
    [ -f "$TARGET/$_file" ] || continue
    _val=$(sed -n "s/^$_field:[[:space:]]*//p" "$TARGET/$_file" | head -n 1 | tr -d '[:space:]')
    [ -n "$_val" ] || continue
    case "$_val" in
        [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]|YYYY-MM-DD) : ;;
        *) warn "$_file : champ $_field='$_val' n'est pas au format YYYY-MM-DD"; _bad_date=1 ;;
    esac
done

# 6b. Dates JJ/MM/AAAA dans le contenu (format français).
# shellcheck disable=SC2086
_slash_n=$(grep -rhoE '[0-9]{1,2}/[0-9]{1,2}/20[0-9]{2}' "$TARGET" --include='*.md' $EXCLUDES 2>/dev/null | wc -l | tr -d ' ')
if [ "${_slash_n:-0}" -gt 0 ]; then
    warn "$_slash_n date(s) au format JJ/MM/AAAA (attendu YYYY-MM-DD), ex :"
    # shellcheck disable=SC2086
    grep -rnE '[0-9]{1,2}/[0-9]{1,2}/20[0-9]{2}' "$TARGET" --include='*.md' $EXCLUDES 2>/dev/null | head -n 3 |
        while IFS= read -r _l; do printf '           %s\n' "${_l#"$TARGET"/}"; done
    _bad_date=1
fi

# 6c. Mois en toutes lettres (français).
_mois='janvier|février|fevrier|mars|avril|mai|juin|juillet|août|aout|septembre|octobre|novembre|décembre|decembre'
# shellcheck disable=SC2086
_lit_n=$(grep -rhniE "[0-9]{1,2} ($_mois) 20[0-9]{2}" "$TARGET" --include='*.md' $EXCLUDES 2>/dev/null | wc -l | tr -d ' ')
if [ "${_lit_n:-0}" -gt 0 ]; then
    warn "$_lit_n date(s) en toutes lettres (mois en français), à passer en YYYY-MM-DD"
    _bad_date=1
fi

[ "$_bad_date" -eq 0 ] && ok "dates au format YYYY-MM-DD"

# --- 7. Taille des fichiers de contexte agent (limite de troncature Hermès) --
# Hermès Agent (Nous Research) charge AGENTS.md/CLAUDE.md/.hermes.md/SOUL.md/
# .cursorrules dans son prompt système, tronqués par défaut à 20 000 caractères
# (context_file_max_chars). Un fichier tronqué prive Hermès d'instructions en
# usage mobile, sans historique de conversation pour compenser. Voir DEC-0020.
echo "Taille des fichiers de contexte agent (limite Hermès) :"
HERMES_MAX_CHARS=20000
for f in AGENTS.md CLAUDE.md .hermes.md SOUL.md .cursorrules; do
    [ -f "$TARGET/$f" ] || continue
    _size=$(wc -c < "$TARGET/$f" | tr -d ' ')
    if [ "$_size" -gt "$HERMES_MAX_CHARS" ]; then
        warn "$f : $_size caractères (> $HERMES_MAX_CHARS) : Hermès Agent le tronque par défaut (context_file_max_chars)"
    else
        ok "$f : $_size caractères (sous la limite Hermès de $HERMES_MAX_CHARS)"
    fi
done

# --- 8. Navigation Knowledge : orphelins, liens cassés, budgets de taille -----
# Seuils indicatifs documentés dans kb_governance.md : niveau 1 <= 200 lignes,
# niveau 2 <= 300 lignes. Avertissements uniquement, jamais bloquant.
if [ -f "$TARGET/docs/INDEX.md" ]; then
    echo "Navigation Knowledge :"
    _kb_issue=0

    # 8a. Orphelins : document présent sur disque mais absent de docs/INDEX.md.
    for _dir in 01_global 02_domains 03_details runbooks; do
        [ -d "$TARGET/docs/$_dir" ] || continue
        for _f in "$TARGET/docs/$_dir"/*.md "$TARGET/docs/$_dir"/*/*.md; do
            [ -f "$_f" ] || continue
            _rel=${_f#"$TARGET"/docs/}
            if ! grep -qF "$_rel" "$TARGET/docs/INDEX.md" 2>/dev/null; then
                warn "docs/$_rel absent de docs/INDEX.md (document orphelin)"
                _kb_issue=1
            fi
        done
    done

    # 8b. Liens cassés : chemin cité dans docs/INDEX.md mais introuvable sur disque.
    _cited_paths=$(grep -oE '(0[123]_[a-z]+|runbooks|plan)/[A-Za-z0-9._/-]+\.md' "$TARGET/docs/INDEX.md" 2>/dev/null | sort -u)
    if [ -n "$_cited_paths" ]; then
        while IFS= read -r _p; do
            [ -n "$_p" ] || continue
            if [ ! -f "$TARGET/docs/$_p" ]; then
                warn "docs/INDEX.md cite docs/$_p qui n'existe pas (lien cassé)"
                _kb_issue=1
            fi
        done <<EOF_KBLINKS
$_cited_paths
EOF_KBLINKS
    fi

    # 8c. Budgets de taille par niveau.
    for _f in "$TARGET/docs/01_global"/*.md; do
        [ -f "$_f" ] || continue
        _n=$(wc -l < "$_f" | tr -d ' ')
        if [ "$_n" -gt 200 ]; then
            warn "${_f#"$TARGET"/} : $_n lignes (> 200) : envisager de scinder vers le niveau 2"
            _kb_issue=1
        fi
    done
    for _f in "$TARGET/docs/02_domains"/*.md "$TARGET/docs/02_domains"/*/*.md; do
        [ -f "$_f" ] || continue
        _n=$(wc -l < "$_f" | tr -d ' ')
        if [ "$_n" -gt 300 ]; then
            warn "${_f#"$TARGET"/} : $_n lignes (> 300) : envisager de scinder vers le niveau 3"
            _kb_issue=1
        fi
    done

    [ "$_kb_issue" -eq 0 ] && ok "index aligné avec le disque, budgets de taille respectés"
fi

# --- 9. Dossiers racine : quasi-doublons et collisions de préfixe -------------
# RETEX LaCIOTAT (2026-07-09) : 99_archives/ a vécu deux jours à côté de
# 99_archive/ sans qu'aucun contrôle ne s'en aperçoive. On compare les dossiers
# de premier niveau après normalisation (norm_dirname). Pas de liste blanche :
# les projets étendent légitimement le canon. Avertissement, jamais bloquant.
echo "Dossiers racine :"
_root_issue=0
_root_pairs=""
for _d in "$TARGET"/*/; do
    [ -d "$_d" ] || continue
    _name=$(basename -- "$_d")
    case "$_name" in .*) continue ;; esac
    _root_pairs="${_root_pairs}$(norm_dirname "$_name")|${_name}
"
done

# 9a. Quasi-doublons : deux dossiers dont le nom normalisé est identique.
_dup_lines=$(printf '%s' "$_root_pairs" | sort |
    awk -F'|' 'BEGIN { p = ""; pn = "" } $1 != "" && $1 == p { print pn " / " $2 } { p = $1; pn = $2 }')
if [ -n "$_dup_lines" ]; then
    while IFS= read -r _l; do
        [ -n "$_l" ] || continue
        warn "dossiers racine quasi-doublons : $_l (noms équivalents après normalisation) : fusionner vers le nom canonique"
        _root_issue=1
    done <<EOF_ROOTDUP
$_dup_lines
EOF_ROOTDUP
fi

# 9b. Même préfixe numérique NN_ sur deux dossiers distincts : casse l'ordre
# de lecture, raison d'être du préfixe. (Les quasi-doublons du 9a sont exclus.)
_pref_lines=$(printf '%s' "$_root_pairs" |
    awk -F'|' '$2 ~ /^[0-9][0-9]_/ { print substr($2, 1, 2) "|" $1 "|" $2 }' | sort |
    awk -F'|' 'BEGIN { p = ""; pn = "" } ($1 "" == p "") && $2 != pn { print pd " / " $3 } { p = $1; pn = $2; pd = $3 }')
if [ -n "$_pref_lines" ]; then
    while IFS= read -r _l; do
        [ -n "$_l" ] || continue
        warn "dossiers racine avec le même préfixe numérique : $_l : renuméroter l'un des deux"
        _root_issue=1
    done <<EOF_ROOTPREF
$_pref_lines
EOF_ROOTPREF
fi

[ "$_root_issue" -eq 0 ] && ok "aucun quasi-doublon ni collision de préfixe parmi les dossiers de premier niveau"

# --- Bilan -------------------------------------------------------------------
echo ""
if [ "$FAILS" -eq 0 ] && [ "$WARNS" -eq 0 ]; then
    echo "Bilan : cohérent, aucun problème détecté."
    exit 0
fi
echo "Bilan : $FAILS bloquant(s), $WARNS avertissement(s)."
[ "$FAILS" -gt 0 ] && exit 1
exit 0
