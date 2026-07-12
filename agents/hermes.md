# hermes.md — Rôle et frontières d'Hermès

> Hermès (Nous Research) est un agent autonome hébergé sur le VPS. Il partage les projets avec Claude Code via Syncthing.

## Ce qu'il est

Un agent autonome, distinct de Claude Code. Il **n'exécute pas** Harness ni les hooks Claude Code. Il consomme la méthode par sa couche **gouvernance documentaire** : les fichiers Markdown à noms fixes et à frontières nettes lui suffisent pour reprendre un projet à froid.

## Ce qu'il fait (cible)

- Lire les fichiers sacrés et produire l'état d'un projet, comme en mode reprise.
- Travailler sur les projets Life en priorité (correspondances, échéances, preuves) côté VPS.
- Respecter les mêmes rituels et la même frontière entre fichiers sacrés que Claude Code.

## Ses frontières

- Pas d'exécution de la skill `my-project-os` ni des hooks Claude Code : ces garde-fous sont, à ce stade, spécifiques au poste Mac.
- Mêmes règles de validation humaine que Claude Code sur les actions sensibles.
- Il ne réorganise pas l'arborescence ni la stack sans validation.

## Fichiers de contexte chargés et limite de troncature

Hermès détecte et charge automatiquement plusieurs fichiers à la racine du projet : `AGENTS.md`, `CLAUDE.md`, `.hermes.md`, `SOUL.md`, `.cursorrules`. Ils sont injectés dans son prompt système, chacun tronqué par défaut à **20 000 caractères** (paramètre `context_file_max_chars`, configurable côté déploiement Hermès).

Un `AGENTS.md` qui dépasse ce seuil est silencieusement coupé : en usage mobile (Hermès comme seul point d'accès, sans historique de conversation Claude Code pour compenser), la partie tronquée devient invisible à l'agent. `scripts/check-project.sh` avertit si `AGENTS.md`/`CLAUDE.md` (ou les autres fichiers listés ci-dessus, s'ils existent) dépassent ce seuil.

Deux leviers si un projet approche la limite : dégraisser `AGENTS.md` (renvoyer vers `docs/` plutôt que dupliquer le contenu) ou relever `context_file_max_chars` côté configuration Hermès — ce dernier point échappe à ce repo, à documenter dans la config du VPS le jour où le besoin se confirme.

## Portabilité des garde-fous (ROADMAP, Phase 7)

Hermès supporte **MCP** et le standard ouvert **agentskills.io** (dossier + `SKILL.md` à frontmatter YAML). Deux pistes pour lui faire respecter les mêmes garde-fous que Claude Code :

1. **MCP partagé** : exposer la couche gouvernance + l'assistant via un serveur MCP commun aux deux agents.
2. **Double skill** : publier une skill équivalente sur agentskills.io, consommable par Hermès.

Tant que ce n'est pas fait, le contrat minimal d'Hermès est : **respecter la gouvernance Markdown**. La reprise à froid garantit qu'il peut le faire sans la skill `my-project-os` elle-même (celle-ci reste spécifique au poste Mac, voir « Ses frontières » ci-dessus).

**Premier cas concret réalisé** (brique Blue, 2026-07-12) : une skill *technique* (pas la skill assistant de méthode) portée dans `templates/skills/blue-app/` est installée à l'identique chez Hermès, Claude Code et Codex — preuve que le standard agentskills.io permet bien de partager une capacité entre les trois agents. Emplacement des skills côté Hermès : `~/.hermes/skills/` (source de vérité, copie globale retenue pour `blue-app`) ; des répertoires externes sont aussi déclarables dans `~/.hermes/config.yaml` (`skills.external_dirs`, priorité au local en cas de doublon), écartés pour `blue-app` (skill modifiable par n'importe quelle session touchant le dossier projet, vulnérable aux conflits Syncthing). Le chemin par profil (`~/.hermes/profiles/<profil>/skills/`) coexiste selon le déploiement : vérifier au premier essai plutôt que de le supposer.

## Voir aussi

- `agents/claude-code.md` — l'agent principal côté Mac.
- `agents/meta-skill.md` — la skill que Claude Code exécute et qu'Hermès n'exécute pas encore.
- `docs/governance.md` — les règles communes aux deux agents.
