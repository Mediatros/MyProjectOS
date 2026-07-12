# Installation de la skill `blue-app`

> Source canonique dans un projet : `98_configuration/skills/blue-app/` (copie synchronisée Syncthing, posée quand la brique Blue est activée). Chaque agent installe ensuite sa propre copie selon sa plateforme, puis renseigne sa ligne dans le tableau « Accès technique » de `98_configuration/GOUVERNANCE_BLUE.md`.

## Prérequis

- CLI `blue` : `brew install heyblueteam/tap/blue-cli` (Mac) ou binaire GitHub `heyblueteam/cli` (Linux/VPS).
- `curl` et `jq` (requis par `scripts/blue-gql.sh` et `scripts/blue-files.sh`).

## Installation par agent

### Claude Code

```sh
mkdir -p <projet>/.claude/skills
cp -r <projet>/98_configuration/skills/blue-app <projet>/.claude/skills/blue-app
```

Installation globale possible (`~/.claude/skills/blue-app/`) si la skill doit être disponible hors du projet.

### Codex

```sh
mkdir -p <projet>/.codex/skills
cp -r <projet>/98_configuration/skills/blue-app <projet>/.codex/skills/blue-app
```

Installation globale possible (`~/.codex/skills/blue-app/`).

### Hermès

Copie unique globale (pas d'installation par projet, décision D3 du plan d'origine) vers le dossier skills d'Hermès :

```sh
cp -r <projet>/98_configuration/skills/blue-app ~/.hermes/skills/blue-app
```

Vérifié en réel le 2026-07-12 : un dossier plat `blue-app/` (avec `SKILL.md` à la racine) déposé dans `~/.hermes/skills/` est découvert comme skill « local » et activé (`hermes skills list`). Un déploiement Hermès peut aussi exposer des skills par profil (`~/.hermes/profiles/<profil>/skills/`) : la copie globale reste le choix canonique, elle sert tous les profils. Si Hermès tourne en root, `~` est `/root`.

Mise à jour ultérieure : via une entrée de handoff « Équiper un agent » (voir `templates/configuration/HANDOFF_INTERAGENT.md`), en recopiant depuis la source projet.

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

Attendu : message OK, exit 0. En cas d'échec, message clair et exit non nul (backend absent ou mal configuré, pas de faux succès). Vérification de découverte : la skill doit apparaître dans `hermes skills list` (Hermès) ; Codex et Claude Code découvrent le dossier au démarrage de session.

Une fois vérifié, renseigner sa ligne dans le tableau « Accès technique » de `98_configuration/GOUVERNANCE_BLUE.md` du projet (agent, chemin d'installation, backend de secrets, date).
