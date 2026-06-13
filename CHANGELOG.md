# CHANGELOG.md — Project OS AI

> Registre daté de ce qui a changé. Historique utile, pas seulement technique.
> Chaque entrée porte un identifiant `CHG-AAAAMMJJ-HHMM` et reste figée une fois écrite.
> Frontière : l'état actuel vit dans `PROGRESS.md` ; le pourquoi des choix structurants dans `DECISIONS.md`.
> Quand le fichier devient long, archiver les entrées anciennes dans `99_archive/CHANGELOG-AAAA.md`.

## Format d'une entrée

```
### CHG-AAAAMMJJ-HHMM — Titre court
- Ce qui a changé, factuel.
- Lien éventuel vers une décision : voir DEC-XXXX.
```

---

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
