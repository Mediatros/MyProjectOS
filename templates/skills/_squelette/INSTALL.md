# Installation de la skill `<outil>`

> Squelette d'INSTALL portable MyProjectOS. Remplacer chaque bloc `<...>` puis supprimer cette note.
> Source canonique dans un projet : `98_configuration/skills/<outil>/` (copie synchronisée entre machines si le projet l'est). Chaque agent installe ensuite sa propre copie selon sa plateforme, puis renseigne sa ligne au tableau d'équipement de `98_configuration/GOUVERNANCE_<OUTIL>.md`.

## Onboarding : créer le compte (si l'outil en demande un)

À dérouler par l'agent AVEC l'utilisateur, avant toute installation :

0. **Préflight d'autonomie (tout ou rien)** : avant de lancer quoi que ce soit, vérifier que l'agent a les droits d'aller au bout — conteneur ? (`[ -f /.dockerenv ]`), privilèges ? (`id -u`, `sudo -n true`), prérequis accessibles ? (démon Docker, gestionnaire de paquets, réseau). Si un contrôle échoue : ne RIEN entamer, dire à l'utilisateur ce qui manque et lui donner les commandes exactes à exécuter lui-même, puis re-vérifier avant de reprendre. Détail : `docs/OUTILS.md` § préflight.
1. **Vérifier l'existant** : <commande de smoke test — si elle passe, sauter l'onboarding>.
2. **Guider la création du compte** : URL d'inscription `<url>`, plan gratuit à choisir : `<plan et limites>`. L'email et le mot de passe sont saisis par l'humain, jamais manipulés par l'agent.
3. **Saisie hors-bande du secret (défaut)** : la valeur d'une clé API ne transite jamais par la conversation. Selon le backend : script `ajout-secret.sh` exécuté par l'utilisateur ou hook Telegram `/secret` d'Hermès traité hors LLM (sops), ou commande que l'utilisateur exécute lui-même dans son terminal (trousseau, fichier). Mode **full-auto** possible uniquement sur choix explicite de l'utilisateur, qui accepte alors de transmettre les clés dans la conversation.
4. **Automatiser le reste** : tout ce que l'API permet après coup (<exemples : créer les ressources initiales, poser un webhook>) est fait par l'agent, avec accord explicite pour les actions au niveau du compte.
5. **Vérifier et consigner** : smoke test, puis ligne au tableau d'équipement.

## Prérequis

<Binaire(s) et dépendances, avec la commande d'installation par plateforme (brew / apt / script officiel).>

## Installation par agent

**Avant d'installer, vérifier la portabilité.** Si la skill ne tourne pas sur toutes les plateformes, son `SKILL.md` doit porter un champ `platforms:` au frontmatter (voir la section « Portabilité » du `SKILL.md`). Hermès lit ce champ nativement et n'offre pas une skill dont la plateforme ne correspond pas à la machine : c'est le filet qui évite qu'une skill écrite pour macOS soit proposée sur un VPS Linux, puis échoue. Claude Code et Codex ne lisent pas ce champ, la restriction y reste documentaire.

**Limites par environnement** (à remplir dès que la skill n'est pas `portable: oui` ; supprimer ce tableau sinon). Une ligne par opération plutôt qu'une phrase de synthèse : c'est ce qui permet à un agent de savoir s'il peut faire *cette* action-là depuis *cette* machine.

| Opération | macOS | Linux / VPS | Blocage et conduite à tenir |
|---|---|---|---|
| `<opération 1>` | oui | oui | — |
| `<opération 2>` | oui | non | `<ce qui manque, et ce que l'agent fait à la place>` |

Par défaut, Claude Code et Codex installent un **lien symbolique relatif** vers la source canonique plutôt qu'une copie : une seule source à éditer (`98_configuration/skills/<outil>/`), aucune dérive possible entre le canon et les copies installées. Contrepartie assumée : un outil d'archive/zip qui ne préserve pas les liens symboliques (ou ne les déréférence pas correctement) casse l'installation — vérifier après tout transfert (section Vérification post-installation).

### Claude Code

```sh
mkdir -p <projet>/.claude/skills
cd <projet>/.claude/skills && ln -s ../../98_configuration/skills/<outil> <outil>
```

Installation globale possible (`~/.claude/skills/<outil>/`, alors en copie `cp -r` puisque hors du projet) si la skill doit être disponible hors du projet.

### Codex

Chemin projet réel vérifié en exécution : `.agents/skills/` (pas `.codex/skills/` — vérifier ce chemin au premier essai plutôt que de le supposer figé, l'outillage Codex évolue).

```sh
mkdir -p <projet>/.agents/skills
cd <projet>/.agents/skills && ln -s ../../98_configuration/skills/<outil> <outil>
```

### Hermès

Ni copie ni lien : le catalogue du projet se **déclare** dans la configuration du profil (DEC-0040). Une seule commande couvre toutes les skills du catalogue, y compris celles qui n'existent pas encore :

```sh
hermes config set skills.external_dirs '<projet>/98_configuration/skills'
```

Trois précautions, toutes vérifiées par exécution :

- **Une chaîne simple, jamais une liste JSON.** `hermes config set` n'écrit que des chaînes : une valeur entre crochets est stockée littéralement, résolue en un chemin unique inexistant, puis ignorée sans aucun message. Pour déclarer plusieurs dossiers, éditer le fichier de configuration à la main.
- **Le bit d'exécution ne survit pas à la synchronisation** : les scripts arrivent en `644` côté VPS. Soit on rétablit les permissions sur place, soit les recettes du `SKILL.md` appellent `bash scripts/<script>.sh` plutôt que `./scripts/<script>.sh`.
- **Ne pas vérifier avec `hermes skills list`**, qui n'observe pas le registre réellement offert à l'agent. Contrôle correct :

  ```sh
  cd <repo hermes> && HERMES_HOME=~/.hermes/profiles/<profil> ./.venv/bin/python -c "
  from agent.skill_commands import scan_skill_commands
  cmds = scan_skill_commands()
  print(len(cmds), cmds.get('/<outil>', {}).get('skill_dir'))
  "
  ```

  La source affichée doit être celle du catalogue du projet.

Une skill qui n'a pas sa place dans le catalogue générique, parce qu'elle est propre à Hermès, s'installe par lien symbolique dans `~/.hermes/profiles/<profil>/skills/`. La copie physique globale dans `~/.hermes/skills/` est abandonnée : sur un déploiement profilé, elle n'est pas offerte à l'agent.

Il n'y a plus de mise à jour à faire : la déclaration pointant sur la source du projet, toute modification du catalogue est prise en compte sans geste.

### OpenCode

Rien à installer : OpenCode découvre `.claude/skills/` et `.agents/skills/`, donc il voit les liens déjà posés pour Claude Code et Codex. Son emplacement propre, si la skill ne doit être offerte qu'à lui, est `.opencode/skill/<outil>` (même mode, lien symbolique relatif).

### Ne pas installer pour `<agent>`

<Section à écrire uniquement si la skill porte `portable: non`. La supprimer sinon.>

**Cette skill ne doit pas être installée pour `<agent>`.** C'est une décision, pas un manque de moyens : `<la raison, en une phrase>`. Document qui la porte : `<chemin>`. Ne pas migrer les clés vers un backend accessible depuis cette machine pour « débloquer » la situation.

Si elle s'y trouve déjà, la retirer : `rm -rf <chemin d'installation de l'agent>/<outil>`.

Conduite à tenir pour l'agent qui rencontre ce besoin depuis la mauvaise machine : préparer l'intervention (commandes exactes, contexte, ce qu'il faut vérifier), la remettre à l'humain ou à l'agent habilité, **ne pas contourner**.

Pour Hermès, la non-installation reste un mécanisme dur et non une consigne, mais elle se joue désormais sur la déclaration : une skill qui ne doit pas lui être offerte ne vit pas dans le catalogue déclaré en `external_dirs`, elle est rangée hors de ce dossier. Ce qui n'est pas déclaré n'existe pas pour lui. C'est la raison pour laquelle une restriction par décision ne se traduit pas en `platforms:` (voir la section « Portabilité » du `SKILL.md`).

## Configuration des secrets par environnement

Le résolveur `scripts/secrets.sh` lit, dans l'ordre : variables d'environnement déjà posées, puis le backend désigné par `<PREFIXE>_SECRET_BACKEND`. Choisir UNE voie ci-dessous ; ne consigner dans le projet que le NOM du backend et les NOMS de clés, jamais une valeur.

### macOS — trousseau (backend `keychain`, défaut si `security` existe)

Commande exécutée par l'utilisateur lui-même (saisie hors-bande) :

```sh
security add-generic-password -a <cle minuscule> -s <prefixe minuscule> -w '<valeur>' -U
```

### SOPS + age (backend `sops`, recommandé sur VPS — DEC-0031)

Prérequis : binaires `sops` et `age` (Mac : `brew install sops age` ; Debian/Ubuntu : `apt install sops age` ou binaires GitHub). Boîte à secrets unique par défaut : `~/.config/secrets/secrets.env` (chiffrée au repos, synchronisable sans risque), clé age au chemin standard `~/.config/sops/age/keys.txt` (chmod 600, HORS du dossier projet, seul secret racine de la machine). Saisie hors-bande des valeurs : script `ajout-secret.sh` du dépôt méthode (deux questions, saisie masquée) ou, chez Hermès, hook Telegram `/secret` (voir `agents/hermes.md`) — jamais par la conversation.

```sh
export <PREFIXE>_SECRET_BACKEND=sops
export <PREFIXE>_SOPS_FILE="$HOME/.config/secrets/secrets.env"   # optionnel, c'est le défaut
```

Le backend `infisical` (cloud) reste supporté par `secrets.sh` si l'utilisateur a déjà un compte Infisical (`<PREFIXE>_SECRET_BACKEND=infisical`, CLI authentifiée, conventions en en-tête de `secrets.sh`).

### Bitwarden Secrets Manager (backend `bws`, si l'utilisateur l'utilise déjà)

```sh
export BWS_ACCESS_TOKEN='<token machine account>'
export <PREFIXE>_SECRET_BACKEND=bws
export <PREFIXE>_BWS_<CLE>_UUID='<uuid du secret>'
```

### Fichier 600 (backend `file`, dernier recours, VPS sans autre voie)

À faire en SSH direct, **hors du dossier projet** (un dossier synchronisé propagerait le secret) :

```sh
mkdir -p ~/.config/<prefixe minuscule>
cat > ~/.config/<prefixe minuscule>/secrets.env <<'EOF'
<PREFIXE>_<CLE>=<valeur>
EOF
chmod 600 ~/.config/<prefixe minuscule>/secrets.env
```

`secrets.sh` refuse le fichier si les permissions ne sont pas à 600. Chemin surchargeable par `<PREFIXE>_SECRETS_FILE`.

### Windows (documentation seule, non testé)

Passer par WSL et suivre les voies Linux ci-dessus (sops ou fichier). Le Credential Manager natif n'est pas outillé par cette skill.

## Vérification post-installation

```sh
<commande de smoke test, exit 0 attendu>
```

Pour une installation par lien symbolique (Claude Code, Codex), vérifier aussi que le lien résout bien vers la source canonique, surtout après un transfert (zip, archive, nouvelle machine) :

```sh
test -L <projet>/.claude/skills/<outil> && ls -L <projet>/.claude/skills/<outil>/SKILL.md
```

Une commande en échec signale un lien cassé (source déplacée ou non préservée par l'outil de transfert utilisé) : recréer le lien plutôt que d'ignorer l'erreur.

Une fois vérifié, renseigner sa ligne au tableau d'équipement de `98_configuration/GOUVERNANCE_<OUTIL>.md` (agent, chemin d'installation, backend de secrets, date, résultat du test).
