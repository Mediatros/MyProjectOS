# CHANGELOG.md — MyProjectOS

> Registre daté de ce qui a changé. Historique utile, pas seulement technique.
> Chaque entrée porte un identifiant `CHG-YYYYMMDD-HHMM` et reste figée une fois écrite.
> Frontière : l'état actuel vit dans `PROGRESS.md` ; le pourquoi des choix structurants dans `DECISIONS.md`.
> Quand le fichier devient long, archiver les entrées anciennes dans `99_archive/CHANGELOG-YYYY.md`.

## Format d'une entrée

```
### CHG-YYYYMMDD-HHMM — Titre court
- Ce qui a changé, factuel.
- Lien éventuel vers une décision : voir DEC-XXXX.
```

## Releases

La version courante de la méthode est dans `VERSION`. Politique et procédure : `docs/versioning.md`.

- **v0.2.0** — 2026-06-14 — le check vérifie désormais la conformité de contenu, pas seulement l'empreinte déclarée : `check-project.sh` détecte les dates au format français (`JJ/MM/AAAA`, mois en toutes lettres) et les champs datés du frontmatter hors `YYYY-MM-DD`. Permet de repérer un projet bâti sur l'ancienne convention de date.
- **v0.1.0** — 2026-06-14 — première version numérotée de la méthode. Regroupe le socle Core, les extensions Life / Code / Knowledge, la skill assistant, les hooks d'enforcement, l'intégration Harness, les outils de cohérence (`check-project.sh`, `build-index.sh`) et l'introduction du versionnement lui-même (fichier `VERSION`, empreinte `version_methode` dans `PROJECT.md`, check d'alignement).

---

### CHG-20260702-1851 — Phase A de l'industrialisation : installation réelle par un agent

- Audit complet du repository (2026-07-02) : plan en 3 phases dans `PLAN/plans/2026-07-02-audit-industrialisation-methode.md`, transposé en `T-A.x`/`T-B.x`/`T-C.x` dans `TASKS.md`.
- T-A.1 : `install.sh` (clone jetable, projet final autonome), `init-project.sh --into-existing`/`--sync`, `README.md` committés. `anatomy.md` gitignoré (généré par le hook Stop) ; workdoc Hermès du 2026-06-03 déplacé de `docs/` vers `PLAN/`.
- T-A.3 : `LICENSE` MIT ajoutée. Voir DEC-0018.
- T-A.4 : `init-project.sh` installe la skill assistant dans `.claude/skills/my-project-os/` à la création du projet.
- T-A.5 : `AGENTS.md`/`CLAUDE.md` posés pour tous les types (Core/Life/Code/Hybrid) ; l'extension Code fusionne une section dans le même fichier au lieu de le remplacer. Voir DEC-0019.
- T-A.6 : `scripts/check-project.sh` + une empreinte `VERSION` figée sont copiés dans le projet cible, qui reste auto-vérifiable sans dépendre du repo méthode.
- T-A.7 : mise en conformité du repo méthode avec sa propre gouvernance — `PROJECT.md` racine créé, `PROGRESS.md` dégraissé (historique renvoyé vers ce fichier et `DECISIONS.md`), `docs/enforcement.md` et `docs/lifecycle.md` réalignés sur le comportement réel des scripts (hooks copiés localement, fusion JSON, sections du check).
- Voir aussi DEC-0017 (le dépôt GitHub reste privé pour l'instant, publication reportée).

### CHG-20260614-2100 — Contrôle du format de date dans le check

- `scripts/check-project.sh` gagne une section « Format de date » : avertit (sans bloquer) sur les dates `JJ/MM/AAAA`, les mois en toutes lettres en français, et les champs `cree_le`/`derniere_maj` qui ne sont pas en `YYYY-MM-DD`.
- Motivation : l'empreinte `version_methode` est déclarative ; la conformité de contenu, elle, se détecte. Le check repère maintenant concrètement un projet resté sur l'ancienne notation de date.
- Version de la méthode portée à `0.2.0` (évolution mineure). Voir DEC-0016.

### CHG-20260614-0312 — Versionnement de la méthode

- Introduction d'une notion de version de la méthode : fichier `VERSION` à la racine (source de vérité unique, `0.1.0`) et politique `MAJEUR.MINEUR.CORRECTIF` documentée dans `docs/versioning.md` (avec définition d'une release).
- Empreinte dans chaque projet : champ `version_methode` ajouté au frontmatter de `templates/core/PROJECT.md` (remplace `methode: my-project-os v1`), estampillé à la création par `scripts/init-project.sh` depuis `VERSION`.
- Check d'alignement : `scripts/check-project.sh` compare l'empreinte du projet à la version courante et signale « à jour / en retard / sans empreinte ». Comparateur de versions portable ajouté.
- Voir DEC-0015.

