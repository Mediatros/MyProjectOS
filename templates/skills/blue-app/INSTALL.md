# Installation de la skill `blue-app`

> Source canonique dans un projet : `98_configuration/skills/blue-app/` (copie synchronisée Syncthing, posée quand la brique Blue est activée). Chaque agent installe ensuite sa propre copie selon sa plateforme, puis renseigne sa ligne dans le tableau « Accès technique » de `98_configuration/GOUVERNANCE_BLUE.md`.

## Prérequis

- CLI `blue` : `brew install heyblueteam/tap/blue-cli` (Mac) ou binaire GitHub `heyblueteam/cli` (Linux/VPS).
- `curl` et `jq` (requis par `scripts/blue-gql.sh` et `scripts/blue-files.sh`).

## Installation par agent

Par défaut, Claude Code et Codex installent un **lien symbolique relatif** vers la source canonique plutôt qu'une copie : une seule source à éditer, aucune dérive possible entre le canon et les copies installées (voir DEC-0034). Contrepartie : un outil d'archive/zip qui ne préserve pas les liens casse l'installation — à vérifier après tout transfert.

### Claude Code

```sh
mkdir -p <projet>/.claude/skills
cd <projet>/.claude/skills && ln -s ../../98_configuration/skills/blue-app blue-app
```

Installation globale possible (`~/.claude/skills/blue-app/`, alors en copie `cp -r` puisque hors du projet) si la skill doit être disponible hors du projet. **Attention** : en cas de nom identique, Claude Code donne priorité à une skill personnelle sur celle du projet — une copie globale masquerait alors silencieusement le lien déjà posé vers la source du projet.

### Codex

Chemin projet réel vérifié en exécution (dogfood d'un autre projet, 2026-07-15) : `.agents/skills/` (pas `.codex/skills/` comme documenté précédemment).

```sh
mkdir -p <projet>/.agents/skills
cd <projet>/.agents/skills && ln -s ../../98_configuration/skills/blue-app blue-app
```

### Hermès

Depuis DEC-0040, Hermès reçoit `blue-app` par déclaration de profil, pas par copie : la clé `skills.external_dirs` désigne le catalogue entier du projet, `blue-app` compris.

```sh
hermes config set skills.external_dirs '<projet>/98_configuration/skills'
```

Vérifier avec `scan_skill_commands()` (voir `agents/hermes.md`, ne pas se fier à `hermes skills list`) que `/blue-app` est bien offerte, source `98_configuration/skills/blue-app`.

**La copie physique globale (`cp -r ... ~/.hermes/skills/blue-app`) est abandonnée** : sur un déploiement profilé, le dossier scanné est celui du profil actif, pas le dossier global, donc une skill déposée là n'était pas offerte à l'agent. Observation historique du 2026-07-12, avant cette correction : un dossier plat `blue-app/` déposé dans `~/.hermes/skills/` était bien découvert comme skill « locale » par `hermes skills list` — commande qui n'observe justement pas le registre réellement offert (DEC-0040).

Mise à jour ultérieure : rien à faire skill par skill, la déclaration porte sur le dossier entier.

## Configuration des secrets par environnement

### macOS — trousseau (`security`, backend `keychain`, défaut)

```sh
security add-generic-password -a client_id  -s blue-cli -w '<valeur client_id>' -U
security add-generic-password -a auth_token -s blue-cli -w '<valeur auth_token>' -U
```

### Bitwarden Secrets Manager (`bws`, backend `bws`, toutes plateformes)

```sh
export BWS_ACCESS_TOKEN='<token machine account>'
export BLUE_SECRET_BACKEND=bws
export BLUE_BWS_TOKEN_ID_UUID='<uuid du secret client_id>'
export BLUE_BWS_TOKEN_SECRET_UUID='<uuid du secret auth_token>'
```

### VPS Linux headless (backend `file`, nominal pour Hermès)

À faire **en SSH direct sur le VPS**, jamais via le dossier projet synchronisé (Syncthing propagerait le secret) :

```sh
mkdir -p ~/.config/blue
cat > ~/.config/blue/secrets.env <<'EOF'
BLUE_TOKEN_ID=<valeur client_id>
BLUE_TOKEN_SECRET=<valeur auth_token>
EOF
chmod 600 ~/.config/blue/secrets.env
```

`blue-secrets.sh` refuse le fichier si les permissions ne sont pas à 600. Chemin surchargeable par `BLUE_SECRETS_FILE`.

Cas observé (2026-07-12) : si le déploiement Hermès applique déjà ses secrets par une couche Bitwarden (variables `BLUE_TOKEN_ID`/`BLUE_TOKEN_SECRET` exportées dans la session de l'agent), la voie 1 (env, prioritaire) suffit sans configuration ; le fichier 600 n'est alors qu'un repli pour les exécutions hors session Hermès (SSH direct, cron).

### Windows (documentation seule, non testé à ce jour, source datée 2026-07-12)

Aucun script fourni. Utiliser PowerShell `SecretManagement`/`SecretStore` pour poser les variables d'environnement avant de lancer l'agent (les variables déjà posées ont priorité absolue dans `blue-secrets.sh`) :

```powershell
$env:BLUE_TOKEN_ID     = Get-Secret -Name blue-client-id  -AsPlainText
$env:BLUE_TOKEN_SECRET = Get-Secret -Name blue-auth-token -AsPlainText
```

## Vérification post-installation

```sh
BLUE_ORG=<org> scripts/blue-gql.sh --check
```

Attendu : message OK, exit 0. En cas d'échec, message clair et exit non nul (backend absent ou mal configuré, pas de faux succès). Vérification de découverte : la skill doit apparaître dans `hermes skills list` (Hermès) ; Codex et Claude Code découvrent le dossier au démarrage de session. Pour une installation par lien symbolique, vérifier aussi qu'il résout : `test -L <projet>/.claude/skills/blue-app && ls -L <projet>/.claude/skills/blue-app/SKILL.md`.

Une fois vérifié, renseigner sa ligne dans le tableau « Accès technique » de `98_configuration/GOUVERNANCE_BLUE.md` du projet (agent, chemin d'installation, backend de secrets, date).
