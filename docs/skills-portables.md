# Skills portables

Comment une skill technique vit dans un projet piloté par plusieurs agents : où elle est stockée, comment chaque agent l'installe, et comment dire qu'elle ne fonctionne pas partout.

Ce document rassemble ce qui était jusqu'ici éparpillé entre le squelette, les fiches d'agent et le registre des décisions. Il est la référence ; les gabarits sont l'outil.

## Le problème

Une skill écrite sur un Mac finit sur toutes les machines du projet dès que le dossier est synchronisé. Elle y est proposée à l'agent, puis elle échoue, parce qu'elle appelle un binaire absent ou lit un trousseau qui n'existe pas. Cas réel : huit skills d'un projet passé de `LOCAL/` à `SYNC/` sont devenues muettes d'un coup côté VPS (voir le RETEX correspondant).

Trois questions en découlent, et ce document répond aux trois.

1. Où vit la source de vérité d'une skill ?
2. Comment chaque agent l'installe chez lui ?
3. Comment dire qu'elle ne tourne pas partout, et faire en sorte que ce soit respecté ?

État au 2026-08-08 : le dispositif fonctionne sur les **quatre agents** utilisés ici, Claude Code, Codex, OpenCode et Hermès. Trois d'entre eux consomment le catalogue par un lien symbolique relatif ou par simple découverte, le quatrième par une déclaration de configuration. Aucun ne demande de copie.

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
| OpenCode | rien à faire | **découverte** | il lit `.claude/skills/` et `.agents/skills/`, donc les liens déjà posés ; son emplacement propre est `.opencode/skill/` |
| Hermès | déclaration `skills.external_dirs` | **ni copie ni lien** | le catalogue du projet est déclaré en une ligne de configuration du profil, et scanné comme le dossier local |

Le lien symbolique supprime la dérive entre la source et la copie : il n'y a qu'un fichier. La contrepartie est qu'un outil d'archive qui ne préserve pas les liens casse l'installation en silence, ce que `check-project.sh` détecte (section « Skills portables »).

Pour Hermès, la voie est différente et meilleure, parce qu'elle ne crée aucun second exemplaire. Sa configuration de profil accepte une clé `skills.external_dirs` qui désigne un dossier **du projet** :

```sh
hermes config set skills.external_dirs '<projet>/98_configuration/skills'
```

Tout le catalogue est alors scanné : chaque skill présente, et chaque skill future, arrive sans installation. Le code marque ces skills « externes », donc en lecture seule pour la maintenance autonome d'Hermès. Aucun lien n'existant, aucune des objections à la copie ne s'applique : ce n'est pas un pointeur de fichiers, c'est une déclaration de configuration, qui survit à un `profile export/import`.

**La copie physique globale est abandonnée** (DEC-0040, qui corrige la justification de DEC-0029 D3 et de DEC-0034). Elle avait un défaut plus grave que la dérive qu'on lui reprochait : sur un déploiement profilé, le dossier scanné est celui du profil actif, donc une skill déposée dans le dossier global n'était **pas offerte à l'agent**. Une restriction par décision reste néanmoins un mécanisme dur chez Hermès, par non-déclaration du catalogue ou par retrait de la skill du catalogue.

Une variante spécifique à un agent, qui n'a pas sa place dans le catalogue générique, s'installe par lien symbolique dans le dossier de skills du profil.

| Cas | Mécanisme Hermès |
|---|---|
| Skill générique du catalogue `98_configuration/skills/` | `skills.external_dirs`, une ligne de configuration |
| Variante spécifique d'un agent, hors catalogue | lien symbolique dans `~/.hermes/profiles/<profil>/skills/` |
| Copie physique globale | abandonnée : ni scannée en déploiement profilé, ni nécessaire |

Deux pièges vérifiés par exécution, à connaître avant de poser la déclaration. La valeur doit être une **chaîne simple** : `hermes config set` n'écrit que des chaînes, et une valeur qui ressemble à une liste JSON est stockée littéralement, puis résolue en un chemin unique inexistant, ignoré **sans message**. Déclarer plusieurs dossiers suppose une édition manuelle du fichier de configuration. Second piège, la synchronisation ne propage pas le bit d'exécution : les scripts du catalogue arrivent en `644` sur le VPS, donc soit on rétablit les permissions côté VPS, soit les recettes appellent `bash scripts/<script>.sh` plutôt que `./scripts/<script>.sh`.

**Il n'existe pas de contrôle automatique de cette déclaration**, et c'est une limite assumée, pas un oubli. `check-project.sh` s'exécute sous le compte propriétaire du projet, qui ne peut pas lire la configuration d'Hermès quand celui-ci tourne en `root` (mesuré en DEC-0038, toujours vrai). La garantie reste documentaire.

Commande de re-vérification, à exécuter sur le VPS avec les droits d'Hermès. Ne pas utiliser `hermes skills list` pour cela, voir la fin de ce document :

