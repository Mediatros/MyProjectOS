# Document de travail — Orientation Project OS AI

Date : 2026-06-03
Repo analysé : `https://github.com/Mediatros/project-os-ai`
Commit inspecté : `60765cf feat: publication du socle Project OS (phases 1 a 5)`
Statut : document de travail Hermes/l'utilisateur enrichi — analyse, orientations validées et décisions candidates ; pas encore plan d'implémentation final
Source : analyse Hermes du repo + échanges vocaux avec l'utilisateur du 2026-06-03

Mise à jour Hermes 2026-06-03 : l'utilisateur valide l'orientation **Core + extensions activables**. `PROGRESS.md` est réorienté comme logbook opérationnel courant, avec archivage déclenché par budget contexte. Les archives `PROGRESS` sont annuelles par défaut, indexées via `INDEX.md`, et découpées seulement si le volume réel le justifie. La revue anti-dérive du nommage reste à intégrer dans `check-project.sh`.

---

## 1. Objet du document

Ce document sert de base de discussion pour affiner l'orientation de **Project OS AI**.

Il récapitule :

1. l'analyse du repository existant ;
2. les informations complémentaires données par l'utilisateur après l'analyse ;
3. les problèmes réellement à résoudre ;
4. les orientations possibles ;
5. les questions à trancher avant d'élargir ou modifier le système.

Ce document ne prescrit pas encore une implémentation finale. Il vise à clarifier le sujet avant de décider quoi construire.

### 1.1 Orientations déjà validées ou stabilisées

Les points suivants ne sont plus de simples hypothèses faibles ; ils constituent des orientations de travail validées ou quasi stabilisées dans les échanges Hermes/l'utilisateur :

- Project OS AI doit être pensé comme un système d'exploitation de projet Markdown-first pour humains + agents IA, pas seulement comme un starter pack de dossiers.
- Le modèle cible s'oriente vers **Core + extensions activables**.
- `type` doit rester une étiquette humaine lisible, tandis que `extensions` décrit les modules réellement activés.
- `PROGRESS.md` doit devenir un logbook opérationnel courant : état actuel + sujets actifs + historique utile récent.
- L'archivage de `PROGRESS.md` doit être déclenché par budget contexte caractères/tokens, pas par calendrier seul.
- Les archives `PROGRESS` sont annuelles par défaut dans `99_archive/progress/PROGRESS-YYYY.md`, avec `INDEX.md` global.
- Les archives annuelles ne sont découpées que si le volume réel le justifie.
- La robustesse doit venir d'un triptyque : règles documentées, skill/profil agent, contrôles déterministes.

### 1.2 Points encore ouverts

Les points suivants restent à trancher avant implémentation :

- granularité exacte de l'extension Ops ;
- statut final de `SUBJECTS.md` ou maintien des sujets uniquement dans `PROGRESS.md` ;
- périmètre v1 de `check-project.sh` ;
- premier projet de dogfood ;
- niveau d'intégration Hermes à court terme.

---

## 2. Résumé exécutif

Project OS AI ne doit pas être pensé uniquement comme un starter pack de dossiers ou comme un template pour projets de code.

L'intention réelle est plus large :

> Créer un système d'ordre, de continuité et de gouvernance pour tous les projets de l'utilisateur, utilisable par lui-même, Claude Code et Hermes, afin d'éviter la perte de contexte, le désordre documentaire et les dérives des agents IA.

Le besoin central est double :

1. **Organiser les dossiers et fichiers de projet** de manière stable, lisible et réutilisable.
2. **Encadrer les agents IA** pour qu'ils reprennent les projets proprement, sans créer des fichiers ou dossiers incohérents, ni dupliquer l'information.

Le repository actuel couvre déjà bien le socle : Core, Life, Code, templates, gouvernance, skill assistant, hooks et script d'initialisation.

La principale piste d'évolution identifiée est l'ajout ou la clarification d'une dimension **Business / Ops / Hybrid**, car les projets réels de l'utilisateur ne sont souvent ni purement Life, ni purement Code.

---

## 3. Contexte utilisateur reformulé

L'utilisateur travaille avec plusieurs environnements et agents :

- Claude Code sur Mac ;
- Hermes Agent sur VPS ;
- un dossier de projets synchronisé entre Mac et VPS ;
- plusieurs profils Hermes créés pour certains projets ;
- des projets personnels, administratifs, professionnels et techniques.

Définitions opératoires à conserver séparées :

- **Agent** : assistant qui lit, raisonne, propose et peut exécuter dans un périmètre donné.
- **Profil** : configuration d'exécution et de contexte pour un agent ou un environnement.
- **Skill** : procédure réutilisable que l'agent doit appliquer dans certains cas.
- **Hook** : garde-fou automatique côté outil, généralement bloquant ou avertissant avant une action.
- **Check script** : audit déterministe, lancé manuellement ou automatiquement, qui vérifie l'état d'un projet sans le modifier.

Ces notions ne doivent pas être mélangées. Un profil n'est pas un agent ; un hook n'est pas une skill ; un check script n'est pas une décision.

L'utilisateur n'est pas développeur de formation ni ingénieur logiciel classique. Il sait exprimer les besoins, piloter des idées, raisonner et travailler avec des agents IA, mais il rencontre des difficultés d'organisation lorsque les projets grandissent.

Le problème n'est pas un manque d'intelligence ou d'ambition. Le problème est la dérive structurelle :

