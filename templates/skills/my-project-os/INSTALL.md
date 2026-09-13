# Installation de la skill `my-project-os`

> Skill assistant de la méthode, posée automatiquement par `init-project.sh` : rien à faire à la main dans le cas courant. Cette page sert de référence pour vérifier l'installation ou la reconstruire après un transfert qui aurait cassé un lien.
> Source canonique dans un projet : `98_configuration/skills/my-project-os/` (copie synchronisée entre machines si le projet l'est). Source dans le dépôt méthode : `templates/skills/my-project-os/SKILL.md`.

## Installation par agent

Posée par `init-project.sh` (création, `--into-existing`, `--update-method`) : la source est copiée dans `98_configuration/skills/my-project-os/SKILL.md`, puis un lien symbolique relatif est posé pour chaque agent à mécanisme de découverte par dossier. Aucune installation manuelle n'est nécessaire.

### Claude Code

```sh
cd <projet>/.claude/skills && ln -s ../../98_configuration/skills/my-project-os my-project-os
```

**Attention** : en cas de nom identique, Claude Code donne priorité à une skill personnelle (`~/.claude/skills/my-project-os/`) sur celle du projet — une copie globale masquerait alors silencieusement le lien déjà posé vers la source du projet. Cette skill n'a pas vocation à être installée globalement : elle est propre à chaque projet MyProjectOS.

### Codex

```sh
cd <projet>/.agents/skills && ln -s ../../98_configuration/skills/my-project-os my-project-os
```

### OpenCode

Rien à installer : OpenCode découvre `.claude/skills/` et `.agents/skills/`, donc il voit les liens déjà posés pour Claude Code et Codex.

### Hermès

Ni copie ni lien : le catalogue du projet se **déclare** dans la configuration du profil (DEC-0040), et couvre `my-project-os` comme toute autre skill du catalogue :

```sh
hermes config set skills.external_dirs '<projet>/98_configuration/skills'
```

### Agent sans mécanisme de découverte

Repli prévu par le contrat d'un agent (§1 du plan de consolidation, DEC-0052) : lire directement `98_configuration/skills/my-project-os/SKILL.md` quand `AGENTS.md` l'indique.

## Vérification post-installation

```sh
test -L <projet>/.claude/skills/my-project-os && ls -L <projet>/.claude/skills/my-project-os/SKILL.md
test -L <projet>/.agents/skills/my-project-os && ls -L <projet>/.agents/skills/my-project-os/SKILL.md
```

Une commande en échec signale un lien cassé ou absent (source déplacée, non préservée par l'outil de transfert utilisé, ou projet pas encore migré) : relancer `init-project.sh --update-method` plutôt que recréer le lien à la main.
