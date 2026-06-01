# PLAN PROPOSITION D'AMÉLIORATION

Analyse critique du `HANDOFF.md` et propositions à étudier avant construction.
Dernière mise à jour : 2026-06-01.

Chaque proposition suit le même format : problème observé, proposition, impact, effort, recommandation. Rien n'est tranché ici : ce document sert de base de décision.

## Décisions actées (2026-06-01)

- **#1 Synchronisation Mac/VPS** : réglé par Syncthing (marqueurs `.stfolder` / `.stignore`).
- **#2 Détection projet courant** : réglé. Ouverture directe du dossier projet côté Claude et côté Hermès (profil dédié isolé, voir `AGENTS.md` racine). L'index global est conservé pour la vue d'ensemble, pas pour la détection.
- **#3 Frontière fichiers sacrés** : validée. PROGRESS = photo de l'instant (dernières actions, en cours, prochaine action), ne s'allonge pas. CHANGELOG = registre daté avec identifiant `CHG-YYYYMMDD-HHMM`. DECISIONS = pourquoi des choix structurants, chaque `DEC-XXXX` pointe vers les `CHG-` liés.
- **#4 Articulation PROGRESS global** : PROGRESS du Project OS s'aligne sur la structure du CLAUDE.md global. `anatomy.md` abandonné.
- **#5 Index global** : retenu. Bloc d'en-tête lisible par machine dans chaque PROGRESS + script `build-index.sh`. Détaillé ci-dessous.
- **#6 Conventions de nommage** : proposition complète inspirée d'Unjque rédigée, en attente d'arbitrage (voir Points à trancher).
- **#7 Skill Project OS** : retenu.
- **#8 Archivage** : retenu. Vieilles entrées du CHANGELOG déplacées vers `archives/CHANGELOG-AAAA.md`. Nom du dossier d'archive à trancher.
- **#9 Validation des fichiers sacrés** : retenu.
- **#10 Type Hybrid** : clarifié. Active simultanément les extensions Life et Code (cas : projet avec dimension réelle ET logicielle, ex `Gestion_Courrier`).
- **#11 Versioning de la méthode** : retenu.
- **#12 Intégrations MCP** : clarifié et reporté en `ROADMAP.md` (Calendar pour échéances, Gmail pour correspondances, Drive pour documents).

### Points encore à trancher

1. Structure de dossiers : numérotée (HANDOFF) pour Life, plate (style Unjque) pour Code, Core ne fixant que les fichiers sacrés.
2. Nom du dossier d'archive : `archives/` (habitude Unjque) ou `99_archive/` (HANDOFF).
3. Génération de l'index : script bash + bloc d'en-tête dans PROGRESS.

## Synthèse des priorités

| # | Amélioration | Priorité | Effort | Recommandation |
|---|---|---|---|---|
| 1 | Mécanisme de synchronisation Mac et VPS | Haute | Faible | À trancher en phase 0 |
| 2 | Détection du projet courant | Haute | Faible | À trancher en phase 0 |
| 3 | Frontière nette entre fichiers sacrés | Haute | Faible | À trancher en phase 0 |
| 4 | Articulation avec le système PROGRESS.md global | Haute | Faible | À trancher en phase 0 |
| 5 | Index global multi-projets | Moyenne | Faible | À retenir |
| 6 | Conventions de nommage concrètes | Haute | Faible | À retenir |
| 7 | Skill Claude Code « Project OS » | Moyenne | Moyen | À étudier après le Core |
| 8 | Stratégie d'archivage et compaction | Moyenne | Faible | À retenir |
| 9 | Validation et cohérence des fichiers sacrés | Basse | Moyen | Optionnel |
| 10 | Définition claire du type Hybrid | Moyenne | Faible | À retenir |
| 11 | Versioning de la méthode elle-même | Basse | Faible | À retenir |
| 12 | Intégrations MCP (Calendar, Gmail, Drive) | Basse | Variable | Reporter |

## 1. Mécanisme de synchronisation Mac et VPS

**Problème.** Le HANDOFF affirme que Claude Code et Hermes doivent reprendre le même projet, mais ne dit pas comment le dossier `Mes Projets/` est synchronisé. Sans réponse, la continuité multi-agents reste théorique.