- fichiers dispersés ;
- dossiers créés sans cohérence ;
- informations redondantes ;
- absence de hiérarchie stable ;
- agents IA qui improvisent l'organisation ;
- difficulté à reprendre un projet après interruption ;
- difficulté à savoir quoi lire, quoi modifier, quoi ne pas toucher.

Analogie donnée : les fichiers `final`, `final-v1`, `final-v2`, `final-final`, etc. Le système doit éviter cette dérive à l'échelle de projets entiers.

---

## 4. Problème réel à résoudre

Le problème principal n'est pas seulement :

> Comment créer un nouveau projet rapidement ?

Le problème réel est plutôt :

> Comment garantir qu'un projet reste compréhensible, organisé et reprenable dans le temps, même quand il est manipulé par plusieurs agents IA et même quand l'utilisateur n'a pas tout le contexte en tête ?

Cela implique plusieurs sous-problèmes.

### 4.1 Organisation documentaire

Le système doit répondre à :

- Où ranger une information ?
- Où ranger un document ?
- Où ranger une décision ?
- Où ranger une tâche ?
- Où ranger une preuve ?
- Où ranger une spécification ?
- Où ranger un livrable ?

### 4.2 Continuité de projet

Le système doit permettre de dire :

> Reprends le projet.

Et obtenir rapidement :

- état actuel ;
- dernière action ;
- prochaine action ;
- décisions importantes ;
- risques ;
- points ouverts ;
- fichiers à consulter ;
- choses à ne pas faire.

### 4.3 Encadrement des agents IA

Le système doit empêcher ou réduire :

- la création de dossiers inutiles ;
- la duplication d'informations ;
- les changements de structure non validés ;
- les modifications de fichiers hors scope ;
- les décisions techniques non documentées ;
- les actions sensibles sans validation humaine.

### 4.4 Adaptation aux vrais projets de l'utilisateur

Les projets de l'utilisateur ne sont pas uniquement documentaires ou uniquement techniques. Beaucoup sont hybrides : métier, documents, automatisations, code, livrables, décisions, clients.

Le système doit donc éviter d'être trop rigide.

---

## 5. Typologie actuelle des projets

Le repository actuel distingue :

- Core ;
- Life ;
- Code ;
- Hybrid.

Cette base est saine, mais l'analyse montre qu'une troisième dimension métier/opérationnelle est probablement nécessaire.

### 5.1 Projets Life

Exemples donnés :

- suivi de copropriété ;
- comptabilité générale ;
- administratif ;
- documents personnels ;
- correspondances ;
- échéances ;
- preuves.

Besoin principal :

- classer ;
- tracer ;
- prouver ;
- suivre les échéances ;
- retrouver les documents ;
- savoir quelle action faire ensuite.

Extension actuelle pertinente : `Life`.

Fichiers associés dans le repo :

- `PREUVES.md` ;
- `ECHEANCES.md` ;
- `CORRESPONDANCES.md`.

Point à ajouter au modèle Life : un projet Life peut contenir plusieurs **sujets indépendants et simultanés**.

Exemple copropriété :

- `S-001` — Portail mécanique ;
- `S-002` — Élagage arbres ;
- `S-003` — Boîte aux lettres ;
- `S-004` — Assemblée générale.

Un sujet est une unité de suivi opérationnelle : il a un état, une dernière action, une prochaine action, des preuves/correspondances liées et éventuellement un historique archivé.

Recommandation provisoire : ne pas créer `SUBJECTS.md` immédiatement. Commencer par une section `Sujets actifs` dans `PROGRESS.md`. Si les projets Life deviennent trop chargés, `SUBJECTS.md` pourra devenir une extension ou un fichier optionnel.

Frontière Life documentaire :

- `PREUVES.md` indexe et résume les preuves ; il ne remplace pas les documents sources.
- `CORRESPONDANCES.md` indexe les échanges importants et pointe vers les mails/documents.
- `ECHEANCES.md` suit les dates limites, relances et rappels.
- Les documents réels restent dans des dossiers ou emplacements dédiés ; les fichiers Markdown servent de registre et de liens.

### 5.2 Projets Code / Automation

Exemples donnés :

- plugin WordPress ;
- automatisations n8n ;
- bases NocoDB ;
- scripts ;
- APIs ;
- SaaS ou mini-SaaS ;
- intégrations techniques.

Besoin principal :

- valider la stack ;
- documenter l'architecture ;
- savoir quels fichiers modifier ;
- définir les tests ;
- encadrer les changements ;
- éviter le code improvisé.

Extension actuelle pertinente : `Code`.

Fichiers associés dans le repo :

- `AGENTS.md` ;
- `STACK_VALIDATION.md` ;
- `ARCHITECTURE.md` ;
- `SPECS.md` ;
- `IMPACT_ANALYSIS.md` ;
- `TEST_PLAN.md` ;
- `RELEASE.md`.

### 5.3 Projets Business / Ops / Hybrid

Exemples donnés :

#### Unjque

Projet visant à créer une boutique e-commerce semi-autonome assistée par IA.

Composants probables :

- boutique e-commerce ;
- plugin WordPress ;
- automatisations n8n ;
- base NocoDB ;
- base documentaire ;
- décisions business ;
- workflows opérationnels.

#### Automatisation Magazine

Projet client orienté SaaS / automatisation :

