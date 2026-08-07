# RETEX — Clé API AllDebrid : faux diagnostic d'une panne d'auth (deux chemins BWS)

> Retour d'expérience issu du profil Hermes `mysecretaire` (agent manager) sur le VPS.
> Date : 2026-08-02.
> Statut : ouvert. L'alignement des copies divergentes est fait côté infrastructure Hermès (CHG-20260802-2341). Sur les trois pistes de fin de document, deux relèvent de la gouvernance Hermès et sortent du canon ; une seule le touche, le contrôle d'empreinte anti-dérive des skills répliquées, à trancher (T-RETEX-2).

## Objet du RETEX

Une skill tiers (`alldebrid-magnet-downloads`) remontait un blocage « clé API AllDebrid inaccessible » avec comme cause annoncée **« token BWS expiré/révoqué (`invalid_client`), il faut ré-authentifier BWS »**. La vérification terrain a prouvé que ce diagnostic était **faux** : le token BWS était valide, la clé était déjà injectée dans l'environnement des gateways, et le blocage réel du pipeline (quand il existait) était ailleurs. Ce RETEX consigne le pattern à retenir pour éviter de re-conclure à une panne d'auth à tort, et la dérive constatée des copies répliquées entre profils.

## Le contexte technique : deux chemins BWS co-existent

Sur cette infrastructure, il y a **deux mécanismes** qui parlent à Bitwarden Secrets Manager :

1. **BWS natif Hermes** (`agent/secret_sources/registry.apply_all`) — au démarrage du process Python, il injecte **toutes les clés du projet BWS dans `os.environ`** via `env[var] = value`. C'est le chemin que les skills utilisent via `os.getenv('...')`. Vérifié : `apply_all` applique 38 secrets (dont `ALLDEBRID_API_KEY`, `AGENTMAIL_API_KEY`, `TUBEONAI_API_KEY`).
2. **Binaire `bws` CLI direct** (`/root/.hermes/bin/bws`, `bws_get` on-demand) — un chemin séparé, ciblé, utilisé pour la résolution ponctuelle d'un secret sans le charger dans l'environnement.

## Constat 1 — Le diagnostic « token BWS expiré » était faux

Le rapport de l'agent annonçait `invalid_client` sur le token BWS et recommandait une ré-authentification. Preuves contraires produites :

- `load_hermes_dotenv()` → `apply_all` → « Bitwarden Secrets Manager: applied 38 secrets (… ALLDEBRID_API_KEY …) » ; `os.getenv('ALLDEBRID_API_KEY')` renvoie la clé (len=20) **dans le contexte Hermes**.
- Le binaire `bws` CLI + token du process → « OK — 39 secrets ». Aucun `invalid_client`.
- Le resolver on-demand `bws_get ALLDEBRID_API_KEY --check` → `resolved`, rc=0.

Le `invalid_client` constaté historiquement venait d'un **autre chemin** (binaire CLI avec un token périmé), pas du chemin d'injection natif qui fonctionne. L'agent a testé le mauvais chemin, vu l'erreur, et généralisé à tort.

**Leçon 1 :** quand un rapport dit « la clé est inaccessible / token cassé », vérifier **les deux chemins** (natif env vs CLI) et le **test de présence réel** (`os.getenv` dans le runtime) avant de conclure — et ne jamais proposer une ré-authentification sans preuve que le token est réellement invalide sur le chemin effectivement utilisé.

## Constat 2 — La vraie cause des blocages AllDebrid passés n'était pas la clé

L'historique réel du pipeline AllDebrid montrait des blocages **non liés à l'authentification** :

- `NO_SERVER` — serveur d'upload AllDebrid indisponible (côté AllDebrid, pas chez nous).
- `MAGNET_INVALID_ID` — magnet 645888391 périmé/invalidé.
- `Permission denied: '/volume1/Téléchargements'` — droits d'écriture insuffisants sur le dossier NAS.

**Leçon 2 :** une erreur de téléchargement ≠ une erreur de clé. Avant de conclure « clé à régénérer », vérifier l'état réel de la ressource externe (serveur, magnet, droits filesystem).

## Constat 3 — Dérive des copies répliquées entre profils

La skill AllDebrid existait en **4 copies** sur le serveur (skill globale `default`, profils `workerexec`, `mysecretaire`, `kimi-k3`). **3 copies étaient déjà identiques** (`2164c18c…`), mais celle de `mysecretaire` divergeait (`a7a2d4f6…`) : c'était une version plus ancienne avec un fallback codé en dur sur un seul chemin (`/root/.hermes/profiles/mysecretaire/bin/bws_get`), au lieu du fallback générique qui découvre `bws_get` partout.

**Leçon 3 :** toute skill répliquée entre agents/profils doit avoir une **source canonique unique** et un mécanisme qui empêche la dérive (lien symbolique relatif, ou contrôle d'empreinte/hash), sans quoi une seule instance éditée crée un comportement divergent selon le profil — exactement le risque que MyProjectOS adresse déjà pour les skills projet (voir `RETEX/retex-lino-skills-portables-agent-agnostique.md`, DEC-0034).

## Action réalisée (2026-08-02)

- **Aligné** le script `get_magnet_links.py` de `mysecretaire` sur la source canonique (fallback générique `bws_get` via glob des profils + `hermes bws get` en second repli).
- Remplacé le wrapper local `run.sh` par le `run_with_bws.sh` standard ; retiré l'ancien wrapper.
- **Vérifié** que les 4 copies sont désormais identiques (même hash `2164c18c…`).
- **Rappel** : le script lit d'abord `os.getenv('ALLDEBRID_API_KEY')` (déjà injecté par le BWS natif), le fallback `bws_get` n'est qu'un filet de sécurité ; la valeur n'est jamais persistée ni affichée (lue, passée à l'appel API, relâchée).
- **Contrôlé** l'état des deux autres secrets du même schéma : `AGENTMAIL_API_KEY` (présent, HTTP 200 sur `/v0/inboxes`) et `TUBEONAI_API_KEY` (présent). Aucun blocage réel.

## Leçon transversale pour MyProjectOS

1. **« Clé inaccessible » est un diagnostic à prouver, pas à inférer.** Sur une infra à secrets centralisés (BWS/Bitwarden), distinguer toujours : clé absente de l'env, intégration non câblée, reseau/API externe down, droits fichiers, et token réellement invalide. La vérification du chemin natif (`os.getenv`) prime sur le binaire CLI séparé.
2. **Ne jamais re-authentifier un fournisseur de secrets sans preuve.** Ré-authentifier BWS = effet de bord (nouveau token, risque de casser les autres consommateurs) ; c'est l'ultime recours, jamais la première hypothèse.
3. **Toute ressource répliquée entre profils a besoin d'une source unique.** Le pattern déjà canonisé (lien symbolique / contrôle d'empreinte) doit aussi s'appliquer aux skills techniques installées dans plusieurs profils Hermes sur un même hôte, pas seulement aux skills projet multi-agents.

## Pistes de décision (à trancher avec Jihad si souhaité)

- Faire migrer les skills techniques Hermès répliquées vers une **installation par lien symbolique relatif** vers `/root/.hermes/skills/` (source canonique unique), au lieu de copies physiques par profil — aligné sur DEC-0029/DEC-0034.
- Ajouter un **contrôle d'empreinte/hash** des skills critiques dans `check-project.sh` ou un watchdog, pour détecter toute dérive de copie avant qu'elle ne produise un faux diagnostic.
- Documenter dans la gouvernance Hermes les **deux chemins BWS** (natif env vs CLI on-demand) pour éviter qu'un agent les confonde et conclue à une panne d'auth.
