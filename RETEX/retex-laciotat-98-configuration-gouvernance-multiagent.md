# RETEX — Dossier `98_configuration/` : gouvernance partagée et handoff inter-agents (LaCIOTAT)

> Retour d'expérience issu du dogfood MyProjectOS sur `/Users/jb/Documents/MyProjects/SYNC/LaCIOTAT` (type Life).
> Date : 2026-07-11.
> Statut : solution locale posée et en usage, évolutions génériques à évaluer pour MyProjectOS.

## Objet du RETEX

Documenter un besoin qui n'avait pas de case dans le canon actuel — des projets pilotés par **plusieurs agents IA distincts** en concurrence sur le même dossier ont besoin (1) d'un endroit pour des règles de configuration/gouvernance partagées entre agents et (2) d'un mécanisme d'échange asynchrone entre agents qui n'ont pas de canal de communication direct — et la solution improvisée localement, pour voir si elle mérite d'entrer dans le canon.

Grille de lecture habituelle :

```text
besoin rencontré dans LaCIOTAT → solution locale appliquée → évolution générique à évaluer pour MyProjectOS
```

## Le contexte

Le projet LaCIOTAT est piloté par plusieurs agents distincts au fil du temps (voir `CLAUDE.md` du projet, section « Agents pouvant intervenir sur ce projet ») : Claude Code (Mac), Hermes Agent (service externe, accès depuis le téléphone), occasionnellement Codex. Chacun a sa propre mémoire, ses propres skills, et pas de visibilité automatique sur ce que fait l'autre.