- input : PDF ;
- traitement : pipeline potentiellement n8n ou autre backend ;
- output : fichier Excel basé sur un template normé ;
- contraintes métier client ;
- besoin de traçabilité et validation.

Ces projets ne sont pas seulement `Code`. Ils contiennent aussi :

- objectif business ;
- livrables ;
- processus métier ;
- données ;
- documentation ;
- automatisations ;
- parfois relation client ;
- parfois opérations récurrentes.

Observation : la catégorie `Hybrid` existe déjà, mais elle semble actuellement définie comme l'activation simultanée de Life + Code. Cela peut être insuffisant pour les projets professionnels de l'utilisateur.

---

## 6. État du repository existant

Analyse vérifiée du repo :

- 53 fichiers suivis ;
- 45 fichiers Markdown ;
- 4 scripts shell ;
- 3 `.gitkeep` ;
- 1 `.gitignore`.

Commit inspecté :

```txt
60765cf feat: publication du socle Project OS (phases 1 a 5)
```

Le repo contient notamment :

- templates Core ;
- templates Life ;
- templates Code ;
- docs de gouvernance ;
- structures d'arborescence ;
- skill assistant `project-os` ;
- hooks Claude Code ;
- script `init-project.sh` ;
- documentation Harness / Spec Kit ;
- roadmap ;
- fichiers de suivi du projet lui-même.

---

## 7. Ce que le repo fait déjà bien

### 7.1 Promesse claire

Le README formule bien l'idée :

> Dire « Reprends le projet » et obtenir un état fiable.

C'est la bonne promesse.

### 7.2 Core robuste

Le Core est cohérent :

- `PROJECT.md` : pourquoi le projet existe ;
- `PROGRESS.md` : état actuel ;
- `TASKS.md` : actions ;
- `CHANGELOG.md` : historique ;
- `DECISIONS.md` : décisions structurantes.

La frontière entre ces fichiers est claire.

### 7.3 Logique Life / Code pertinente

Les extensions Life et Code répondent à deux familles de besoins réels.

Life couvre les documents, preuves, échéances et correspondances.

Code couvre la stack, l'architecture, l'analyse d'impact, les specs, les tests et les releases.

### 7.4 Démarrage automatisé

Le script `scripts/init-project.sh` fonctionne.

Test local réalisé :

- génération d'un projet Hybrid ;
- création des fichiers Core ;
- création des fichiers Life ;
- création des fichiers Code ;
- création de `00_inbox/` ;
- génération de `.claude/settings.json` ;
- validation JSON OK.

### 7.5 Début d'enforcement

Les hooks livrés sont utiles :

- blocage des espaces dans les noms de fichiers ;
- blocage des caractères non ASCII / accents ;
- blocage des documents déposés directement à la racine ;
- avertissement si changements sans mise à jour de `PROGRESS.md`.

Test local réalisé :

- `facture client.pdf` à la racine : bloqué ;
- `00_inbox/facture-client.pdf` : autorisé.

### 7.6 Bonne philosophie agent

Le repo comprend une idée importante :

> Les règles critiques ne doivent pas dépendre seulement de la bonne volonté de l'agent.

D'où l'enforcement à trois couches : documentation, skill assistant, hooks.

---

## 8. Limites identifiées

### 8.1 Le système est encore très documentaire

Le repository décrit bien la méthode, mais le niveau d'usage concret reste à prouver sur de vrais projets.

Le risque : créer une bonne documentation qui paraît logique, mais qui devient trop lourde ou trop abstraite en situation réelle.

### 8.2 Les exemples réels manquent

Le dossier `examples/` est vide à ce stade.

Or les exemples sont essentiels pour tester la méthode et la rendre compréhensible.

Exemples à forte valeur :

- copropriété ;
- comptabilité générale ;
- Unjque ;
- Automatisation Magazine.

### 8.3 La catégorie Hybrid doit être clarifiée

Aujourd'hui, Hybrid semble signifier Life + Code.

Mais les projets réels de l'utilisateur peuvent être :

- business + code ;
- business + ops + documents ;
- life + ops ;
- code + automation + docs ;
- client + livrables + workflow.

Il faut décider si `Hybrid` reste un type ou devient une combinaison d'extensions.

### 8.4 Il manque probablement une couche Business / Ops

Pour les projets comme Unjque et Automatisation Magazine, il manque peut-être une extension dédiée aux éléments suivants :

- objectifs business ;
- workflows métier ;
- livrables ;
- contraintes client ;
- données ;
- automatisations ;
- process opérationnels ;
- critères d'acceptation métier.

Cette extension pourrait éviter de forcer tout dans `Code`.

### 8.5 Les hooks ne couvrent pas tous les chemins de dérive

Les hooks actuels sont utiles mais partiels.

Ils ne garantissent pas totalement :

- absence de création de dossiers via shell ;
- absence de modifications via outils autres que `Write` ;
- cohérence globale du projet ;
- absence de placeholders ;
- fraîcheur réelle de tous les fichiers sacrés ;
- validité des références `DEC-`, `CHG-`, `P-`, etc.

Ils doivent être considérés comme des garde-fous de base, pas comme une garantie complète.

### 8.6 Le check de cohérence manque

Le repo mentionne un futur `scripts/check-project.sh`, mais il n'est pas encore présent.

Ce script semble devenir une priorité, car il permettrait de transformer la méthode en système contrôlable.