**Proposition.** Choisir explicitement un mécanisme : Git (chaque projet ou le dossier entier est un dépôt), ou un outil de synchronisation de fichiers (Syncthing, rsync). Git est cohérent avec l'esprit Markdown-first et donne l'historique gratuitement, mais impose une discipline de commit. Documenter le choix dans `docs/governance.md`.

**Impact.** Conditionne toute la promesse « Hermes reprend le projet sur VPS ».
**Effort.** Faible (décision), moyen si Git par projet implique une routine de commit automatisée.
**Recommandation.** Trancher en phase 0. Git par défaut, avec règle de commit en fin de session.

## 2. Détection du projet courant

**Problème.** La section 15.1 demande à l'agent « d'identifier le projet courant » sans préciser comment, alors que `Mes Projets/` contient plusieurs projets.

**Proposition.** Convention simple : le projet courant est le dossier de travail contenant un `PROJECT.md`. Si l'agent est lancé à la racine de `Mes Projets/`, il liste les projets disponibles et demande lequel reprendre.

**Impact.** Évite l'ambiguïté au démarrage de chaque session.
**Effort.** Faible.
**Recommandation.** Retenir. À documenter dans `agents/claude-code.md` et `agents/hermes.md`.

## 3. Frontière nette entre fichiers sacrés

**Problème.** `PROGRESS.md`, `CHANGELOG.md`, `TASKS.md` et `DECISIONS.md` se recouvrent partiellement. Sans frontière explicite, l'information se duplique et diverge.

**Proposition.** Règle d'aiguillage unique :
- état présent et prochaines actions, jamais d'historique, va dans `PROGRESS.md` ;
- ce qui a changé, daté, va dans `CHANGELOG.md` ;
- les actions atomiques cochables vont dans `TASKS.md` ;
- le pourquoi des choix structurants va dans `DECISIONS.md`.

Une même information ne vit qu'à un seul endroit. Les autres fichiers la référencent (`voir DEC-0003`).

**Impact.** Réduit la dérive et le bruit, fiabilise la reprise.
**Effort.** Faible.
**Recommandation.** Retenir. À intégrer en tête de chaque template Core.

## 4. Articulation avec le système PROGRESS.md global

**Problème.** Le `CLAUDE.md` global de l'utilisateur impose déjà un système `PROGRESS.md` et `anatomy.md` pour tous les projets, avec sa propre structure obligatoire. Le Project OS définit son propre `PROGRESS.md` avec une structure différente. Risque de conflit ou de double standard.

**Proposition.** Aligner les deux. Soit le Project OS adopte la structure `PROGRESS.md` du CLAUDE.md global, soit le CLAUDE.md global est mis à jour pour pointer vers la structure Project OS sur les projets concernés. Décider d'une seule source de vérité pour le format.

**Impact.** Évite que l'agent applique deux conventions contradictoires.
**Effort.** Faible.
**Recommandation.** Trancher en phase 0. Préférer une structure unifiée.

## 5. Index global multi-projets

**Problème.** Le système répond à « où en est ce projet ? » mais pas à « où en est l'ensemble de mes projets ? ». L'utilisateur a beaucoup de projets et se disperse.

**Proposition.** Un fichier `INDEX.md` à la racine de `Mes Projets/`, listant chaque projet avec type, état d'une ligne, prochaine échéance et dernière mise à jour. Régénérable par script à partir des `PROGRESS.md`.

**Impact.** Vue d'ensemble, priorisation, lutte contre la dispersion.
**Effort.** Faible (manuel) à moyen (génération automatique).
**Recommandation.** Retenir, version manuelle d'abord.

## 6. Conventions de nommage concrètes

**Problème.** L'incohérence des noms de fichiers est citée comme un problème central, mais `naming-conventions.md` n'est que mentionné, jamais spécifié.

**Proposition.** Règles concrètes et minimales : préfixe date `AAAA-MM-JJ` pour les documents datés, minuscules, tirets plutôt qu'espaces, pas d'accents dans les noms de fichiers, identifiants stables pour les registres (`DEC-`, `P-`, `C-`). Donner des exemples avant et après.

**Impact.** Attaque directement un des problèmes fondateurs.
**Effort.** Faible.
**Recommandation.** Retenir et rédiger tôt.