```sh
cd <repo hermes> && HERMES_HOME=~/.hermes/profiles/<profil> ./.venv/bin/python -c "
from agent.skill_commands import scan_skill_commands
cmds = scan_skill_commands()
print(len(cmds), cmds.get('/<skill>', {}).get('skill_dir'))
"
```

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

### Deux versions d'une même skill : un signal, pas un état

Le motif se reconnaît vite : un projet porte la même skill deux fois, une par agent, à deux endroits différents. C'est le symptôme d'un parc constitué avant la logique de catalogue, quand chaque agent recevait sa propre écriture.

Cas réel mesuré : `radar-projets` existait en version Claude Code et en adaptation Hermès dans le même projet, avec un sous-agent présent d'un côté et absent de l'autre, une description de déclenchement enrichie d'un côté seulement, et une numérotation des usages inversée. Aucune des deux n'était fausse, elles avaient simplement divergé chacune de son côté.

Le motif « une skill par agent » ne se justifie que pour une variante **spécifique** à un agent. Dès qu'un projet en découvre deux qui font la même chose, c'est le signal de fusionner : une skill générique unique dans le catalogue, les agents la découvrant par leur mécanisme respectif, l'ancienne version archivée. Ne pas attendre : ce qui a divergé une fois diverge encore.

## Ce qui est vérifié, et ce qui ne l'est pas

Ce document distingue ce qui a été prouvé par exécution de ce qui reste une convention. La distinction compte : deux règles tenues pour acquises n'ont pas survécu à la vérification, à une version d'intervalle.

| Affirmation | Statut |
|---|---|
| Le filtre `platforms:` écarte bien une skill incompatible | **vérifié par exécution**, 6 cas sur 6 (DEC-0037) |
| Le chemin projet de Codex est `.agents/skills/` | **vérifié par exécution** (DEC-0034) |
| Les `SKILL.md` ne sont jamais tronqués par Hermès | **vérifié** par lecture du code et contre-preuve empirique (DEC-0037) |
| `check-project.sh` ne peut pas lire les skills d'Hermès depuis le projet | **vérifié par exécution** (DEC-0038) |
| Hermès offre une skill du catalogue déclarée en `external_dirs`, sans copie ni lien | **vérifié par exécution** sur le registre réel (DEC-0040) |
| OpenCode découvre `.claude/skills/` et `.agents/skills/` | vérifié par lecture des chemins du binaire v1.18.15, non exercé en session (DEC-0040) |
| Une skill du dossier global n'est pas offerte sur un déploiement profilé | **vérifié par exécution** (DEC-0040) |
| Budget de 500 lignes pour le corps d'un `SKILL.md` | convention du standard Agent Skills, non contrôlée ici |
| Le champ `portable:` | convention interne, lue par personne, non contrôlée |
| La déclaration `external_dirs` est bien posée sur le profil | non contrôlable depuis le projet, garantie documentaire (DEC-0040) |

Deux règles qui figuraient au canon en ont été retirées faute de mécanisme réel : la limite de 20 000 caractères pour un `SKILL.md` (DEC-0037) et le contrôle de dérive de la copie Hermès (DEC-0038). Avant d'ajouter une contrainte à ce document, **mesurer le mécanisme avant de l'outiller**.

### Et mesurer avec le bon instrument

Une contrainte peut aussi être mesurée de travers, ce qui est plus dangereux qu'une contrainte non mesurée : le chiffre obtenu inspire confiance et personne ne redemande la preuve.

Cas réel, sur le profil d'un même projet : `hermes skills list` renvoie 224 skills, le dossier de skills du profil en contient 174, et le registre réellement offert à l'agent en compte 148. Trois nombres, trois objets différents. Une conclusion tirée du premier pour parler du troisième s'est révélée juste par accident sur un cas et fausse sur l'autre, la contre-preuve étant présente dans les mêmes données sans être relevée (DEC-0040).

Règle : avant de conclure d'une commande d'inspection, **vérifier qu'elle observe bien l'objet dont on parle**. Une commande de confort listant un dossier n'est pas le registre que l'agent consulte au moment d'offrir une skill. Quand la mesure porte sur ce que l'agent voit, l'instrument doit être le chemin de code que l'agent emprunte.

## Voir aussi

- `templates/skills/_squelette/` — le squelette dont part toute nouvelle skill.
- `templates/configuration/README_SKILLS.md` — le gabarit du tableau de bord de parc.
- `docs/OUTILS.md` — le catalogue des outils proposés nativement et les backends de secrets.
- `agents/hermes.md` — les fichiers de contexte d'Hermès, sa limite de troncature réelle et son filtrage natif.
- `structures/core-tree.md` — la place de `98_configuration/` dans l'arborescence.
- `docs/enforcement.md` — pourquoi certaines règles sont tenues par un hook et d'autres par de la documentation.
- DEC-0029, DEC-0034, DEC-0037, DEC-0038 — les décisions qui ont construit ce dispositif.
