# CHANGELOG.md — Project OS AI

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

- **v0.1.0** — 2026-06-14 — première version numérotée de la méthode. Regroupe le socle Core, les extensions Life / Code / Knowledge, la skill assistant, les hooks d'enforcement, l'intégration Harness, les outils de cohérence (`check-project.sh`, `build-index.sh`) et l'introduction du versionnement lui-même (fichier `VERSION`, empreinte `version_methode` dans `PROJECT.md`, check d'alignement).

---

### CHG-20260614-0312 — Versionnement de la méthode

- Introduction d'une notion de version de la méthode : fichier `VERSION` à la racine (source de vérité unique, `0.1.0`) et politique `MAJEUR.MINEUR.CORRECTIF` documentée dans `docs/versioning.md` (avec définition d'une release).
- Empreinte dans chaque projet : champ `version_methode` ajouté au frontmatter de `templates/core/PROJECT.md` (remplace `methode: project-os v1`), estampillé à la création par `scripts/init-project.sh` depuis `VERSION`.
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
