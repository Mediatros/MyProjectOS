# Vérification terrain — limites de taille Hermès et filtrage natif des skills

> Date : 2026-08-07.
> Statut : vérification exécutée, résultats acquis. Document de preuve, pas un plan d'évolution.
> Origine : question posée en session sur la façon de découper des `SKILL.md` jugés trop gros. La vérification a montré qu'il n'y avait rien à découper, et a trouvé un mécanisme natif inutilisé.
> Suivi : DEC-0037, CHG-20260807-2047, T-RETEX-1.

## Pourquoi cette vérification

Le canon affirmait deux choses jamais vérifiées :

1. `templates/skills/_squelette/SKILL.md` prescrit « `SKILL.md` sous 20 000 caractères (seuil de troncature Hermès — externaliser les recettes dans un fichier compagnon si besoin) ».
2. `agents/hermes.md` § « Fichiers de contexte chargés et limite de troncature » décrit un seuil fixe de 20 000 caractères.

Deux fichiers du dépôt dépassaient ce seuil sans que rien ne le signale : `skills/my-project-os/SKILL.md` (21 245 caractères) et `templates/skills/blue-app/SKILL.md` (21 689 caractères). Avant de lancer un chantier de découpage, il fallait établir si la contrainte existait réellement pour ce type de fichier.

## Méthode