### 8.7 La gestion de l'historique dans `PROGRESS.md` doit être affinée

Le repo actuel insiste sur une règle saine : `PROGRESS.md` ne doit pas devenir un journal complet illimité.

Mais l'utilisateur signale un besoin important : pour comprendre correctement une situation, il ne suffit pas toujours d'avoir seulement l'action en cours, la prochaine action et l'objectif court terme. Il faut parfois voir les actions passées récentes pour reconstituer le fil opérationnel.

Orientation actualisée : `PROGRESS.md` doit être un **logbook opérationnel courant**, pas seulement une photo statique. Il garde l'état actuel et un historique utile, puis archive l'ancien quand le fichier devient trop lourd pour la reprise à froid.

Frontière proposée :

- `PROGRESS.md` : état actuel + fil opérationnel courant ;
- archives `PROGRESS` : fil ancien conservé, consultable à la demande ;
- `CHANGELOG.md` : changements structurants du projet ;
- `DECISIONS.md` : arbitrages et raisons.

La règle d'archivage ne doit pas être uniquement temporelle. Sur un projet peu actif, trois ou quatre actions dans l'année ne justifient pas forcément une archive annuelle ou trimestrielle. À l'inverse, un projet très actif peut saturer `PROGRESS.md` en quelques semaines.

Critère recommandé : **seuil de taille en caractères/tokens, avec garde-fou temporel optionnel**.

Modèle provisoire :

```txt
PROGRESS.md
- contient l'état actuel ;
- contient les sujets actifs ;
- contient le journal opérationnel courant ;
- reste lisible par défaut au démarrage agent.

99_archive/progress/
- INDEX.md ;
- PROGRESS-YYYY.md par défaut ;
- contient les anciennes entrées déplacées ;
- reste accessible pour historique moyen/long terme ;
- peut être découpé en périodes réelles si l'archive annuelle devient trop volumineuse.
```

Règle possible :

```txt
Si PROGRESS.md dépasse un seuil défini :
1. garder l'état actuel, les sujets actifs et les N dernières actions structurantes ;
2. déplacer les anciennes entrées vers 99_archive/progress/ ;
3. ajouter dans PROGRESS.md un lien vers l'archive créée ;
4. ne pas archiver si le fichier reste court, même si l'année change.
```

Seuils retenus comme hypothèse de travail :

- zone saine : moins de 30 000 caractères ;
- seuil d'alerte : à partir de 30 000 caractères, signaler le risque de saturation contexte ;
- archivage recommandé : à partir de 45 000 caractères ;
- archivage obligatoire / dette de contexte : à partir de 60 000 caractères ;
- anomalie de gouvernance : autour de 90 000 caractères, car `PROGRESS.md` consommerait déjà environ 22 500 tokens à lui seul ;
- objectif après archivage : ramener `PROGRESS.md` vers 25 000 à 30 000 caractères.

Pourquoi caractères plutôt que période : le vrai coût est la fenêtre de contexte agent. Les tokens seraient plus précis, mais les caractères sont plus simples à mesurer dans un script. Approximation provisoire : 1 token ≈ 4 caractères.

Règle importante : l'archivage ne déplace jamais l'intégralité de `PROGRESS.md`. Il archive des blocs logiques jusqu'à revenir sous le budget cible.

Priorité d'archivage :

1. anciennes entrées du journal opérationnel ;
2. sujets clôturés ;
3. détails anciens de sujets encore actifs, à condition de conserver dans `PROGRESS.md` un résumé, le statut, la prochaine action et le lien vers l'archive ;
4. anciennes relances ou jalons dont seul le résumé reste utile.

À conserver impérativement dans `PROGRESS.md` :

- état actuel ;
- sujets actifs ;
- blocages ;
- prochaines actions ;
- décisions ouvertes ;
- risques ;
- 20 à 30 dernières entrées structurantes ou l'équivalent utile en historique récent ;
- liens vers les archives créées.

Règle possible pour `scripts/check-project.sh` : mesurer `PROGRESS.md`, estimer les tokens, compter les entrées de journal, détecter les sujets clôturés, puis recommander l'archivage sans couper brutalement par nombre de caractères.

Politique proposée pour les fichiers d'archives `PROGRESS` :

- chemin : `99_archive/progress/` ;
- index global obligatoire : `99_archive/progress/INDEX.md` ;
- format par défaut : archive annuelle `PROGRESS-YYYY.md` ;
- ne jamais créer de fichiers trimestriels ou mensuels vides ;
- ne découper l'année que si le volume réel le justifie ;
- si découpage nécessaire, privilégier les périodes réelles plutôt que des trimestres artificiels ;
- conserver `PROGRESS-YYYY.md` comme index annuel si l'archive annuelle est découpée, afin de ne pas casser les liens existants.

Exemple nominal :

```txt
99_archive/progress/
├── INDEX.md
├── PROGRESS-2026.md
└── PROGRESS-2027.md
```

Exemple après découpage d'une année trop volumineuse :

```txt
99_archive/progress/
├── INDEX.md
├── PROGRESS-2026.md                    # index annuel
├── PROGRESS-2026-01_to_2026-04.md
├── PROGRESS-2026-05_to_2026-08.md
└── PROGRESS-2026-09_to_2026-12.md
```

Seuils proposés pour découper une archive annuelle, plus tolérants que `PROGRESS.md` car l'archive n'est pas chargée par défaut :

