# Skills portables

Comment une skill technique vit dans un projet piloté par plusieurs agents : où elle est stockée, comment chaque agent l'installe, et comment dire qu'elle ne fonctionne pas partout.

Ce document rassemble ce qui était jusqu'ici éparpillé entre le squelette, les fiches d'agent et le registre des décisions. Il est la référence ; les gabarits sont l'outil.

## Le problème

Une skill écrite sur un Mac finit sur toutes les machines du projet dès que le dossier est synchronisé. Elle y est proposée à l'agent, puis elle échoue, parce qu'elle appelle un binaire absent ou lit un trousseau qui n'existe pas. Cas réel : huit skills d'un projet passé de `LOCAL/` à `SYNC/` sont devenues muettes d'un coup côté VPS (`RETEX/retex-mediatros-retrofit-skills-portables.md`).

Trois questions en découlent, et ce document répond aux trois.

1. Où vit la source de vérité d'une skill ?
2. Comment chaque agent l'installe chez lui ?
3. Comment dire qu'elle ne tourne pas partout, et faire en sorte que ce soit respecté ?

## 1. Une source canonique par projet

La source de vérité d'une skill de projet est `98_configuration/skills/<outil>/`. C'est le seul endroit qu'on édite.

```
98_configuration/skills/
├── README.md              # tableau de bord du parc (gabarit templates/configuration/README_SKILLS.md)
└── <outil>/
    ├── SKILL.md           # méthodologie, déclencheurs, recettes
    ├── INSTALL.md         # prérequis, installation par agent, secrets, limites
    └── scripts/           # secrets.sh et scripts propres à l'outil
```

Créer une skill part toujours de `templates/skills/_squelette/`, qui fournit les trois pièces plus le résolveur de secrets multi-backend. **Vérifier ce que le squelette fournit avant d'écrire quoi que ce soit** : un projet qui part de zéro sur ce sujet réinvente un résolveur moins complet, installe par copie là où le canon prescrit un lien, et met des identifiants en dur. Cas constaté, pas hypothétique (DEC-0038).

Aucun secret ne vit jamais dans `98_configuration/` : seulement des **noms** de clés et un nom de backend. Les valeurs se saisissent hors-bande, voir l'`INSTALL.md` de la skill et `docs/OUTILS.md`.

## 2. Installation par agent

Chaque agent installe sa propre copie depuis la source canonique. Les chemins et les modes diffèrent, et c'est délibéré.

| Agent | Emplacement | Mode | Pourquoi |
|---|---|---|---|
| Claude Code | `.claude/skills/<outil>` | lien symbolique **relatif** | interne au projet, donc il voyage avec lui (renommage, déplacement, archive) |
| Codex | `.agents/skills/<outil>` | lien symbolique **relatif** | idem ; chemin vérifié par exécution, pas `.codex/skills/` |
| Hermès | `~/.hermes/skills/<outil>` | **copie physique** | le dossier est global et hors du projet : un lien y serait absolu, donc cassé au premier déplacement ou à la première pause de synchronisation |

Le lien symbolique supprime la dérive entre la source et la copie : il n'y a qu'un fichier. La contrepartie est qu'un outil d'archive qui ne préserve pas les liens casse l'installation en silence, ce que `check-project.sh` détecte (section « Skills portables »).

Pour Hermès, la copie est assumée : une skill absente parce que la synchronisation est en pause est un incident plus grave qu'une skill légèrement périmée (DEC-0029 D3, étayé par DEC-0034).

**Il n'existe pas de contrôle automatique de dérive de la copie Hermès**, et c'est une décision documentée, pas un oubli. La mesure du 2026-08-07 a établi que le contrôle serait muet là où il devrait tourner : `check-project.sh` s'exécute sous le compte propriétaire du projet, qui ne peut pas lire le dossier de skills d'Hermès quand celui-ci tourne en `root`. Elle a aussi établi que la dérive redoutée ne se produisait pas. Détail et commandes de re-vérification : DEC-0038.

## 3. Dire qu'une skill ne tourne pas partout

Deux champs, deux rôles. Ne pas les confondre est le point le plus important de ce document.

