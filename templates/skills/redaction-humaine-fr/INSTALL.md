# Installation de la skill `redaction-humaine-fr`

> Source canonique dans un projet : `98_configuration/skills/redaction-humaine-fr/`. Skill utilitaire sans compte, sans secret et sans dépendance : l'installation est une simple copie.

## Prérequis

Aucun. La skill est un guide de rédaction pur (aucun binaire, aucune clé).

## À savoir avant d'installer

- Deux niveaux : **niveau 1 « soigné »** (défaut, humain sans faute) et **niveau 2 « relâché »** (quelques fautes subtiles crédibles, uniquement sur demande explicite de l'utilisateur).
- Portée : textes publiés ou envoyés **sous le nom de l'utilisateur** (articles, posts, emails, courriers). Elle se combine naturellement avec `courrier-manuscrit` (qui applique son niveau 1 pour le texte des courriers).

## Installation par agent

### Claude Code

```sh
mkdir -p <projet>/.claude/skills
cp -r <projet>/98_configuration/skills/redaction-humaine-fr <projet>/.claude/skills/redaction-humaine-fr
```

Installation globale possible (`~/.claude/skills/redaction-humaine-fr/`) : recommandée, la rédaction sert dans tous les projets.

### Codex

```sh
mkdir -p <projet>/.codex/skills
cp -r <projet>/98_configuration/skills/redaction-humaine-fr <projet>/.codex/skills/redaction-humaine-fr
```

### Hermès

```sh
cp -r <projet>/98_configuration/skills/redaction-humaine-fr ~/.hermes/skills/redaction-humaine-fr
```

Vérification de découverte : `hermes skills list`.

## Vérification post-installation (smoke test)

Demander à l'agent un court paragraphe de test en niveau 1 et vérifier les marqueurs : typographie française (espace avant `:` `!` `?`), aucun tiret cadratin, aucune formule de la liste interdite, rythme de phrases irrégulier. Noter l'installation dans le `CHANGELOG.md` du projet ou au tableau d'équipement si une gouvernance existe.