- archive annuelle saine : moins de 60 000 caractères ;
- archive annuelle grosse : 60 000 à 90 000 caractères ;
- découpage recommandé : au-delà de 90 000 caractères ;
- découpage obligatoire : au-delà de 120 000 caractères.

Chaque archive annuelle doit commencer par un court résumé et une liste des sujets couverts pour éviter de devoir tout lire. `INDEX.md` sert de point d'entrée avant toute recherche historique.

### 8.8 La revue anti-dérive du nommage doit être pensée

Les règles de nommage existent, et un hook bloque déjà certains cas simples : espaces, accents, caractères non ASCII, documents déposés à la racine.

Mais il manque une méthode de revue plus globale pour détecter la dérive dans la durée :

- dossiers racine non prévus ;
- noms incohérents ;
- fichiers datés sans préfixe date ;
- doublons proches (`final`, `v2`, `final-final`) ;
- documents placés hors zone logique ;
- conventions respectées dans un dossier mais pas dans un autre.

Hypothèse de travail : intégrer cette revue dans `check-project.sh`, avec une section dédiée :

```txt
Naming drift:
- warning: fichier avec espace
- warning: fichier daté sans préfixe AAAA-MM-JJ
- warning: dossier racine inconnu
- warning: doublons probables final/v2/final-final
```

Ce contrôle doit d'abord avertir, pas bloquer, sauf cas évident déjà couvert par hook.

---

## 9. Hypothèse structurante retenue comme évolution envisagée

Au lieu de considérer les projets comme un choix unique entre Life, Code ou Hybrid, l'évolution envisagée est de les considérer comme un **Core commun** auquel on active des extensions selon le besoin.

Cette orientation est validée comme piste pertinente par l'utilisateur dans l'échange du 2026-06-03.

Modèle possible :

```yaml
type: Project
extensions:
  - life
  - code
  - ops
```

Exemples :

### Copropriété

```yaml
type: Life
extensions:
  - life
```

### Comptabilité générale

```yaml
type: Life
extensions:
  - life
  - ops
```

### Unjque

```yaml
type: Hybrid
extensions:
  - code
  - ops
```

### Automatisation Magazine

```yaml
type: Hybrid
extensions:
  - code
  - ops
```

Avantage : le système devient modulaire.

Inconvénient : il faut modifier la façon de penser le type de projet, les templates et le script d'initialisation.

Règle proposée : `type` sert d'étiquette humaine principale ; `extensions` liste les modules réellement activés. Cela évite de faire porter trop de sens au seul mot `Hybrid`.

---

## 10. Extension Business / Ops — piste à étudier

Nom possible :

- `Ops` ;
- `Business` ;
- `Workflows` ;
- `Operations` ;
- `Project Business Layer`.

Nom recommandé provisoire : **Ops**, car il couvre mieux les projets avec workflows, livrables et automatisations sans limiter au business pur.

### 10.1 Rôle possible

L'extension Ops couvrirait :

- les workflows métier ;
- les livrables ;
- les inputs / outputs ;
- les critères d'acceptation ;
- les données ;
- les outils impliqués ;
- les responsabilités ;
- les processus récurrents.

Frontière proposée :

- **Life** = suivi personnel/documentaire/preuve/échéance.
- **Code** = construction technique, modification logicielle, architecture, tests, release.
- **Ops** = processus récurrent, livrable, workflow, exploitation ou critères d'acceptation métier.

Règle de prudence : Ops n'est activé que s'il existe un processus ou livrable à piloter. Le simple fait d'avoir des tâches ne suffit pas à rendre un projet Ops.

### 10.2 Fichiers possibles

À discuter, sans surcharger :

```txt
WORKFLOWS.md
DELIVERABLES.md
BUSINESS_CONTEXT.md
DATA.md
```

Version minimale recommandée pour démarrer :

```txt
WORKFLOWS.md
DELIVERABLES.md
```

Éviter de créer trop de fichiers obligatoires dès le départ.

### 10.3 Exemple Automatisation Magazine

`WORKFLOWS.md` pourrait décrire :

- input : PDF ;
- extraction ;
- transformation ;
- validation ;
- output : Excel normé ;
- outils possibles ;
- contrôles qualité ;
- exceptions.

`DELIVERABLES.md` pourrait décrire :

- template Excel attendu ;
- critères d'acceptation ;
- statut des livrables ;
- versions livrées ;
- retours client.

### 10.4 Exemple Unjque

`WORKFLOWS.md` pourrait décrire :

- ajout produit ;
- génération contenu ;
- publication boutique ;
- automatisations n8n ;
- synchronisation NocoDB ;
- interventions manuelles restantes.

`DELIVERABLES.md` pourrait décrire :

- plugin WordPress ;
- workflows n8n ;
- base NocoDB ;
- documentation d'exploitation ;
- boutique opérationnelle.

---

## 11. Orientation produit proposée

Positionnement recommandé :

> Project OS AI est un système d'exploitation de projet Markdown-first pour humains et agents IA.

Promesse :

> Chaque projet possède une mémoire, une structure, des règles et une reprise à froid fiable.

Sous-promesse :

> Plus de dossiers incohérents, plus d'informations dupliquées, plus d'agents qui improvisent l'organisation.

Ce positionnement est plus juste que :

> starter pack de projet.

Le terme starter pack reste utile pour l'usage pratique, mais il ne décrit pas toute l'ambition.

