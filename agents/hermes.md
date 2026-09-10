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

Hermès détecte et charge automatiquement plusieurs fichiers à la racine du projet : `AGENTS.md`, `CLAUDE.md`, `.hermes.md`, `SOUL.md`, `.cursorrules`. Ils sont injectés dans son prompt système et tronqués au-delà d'une limite.

**Cette limite n'est plus fixe** (vérifié dans le code Hermès le 2026-08-07, DEC-0037). Ordre de résolution : un `context_file_max_chars` explicite dans la configuration l'emporte toujours ; sinon la limite est calculée à partir de la fenêtre de contexte du modèle, avec un plancher à **20 000 caractères** et un plafond à 500 000 ; le plancher s'applique aussi quand la fenêtre du modèle n'est pas résolue. Les 20 000 caractères sont donc un repli, plus une limite : sur un modèle à large fenêtre, un `AGENTS.md` de 40 000 caractères passe souvent sans être coupé.

Un `AGENTS.md` qui dépasse la limite effective est silencieusement coupé (tête et queue conservées, milieu remplacé par un marqueur) : en usage mobile (Hermès comme seul point d'accès, sans historique de conversation Claude Code pour compenser), la partie tronquée devient invisible à l'agent. `scripts/check-project.sh` avertit au-delà de 20 000 caractères. Ce seuil est délibérément conservateur : c'est le repli réel quand la fenêtre du modèle est inconnue, donc le seul chiffre sûr sans connaître le modèle servi.

Trois leviers si un projet approche la limite : dégraisser `AGENTS.md` (renvoyer vers `docs/` plutôt que dupliquer le contenu), relever `context_file_max_chars` côté configuration Hermès, ou servir Hermès avec un modèle à plus grande fenêtre (la limite suit automatiquement). Les deux derniers échappent à ce repo.

**Cette limite ne concerne pas les `SKILL.md`.** La troncature ne s'applique qu'aux cinq fichiers de contexte listés ci-dessus ; les skills sont lues intégralement, sans plafond. Contre-preuve : plusieurs skills livrées avec Hermès dépassent largement 20 000 caractères, l'une d'elles atteignant 74 000. Le budget pertinent pour un `SKILL.md` est celui du standard Agent Skills, soit 500 lignes de corps, au-delà duquel il faut externaliser dans un fichier compagnon.

## Filtrage natif des skills par plateforme

Hermès lit un champ `platforms:` au frontmatter d'un `SKILL.md` et **n'offre pas** une skill dont la plateforme ne correspond pas à la machine courante :

```yaml
platforms: [macos]           # écartée sur Linux et Windows
platforms: [macos, linux]
```

Valeurs reconnues : `macos`, `linux`, `windows`. Champ absent ou vide égale compatible partout, donc rétrocompatible. Le filtre agit au moment de l'offre : un chargement explicite le contourne. Vérifié par exécution le 2026-08-07 (6 cas sur 6, DEC-0037).

C'est le filet contre le scénario du RETEX d'un projet Code+Knowledge : une skill écrite pour macOS qui arrive sur un VPS Linux par synchronisation, est proposée, puis échoue. Avec `platforms: [macos]`, elle n'est jamais proposée. Claude Code et Codex ne lisent pas ce champ.

Un second champ existe, `environments:` (`kanban`, `docker`, `s6`), **écarté du canon MyProjectOS** : ses valeurs sont internes à l'infrastructure Hermès, et sa détection s'est révélée en faux positif au test (un hôte où Docker est simplement installé est vu comme un conteneur). Un tag non reconnu n'y écarte jamais la skill, donc une faute de frappe n'y filtre rien en silence.

## Portabilité des garde-fous (ROADMAP, Phase 7)

Hermès supporte **MCP** et le standard ouvert **agentskills.io** (dossier + `SKILL.md` à frontmatter YAML). Deux pistes pour lui faire respecter les mêmes garde-fous que Claude Code :

1. **MCP partagé** : exposer la couche gouvernance + l'assistant via un serveur MCP commun aux deux agents.
2. **Double skill** : publier une skill équivalente sur agentskills.io, consommable par Hermès.

Tant que ce n'est pas fait, le contrat minimal d'Hermès est : **respecter la gouvernance Markdown**. La reprise à froid garantit qu'il peut le faire sans la skill `my-project-os` elle-même (celle-ci reste spécifique au poste Mac, voir « Ses frontières » ci-dessus).

**Premier cas concret réalisé** (brique Blue, 2026-07-12) : une skill *technique* (pas la skill assistant de méthode) portée dans `templates/skills/blue-app/` est installée à l'identique chez Hermès, Claude Code et Codex, preuve que le standard agentskills.io permet bien de partager une capacité entre les trois agents.

## Comment Hermès reçoit les skills d'un projet

La voie canonique est la **déclaration**, pas la copie (DEC-0040). Le catalogue du projet est désigné en une ligne dans la configuration du profil :

```sh
hermes config set skills.external_dirs '<projet>/98_configuration/skills'
```

Hermès scanne alors ce dossier comme le sien : toutes les skills du catalogue, présentes et futures, sont offertes sans installation, sans copie et sans lien. Le code les marque « externes », donc en lecture seule pour sa maintenance autonome. La déclaration est une ligne de configuration, elle survit à un `profile export/import`.

**La copie physique globale dans `~/.hermes/skills/` est abandonnée.** Le motif n'est pas la dérive qu'on lui reprochait, mais un défaut plus net : sur un **déploiement profilé** (`~/.hermes/profiles/<profil>/`), le dossier scanné est celui du profil actif, donc une skill déposée dans le dossier global n'est tout simplement pas offerte. Elle existe sur le disque et l'agent ne la voit pas. Une variante propre à un agent, hors catalogue, s'installe par lien symbolique dans le dossier de skills du profil.

Deux pièges vérifiés par exécution. La valeur doit être une **chaîne simple** : `hermes config set` n'écrit que des chaînes, et une valeur ressemblant à une liste JSON est stockée telle quelle, résolue en un chemin unique inexistant, puis ignorée **sans le moindre message**. Déclarer plusieurs dossiers suppose d'éditer le fichier de configuration à la main. Et la synchronisation ne propage pas le bit d'exécution : les scripts du catalogue arrivent en `644`, donc soit les permissions sont rétablies côté VPS, soit les recettes appellent `bash scripts/<script>.sh`.

**Ne pas vérifier avec `hermes skills list`** : cette commande n'observe pas le registre réellement offert. Sur un même profil, elle a renvoyé 224 skills là où le dossier du profil en contenait 174 et où le registre effectif en comptait 148. Le contrôle correct porte sur le chemin de code que l'agent emprunte :

```sh
cd <repo hermes> && HERMES_HOME=~/.hermes/profiles/<profil> ./.venv/bin/python -c "
from agent.skill_commands import scan_skill_commands
cmds = scan_skill_commands()
print(len(cmds), cmds.get('/<skill>', {}).get('skill_dir'))
"
```

## Saisie de secrets hors-LLM : hook gateway `/secret` (cible DEC-0031, à valider en réel)

La brique secrets VPS est SOPS + age (backend `sops` de `secrets.sh`, boîte `~/.config/secrets/secrets.env`). Pour ajouter une valeur depuis Telegram sans qu'elle ne transite par le LLM, la cible est un **hook de gateway** Hermès : un répertoire sous `~/.hermes/hooks/` (un `HOOK.yaml` + un `handler.py`) abonné à l'événement `command:secret`, qui intercepte `/secret NOM valeur` au niveau de la gateway Telegram, AVANT le LLM.

Comportement du handler :

1. Vérifier que l'expéditeur est l'user ID Telegram de l'utilisateur (sinon ignorer).
2. Exécuter `sops set` sur la boîte (équivalent de `scripts/ajout-secret.sh`, non interactif).
3. Supprimer le message Telegram d'origine via l'API Bot (la valeur quitte l'historique du chat).
4. Répondre « Secret NOM enregistré », sans jamais citer la valeur.

Garanties et limites : rien n'atteint le contexte ni les logs de session du LLM ; en revanche la valeur transite par les serveurs Telegram (pas de chiffrement de bout en bout avec un bot) et existe brièvement dans l'historique avant suppression. Pour un secret critique, préférer la saisie côté Mac (`scripts/ajout-secret.sh`, la boîte chiffrée voyage ensuite par Syncthing).

Protocole de validation obligatoire avant toute vraie valeur : poser d'abord un hook à blanc qui logue « intercepté » et vérifier qu'un `/secret TEST x` n'apparaît nulle part dans la session LLM (vigilance : l'issue hermes-agent #2817 signale des hooks documentés côté plugins jamais invoqués ; les hooks de gateway `command:*` sont un mécanisme distinct, mais la preuve d'interception doit être faite en réel).

## Voir aussi

- `docs/skills-portables.md` — le dispositif complet des skills de projet, dont le filtre `platforms:` et la déclaration `external_dirs` côté Hermès.
- `agents/claude-code.md` — l'agent principal côté Mac.
- `agents/meta-skill.md` — la skill que Claude Code exécute et qu'Hermès n'exécute pas encore.
- `docs/governance.md` — les règles communes aux deux agents.
