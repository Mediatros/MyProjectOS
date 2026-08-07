---
name: <outil>
description: <Ce que la skill permet de faire, en une ou deux phrases orientées déclencheurs : quand l'agent doit-il la charger ? Citer les mots que l'utilisateur emploierait.>
---

# <Outil> — <rôle en une ligne>

> Squelette de skill portable MyProjectOS. Remplacer chaque bloc `<...>` puis supprimer cette note.
> Règles du pattern : agent-agnostique (Claude Code, Codex, Hermès — standard agentskills.io), aucun identifiant ni secret en dur (les IDs vivent dans la gouvernance du projet, les secrets dans un backend via `scripts/secrets.sh`), corps du `SKILL.md` sous 500 lignes (budget officiel Agent Skills — au-delà, externaliser dans un fichier compagnon référencé depuis ce fichier, à un seul niveau de profondeur).

## Ce que fait cette skill

<Périmètre en 3-5 lignes : ce qu'elle couvre, ce qu'elle ne couvre pas.>

## Prérequis

<Binaire(s) requis et commande d'installation par plateforme. Secrets attendus : noms de clés uniquement, jamais de valeur.>

## Portabilité

<Une skill posée dans un projet synchronisé finit sur toutes les machines du projet. Si elle ne peut pas tourner partout, le dire ici ET au frontmatter.>

Si la skill est restreinte, **ajouter une ligne `platforms:` au frontmatter ci-dessus** (lue nativement par Hermès, vérifiée par exécution le 2026-08-07) : une skill dont la plateforme ne correspond pas à la machine courante n'est alors **pas proposée** à l'agent, au lieu d'être proposée puis d'échouer.

```yaml
platforms: [macos]           # macOS uniquement (ex. trousseau, AppleScript, chemins /Users/...)
platforms: [macos, linux]    # les deux
platforms: [linux]           # VPS uniquement
```

Valeurs reconnues : `macos`, `linux`, `windows`. **Champ absent égale compatible partout**, c'est le défaut : ne l'ajouter que si la skill est réellement restreinte. Ne pas le mettre en commentaire dans le frontmatter, le lecteur de frontmatter d'Hermès ne traite pas les commentaires YAML et en ferait une clé parasite.

Deux cas à ne pas confondre :

- **restriction technique** (la skill ne peut pas tourner ailleurs) : renseigner `platforms:` et expliquer pourquoi en une ligne ci-dessous ;
- **restriction par décision** (elle pourrait tourner ailleurs, mais on ne le veut pas, par exemple un accès SSH client qu'un agent joignable depuis un téléphone ne doit pas atteindre) : l'écrire comme une décision et non comme un manque, avec la raison et le renvoi au document qui la porte, plus la conduite à tenir pour l'agent qui rencontre le besoin depuis la mauvaise machine (préparer l'intervention, la remettre à l'humain, ne pas contourner).

## Résolution des secrets

Sourcer le résolveur générique avant tout appel authentifié :

```sh
SECRETS_PREFIX="<PREFIXE>" SECRETS_KEYS="<CLE1> <CLE2>" . "$(dirname "$0")/secrets.sh"
```

Produit les variables `<PREFIXE>_<CLE>` exportées. Ordre de résolution : variables d'environnement déjà posées > backend désigné par `<PREFIXE>_SECRET_BACKEND` (`keychain`, `sops`, `bws`, `infisical`, `file`). Détail des conventions par backend : en-tête de `scripts/secrets.sh` ; choix et pose du backend : `INSTALL.md`.

## Commandes / recettes

<Table de routage ou liste des opérations, avec les commandes exactes vérifiées en réel. Consigner chaque piège découvert (même format que blue-app : symptôme → cause → contournement).>

## Pièges connus

<Alimenter au fil des découvertes ; reporter aussi dans la GOUVERNANCE_<OUTIL>.md du projet si le piège touche l'usage quotidien.>

## Provenance et maintenance

<Date de rédaction, comment re-vérifier (commandes), version de la skill (SemVer). Toute modification du canon (`98_configuration/skills/<outil>/`) se propage aux copies installées via une entrée de handoff « Équiper un agent ».>
