# Cycle de vie d'un projet — MyProjectOS

De la création à l'archivage, les étapes par lesquelles passe un projet.

## 1. Création

Un projet naît à partir des templates. On choisit son **type** (Life, Code ou Hybrid), ce qui détermine les extensions activées.

- On copie les cinq fichiers sacrés Core depuis `templates/core/`.
- On ajoute les templates des extensions choisies (Life, Code, ou les deux pour Hybrid).
- On active l'extension `knowledge` seulement si le projet a assez de documentation pour justifier une navigation par niveaux et une analyse transverse.
- On crée les dossiers numérotés à la demande, au moment où ils servent.
- On renseigne `PROJECT.md` (pourquoi, périmètre, objectifs, critères de réussite).

À terme, `scripts/init-project.sh` automatise cette étape.

## 2. Travail

Le cœur de la vie du projet. À chaque session, les rituels de `governance.md` s'appliquent : lecture des fichiers sacrés au démarrage, mises à jour pendant, clôture en fin de session.

L'information se range selon la frontière des fichiers sacrés. Les documents entrants passent par `00_inbox/` puis sont classés.

## 3. Reprise

Une reprise est un démarrage de session sur un projet existant, éventuellement après une longue interruption ou un changement d'agent (Claude Code ↔ Hermès). Le principe **reprise à froid** garantit qu'aucun historique de conversation n'est nécessaire : tout est dans les fichiers.

## 4. Décision

Quand un choix structurant se présente, l'agent éclaire (options, avantages, inconvénients, recommandation) avant de laisser l'humain trancher. La décision retenue est consignée en `DEC-XXXX` dans `DECISIONS.md`.

## 5. Archivage

Quand un projet est clôturé, son statut passe à `clôturé` dans l'en-tête de `PROGRESS.md` et `PROJECT.md`. Les éléments obsolètes vont dans `99_archive/`. Le projet reste lisible et repris à froid si besoin.

## Le cas Hybrid

Un projet **Hybrid** active simultanément les extensions Life et Code. Cas typique : un sujet à la fois réel et logiciel, par exemple un litige qui débouche sur un outil, ou une activité administrative pilotée par un logiciel. Les fichiers des deux extensions cohabitent à la racine ; aucun ne se substitue à un fichier sacré Core.

## Le cas Knowledge

L'extension **Knowledge** est optionnelle et transverse : elle peut s'ajouter à Life, Code ou Hybrid quand la documentation devient assez dense pour nécessiter `docs/INDEX.md`, `docs/kb_governance.md`, des niveaux `01_global/`, `02_domains/`, `03_details/`, des runbooks et des plans.

Elle sert à naviguer, analyser les dépendances et limiter la dérive documentaire. Elle ne remplace pas les fichiers sacrés Core et ne transforme pas le projet en wiki généraliste.