Le 2026-07-11, une intégration Blue (blue.cc, gestion de tâches) a été mise en place côté Claude Code : une skill technique (`blue-cli-laciotat`) plus un ensemble de règles de fond (nommage des records, usage d'un custom field comme clé de correspondance avec `TASKS.md`, politique de création de sous-tâches/checklists, workflow de synchronisation). Hermes Agent dispose de sa propre skill Blue, indépendante. Sans garde-fou, rien n'empêchait les deux skills de diverger silencieusement sur la façon de remplir Blue (un agent créant des records avec un format de titre différent de l'autre, oubliant le custom field de correspondance, etc.) — un problème de fond, pas un détail cosmétique, car Blue devient alors une source non fiable au lieu d'un miroir fidèle de `TASKS.md`.

Second besoin, plus général : quand un agent a besoin qu'un autre agent exécute une action sur son propre environnement (ex. « mets à jour ta configuration Blue »), il n'existe ni canal de communication ni protocole pour formuler la demande, savoir si elle a été vue, et obtenir confirmation qu'elle a été traitée.

## Solution locale appliquée (LaCIOTAT, 2026-07-11)

Un dossier racine numéroté **`98_configuration/`** a été créé, positionné juste avant `99_archive/` (les projets Life de ce dossier utilisent déjà des extensions numérotées jusqu'à `09_`, ce numéro était donc le premier créneau libre et cohérent avec la sémantique « fin de canon, avant l'archive »). Il contient deux fichiers :

1. **`GOUVERNANCE_BLUE.md`** — source unique de vérité des règles de fond pour l'intégration Blue : IDs de référence (workspace, lists, tags, custom field), règles de nommage des records, politique de création de sous-tâches, workflow de synchronisation pas à pas. Les deux skills (Claude Code et, à terme, Hermes Agent) sont censées **lire ce fichier avant toute opération Blue** plutôt que dupliquer les règles en dur chacune de leur côté — la skill Claude Code (`blue-cli-laciotat`) a été volontairement allégée pour ne garder que sa mécanique technique propre (accès credentials, syntaxe CLI) et renvoyer vers ce fichier pour tout le reste.
2. **`HANDOFF_CLAUDE_HERMES.md`** — boîte aux lettres asynchrone, format append-only, une entrée par demande avec `De` / `À` / `Statut` (`EN_ATTENTE` → `EN_COURS` → `FAIT`/`BLOQUÉ`) / `Demande` / `Réponse`. Le destinataire édite l'entrée existante pour répondre (jamais de suppression, jamais une nouvelle entrée pour la réponse) ; l'émetteur confirme avoir vu la réponse à sa prochaine relecture. Une vérification de ce fichier a été ajoutée aux réflexes de début de session dans `CLAUDE.md` du projet, sur le même principe que le contrôle proactif de `ECHEANCES.md` déjà en place.

Limite assumée et documentée dans le fichier lui-même : ce mécanisme n'a **aucune notification push**. Un agent ne sait qu'une demande lui a été adressée que lorsqu'une session s'ouvre sur le projet et qu'il la lit — le fichier garantit la fidélité de l'échange une fois lu, pas sa vélocité.

## Pourquoi ça ne rentrait dans aucune case existante

| Dossier canon | Pourquoi il ne convient pas |
|---|---|
| `06_preuves/` | Registre de pièces justificatives (P-XXXX), pas de règles de fonctionnement des outils |
| `07_`-`09_` (extensions Life déjà utilisées par LaCIOTAT : fiches prestataires, recherche mail, modèles de courriers) | Contenu métier du dossier de succession, pas de la configuration d'outillage agent |
| `05_correspondances/` / `CORRESPONDANCES.md` | Registre des échanges avec des **tiers humains** (bailleur, notaire...), pas un canal inter-agents IA |
| `99_archive/` | Contenu mort/historique, alors que la gouvernance et le handoff sont des documents **vivants**, relus et modifiés à chaque session |
| `.claude/skills/` | Contient la mécanique technique d'un agent donné, pas des règles censées être lues par plusieurs agents différents avec des mécanismes d'accès distincts |

Aucun de ces emplacements ne convenait à un contenu qui doit être : (a) synchronisé (donc dans le dossier projet, pas dans `~/.claude/skills/` local à une machine), (b) neutre vis-à-vis de l'agent qui le lit, (c) distinct du contenu métier du dossier.

## Évolutions génériques à évaluer pour MyProjectOS

Par ordre de valeur décroissante :

### 1. Canoniser `98_configuration/` (ou un nom équivalent) dans `structures/core-tree.md` (priorité haute)

Slot optionnel entre les extensions numérotées d'un type de projet et `99_archive/`, réservé à la configuration et à la gouvernance **destinées à plusieurs agents/outils**, par opposition aux dossiers `0X_` qui portent le contenu métier du projet. À documenter dans `docs/NAMING-CONVENTIONS.md` avec une définition explicite de ce qui va dedans (règles d'intégration d'outils tiers, conventions partagées) et de ce qui n'y va pas (secrets — restent en `.env`/trousseau ; contenu métier — reste en `0X_`).

Point de vigilance directement hérité du RETEX précédent (`retex-laciotat-doublon-archives.md`) : une fois ce numéro canonisé, s'assurer que `check-project.sh`/`hook-pre-write.sh` le reconnaissent et empêchent les variantes (`98_config`, `98_conf`, `configuration/` sans préfixe) — même logique de normalisation déjà recommandée pour `99_archive`.

### 2. Template générique de handoff inter-agents (priorité haute)

Extraire `HANDOFF_CLAUDE_HERMES.md` en gabarit réutilisable dans `templates/` (ex. `templates/HANDOFF_INTERAGENT.md`), paramétrable sur les noms des agents concernés. Pertinent pour tout projet **multi-agent** (pas seulement Life/LaCIOTAT) — n'importe quel projet MyProjectOS piloté à la fois par Claude Code et un agent externe (Hermes Agent, Codex...) rencontrera le même besoin. Le protocole de statuts (`EN_ATTENTE`/`EN_COURS`/`FAIT`/`BLOQUÉ`, append-only, édition-en-place de la réponse) est le cœur générique à conserver tel quel.

### 3. Gabarit de fichier de gouvernance d'intégration tierce (priorité moyenne)

`GOUVERNANCE_BLUE.md` suit une structure qui se généralise probablement à toute intégration d'outil externe partagée entre agents (Blue ici, mais potentiellement Notion, Linear, un CRM...) : portée, IDs de référence, règles de nommage, workflow de synchronisation, journal des changements daté. Un gabarit dans `templates/` (`templates/GOUVERNANCE_INTEGRATION.md`) éviterait de repartir de zéro à chaque nouvel outil.

### 4. Skill `my-project-os` : consigne active sur le nouveau dossier (priorité basse, dépend de 1)

Si le point 1 est retenu, ajouter la même logique de garde-fou que pour `99_archive` : la création d'un dossier `98_...` à la racine se fait en consultant le canon, jamais au fil de l'eau.

## Leçon générique

Le canon actuel distingue bien le contenu métier (dossiers `0X_`) du contenu mort (`99_archive/`), mais n'avait pas de case pour du contenu **vivant, transverse aux agents, mais pas métier** — la configuration/gouvernance d'intégrations partagées et la communication inter-agents. Ce besoin ne se limitera probablement pas à LaCIOTAT dès qu'un second projet sera piloté par plusieurs agents concurrents ; canoniser tôt évite que chaque projet invente sa propre variante (risque déjà documenté dans le RETEX précédent sur les doublons de dossiers racine).