---

## 12. Architecture cible provisoire

### 12.1 Core obligatoire

```txt
PROJECT.md
PROGRESS.md
TASKS.md
CHANGELOG.md
DECISIONS.md
00_inbox/
```

Rôle : continuité minimale et reprise à froid.

### 12.1.1 Contrat des fichiers sacrés

Les fichiers Core sont des fichiers sacrés : ils ne doivent pas être supprimés, renommés, fusionnés ou vidés sans décision explicite.

- `PROJECT.md` : identité stable du projet, objectif, périmètre, contexte durable.
- `PROGRESS.md` : état courant, sujets actifs, logbook opérationnel récent, liens vers archives.
- `TASKS.md` : liste actionnable des choses à faire, priorités, statuts, responsables éventuels.
- `CHANGELOG.md` : changements structurants du projet, de sa structure, de ses jalons ou de ses livrables.
- `DECISIONS.md` : arbitrages durables, options considérées, raisons, impacts et éventuels critères de rollback.

Frontière de granularité :

- action faite ou état changé → `PROGRESS.md` ;
- tâche à faire ou à suivre → `TASKS.md` ;
- structure, scope, jalon ou livrable changé → `CHANGELOG.md` ;
- choix entre plusieurs options avec impact durable → `DECISIONS.md`.

Exemples :

- relance envoyée au syndic → `PROGRESS.md` ;
- relancer le syndic avant une date → `TASKS.md` ;
- création d'une extension Ops → `CHANGELOG.md` + `DECISIONS.md` ;
- choix de l'archive annuelle par défaut → `DECISIONS.md` ;
- sujet clôturé → `PROGRESS.md`, et `CHANGELOG.md` seulement si cela marque un jalon important.

### 12.2 Extensions optionnelles

```txt
Life
├── PREUVES.md
├── ECHEANCES.md
└── CORRESPONDANCES.md

Code
├── AGENTS.md
├── STACK_VALIDATION.md
├── ARCHITECTURE.md
├── SPECS.md
├── IMPACT_ANALYSIS.md
├── TEST_PLAN.md
└── RELEASE.md

Ops / Business
├── WORKFLOWS.md
└── DELIVERABLES.md
```

### 12.3 Règles agents

Les agents doivent :

1. lire les fichiers sacrés au démarrage ;
2. ne pas créer de dossier racine sans vérifier la structure ;
3. ne pas dupliquer une information ;
4. ranger dans `00_inbox/` si incertain ;
5. demander validation avant réorganisation ;
6. mettre à jour `PROGRESS.md` après avancée significative ;
7. surveiller la taille de `PROGRESS.md` et archiver l'ancien fil opérationnel quand il dépasse le seuil défini ;
8. écrire les décisions structurantes dans `DECISIONS.md` ;
9. écrire les changements structurants dans `CHANGELOG.md` ;
10. respecter le type/extensions du projet ;
11. ne jamais créer un nouveau dossier racine sans vérifier la structure attendue ou demander validation ;
12. si l'agent hésite sur le rangement, placer temporairement dans `00_inbox/` plutôt que créer une nouvelle logique.

### 12.3.1 Workflow dynamique / harness de tâche

Orientation à tester : Project OS AI doit permettre aux agents de construire un mode opératoire adapté à chaque tâche complexe, sans rendre ce mécanisme obligatoire pour les actions simples.

Principe :

- le Core donne l'état courant, les règles et les frontières d'information ;
- les extensions donnent le contexte spécialisé ;
- l'agent construit un mini-harness de tâche quand la complexité le justifie ;
- ce mini-harness précise l'objectif, les fichiers à lire, les sous-tâches, les validations, les critères de fin et les fichiers à mettre à jour ;
- les sous-agents ne sont utilisés que pour les tâches complexes, volumineuses ou à risque ;
- le résultat final doit être synthétisé dans `PROGRESS.md`, `TASKS.md`, `CHANGELOG.md` ou `DECISIONS.md` selon la granularité.

Exemples de tâches qui justifient un harness :

- audit complet d'un projet ;
- migration de structure ;
- revue de plusieurs archives `PROGRESS` ;
- analyse de nombreux documents Life ;
- revue d'un projet Code/Ops ;
- vérification de claims dans un document.

Exemples de tâches qui ne justifient pas un harness :

- ajouter une entrée simple dans `PROGRESS.md` ;
- créer une tâche simple dans `TASKS.md` ;
- lire un fichier ;
- corriger un nom de fichier évident.

Règle de prudence : ne pas ajouter de fichier obligatoire `HARNESS.md`, `WORKFLOW_EXECUTION.md` ou `SUBAGENTS.md` en v1. Le harness est d'abord une règle d'exécution agent. Un fichier dédié ne sera envisagé que si le dogfood montre un besoin réel.

### 12.4 Enforcement

Contrôles déterministes souhaitables :

- nommage ;
- placement ;
- fichiers sacrés présents ;
- placeholders restants ;
- cohérence type/extensions ;
- fraîcheur `PROGRESS.md` ;
- présence `STACK_VALIDATION.md` validé avant code ;
- références cassées ;
- documents à la racine ;
- dossiers inconnus à la racine ;
- revue anti-dérive du nommage et de la structure, probablement dans `scripts/check-project.sh` plutôt que dans un hook bloquant.

---

## 13. Priorités proposées

