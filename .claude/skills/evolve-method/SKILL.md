---
name: evolve-method
description: Faire évoluer la méthode MyProjectOS elle-même — gate décisionnel DEC/CHG/Release, bump de VERSION, propagation d'un changement vers templates/structures/scripts/skill/docs, piège de la non-propagation des hooks (DEC-0017), traitement des RETEX et de la veille upstream. À charger pour toute modification du dépôt MyProjectOS : templates, scripts, docs, versioning, intégration d'une proposition, ou question « où consigner cette décision ».
---

# Faire évoluer la méthode — MyProjectOS

Ce dépôt EST la méthode : toute modification ici change le comportement attendu de tous les futurs projets générés. On ne « patch » pas, on légifère.

## Quand NE PAS utiliser cette skill

- Piloter un PROJET organisé avec la méthode (reprise à froid, état, clôture) → skill globale `my-project-os` (déjà installée).
- Ajouter/modifier concrètement un template ou une extension → skill `add-extension` (le runbook pas-à-pas).
- Vérifier que rien n'est cassé après modification → skill `validate`.

## Gate décisionnel avant toute modification

1. Le changement est-il structurant ? → entrée `DEC-XXXX` dans `DECISIONS.md` (contexte, options, choix, raison, conséquences), reliée aux `CHG-`.
2. Dans tous les cas → entrée `CHG-YYYYMMDD-HHMM` dans `CHANGELOG.md`.
3. Nouvelle capacité ou rupture ? → bump de `VERSION` (SemVer simplifié, politique complète dans `docs/versioning.md`) + ligne dans la section « Releases » du CHANGELOG + tag `vX.Y.Z` au commit (sur demande explicite uniquement). ⚠️ `docs/governance.md` §Versioning décrit encore l'ancien schéma « v1, v2 » antérieur à DEC-0015 [verified: executed grep 2026-07-07] : divergence à aligner via ce gate.
4. `PROGRESS.md` : mettre à jour l'état ET le frontmatter (règle immuable : toute maj de PROGRESS met à jour le bloc d'en-tête).

Version courante : 0.6.0 [verified: executed cat VERSION 2026-07-09]. Ne jamais committer sans demande explicite.

## Checklist de propagation d'un changement de méthode

Un changement de règle ou de gabarit doit être reporté PARTOUT où il vit, sinon la méthode diverge d'elle-même :

- [ ] `templates/core/` ou `templates/extensions/<x>/` (les gabarits)
- [ ] `structures/<x>-tree.md` (la description de l'arborescence)
- [ ] `scripts/init-project.sh` (le câblage de génération)
- [ ] `scripts/check-project.sh` (le contrôle correspondant, si vérifiable — cf. DEC-0016 : un versionnement sans détection concrète est creux)
- [ ] `skills/my-project-os/SKILL.md` (la skill assistant distribuée)
- [ ] `docs/` (governance, lifecycle, versioning… selon le sujet)
- [ ] Dogfooding : les fichiers RÉELS du dépôt (PROGRESS, CHANGELOG, DECISIONS à la racine) respectent la nouvelle règle

Puis dérouler la skill `validate` (génération de test + check).

## ⚠️ Piège DEC-0025 : les hooks ne se propagent plus

Depuis v0.3.0, `init-project.sh` COPIE `_lib.sh`, `hook-pre-write.sh`, `hook-stop-progress.sh` dans `.claude/hooks/` de chaque projet créé (isolation voulue : un projet Life avec données sensibles ne doit pas changer de comportement depuis l'extérieur).

Conséquences opérationnelles :
- Corriger un bug de hook dans `scripts/hooks/` ne répare AUCUN projet existant → recopier projet par projet, ou `--update-method` (v0.5.0), décision humaine.
- Les projets créés AVANT v0.3.0 gardent l'ANCIEN câblage (référence à distance vers `MyProjectOS/scripts/hooks/`) : toute modification de ces scripts les affecte SILENCIEUSEMENT tant qu'ils ne sont pas migrés. Liste des projets concernés (volatile) : DEC-0025 dans DECISIONS.md, qui fait foi. Vérifier avant de toucher `scripts/hooks/*`. [read: from DECISIONS.md DEC-0025]

## Décisions déjà tranchées (ne pas re-litiguer, détail dans DECISIONS.md)

DEC-0012 (Harness = colonne vertébrale Code, emprunts Spec Kit FIGÉS en Markdown), DEC-0011 (Knowledge = brique transverse, pas un type), DEC-0009 (gate STACK_VALIDATION avant tout code), DEC-0005 (frontières PROGRESS/CHANGELOG/DECISIONS), DEC-0002 (dossiers numérotés à la demande), DEC-0001 (templates/ = nature, core/ vs extensions/ = rôle). Proposer de revenir dessus exige une nouvelle DEC- avec un contexte qui a changé.

## Entrées d'évolution (backlog vivant)

- **RETEX** : `RETEX/retex-projet-comptabilite.md` (dogfood Life+Knowledge) au format « problème → correction locale → évolution générique à intégrer ». Ses 4 sections « Évolution générique attendue » sont un backlog non traité. Tout nouveau RETEX suit ce format.
- **Veille upstream** (DEC-0013) : routine cloud `veille-outils-upstream` (cron `0 8 1 * *`) écrit `docs/veille/VEILLE-OUTILS.md` avec verdict à intégrer / à surveiller / à ignorer. Elle PROPOSE, n'intègre jamais seule ; l'intégration passe par le gate ci-dessus. Consigne : `docs/veille/_consigne.md`.
- **Zone PLAN/** : plans d'évolution isolés avant intégration (dont Company OS, en attente de validation utilisateur). Ne pas confondre avec `docs/` (stable). [read: from PLAN/README.md]

## Chantier ouvert prioritaire

La méthode n'a jamais été validée sur un vrai projet Code : banc d'essai Unjque (phase 6 de TASKS.md), bloqué derrière la validation du plan Company OS. Le passage à `1.0.0` dépend de ce cap (DEC-0015). [read: from PROGRESS.md, DECISIONS.md]

## Provenance et maintenance

Rédigé le 2026-07-07 par audit complet du dépôt. Volatile : VERSION, liste des projets à l'ancien câblage. Re-vérifications :
- `cat VERSION && git status --short`
- `grep -n "v0\." CHANGELOG.md | head -5` (releases)
- `grep -rn "Évolution générique attendue" RETEX/ | wc -l` (backlog RETEX)
