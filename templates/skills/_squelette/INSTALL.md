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

### Claude Code

```sh
mkdir -p <projet>/.claude/skills
cp -r <projet>/98_configuration/skills/<outil> <projet>/.claude/skills/<outil>
```

Installation globale possible (`~/.claude/skills/<outil>/`) si la skill doit être disponible hors du projet.

### Codex

```sh
mkdir -p <projet>/.codex/skills
cp -r <projet>/98_configuration/skills/<outil> <projet>/.codex/skills/<outil>
```

Installation globale possible (`~/.codex/skills/<outil>/`).

### Hermès

Copie unique globale (sert tous les profils ; si Hermès tourne en root, `~` est `/root`) :

```sh
cp -r <projet>/98_configuration/skills/<outil> ~/.hermes/skills/<outil>
```

Vérification de découverte : `hermes skills list`. Mise à jour ultérieure : entrée de handoff « Équiper un agent » (voir `templates/configuration/HANDOFF_INTERAGENT.md`), en recopiant depuis la source projet.

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

Une fois vérifié, renseigner sa ligne au tableau d'équipement de `98_configuration/GOUVERNANCE_<OUTIL>.md` (agent, chemin d'installation, backend de secrets, date, résultat du test).
