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

- **v0.5.0** — 2026-07-07 — la méthode se met à jour dans les projets existants : manifest d'artefacts (`.myprojectos/manifest`), détection distante (`check-update.sh`), application sécurisée (`init-project.sh --update-method` avec sauvegarde dans `99_archive/`). Cycle de travail itératif codifié (`docs/cycle-de-travail.md`), skill assistant portée à 7 modes (cadrage guidé, adoption d'un projet existant, mise à jour), protocole agent `docs/INSTALL-AGENT.md`, intégration du RETEX comptabilité (`SUJETS.md`, source fraîche prioritaire), navigation Knowledge outillée (orphelins, liens cassés, budgets de taille), exemples complets Life et Code, CI GitHub Actions, corrections de fiabilité. Voir CHG-20260707-1100.
- **v0.4.0** — 2026-07-04 — `check-project.sh` vérifie désormais `AGENTS.md`/`CLAUDE.md` pour tous les types de projet (plus seulement Code/Hybrid) et avertit si un fichier de contexte agent (`AGENTS.md`, `CLAUDE.md`, `.hermes.md`, `SOUL.md`, `.cursorrules`) dépasse 20 000 caractères, seuil de troncature par défaut d'Hermès Agent. Voir CHG-20260704-1200.
- **v0.3.0** — 2026-07-02 — Phase A du plan d'industrialisation (installation réelle par un agent) : `install.sh` en une commande, `init-project.sh --into-existing`/`--sync`, skill assistant installée à la création, `AGENTS.md`/`CLAUDE.md` posés pour tous les types (l'extension Code fusionne une section au lieu d'écraser), projet créé auto-vérifiable (`check-project.sh` + `VERSION` figée copiés), `LICENSE` MIT, repo méthode remis en conformité avec sa propre gouvernance. Voir CHG-20260702-1851.
- **v0.2.0** — 2026-06-14 — le check vérifie désormais la conformité de contenu, pas seulement l'empreinte déclarée : `check-project.sh` détecte les dates au format français (`JJ/MM/AAAA`, mois en toutes lettres) et les champs datés du frontmatter hors `YYYY-MM-DD`. Permet de repérer un projet bâti sur l'ancienne convention de date.
- **v0.1.0** — 2026-06-14 — première version numérotée de la méthode. Regroupe le socle Core, les extensions Life / Code / Knowledge, la skill assistant, les hooks d'enforcement, l'intégration Harness, les outils de cohérence (`check-project.sh`, `build-index.sh`) et l'introduction du versionnement lui-même (fichier `VERSION`, empreinte `version_methode` dans `PROJECT.md`, check d'alignement).

---

### CHG-20260707-1100 — v0.5.0 : mise à jour de la méthode, cadrage, cycle itératif, qualité production

- Application du plan `PLAN/plans/2026-07-06-plan-amelioration-production-ready.md` (phases D/E/F/G), conception pour dépôt public actée (DEC-0021).
- **Mise à jour de la méthode** (DEC-0022) : manifest `.myprojectos/manifest` posé dans chaque projet (frontière artefacts méthode / contenu) ; `scripts/check-update.sh` copié dans les projets (détection distante, apports par version, code de sortie 10) ; `init-project.sh --update-method` (sauvegarde dans `99_archive/methode-avant-vX.Y.Z/`, remplacement des seuls artefacts du manifest, empreinte et manifest réécrits) ; runbooks de migration dans `docs/versioning.md` ; releases GitHub v0.1.0 à v0.4.0 créées, tag v0.3.0 poussé.
- **Accompagnement** (DEC-0023) : `docs/cycle-de-travail.md` (une tâche par itération, clôture, `/clear`, reprise à froid) ; règles de découpage dans `templates/core/TASKS.md` ; sections cycle de travail et skills par agent dans `templates/core/AGENTS.md` ; skill assistant portée à 7 modes (cadrage guidé type interview, adoption, mise à jour) et purgée de ses références au repo méthode ; `docs/INSTALL-AGENT.md` (méthode 1 création / méthode 2 adoption avec validation humaine).
- **RETEX comptabilité intégré** (DEC-0024) : template `SUJETS.md` à la racine (routeur métier, posé par `--knowledge`), source fraîche prioritaire dans `kb_governance.md`, règle « SUJETS.md avant INDEX.md » dans skill/AGENTS/governance, contrôle dans `check-project.sh`.
- **Navigation Knowledge outillée** : frontmatter standard et budgets de taille documentés dans `kb_governance.md`, convention de nommage niveaux 2↔3 (`docs/NAMING-CONVENTIONS.md`), détection d'orphelins, de liens cassés et de dépassements de budget dans `check-project.sh`.
- **Qualité production** : CI GitHub Actions (`shellcheck -S warning` + tests de fumée création/greffe/mise à jour/dogfooding) ; exemples complets `examples/life-copropriete/` et `examples/code-site-vitrine/` ; `AGENTS.md` posé sur le repo méthode lui-même ; mode repo méthode dans `check-project.sh` (exclusion de `templates/`, `examples/`, `PLAN/`, `NAMING-CONVENTIONS.md`) : dogfooding à 0 avertissement.
- **Corrections** : comptage `WARNS` (sous-shell), faux négatif du hook Stop (`templates/core/PROGRESS.md` satisfaisait le contrôle), ordre des options grep pour BSD, limite de couverture du hook pre-write documentée, idiome `CDPATH=''`.

### CHG-20260704-1200 — Check AGENTS.md universel + garde-fou taille Hermès

- `scripts/check-project.sh` : le contrôle de présence d'`AGENTS.md`/`CLAUDE.md` sort de la liste spécifique à l'extension Code et devient une section universelle (« Socle agent »), avertissement non bloquant, tous types de projet.
- Nouvelle section « Taille des fichiers de contexte agent » : mesure `AGENTS.md`, `CLAUDE.md`, `.hermes.md`, `SOUL.md`, `.cursorrules` (s'ils existent) et avertit au-delà de 20 000 caractères, seuil de troncature par défaut d'Hermès Agent (`context_file_max_chars`).
- `agents/hermes.md` : nouvelle section documentant les fichiers de contexte chargés par Hermès et cette limite de troncature.
- Version portée à `0.4.0` (nouvelle capacité de contrôle = évolution mineure). Voir DEC-0020.

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