### Priorité 0 — Stabiliser les décisions d'orientation

But : transformer ce document de travail en décisions structurées avant d'implémenter.

Résultat attendu :

- extraire les orientations validées ;
- lister les décisions candidates ;
- isoler les questions encore ouvertes ;
- produire un plan de modification du repository avec fichiers exacts ;
- ne pas modifier le repo sans GO explicite.

### Priorité 1 — Dogfood sur Unjque

But : tester la méthode sur un vrai projet hybride.

Pourquoi Unjque :

- projet réel ;
- business + code + automation + documentation ;
- présence WordPress, n8n, NocoDB ;
- complexité suffisante pour révéler les limites ;
- cas représentatif des besoins de l'utilisateur.

Résultat attendu :

- liste des frictions ;
- ajustements nécessaires ;
- décision sur l'extension Ops ;
- preuve que la reprise à froid fonctionne.

### Priorité 2 — Ajouter `check-project.sh`

But : auditer un projet sans modification.

Périmètre recommandé par versions :

```txt
check-project.sh v1
- fichiers sacrés présents ;
- placeholders évidents ;
- documents déposés à la racine ;
- dossiers racine inconnus ;
- taille et budget contexte de PROGRESS.md ;
- cohérence basique type/extensions.

check-project.sh v2
- références DEC/CHG/P cassées ;
- recommandations d'archivage PROGRESS ;
- naming drift avancé ;
- sujets clôturés candidats à l'archive.

check-project.sh v3
- scoring global ;
- recommandations agent ;
- intégration Hermes/profil ;
- vérifications multi-environnements Mac/VPS.
```

Règle : ne pas essayer de tout faire en v1. Le script doit d'abord produire un diagnostic fiable et court.

Sortie attendue :

```txt
Project OS check — NomProjet
Status: OK | warning | error

OK:
- PROJECT.md présent
- PROGRESS.md présent

Warnings:
- PROJECT.md contient encore des placeholders
- PROGRESS.md dernière mise à jour ancienne

Errors:
- Type Code mais STACK_VALIDATION.md absent

Next action:
- compléter PROJECT.md puis valider STACK_VALIDATION.md
```

### Priorité 3 — Créer des exemples réels

Exemples minimum :

- `examples/life-copropriete/` ;
- `examples/code-ops-unjque/` ou `examples/hybrid-unjque/`.

Ces exemples doivent rester courts mais réalistes.

### Priorité 4 — Clarifier Hermes

Hermes doit consommer le système, mais pas forcément exécuter les mêmes hooks que Claude Code.

À clarifier :

- skill Hermes dédiée ou skill compatible ;
- profil Hermes Project OS ;
- la reprise projet via Telegram ;
- la création projet via Telegram ;
- la sélection de projet depuis le dossier synchronisé ;
- le rapport court de reprise ;
- la capacité à construire un mini-harness de tâche pour les demandes complexes, sans charger tout le projet inutilement.

---

## 14. Questions à trancher

### Q1 — Le mot `Hybrid` suffit-il ?

Options :

1. Garder `Life | Code | Hybrid`.
2. Remplacer par `extensions: [life, code, ops]`.
3. Garder `type` + ajouter `extensions`.

Recommandation actualisée : option 3, car elle préserve la lisibilité tout en ajoutant la modularité. L'utilisateur est favorable à l'approche **Core + extensions activables**.

Exemple :

```yaml
type: Hybrid
extensions:
  - code
  - ops
```

### Q2 — Faut-il une extension Ops ?

Options :

1. Non, intégrer ces besoins dans Code ou Core.
2. Oui, avec deux fichiers minimaux : `WORKFLOWS.md` et `DELIVERABLES.md`.
3. Oui, avec une extension complète Business/Ops.

Recommandation provisoire : option 2, testée sur Unjque avant généralisation.

### Q3 — Quel niveau de dossiers créer par défaut ?

Options :

1. Créer seulement `00_inbox/` et les fichiers sacrés.
2. Créer toute l'arborescence dès l'init.
3. Créer les dossiers à la demande selon extension.

Recommandation provisoire : option 1 ou 3. Éviter les squelettes vides trop lourds.

### Q4 — Le système est-il pour l'utilisateur seulement ou packagé pour d'autres ?

Options :

1. Usage personnel prioritaire.
2. Usage Mediatros / Unjque.
3. Produit réutilisable par d'autres.

Recommandation provisoire : usage personnel d'abord, puis extraction si le système marche vraiment.

### Q5 — Quel est le premier projet test ?

Options :

1. Unjque.
2. Automatisation Magazine.
3. Copropriété.
4. Comptabilité générale.

Recommandation provisoire : Unjque, car c'est le meilleur stress test hybride.

### Q6 — Quelle place donner à l'historique courant dans `PROGRESS.md` ?

Options :

1. Garder `PROGRESS.md` comme photo stricte sans historique.
2. Utiliser `PROGRESS.md` comme logbook opérationnel courant, avec archivage quand il devient trop lourd.
3. Mettre tout l'historique dans `CHANGELOG.md` et ajouter seulement des liens depuis `PROGRESS.md`.

Recommandation actualisée : option 2. `PROGRESS.md` doit garder le fil opérationnel utile pour la reprise à froid, mais avec une limite basée d'abord sur la taille caractères/tokens, pas sur une période fixe.

