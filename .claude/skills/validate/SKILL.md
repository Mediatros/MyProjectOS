---
name: validate
description: Vérifier par exécution que MyProjectOS n'est pas cassé — syntaxe des scripts sh, génération d'un projet de test avec chaque combinaison de flags, check-project.sh et lecture de son verdict, résidus de substitution, comportement attendu des hooks d'enforcement. À charger après toute modification de scripts/ ou templates/, avant de déclarer un changement terminé, ou pour diagnostiquer un init-project/check-project qui se comporte mal.
---

# Valider MyProjectOS par exécution

Règle de la maison : rien n'est « fait » sans commande exécutée et sortie observée.

## Quand NE PAS utiliser cette skill

- Décider et consigner un changement → skill `evolve-method`.
- Le runbook complet d'ajout de template → skill `add-extension` (qui appelle cette skill en étape finale).

## Batterie de vérification

Depuis la racine du dépôt (`sh` obligatoire, les scripts ne sont pas exécutables [verified: executed]) :

```bash
# 1. Syntaxe de tous les scripts
for s in scripts/*.sh scripts/hooks/*.sh; do sh -n "$s" && echo "OK $s"; done
# Attendu : OK sur les 8 scripts (5 scripts/ dont ajout-secret.sh depuis v0.13.0 + 3 hooks).
# [verified: executed 2026-07-13]

# 2. Génération de test — répéter pour chaque combinaison touchée
sh scripts/init-project.sh /tmp/T-core                      # Core seul
sh scripts/init-project.sh /tmp/T-life --life               # Life
sh scripts/init-project.sh /tmp/T-full --life --code --knowledge  # Hybrid complet

# 3. Contrôle de cohérence
sh scripts/check-project.sh /tmp/T-full
# Attendu (dernière ligne) : « Bilan : 0 bloquant(s), 1 avertissement(s). »
# L'avertissement attendu est le rappel DEC-0024 « SUJETS.md resté en gabarit »,
# normal sur un projet frais généré avec --knowledge.
# Sortie : [ok] / [!] avertissement / [X] bloquant. [verified: executed 2026-07-09]

# 4. Résidus de substitution — --include="*.md" obligatoire : depuis v0.5.0 le projet
# embarque check-project.sh, dont le code contient le motif (faux ÉCHEC sinon).
grep -rn --include="*.md" "<NomDuProjet>" /tmp/T-full && echo "ÉCHEC" || echo "OK substitution"  # [verified: executed 2026-07-09]

# 5. Empreinte de version posée
grep "version_methode" /tmp/T-full/PROJECT.md   # attendu : la valeur de VERSION

# 6. Isolation des hooks (post-DEC-0025)
ls /tmp/T-full/.claude/hooks/   # attendu : _lib.sh, hook-pre-write.sh, hook-stop-progress.sh
grep -n "MyProjectOS" /tmp/T-full/.claude/settings.json && echo "ÉCHEC isolation" || echo "OK isolation"

# 7. Nettoyage — UNIQUEMENT les dossiers de test créés par cette batterie.
# Toute autre suppression exige la confirmation de l'utilisateur (règle globale).
rm -rf /tmp/T-core /tmp/T-life /tmp/T-full
```

Ce qu'a produit la génération vérifiée du 2026-07-09 (Life+Code+Knowledge) : 5 fichiers sacrés Core + `AGENTS.md`/`CLAUDE.md`, extension Life (PREUVES, ECHEANCES, CORRESPONDANCES), extension Code (CONSTITUTION, STACK_VALIDATION, ARCHITECTURE, SPECS, TEST_PLAN, IMPACT_ANALYSIS, RELEASE), Knowledge (docs/INDEX.md, docs/kb_governance.md, SUJETS.md), `.claude/hooks/` en copie locale, `.claude/settings.json` câblé, `check-project.sh` + empreinte `VERSION` embarqués. check-project : 0 bloquant, 1 avertissement attendu (SUJETS.md en gabarit, DEC-0024). [verified: executed]

## Comportement attendu des hooks d'enforcement (référence : docs/enforcement.md)

| Hook | Événement | Comportement |
|---|---|---|
| `hook-pre-write.sh` | PreToolUse Write | BLOQUE : nom de fichier avec espaces/accents ; document posé à la racine ; dossier racine quasi-doublon/collision de préfixe `NN_`. AVERTIT (systemMessage, non bloquant) depuis DEC-0032 : nouveau `.md` à la racine d'un projet Life/Hybrid portant le compte de fichiers thématiques à 5+ sans `02_sujets/` [verified: executed 2026-07-14] |
| `hook-stop-progress.sh` | Stop | AVERTIT (systemMessage, non bloquant) si PROGRESS.md pas fraîche ; détecte aussi sans git (dates de fichiers) depuis CHG-20260709-0017 |

sh POSIX, dégradation silencieuse si `python3`/`jq` absents (DEC-0008). Tester un hook = lui passer le JSON d'événement sur stdin et observer exit code + stdout. [read: from docs/enforcement.md, DECISIONS.md]

## Outil complémentaire

`sh scripts/build-index.sh` : index global multi-projets. [inferred: unconfirmed — non exécuté le 2026-07-07 ; vérifier son usage dans son en-tête avant de s'en servir]

## Provenance et maintenance

Rédigé le 2026-07-07 par audit complet du dépôt. La batterie ci-dessus EST la re-vérification ; si une sortie attendue change légitimement, mettre à jour cette skill dans le même changement (gate `evolve-method`).