## 7. Skill Claude Code « Project OS »

**Problème.** Les rituels de démarrage et de fin de session sont décrits mais reposent sur la mémoire de l'agent. Ils seront appliqués de façon inégale.

**Proposition.** Encapsuler les rituels dans une skill ou des commandes Claude Code : une commande « reprise » qui lit les fichiers sacrés et produit le résumé, une commande « clôture » qui met à jour `PROGRESS.md`, `CHANGELOG.md`, `TASKS.md`. L'utilisateur exploite déjà beaucoup de skills, l'approche est cohérente avec son environnement.

**Impact.** Rend le système opérationnel et régulier, pas seulement documentaire.
**Effort.** Moyen.
**Recommandation.** Étudier après la livraison du Core, une fois le format stabilisé.

## 8. Stratégie d'archivage et compaction

**Problème.** `CHANGELOG.md` et les registres grossissent indéfiniment. À terme ils deviennent lourds à lire pour l'humain comme pour l'agent.

**Proposition.** Règle d'archivage : au-delà d'un seuil, les entrées anciennes du `CHANGELOG.md` partent dans `99_archive/CHANGELOG-AAAA.md`. `PROGRESS.md` reste par nature court. Documenter le seuil et la procédure.

**Impact.** Maintient la lisibilité dans la durée.
**Effort.** Faible.
**Recommandation.** Retenir, appliquer quand le besoin apparaît.

## 9. Validation et cohérence des fichiers sacrés

**Problème.** Rien ne garantit qu'un projet possède bien ses fichiers sacrés ni qu'ils sont à jour.

**Proposition.** Un script de vérification (`scripts/check-project.sh`) qui signale les fichiers manquants, les dates de mise à jour anciennes, les références cassées entre registres. Alerte sans bloquer, conformément à la règle de gouvernance 8.3.

**Impact.** Filet de sécurité contre la dérive silencieuse.
**Effort.** Moyen.
**Recommandation.** Optionnel, après les phases prioritaires.

## 10. Définition claire du type Hybrid

**Problème.** `PROJECT.md` autorise le type Hybrid, mais le système ne décrit que les extensions Life et Code séparément. Le comportement d'un projet Hybrid est indéfini.

**Proposition.** Définir Hybrid comme l'activation simultanée des deux extensions, avec une note sur les cas d'usage (ex : un litige qui débouche sur un outil logiciel). Préciser quels fichiers cohabitent.

**Impact.** Lève une ambiguïté de conception.
**Effort.** Faible.
**Recommandation.** Retenir, à traiter dans `docs/lifecycle.md`.

## 11. Versioning de la méthode elle-même

**Problème.** La méthode évoluera. Les projets créés avec une version ancienne devront pouvoir continuer ou migrer.

**Proposition.** Versionner la méthode (`project-os v1`, `v2`) et inscrire la version utilisée dans `PROJECT.md` de chaque projet. Documenter les changements de méthode dans le `CHANGELOG.md` du repository et fournir des notes de migration au besoin.

**Impact.** Évolutivité maîtrisée sans casser l'existant.
**Effort.** Faible.
**Recommandation.** Retenir, ligne de version dans `PROJECT.md`.

## 12. Intégrations MCP (Calendar, Gmail, Drive)

**Problème.** Les échéances et correspondances sont gérées en Markdown manuel, alors que des connecteurs existent dans l'environnement de l'utilisateur (Google Calendar, Gmail, Drive, GitHub, n8n).

**Proposition.** À terme, relier `ECHEANCES.md` à Google Calendar, `CORRESPONDANCES.md` à Gmail, les documents à Drive. Le HANDOFF demande explicitement de ne pas intégrer d'outils externes pour l'instant.

**Impact.** Fort potentiel mais hors périmètre initial.
**Effort.** Variable.
**Recommandation.** Reporter, à inscrire dans `ROADMAP.md` comme piste future.

## Décisions à prendre en phase 0

Avant d'écrire le moindre template, trancher les points 1, 2, 3 et 4. Ils déterminent la cohérence de tout le reste. Les points 5, 6, 10 et 11 sont des ajouts à faible coût recommandés dès la fondation. Les points 7, 8, 9 et 12 viennent après la livraison du Core.
