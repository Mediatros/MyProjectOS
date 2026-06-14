# Handoff — Renommage : regroupement des extensions sous `templates/extensions/`

_Date : 2026-06-13. Auteur : session Claude Code (Mac). Destinataire : agent en charge du repo `my-project-os`._

## Résumé en une phrase

Les extensions Life, Code et Knowledge ont été déplacées de `templates/{life,code,knowledge}/` vers `templates/extensions/{life,code,knowledge}/`, en gardant `templates/core/` comme socle. Commit `abfc7f1`, non poussé.

## Point de départ

L'utilisateur explorait le repo et ne trouvait « pas logique » que le dossier `templates/` contienne les extensions. Il a d'abord proposé de renommer `templates/` en `extensions/`, puis de sortir `core/` à la racine, puis de renommer `templates/` en `modules/`. La discussion a tranché autrement. Ce document trace le raisonnement pour éviter de le refaire.

## Le débat de nommage et pourquoi on a tranché ainsi

Trois options ont été proposées par l'utilisateur, et écartées ou amendées :

1. **Renommer `templates/` en `extensions/`.**
   Écarté : `templates/` contient aussi `core/`, qui n'est PAS une extension mais le socle commun. Mettre `core/` dans un dossier `extensions/` serait contradictoire.

2. **Sortir `core/` à la racine, puis renommer `templates/` en `extensions/`.**
   Écarté pour deux raisons :
   - On perd le signal « ce sont des gabarits ». Tout ce qui est sous `templates/` n'est pas le projet réel : ce sont des moules copiés par `init-project.sh`. Le wrapper `templates/` dit exactement ça. À la racine, `core/` et `extensions/` se mélangeraient visuellement avec `docs/`, `agents/`, `structures/` et on ne distinguerait plus gabarit et contenu réel.
   - Collision avec le dogfooding : le repo s'applique son propre système et a déjà un `PROGRESS.md`, `CHANGELOG.md`, `TASKS.md` réels à la racine. Un `core/PROGRESS.md` (gabarit) à la racine créerait une ambiguïté entre le modèle et l'état réel du repo.

3. **Renommer `templates/` en `modules/`.**
   Écarté : « module » évoque une unité logicielle composable qui *fait* quelque chose (qu'on importe, qui a un comportement). Or ces dossiers ne contiennent que des fichiers Markdown inertes (gabarits). « Templates » est le mot le plus exact. De plus `modules/{core,life,code,knowledge}` remettrait core et extensions au même niveau, reperdant la distinction socle / extension.

**Principe de nommage retenu : nature d'abord, rôle ensuite.**
- Niveau 1 = nature : `templates/` (ce sont des gabarits).
- Niveau 2 = rôle : `core/` (socle) vs `extensions/` (modules activables).

Chaque niveau dit une seule chose claire. La notion d'« extension » devient un dossier physique lisible sans casser la séparation existante entre gabarits (`templates/`) et descriptions d'arborescence (`structures/`).

## Structure résultante

```
templates/
├── core/              # socle : PROJECT, PROGRESS, CHANGELOG, TASKS, DECISIONS
└── extensions/        # modules activables selon le type de projet
    ├── life/          # PREUVES, ECHEANCES, CORRESPONDANCES
    ├── code/          # AGENTS, CONSTITUTION, STACK_VALIDATION, ARCHITECTURE, SPECS, TEST_PLAN, IMPACT_ANALYSIS, RELEASE
    └── knowledge/     # docs/INDEX, kb_governance, niveaux 01/02/03, plan/, runbooks/
```

Rappel conceptuel inchangé : une extension = sa description dans `structures/<x>-tree.md` + ses gabarits dans `templates/extensions/<x>/`. Seul l'emplacement des gabarits a bougé.

## Ce qui a été modifié (commit `abfc7f1`)

- **Déplacements** : `git mv` des trois dossiers d'extension (historique préservé, vu comme renommages `R` par git).
- **`scripts/init-project.sh`** : 3 chemins mis à jour (`templates/extensions/life|code|knowledge`). Validé `sh -n` + test réel de bout en bout (`bash scripts/init-project.sh /tmp/posai-test --code --knowledge`) : tous les fichiers Core + Code + Knowledge générés correctement depuis les nouveaux chemins.
- **Docs de référence « vivantes »** alignées : `README.md` et `CLAUDE.md` (blocs « structure du repository »), `docs/governance.md`, `docs/clarify.md`, `docs/harness.md`.

Rappel d'usage du script (n'avait pas changé) : `init-project.sh <chemin-projet> [--life] [--code] [--knowledge]` (aucun flag = Core seul ; `--life --code` = Hybrid).

## Ce qui a été délibérément LAISSÉ EN L'ÉTAT

Par principe chirurgical, les références aux anciens chemins dans les **traces historiques et de planification** n'ont pas été réécrites :
- `PROGRESS.md` (paragraphe d'historique des phases).
- Items terminés de `TASKS.md` (T2.1, T2.3, T2.7, T5.2 mentionnent encore `templates/life|code|knowledge`).
- `docs/plan-integration-extension-knowledge.md` (document de plan, nombreuses occurrences `templates/knowledge/...`).
- `PLAN/*` (HANDOFF, plans).

Raison : réécrire ces fichiers reviendrait à modifier l'historique du projet, pas son état courant. **Décision à prendre par l'agent / l'utilisateur** : faut-il aligner aussi ces traces ? Si oui, c'est mécanique (remplacer `templates/life|code|knowledge` par `templates/extensions/...`).

`anatomy.md` (non suivi, auto-régénéré par le hook Stop) n'a pas été touché : il se met à jour seul. Le workdoc `docs/hermes-workdoc-2026-06-03-...` (non suivi) n'a pas été staged.

## État Git

- Commit local `abfc7f1` sur `main`, **non poussé**.
- Non suivis restants (intacts) : `anatomy.md`, `docs/hermes-workdoc-2026-06-03-orientation-my-project-os.md`.

## Prochaines étapes suggérées

1. Décider de l'alignement (ou non) des traces historiques listées ci-dessus.
2. Pousser le commit si validé (`git push`).
3. Vérifier qu'aucun outil externe ou autre projet ne référence en dur l'ancien chemin `templates/life|code|knowledge`.
4. Mettre à jour `PROGRESS.md` / `CHANGELOG.md` selon la gouvernance du repo si ce changement de structure mérite d'y figurer comme évolution.