Seuil provisoire à tester : alerte à 30 000 caractères, archivage recommandé à 45 000 caractères, archivage obligatoire à 60 000 caractères. Après archivage, `PROGRESS.md` doit redescendre vers 25 000 à 30 000 caractères. La période ne sert que pour nommer ou découper les archives, pas comme déclencheur principal. Les archives sont annuelles par défaut (`99_archive/progress/PROGRESS-YYYY.md`) avec `INDEX.md` global ; elles ne sont découpées en périodes réelles que si l'année devient trop volumineuse.

### Q7 — Comment organiser la revue anti-dérive du nommage ?

Options :

1. Hooks bloquants uniquement.
2. Check script non bloquant uniquement.
3. Combinaison : hooks pour les cas évidents, check script pour les dérives globales.

Recommandation provisoire : option 3. Les hooks bloquent le clair ; `check-project.sh` signale le reste.

---

## 15. Risques

### Risque 1 — Trop de structure

Si le système impose trop de fichiers, il devient lourd et ne sera pas utilisé.

Parade : fichiers obligatoires limités, extensions minimales, dossiers créés à la demande.

### Risque 2 — Trop de liberté

Si les agents peuvent improviser, le chaos revient.

Parade : règles agents, hooks, check script, `00_inbox/` comme zone tampon.

### Risque 3 — Confondre Code et Business

Les projets professionnels de l'utilisateur ne sont pas uniquement des projets logiciels.

Parade : clarifier la couche Ops / Business.

### Risque 4 — Construire sans tester

Le système peut paraître bon en théorie mais échouer sur un vrai projet.

Parade : dogfood immédiat sur Unjque.

### Risque 5 — Porter Hermes trop tôt

Si la méthode n'est pas stabilisée, une intégration Hermes avancée risque d'automatiser un système encore mouvant.

Parade : stabiliser Core + test Unjque + check script avant portage complet Hermes.

### Risque 6 — Divergence Mac/VPS

Si Claude Code sur Mac et Hermes sur VPS modifient le même projet dans des environnements différents, le système peut créer des conflits ou incohérences : chemins différents, ownership différent, sync incomplète, fichiers temporaires, hooks présents d'un côté mais pas de l'autre.

Parade :

- conventions de chemins ;
- ownership clair ;
- pas de modification simultanée du même projet ;
- `check-project.sh` avant/après reprise sensible ;
- logs de modification dans `PROGRESS.md` ou `CHANGELOG.md` selon granularité ;
- considérer les hooks Claude Code comme utiles mais non suffisants côté Hermes.

---

## 16. Proposition de prochaine session de travail

Objectif : transformer ce document en décision d'orientation.

Ordre proposé :

1. Relire la vision : confirmer ou corriger.
2. Extraire les orientations validées dans un document de décisions.
3. Trancher la question `type + extensions`.
4. Décider si l'extension Ops existe en v1, et avec quels fichiers minimaux.
5. Clarifier la gestion des sujets Life/Ops actifs.
6. Définir le périmètre v1 de `check-project.sh`.
7. Choisir le premier projet test.
8. Définir les critères de succès du dogfood.
9. Écrire un plan court d'évolution du repo.

Livrable attendu après arbitrage :

- un plan de modification du repository ;
- sans implémentation immédiate ;
- avec fichiers exacts à modifier ;
- puis demande de GO avant changement.

---

## 17. Recommandation provisoire

Recommandation actuelle, à valider avec l'utilisateur :

1. Ne pas repositionner Project OS comme simple starter pack.
2. Le positionner comme système d'exploitation de projet pour humains + agents IA.
3. Garder le Core actuel.
4. Garder Life et Code.
5. Ajouter une piste Ops minimale à tester, pas encore généraliser brutalement.
6. Passer progressivement vers une logique `type + extensions`, avec l'approche **Core + extensions activables** comme évolution envisagée.
7. Dogfooder sur Unjque avant toute refonte.
8. Ajouter ensuite `check-project.sh` comme premier vrai outil de robustesse, en périmètre v1 limité : fichiers sacrés, placeholders, documents racine, dossiers inconnus, taille `PROGRESS.md`, cohérence basique `type/extensions`.
9. Créer des exemples réels seulement après le dogfood.
10. Porter vers Hermes quand la méthode est stable.
11. Ajuster `PROGRESS.md` pour devenir un logbook opérationnel courant : état actuel + sujets actifs + historique utile + archivage quand le fichier dépasse un seuil caractères/tokens.
12. Clarifier la frontière `TASKS.md` / `PROGRESS.md` / `CHANGELOG.md` / `DECISIONS.md` dans les templates Core.
13. Ajouter le risque Mac/VPS et les règles anti-divergence dans la gouvernance projet.
14. Après stabilisation, extraire ce document en deux livrables plus courts : décisions d'orientation et plan d'évolution du repo.
15. Ajouter le concept de workflow dynamique / mini-harness de tâche comme règle agent pour les tâches complexes, sans créer de fichier obligatoire en v1.

---

## 18. Formule de synthèse

Project OS AI doit empêcher le retour du chaos.

Pas seulement en créant des dossiers, mais en donnant à chaque projet :

- une structure ;
- une mémoire ;
- des frontières d'information ;
- des règles pour les agents ;
- des contrôles ;
- une reprise à froid fiable.

La question centrale à affiner maintenant :

> Quelle structure minimale permet d'organiser les vrais projets de l'utilisateur sans créer une usine à gaz ?
