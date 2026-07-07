# INSTALL-AGENT — Protocole d'installation pour un agent

> Tu es un agent (Claude Code, Codex, Hermès ou autre) et on t'a donné le lien de ce dépôt avec pour mission d'installer MyProjectOS sur un projet. Voici le protocole exact. Il est écrit pour toi, pas pour l'humain.

## Étape 0 — Identifier le scénario

Regarde le dossier cible :

| Constat | Scénario |
|---|---|
| Dossier inexistant ou vide | **Méthode 1 — création** |
| Dossier peuplé, sans `PROJECT.md` | **Méthode 2 — adoption** |
| `PROJECT.md` présent avec `version_methode` | Pas une installation : mise à jour éventuelle (`sh scripts/check-update.sh`, puis `docs/versioning.md`) |
| `PROJECT.md` présent sans `version_methode` | Migration d'un projet né avant le versionnement (`docs/versioning.md`, runbook dédié) |

Si le type de projet (Life / Code / Hybrid, avec ou sans Knowledge) n'a pas été précisé, pose la question à l'humain avant d'installer. Ne le déduis pas seul.

## Méthode 1 — Création (dossier vierge)

1. Installer en une commande (le clone est temporaire, le projet final est autonome) :

   ```sh
   curl -fsSL https://raw.githubusercontent.com/Mediatros/MyProjectOS/main/install.sh \
     | sh -s -- <chemin-projet> [--life] [--code] [--knowledge]
   ```

2. Vérifier : `sh <chemin-projet>/scripts/check-project.sh <chemin-projet>` doit sortir sans bloquant.
3. Enchaîner sur le **cadrage** : `PROJECT.md` ne doit pas rester en gabarit. Conduis l'interview de cadrage (mode « cadrage » de la skill `my-project-os` : pourquoi, périmètre, objectifs, critères de réussite, risques), pré-remplis le fichier et soumets-le à relecture humaine.

## Méthode 2 — Adoption (dossier peuplé, désordonné ou non)

Séquence stricte. La réorganisation d'une arborescence est une **action sensible** (`docs/governance.md`) : rien ne bouge sans validation humaine explicite.

1. **Inventaire** (lecture seule). Arborescence sur 2 ou 3 niveaux, types et volumes de fichiers, README ou notes existants, historique git s'il y en a un. Ne modifie rien, ne déplace rien.
2. **Classification.** Rapproche l'existant des concepts de la méthode : quel fichier joue déjà le rôle d'un `PROGRESS` ou d'un `README` de projet ; quels documents iraient dans `03_documents/` ; quelles preuves, échéances ou correspondances (Life) ; quel code ou specs (Code) ; quelle documentation dense (Knowledge).
3. **Proposition de mapping.** Présente à l'humain un tableau : élément existant → destination proposée (déplacement, renommage conforme à `docs/NAMING-CONVENTIONS.md`, ou statu quo), plus les fichiers sacrés à créer et les extensions recommandées avec leur raison. Termine par des questions fermées (« valides-tu ces déplacements ? », « ce dossier est-il bien de l'archive ? »).
4. **Exécution** (après validation seulement). Greffe d'abord la structure sans rien écraser :

   ```sh
   curl -fsSL https://raw.githubusercontent.com/Mediatros/MyProjectOS/main/install.sh \
     | sh -s -- <chemin-projet> --into-existing [--life] [--code] [--knowledge]
   ```

   Puis applique uniquement les déplacements et renommages validés au point 3.
5. **Remplissage assisté.** Pré-remplis `PROJECT.md` et `PROGRESS.md` à partir des traces trouvées (README, commits, structure, documents datés). Marque clairement ce qui est déduit (« à confirmer ») et soumets les deux fichiers à relecture humaine. Un fichier sacré resté en gabarit est un échec d'adoption.
6. **Rapport de migration.** Consigne dans le `CHANGELOG.md` du projet (entrée `CHG-`) ce qui a été créé, déplacé et renommé. Termine par `sh scripts/check-project.sh` : zéro bloquant attendu.

## Après l'installation, dans tous les cas

- Les rituels de session vivent dans l'`AGENTS.md` du projet (Codex et Hermès le lisent nativement ; Claude Code y arrive via `CLAUDE.md`).
- Le rythme d'exécution est **une tâche par itération** : `docs/cycle-de-travail.md`.
- Vérification à la demande : `sh scripts/check-project.sh`. Détection de mise à jour : `sh scripts/check-update.sh`.
- Ce que tu ne fais jamais sans validation humaine : suppression massive, réorganisation, changement de stack, déploiement, push important, action juridique ou administrative sensible.
