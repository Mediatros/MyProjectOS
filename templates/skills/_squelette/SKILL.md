---
name: <outil>
description: <Ce que la skill permet de faire, en une ou deux phrases orientées déclencheurs : quand l'agent doit-il la charger ? Citer les mots que l'utilisateur emploierait.>
---

# <Outil> — <rôle en une ligne>

> Squelette de skill portable MyProjectOS. Remplacer chaque bloc `<...>` puis supprimer cette note.
> Règles du pattern : agent-agnostique (Claude Code, Codex, Hermès — standard agentskills.io), aucun identifiant ni secret en dur (les IDs vivent dans la gouvernance du projet, les secrets dans un backend via `scripts/secrets.sh`), `SKILL.md` sous 20 000 caractères (seuil de troncature Hermès — externaliser les recettes dans un fichier compagnon si besoin).

## Ce que fait cette skill

<Périmètre en 3-5 lignes : ce qu'elle couvre, ce qu'elle ne couvre pas.>

## Prérequis

<Binaire(s) requis et commande d'installation par plateforme. Secrets attendus : noms de clés uniquement, jamais de valeur.>

## Résolution des secrets

Sourcer le résolveur générique avant tout appel authentifié :

```sh
SECRETS_PREFIX="<PREFIXE>" SECRETS_KEYS="<CLE1> <CLE2>" . "$(dirname "$0")/secrets.sh"
```

Produit les variables `<PREFIXE>_<CLE>` exportées. Ordre de résolution : variables d'environnement déjà posées > backend désigné par `<PREFIXE>_SECRET_BACKEND` (`keychain`, `bws`, `infisical`, `file`). Détail des conventions par backend : en-tête de `scripts/secrets.sh` ; choix et pose du backend : `INSTALL.md`.

## Commandes / recettes

<Table de routage ou liste des opérations, avec les commandes exactes vérifiées en réel. Consigner chaque piège découvert (même format que blue-app : symptôme → cause → contournement).>

## Pièges connus

<Alimenter au fil des découvertes ; reporter aussi dans la GOUVERNANCE_<OUTIL>.md du projet si le piège touche l'usage quotidien.>

## Provenance et maintenance

<Date de rédaction, comment re-vérifier (commandes), version de la skill (SemVer). Toute modification du canon (`98_configuration/skills/<outil>/`) se propage aux copies installées via une entrée de handoff « Équiper un agent ».>