### CHG-20260614-0240 — Index global multi-projets `build-index.sh`

- Ajout de `scripts/build-index.sh` : régénère un `INDEX.md` à la racine du dossier de projets à partir du frontmatter des `PROGRESS.md` (vue d'ensemble : type, statut, dernière maj, prochaine action, échéance), trié par date.
- Documenté dans `docs/governance.md` (section « Index global multi-projets »). Réalise la proposition #5 de `PLAN/PLAN_PROPOSITION_AMELIORATION.md`.

### CHG-20260614-0233 — Script de validation `check-project.sh`

- Ajout de `scripts/check-project.sh` : contrôle à la demande d'un projet (fichiers sacrés selon le type, fraîcheur de PROGRESS, placeholders résiduels, références `DEC-`/`CHG-` cassées). Informe sans bloquer, code de sortie 1 si bloquant.
- Documenté dans `docs/enforcement.md` (section « Vérification à la demande »). Réalise la proposition #9 de `PLAN/PLAN_PROPOSITION_AMELIORATION.md`.

### CHG-20260613-2253 — Mise en conformité dogfooding : CHANGELOG et DECISIONS à la racine

- Création des deux fichiers sacrés manquants à la racine du repo : `CHANGELOG.md` et `DECISIONS.md`, conformément à la gouvernance de la méthode.
- Migration des 13 décisions de la section « Décisions actées » de `PROGRESS.md` vers `DECISIONS.md` (DEC-0002 à DEC-0014, format complet). `PROGRESS.md` ne garde que l'état courant et renvoie vers `DECISIONS.md` et `CHANGELOG.md`.
- Voir DEC-0005 (frontière entre les fichiers sacrés).

### CHG-20260613-2226 — Alignement des traces sur `templates/extensions/`

- Mise à jour des chemins dans les fichiers de suivi et de plan qui pointaient encore vers les anciens emplacements : `PROGRESS.md`, `TASKS.md`, `PLAN/PLAN_PROJECT_OS_AI.md`, `PLAN/plans/2026-06-07-company-os-integration.md`, `docs/plan-integration-extension-knowledge.md`.
- Le handoff `PLAN/handoff-2026-06-13-renommage-templates-extensions.md` est volontairement laissé intact : il cite les anciens chemins pour expliquer la migration.
- Voir DEC-0001.

### CHG-20260613-2055 — Regroupement des extensions sous `templates/extensions/`

- Déplacement des trois dossiers d'extension de `templates/{life,code,knowledge}/` vers `templates/extensions/{life,code,knowledge}/` (`git mv`, historique préservé). `templates/core/` reste le socle.
- `scripts/init-project.sh` : trois chemins mis à jour, validé `sh -n` + test de bout en bout (`--code --knowledge`).
- Docs de référence vivantes alignées : `README.md`, `CLAUDE.md`, `docs/governance.md`, `docs/clarify.md`, `docs/harness.md`.
- Voir DEC-0001.
