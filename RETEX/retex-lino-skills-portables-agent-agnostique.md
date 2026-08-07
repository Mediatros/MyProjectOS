# RETEX — Skills portables agent-agnostiques : deux corrections issues du dogfood Lino

> Retour d'expérience issu du dogfood MyProjectOS sur `/Users/jb/Documents/MyProjects/LOCAL/Lino` (type Life).
> Date : 2026-07-15.
> Statut : intégré via DEC-0034 (même session).

## Objet du RETEX

Le pattern « skill technique portable » (`98_configuration/skills/<skill>/` en source canonique, une copie installée par agent) existe dans le canon depuis la brique Blue (DEC-0027 à DEC-0029) et le catalogue d'outils (DEC-0030). Il reste toutefois cantonné à deux usages : les outils du catalogue (`docs/OUTILS.md`) et les skills utilitaires sans compte. Le projet Lino, construit en dehors du dépôt méthode pour un usage multi-agents réel (Claude Code + Codex), a poussé ce pattern plus loin sur deux points concrets, vérifiés en exécution plutôt que supposés.

## Le contexte

Lino est un dossier Life piloté par Claude Code et Codex, pensé dès le départ pour être portable (archivable/déplaçable tel quel). Il porte neuf skills dans `98_configuration/skills/` (dont `blue-app`, `agentmail-darrabot`, six skills métier `lino-*`, et `my-project-os`), installées à la fois pour Claude Code et pour Codex. Un script de vérification (`98_configuration/scripts/check-codex-portable.sh`) contrôle que les neuf skills sont bien découvertes par Codex avant tout usage.

## Constat 1 — Le chemin projet réel de Codex est `.agents/skills/`, pas `.codex/skills/`

Le canon documente encore `.codex/skills/` comme emplacement natif de Codex (`skills/my-project-os/SKILL.md` ligne 192, `templates/skills/_squelette/INSTALL.md`, `templates/skills/blue-app/INSTALL.md`), hérité de la vérification faite lors de la brique Blue (DEC-0029, juillet 2026). Le `AGENTS.md` de Lino documente et le script de vérification confirme (9/9 skills détectées) que Codex découvre en réalité les skills projet dans `.agents/skills/` à la racine. Les deux emplacements ne sont pas nécessairement mutuellement exclusifs dans le temps (l'outillage Codex peut évoluer), mais la vérification la plus récente pointe vers `.agents/skills/` : c'est ce chemin qui doit primer dans le canon, avec la même consigne déjà en place ailleurs (« vérifier le chemin réel au premier essai plutôt que de le supposer »).

## Constat 2 — Lien symbolique relatif plutôt que copie physique

Le squelette actuel (`templates/skills/_squelette/INSTALL.md`) prescrit `cp -r` depuis `98_configuration/skills/<outil>` vers l'emplacement de chaque agent. Lino installe à la place des **liens symboliques relatifs** : `.claude/skills/<skill>` et `.agents/skills/<skill>` pointent vers l'unique copie canonique. Une seule source à éditer, aucune dérive possible entre la source et les copies installées — exactement le risque qui avait motivé la création du dossier `98_configuration/` (RETEX LaCIOTAT, DEC-0026). Contrepartie assumée : un lien symbolique ne survit pas à un outil d'archive/zip qui ne le préserve pas ou ne le déréférence pas correctement ; `check-codex-portable.sh` le détecte en vérifiant que chaque skill attendue reste lisible après décompression sur une autre machine.

## Pourquoi généraliser au-delà du catalogue

Les neuf skills de Lino ne sont pas toutes des « outils » au sens de `docs/OUTILS.md` : six sont des skills métier bespoke (`lino-avocat-adverse`, `lino-chronologie`...), sans gouvernance d'intégration ni compte tiers. Le besoin de portabilité multi-agents ne se limite donc pas aux outils catalogués : dès qu'un projet est piloté par plusieurs agents, toute skill technique créée dans ce projet bénéficie du même traitement.

## Évolution retenue (DEC-0034, même session)

1. Correction du chemin Codex dans tout le canon (`.agents/skills/`).
2. Installation par lien symbolique relatif pour Claude Code et Codex (Hermès reste en copie physique globale, DEC-0029 D3 non rediscutée : la contrainte anti-conflit Syncthing qui l'a motivée reste valable).
3. Le réflexe « proposer la pose en `98_configuration/skills/` » devient un garde-fou permanent de la skill assistant, déclenché à la création de toute nouvelle skill technique de projet — catalogue ou bespoke — et non plus seulement aux Modes 5/6 (cadrage/adoption).

Détail de la propagation : voir DEC-0034 dans `DECISIONS.md`.