- Accès : `ssh root@100.74.158.86` (le compte `jihad` de `~/.ssh/config` n'a pas accès à `/root/.hermes/`, et `sudo` exige un mot de passe).
- Lecture seule. Aucune modification, ni sur le VPS ni dans le dépôt, pendant la vérification.
- Source lue : `/root/.hermes/hermes-agent/repo`, commit `015aae836` du 2026-08-04 (`fix(codex): honor configured base_url for openai-codex provider`).
- Configuration lue : `/root/.hermes/config.yaml`.
- Installation observée : `/root/.hermes/skills/`.

## Résultat 1 — La troncature ne s'applique pas aux `SKILL.md`

**C'est le point qui invalide l'affirmation du squelette.**

La fonction de troncature est `_truncate_content()`, définie dans `agent/prompt_builder.py:1945`. Elle est appelée en cinq endroits, tous dans le même fichier : lignes 2007, 2034, 2053, 2072 et 2108.

Ces cinq appels correspondent exactement aux cinq chargeurs de fichiers de contexte :

| Fonction | Ligne | Fichier traité |
|---|---|---|
| `load_soul_md` | 1986 | `SOUL.md` |
| `_load_hermes_md` | 2017 | `.hermes.md` |
| `_load_agents_md` | 2043 | `AGENTS.md` |
| `_load_claude_md` | 2062 | `CLAUDE.md` |
| `_load_cursorrules` | 2081 | `.cursorrules` |

Aucun chargeur de skill n'appelle `_truncate_content()`. Les `SKILL.md` sont lus intégralement, par `read_text()` sans plafond, sur trois chemins distincts :

- `agent/skill_commands.py:401` : `content = skill_md.read_text(encoding='utf-8')`, puis parsing du frontmatter et injection ;
- `hermes_cli/skills_hub.py:1485` ;
- `agent/learning_mutations.py:117`.

Seule exception, sans effet sur le chargement : `agent/learning_graph.py:133` lit `skill_md.read_text(...)[:4000]`, mais uniquement pour en extraire le frontmatter, pas pour servir la skill.

### Confirmation empirique

Les skills livrées avec Hermès dépassent largement le seuil supposé, sur cette installation même :

| Skill | Taille du `SKILL.md` |
|---|---|
| `autonomous-ai-agents/hermes-agent` | 74 278 caractères |
| `productivity/project-operating-systems` | 26 154 caractères |
| `productivity/wiki-veille-ingestion` | 22 930 caractères |
| `productivity/powerpoint` | 20 539 caractères |

Si la limite s'appliquait aux skills, la skill principale d'Hermès perdrait 73 % de son contenu à chaque chargement.

**Conclusion : la phrase du squelette est fausse.** Elle a été propagée par analogie avec la contrainte réelle des fichiers de contexte racine, sans vérification, et elle se recopie dans chaque skill créée depuis le squelette.

## Résultat 2 — Le seuil de 20 000 est devenu un plancher, pas une limite

Découvert en marge, mais il touche un contrôle actif du dépôt.

Constantes dans `agent/prompt_builder.py` :

```python
CONTEXT_FILE_MAX_CHARS = 20_000          # ligne 1264
CONTEXT_TRUNCATE_HEAD_RATIO = 0.7        # ligne 1265
CONTEXT_TRUNCATE_TAIL_RATIO = 0.2        # ligne 1266

_CONTEXT_FILE_CHARS_PER_TOKEN = 4        # ligne 1272
_CONTEXT_FILE_WINDOW_FRACTION = 0.06     # ligne 1273
_CONTEXT_FILE_DYNAMIC_CEILING = 500_000  # ligne 1274
```

`_dynamic_context_file_max_chars()` (ligne 1279) calcule `context_length × 4 × 0,06`, borné entre 20 000 et 500 000. Le commentaire du code est explicite : « the cap scales with the model's context window so large-context models rarely truncate a project doc, while small-context models stay at the historical 20K floor ».

`_get_context_file_max_chars()` (ligne 1294) résout dans cet ordre :

1. `context_file_max_chars` explicite dans `config.yaml` (gagne toujours) ;
2. sinon, le calcul dynamique dérivé de la fenêtre du modèle ;
3. sinon, 20 000 en repli de compatibilité.

Sur cette installation, `context_file_max_chars` est **absent** de `config.yaml` (vérifié par `grep` sur l'ensemble du fichier). C'est donc le calcul dynamique qui s'applique. Le modèle actif est `gpt-5.6-sol` (provider `openai-codex`), et `context_length` n'est pas déclaré en configuration : il remonte du `context_compressor` à l'initialisation (`agent/agent_init.py`, `agent/agent_runtime_helpers.py:1584`).

Ordres de grandeur : une fenêtre de 200 000 tokens donne une limite d'environ 48 000 caractères, une fenêtre de 1 000 000 donne 240 000.

Autre paramètre à ne pas confondre, `config.yaml:143` : `file_read_max_chars: 100000`, qui concerne la lecture de fichiers par l'agent, pas l'injection de contexte.

Mécanique de troncature, si elle se déclenche : conservation de 70 % en tête et 20 % en queue, marqueur au milieu, et émission d'un avertissement explicite nommant le fichier, sa taille et la limite appliquée.

**Conséquence** : la valeur de 20 000 documentée par DEC-0020 n'est plus la limite effective, c'est son plancher. Le contrôle de `check-project.sh` (`HERMES_MAX_CHARS=20000`, ligne 281) n'est pas faux, il est devenu pessimiste. Il reste défendable comme seuil de prudence, puisque le repli à 20 000 s'applique dès que la fenêtre du modèle est inconnue.

## Résultat 3 — Hermès filtre déjà les skills par plateforme et par environnement

C'est le résultat le plus actionnable, et il concerne directement le RETEX Mediatros.

`agent/skill_utils.py` expose deux filtres lus dans le frontmatter des skills :

**`skill_matches_platform()`** (ligne 251, logique en 226) :

```yaml
platforms: [macos]           # macOS uniquement
platforms: [macos, linux]    # les deux
```

Correspondance déclarée ligne 21 : `PLATFORM_MAP = {"macos": "darwin", "linux": "linux", "windows": "win32"}`. Le cas Termux/Android est traité explicitement (une skill marquée `linux` reste acceptée sous Termux). **Champ absent ou vide égale compatible partout**, donc parfaitement rétrocompatible.

**`skill_matches_environment()`** (ligne 335) :

```yaml
environments: [kanban]   # seulement quand kanban est actif
environments: [s6]       # seulement dans l'image Docker s6
environments: [docker]   # seulement en conteneur
```

Les deux filtres sont appliqués au moment de l'offre, dans `agent/skill_commands.py:403-409` : une skill dont la plateforme ne correspond pas est écartée avant même d'être proposée à l'agent. Le code précise qu'il s'agit d'un filtre « OFFER-time » : un chargement explicite le contourne.

### Pourquoi c'est exactement le problème de Mediatros

Le RETEX décrit huit skills écrites pour macOS devenues muettes d'un coup sur le VPS Linux. Avec `platforms: [macos]`, Hermès ne les aurait jamais proposées, au lieu de les proposer puis d'échouer sur `security find-generic-password` ou sur un chemin `/Users/jb/...`.

Le RETEX propose d'inventer un champ `portable:` à quatre valeurs. Ce champ garde son utilité, mais il faut voir ce qu'il est : de la documentation, au sens de l'échelle de fermeté posée par DEC-0036. `platforms:` est un mécanisme, il change le comportement de l'agent. Les deux se complètent, ils ne se remplacent pas.

### Limite constatée du champ `portable:`

Le lanceur `/root/.local/bin/hermes` intercepte `hermes skills list` et n'extrait du frontmatter que `description`, `version` et `author`. Un champ `portable:` n'apparaîtrait donc pas dans la sortie de `hermes skills list`. Il ne serait lisible qu'à l'ouverture du fichier ou via le tableau d'inventaire proposé par le RETEX (évolution 4).

## Test d'exécution des deux filtres (2026-08-07, après la lecture statique)

La lecture du code ne suffisait pas à canoniser un mécanisme. Les deux fonctions ont donc été appelées directement, sur le VPS, dans l'interpréteur du venv d'Hermès, sans créer ni modifier aucune skill.

Piège évité : créer une skill jetable puis lancer `hermes skills list` **ne prouverait rien**. Ce lanceur est un wrapper bash (`/root/.local/bin/hermes`) qui lit directement le système de fichiers et court-circuite le filtre. La skill apparaîtrait quand même, et on en conclurait à tort que `platforms:` ne fonctionne pas.

### `platforms:` — 6 cas sur 6, mécanisme confirmé

Plateforme courante : `linux`.

| Frontmatter | Attendu | Obtenu |
|---|---|---|
| `platforms: [macos]` | écartée | `False` |
| `platforms: [linux]` | offerte | `True` |
| `platforms: [macos, linux]` | offerte | `True` |
| `platforms: [windows]` | écartée | `False` |
| champ absent | offerte | `True` |
| `platforms: []` | offerte | `True` |

Le mécanisme est fiable et sa sémantique est celle annoncée. **Retenu pour le canon.**

### `environments:` — écarté, détection en faux positif

`skill_matches_environment({"environments": ["docker"]})` renvoie `True` sur ce VPS, **alors que le VPS n'est pas un conteneur**. Vérifié : `/.dockerenv` absent, `/run/.containerenv` absent, `KUBERNETES_SERVICE_HOST` non défini, aucun marqueur dans `/proc/1/cgroup`, PID 1 = `systemd`.

Cause identifiée : `_detect_environment("docker")` délègue à `is_container()` de `hermes_constants`, dont le repli cgroup-v2 cherche les marqueurs `kubepods`/`containerd`/`crio` dans `/proc/self/mountinfo`. Or Docker est **installé sur l'hôte**, ce qui y laisse des montages `containerd`. La fonction conclut donc à un conteneur sur une machine qui n'en est pas un.

Deux raisons cumulées de ne pas porter ce champ au canon :

1. ses trois seules valeurs reconnues (`_KNOWN_ENVIRONMENTS = {"kanban", "docker", "s6"}`) sont internes à l'infrastructure Hermès et ne répondent à aucun besoin de portabilité de MyProjectOS ;
2. sa détection est démontrée faillible sur un hôte où Docker est installé, cas courant.

À noter pour qui s'y intéresserait plus tard : un tag non reconnu **n'écarte jamais** la skill (`fail open`, ligne 366). Une faute de frappe dans `environments:` ne filtre donc rien, en silence.

## Ce que la vérification invalide dans le canon

| Emplacement | Affirmation | Statut |
|---|---|---|
| `templates/skills/_squelette/SKILL.md` | « `SKILL.md` sous 20 000 caractères (seuil de troncature Hermès) » | **Faux**, aucun mécanisme correspondant |
| `agents/hermes.md:23` | seuil fixe de 20 000 caractères | **Obsolète**, devenu le plancher d'un calcul dynamique |
| `agents/hermes.md:27` | « deux leviers » si un projet approche la limite | **Incomplet**, un troisième levier existe : un modèle à plus grande fenêtre |
| `scripts/check-project.sh:281` | `HERMES_MAX_CHARS=20000` | **Conservateur mais défendable**, c'est le repli réel quand la fenêtre est inconnue |
| `PROGRESS.md` (vigilance Phase 4 Blue) | « `SKILL.md` proche du seuil de troncature Hermès (20 000) » | **Sans objet** pour un `SKILL.md` |

## Ce que la vérification ne dit pas

Points volontairement laissés ouverts, pour ne pas transformer une déduction en constat :

- La `context_length` effectivement remontée pour `gpt-5.6-sol` n'a pas été mesurée. La limite dynamique réelle sur cette installation n'est donc pas chiffrée. Si la fenêtre n'est pas résolue, le repli à 20 000 s'applique.
- La vérification porte sur le commit `015aae836` du 2026-08-04. Hermès évolue vite : ces résultats sont datés et doivent être re-testés avant d'être réutilisés comme fondement d'une décision ultérieure.
- Aucun test d'exécution n'a été fait pour observer une troncature réelle. Les conclusions du résultat 1 viennent de la lecture du code et des tailles installées, ce qui est suffisant (aucun appel à la fonction de troncature sur ce chemin) mais reste de la lecture statique.
- Les deux filtres du résultat 3 ont, eux, été exercés en exécution (voir la section dédiée) : `platforms:` confirmé 6 cas sur 6, `environments:` écarté pour faux positif de détection.
- Le faux positif de `is_container()` sur un hôte où Docker est installé n'a pas été remonté en amont chez Hermès. Il dépasse le périmètre de ce dépôt.

## Comment re-vérifier

```sh
# 1. Les SKILL.md sont-ils tronqués ? Chercher les appelants de la troncature.
ssh root@100.74.158.86 \
  'grep -rn "_truncate_content(" /root/.hermes/hermes-agent/repo --include=*.py | grep -v "def "'

# 2. Le seuil est-il fixe ou dynamique ?
ssh root@100.74.158.86 \
  'sed -n "1264,1315p" /root/.hermes/hermes-agent/repo/agent/prompt_builder.py'

# 3. Un plafond explicite est-il posé en configuration ?
ssh root@100.74.158.86 'grep -n "context_file_max_chars" /root/.hermes/config.yaml || echo "(absent, cap dynamique)"'

# 4. Contre-preuve empirique : des skills installées dépassent-elles 20 000 ?
ssh root@100.74.158.86 'find /root/.hermes/skills -name SKILL.md -exec wc -c {} \; | sort -rn | head -5'

# 5. Les filtres natifs de frontmatter existent-ils toujours ?
ssh root@100.74.158.86 \
  'grep -n "def skill_matches_platform\|def skill_matches_environment\|PLATFORM_MAP" \
   /root/.hermes/hermes-agent/repo/agent/skill_utils.py'
```

## Suite donnée

Validée en session le 2026-08-07, formalisée par DEC-0037 :

1. corriger les deux affirmations fausses (squelette, `agents/hermes.md`) ;
2. porter `platforms:` au squelette (et **seulement** lui, `environments:` étant écarté après test), et articuler le `portable:` du RETEX avec `platforms:` au lieu de le doubler ;
3. ne **pas** ajouter les `SKILL.md` au contrôle de taille de `check-project.sh`, ce qui outillerait une contrainte inexistante ;
4. reclasser l'externalisation des recettes de `blue-app` en confort (économie de contexte), et non en correction.

## Observation annexe

Une skill Hermès nommée `productivity/project-operating-systems` (26 154 caractères) est installée sur le VPS. Le nom recouvre le domaine de MyProjectOS. À examiner un jour : reprise de la méthode, convergence indépendante, ou concurrent traitant le même besoin. Aucune conclusion tirée ici, le fichier n'a pas été lu.