### `platforms:` — un mécanisme

Champ de frontmatter lu **nativement par Hermès**, qui écarte une skill incompatible **avant même de la proposer** à l'agent. C'est un filtre actif, pas une note.

```yaml
platforms: [macos]           # écartée sur Linux et Windows
platforms: [macos, linux]
platforms: [linux]
```

Valeurs reconnues : `macos`, `linux`, `windows`. **Champ absent égale compatible partout**, c'est le défaut : rien à migrer sur l'existant.

Deux précautions vérifiées par l'exécution. Ne jamais l'écrire en commentaire YAML : le lecteur de frontmatter d'Hermès ne traite pas les commentaires et en fait une clé parasite. Et ne pas compter sur `hermes skills list` pour le relire, ce lanceur n'extrait que `description`, `version` et `author`.

Claude Code et Codex ne lisent pas ce champ : la restriction y reste documentaire, ce qui est sans conséquence puisque ces deux agents tournent sur la machine où la skill a été écrite.

Le champ voisin `environments:` existe mais **n'est pas au canon** : sa détection s'est révélée en faux positif au test, et ses valeurs sont internes à l'infrastructure d'Hermès (DEC-0037).

### `portable:` — de la documentation

`platforms:` ne dit qu'une chose : sur quel système d'exploitation la skill peut tourner. Tout ce que la machine ne peut pas déduire s'écrit dans `portable:`, en clé de premier niveau du frontmatter.

| Valeur | Sens | Qui peut le déduire ? |
|---|---|---|
| `oui` | fonctionne partout une fois le secret disponible (**défaut si le champ est absent**) | — |
| `partiel` | une partie des opérations seulement | personne, il faut l'écrire |
| `conditionnel` | portable une fois des prérequis posés, chemin écrit | personne |
| `non` | non portable **par décision** | personne |

Aucun agent ne lit ce champ. Il sert à l'humain et au tableau de bord du parc. C'est de la documentation, et c'est assumé comme tel.

**Règle de cohérence** : toute valeur `non` ou `partiel` dont la cause est **technique** doit s'accompagner d'un `platforms:` restrictif. Sinon la skill documente un problème au lieu de l'empêcher. Le cas inverse, `platforms:` sans `portable:`, est normal.

### Restriction technique ou restriction par décision

C'est la distinction qui décide de tout le reste.

| | Restriction **technique** | Restriction **par décision** |
|---|---|---|
| Nature | la skill ne **peut pas** tourner ailleurs | elle le pourrait, mais on ne le **veut** pas |
| Exemple | trousseau macOS, AppleScript, chemins `/Users/...` | un accès SSH aux serveurs des clients, qu'un agent joignable depuis un téléphone ne doit pas atteindre |
| Champ | `platforms:` restrictif | **pas de `platforms:`** |
| Mécanisme | le filtre natif d'Hermès | la **non-installation** |
| À écrire | une ligne de raison dans le `SKILL.md` | une décision, avec sa raison et le renvoi au document qui la porte |

Pourquoi une restriction par décision ne se traduit pas en `platforms:` : ce champ dit « ne peut pas tourner ici », pas « ne doit pas être offerte ici ». Le jour où un Hermès tourne sur macOS, `platforms: [macos]` lui offrirait la skill précisément dans le cas qu'on voulait interdire, puisque la frontière visait l'agent et non le système d'exploitation.

Le mécanisme correct est de ne pas installer la skill pour cet agent. Chez Hermès, dont l'installation est une copie physique, **c'est un mécanisme dur et non une consigne** : ce qui n'a pas été copié n'existe pas pour lui. L'`INSTALL.md` porte alors une section « ne pas installer » à la place de la commande d'installation, avec la commande de retrait si la skill s'y trouve déjà.

Et une conduite à tenir, sans laquelle la frontière finit contournée par bonne volonté : l'agent qui rencontre ce besoin depuis la mauvaise machine **prépare** l'intervention (commandes exactes, contexte, points à vérifier), la **remet** à l'humain ou à l'agent habilité, et **ne contourne pas**. Sans marque explicite, « non portable » se lit comme une tâche en attente, et un agent diligent finit par « réparer » ce qui était une frontière de sécurité volontaire.

## 4. Le tableau de bord du parc

Dès qu'un projet a plus d'une skill, `98_configuration/skills/README.md` répond à « qu'est-ce que chaque agent peut faire aujourd'hui ? » sans ouvrir un seul fichier. Gabarit : `templates/configuration/README_SKILLS.md`.

| Skill | `portable:` | `platforms:` | Secret | Agents équipés | Blocage résiduel |
|---|---|---|---|---|---|

Il n'y a **pas d'autre registre**. Le détail par opération vit dans le tableau « limites par environnement » de l'`INSTALL.md` de chaque skill, et le pourquoi d'une non-portabilité décidée dans le `DECISIONS.md` du projet. Trois surfaces, trois rôles, aucune recopie.

## 5. Rattraper un parc existant

Le cas le plus fréquent n'est pas d'écrire une skill portable, c'est de rattraper des skills écrites pour une seule machine quand le projet devient multi-agents après coup. Tout projet ancien qui bascule y passe.

**Déclencheurs** : passage de `LOCAL/` à `SYNC/`, arrivée d'un second agent, nouvelle machine.

Pour chaque skill du parc, répondre à cinq questions et consigner la réponse dans le tableau de bord :

1. Que fait-elle ?
2. Quelle dépendance la cloue à une machine (chemin, trousseau, binaire, script d'environnement) ?
3. Quel secret utilise-t-elle, et par quel backend ?
4. Verdict `portable:` : `oui`, `partiel`, `conditionnel`, `non` ?
5. Que reste-t-il bloqué, et quel est le chemin pour le lever ?

Puis appliquer : `platforms:` pour toute incompatibilité **technique**, non-installation pour toute restriction **par décision**, et le tableau « limites par environnement » dans l'`INSTALL.md` pour les cas `partiel`.

La skill assistant propose ce rattrapage d'elle-même en Mode 2 quand elle détecte le déclencheur. Elle le **propose**, elle ne l'applique pas d'autorité.

## Ce qui est vérifié, et ce qui ne l'est pas

Ce document distingue ce qui a été prouvé par exécution de ce qui reste une convention. La distinction compte : deux règles tenues pour acquises n'ont pas survécu à la vérification, à une version d'intervalle.

| Affirmation | Statut |
|---|---|
| Le filtre `platforms:` écarte bien une skill incompatible | **vérifié par exécution**, 6 cas sur 6 (DEC-0037) |
| Le chemin projet de Codex est `.agents/skills/` | **vérifié par exécution** (DEC-0034) |
| Les `SKILL.md` ne sont jamais tronqués par Hermès | **vérifié** par lecture du code et contre-preuve empirique (DEC-0037) |
| `check-project.sh` ne peut pas lire les skills d'Hermès depuis le projet | **vérifié par exécution** (DEC-0038) |
| Budget de 500 lignes pour le corps d'un `SKILL.md` | convention du standard Agent Skills, non contrôlée ici |
| Le champ `portable:` | convention interne, lue par personne, non contrôlée |

Deux règles qui figuraient au canon en ont été retirées faute de mécanisme réel : la limite de 20 000 caractères pour un `SKILL.md` (DEC-0037) et le contrôle de dérive de la copie Hermès (DEC-0038). Avant d'ajouter une contrainte à ce document, **mesurer le mécanisme avant de l'outiller**.

## Voir aussi

- `templates/skills/_squelette/` — le squelette dont part toute nouvelle skill.
- `templates/configuration/README_SKILLS.md` — le gabarit du tableau de bord de parc.
- `docs/OUTILS.md` — le catalogue des outils proposés nativement et les backends de secrets.
- `agents/hermes.md` — les fichiers de contexte d'Hermès, sa limite de troncature réelle et son filtrage natif.
- `structures/core-tree.md` — la place de `98_configuration/` dans l'arborescence.
- `docs/enforcement.md` — pourquoi certaines règles sont tenues par un hook et d'autres par de la documentation.
- DEC-0029, DEC-0034, DEC-0037, DEC-0038 — les décisions qui ont construit ce dispositif.
