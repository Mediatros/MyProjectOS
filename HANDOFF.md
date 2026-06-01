HANDOFF — Création d’un Project OS IA pour projets Life & Code

1. Contexte général

L’objectif est de créer un repository GitHub permettant de concevoir, documenter, versionner et faire évoluer une méthode complète d’organisation de projets assistée par IA.

Ce projet ne doit pas être pensé comme un simple template de dossiers, ni comme un simple outil pour coder.

Il doit être conçu comme un Project Operating System IA : une méthode structurée permettant à un utilisateur non-développeur, parfois peu organisé, de piloter efficacement ses projets avec l’aide d’agents IA comme Claude Code et Hermes Agent.

L’utilisateur travaille avec deux environnements principaux :

* Claude Code sur Mac ;
* Hermes Agent sur VPS ;
* un dossier local Mes Projets/ synchronisé entre Mac et VPS ;
* chaque sous-dossier de Mes Projets/ représente généralement un projet.

L’objectif est que Claude Code et Hermes puissent reprendre un projet à tout moment, comprendre son contexte, son état, ses décisions, ses documents, ses actions restantes et ses prochaines étapes.

⸻

2. Problème à résoudre

L’utilisateur constate que ses projets deviennent souvent chaotiques :

* dossiers mal organisés ;
* fichiers dispersés ;
* noms de fichiers incohérents ;
* absence de logique commune ;
* difficulté à reprendre un projet après interruption ;
* difficulté à savoir ce qui a été fait ;
* difficulté à savoir pourquoi certaines décisions ont été prises ;
* difficulté à retrouver les preuves, emails, PDF, courriers ou documents sources ;
* difficulté à maintenir un projet code propre dans le temps ;
* difficulté à savoir quels fichiers modifier lorsqu’une nouvelle fonctionnalité est demandée.

Le problème principal n’est donc pas seulement le code.

Le problème central est :

maintenir l’ordre, le contexte, la traçabilité et la continuité dans tous les projets.

⸻

3. Vision du système

Le système doit permettre à l’utilisateur de dire simplement :

Reprends le projet.

Et l’agent doit pouvoir lire les fichiers de pilotage du projet et répondre :

Voici où on en est.
Voici ce qui a été fait.
Voici pourquoi ça a été fait.
Voici les décisions importantes.
Voici les points ouverts.
Voici les risques.
Voici la prochaine action recommandée.

Le système doit fonctionner pour deux grandes familles de projets :

1. Projets Life
2. Projets Code

⸻

4. Deux familles de projets

4.1 Project OS Life

Exemples :

* copropriété ;
* voisinage ;
* litige ;
* comptabilité ;
* démarches administratives ;
* organisation personnelle ;
* suivi de budget ;
* suivi de documents ;
* préparation d’assemblée générale ;
* courriers ;
* échanges par email.

La matière première d’un projet Life est :

Documents
Emails
PDF
Photos
Courriers
Comptes-rendus
Décisions
Preuves
Actions
Échéances

Les questions principales sont :

Où en est-on ?
Que s’est-il passé ?
Quelle est la preuve ?
Quel document source justifie cette affirmation ?
Quelle est la prochaine action ?
Quelle échéance approche ?
Quel courrier faut-il préparer ?
Quelle décision a été prise ?

4.2 Project OS Code

Exemples :

* plugin WordPress ;
* plugin WooCommerce ;
* intégration Gelato ;
* SaaS ;
* automatisation n8n ;
* application web ;
* API ;
* agent IA ;
* scripts ;
* outils internes.

La matière première d’un projet Code est :

Code
Architecture
Stack
Dépendances
Compatibilités
Tests
Documentation
Issues
Releases
Changelog
Décisions techniques

Les questions principales sont :

Quelle est la stack ?
Pourquoi cette architecture ?
Quelles versions sont utilisées ?
Quelles compatibilités ont été validées ?
Quels fichiers sont concernés par cette fonctionnalité ?
Quels fichiers ne doivent pas être touchés ?
Quels tests doivent être lancés ?
Quels risques techniques existent ?
Quelle est la prochaine étape de développement ?

⸻

5. Architecture conceptuelle retenue

Ne pas créer deux systèmes totalement séparés.

Créer plutôt :

Core Project OS
+
Extension Life
+
Extension Code

5.1 Core Project OS

Le Core Project OS est commun à tous les projets.

Il doit contenir les fichiers et règles nécessaires pour piloter n’importe quel projet.

Il couvre :

* contexte ;
* objectif ;
* état actuel ;
* tâches ;
* décisions ;
* progression ;
* historique ;
* prochaines actions ;
* reprise de contexte.

5.2 Extension Life

Ajoute les mécanismes spécifiques aux projets personnels, administratifs, juridiques ou organisationnels :

* documents sources ;
* preuves ;
* correspondances ;
* échéances ;
* courriers ;
* historiques d’échanges ;
* dossiers thématiques.

5.3 Extension Code

Ajoute les mécanismes spécifiques aux projets logiciels :

* stack validation ;
* architecture ;
* specs ;
* tests ;
* documentation technique ;
* conventions de repository ;
* instructions agent ;
* analyse d’impact ;
* releases ;
* maintenance.

⸻

6. Principe fondamental

Le système doit être conçu pour être lisible par :

* l’utilisateur humain ;
* Claude Code ;
* Hermes Agent ;
* un futur agent IA.

La structure doit donc être :

* claire ;
* simple ;
* logique ;
* stable ;
* extensible ;
* versionnable ;
* compatible Markdown ;
* compatible Git ;
* facile à maintenir.

Il faut éviter une structure trop complexe.

Le système doit couvrir 80 % des besoins avec une base simple.

⸻

7. Fichiers sacrés du Core Project OS

Les fichiers suivants doivent exister dans tous les projets.

7.1 PROJECT.md

Rôle :

* expliquer pourquoi le projet existe ;
* définir son périmètre ;
* définir ses objectifs ;
* définir ce qui est hors périmètre ;
* donner les critères de réussite ;
* identifier le type de projet : Life, Code, Hybrid.

Contenu recommandé :

# PROJECT
## Type de projet
Life / Code / Hybrid
## Objectif
...
## Contexte
...
## Périmètre
...
## Hors périmètre
...
## Critères de réussite
...
## Parties prenantes
...
## Contraintes connues
...
## Dernière mise à jour
...

7.2 PROGRESS.md

Rôle :

* donner l’état actuel du projet ;
* permettre une reprise rapide ;
* indiquer ce qui est terminé, en cours, bloqué, à faire ;
* indiquer la prochaine action recommandée.

Ce fichier est essentiel.

Il doit permettre à l’utilisateur de dire :

On en est où ?

Contenu recommandé :

# PROGRESS
## État actuel résumé
...
## Dernières actions réalisées
- ...
## En cours
- ...
## Bloqué
- ...
## Prochaines actions
1. ...
## Points d’attention
- ...
## Dernière session
Date :
Résumé :

7.3 CHANGELOG.md

Rôle :

* conserver l’historique utile du projet ;
* tracer les évolutions importantes ;
* expliquer ce qui a changé et pourquoi.

Ce n’est pas seulement un changelog technique.

Il doit être utilisable aussi pour les projets Life.

Contenu recommandé :

# CHANGELOG
## YYYY-MM-DD
### Ajouté
- ...
### Modifié
- ...
### Décidé
- ...
### Supprimé
- ...
### Pourquoi
...

7.4 TASKS.md

Rôle :

* suivre les actions ;
* garder une checklist claire ;
* distinguer tâches ouvertes, en cours, terminées, abandonnées.

Contenu recommandé :

# TASKS
## À faire
- [ ] ...
## En cours
- [ ] ...
## Terminé
- [x] ...
## Abandonné
- [ ] ...

7.5 DECISIONS.md

Rôle :

* conserver les décisions importantes ;
* expliquer pourquoi une option a été choisie ;
* garder la trace des alternatives.

Important :

Toutes les petites décisions n’ont pas besoin d’une entrée longue.

Mais les décisions structurantes doivent être documentées.

Exemples de décisions structurantes :

* changer de fournisseur ;
* changer de stack ;
* abandonner Printful pour Gelato ;
* choisir un framework ;
* décider d’envoyer un courrier recommandé ;
* décider d’attendre une réponse ;
* décider d’accepter un risque.

Format recommandé :

# DECISIONS
## DEC-0001 — Titre de la décision
Date :
Statut : proposée / acceptée / rejetée / remplacée
### Contexte
...
### Options étudiées
1. ...
2. ...
### Décision retenue
...
### Pourquoi
...
### Conséquences
...
### Risques acceptés
...

⸻

8. Règles strictes de gouvernance

8.1 Mise à jour obligatoire

Toute action importante doit mettre à jour au minimum :

* PROGRESS.md
* CHANGELOG.md

Si l’action implique une décision importante :

* DECISIONS.md doit aussi être mis à jour.

8.2 Reprise obligatoire

Au démarrage d’une session, l’agent doit lire :

1. PROJECT.md
2. PROGRESS.md
3. TASKS.md
4. CHANGELOG.md
5. DECISIONS.md

Puis produire un résumé court :

État actuel :
Dernière action :
Prochaine action :
Points de vigilance :

Si l’utilisateur demande un récap complet, produire :

Contexte
Objectifs
Décisions importantes
État actuel
Travail effectué
Travail restant
Risques
Blocages
Prochaine action recommandée

8.3 Alerte sans blocage

L’agent doit signaler les risques, incohérences, oublis ou informations manquantes.

Mais il ne bloque pas systématiquement le projet.

Il doit :

* prévenir ;
* expliquer le risque ;
* proposer une correction ;
* laisser l’utilisateur accepter le risque.

En cas de risque fort, l’agent doit insister clairement.

8.4 Pas d’action critique sans validation

Actions nécessitant validation humaine :

* suppression massive ;
* réorganisation de dossiers ;
* changement de stack ;
* migration base de données ;
* déploiement ;
* release ;
* push Git important ;
* abandon d’une option structurante ;
* envoi d’un courrier important ;
* action juridique ou administrative sensible.

⸻

9. Gestion des preuves et documents sources

Pour les projets Life, il faut combiner deux logiques :

9.1 Documents stockés physiquement

Les documents doivent être rangés dans des dossiers lisibles humainement.

Exemples :

documents/
correspondances/
preuves/
photos/
courriers/

9.2 Registre logique des preuves

Créer un fichier de registre :

EVIDENCE.md

ou en français :

PREUVES.md

Ce fichier doit référencer les documents.

Exemple :

# PREUVES
## P-0001 — Email du syndic concernant les travaux
Date du document :
Date d’ajout :
Type : email / PDF / photo / courrier
Source :
Chemin fichier :
Sujet :
Résumé :
Relié à :
- Décision :
- Tâche :
- Événement :

Objectif :

* l’humain retrouve le fichier ;
* l’agent comprend son rôle ;
* chaque affirmation importante peut être reliée à une source.

⸻

10. Organisation physique des dossiers

L’organisation physique est un point central du projet.

L’utilisateur a explicitement indiqué que le chaos des dossiers et sous-dossiers est un problème récurrent.

Le système doit donc :

* créer une structure claire ;
* maintenir cette structure ;
* éviter les fichiers dispersés ;
* éviter les doublons ;
* éviter les noms incohérents ;
* auditer les dossiers ;
* proposer des réorganisations ;
* ne jamais réorganiser massivement sans validation.

⸻

11. Structure proposée — Core Project OS

Base commune minimale :

MonProjet/
├── PROJECT.md
├── PROGRESS.md
├── CHANGELOG.md
├── TASKS.md
├── DECISIONS.md
├── 00_inbox/
├── 01_context/
├── 02_work/
├── 03_documents/
├── 04_deliverables/
└── 99_archive/

Rôle des dossiers

00_inbox/

Zone temporaire.

Tout document non classé peut être placé ici.

L’agent doit régulièrement proposer de vider l’inbox.

01_context/

Contexte stable du projet.

Contient :

* notes de contexte ;
* historique ;
* parties prenantes ;
* informations générales.

02_work/

Zone de travail active.

Contient les travaux en cours.

03_documents/

Documents sources.

Contient :

* PDF ;
* images ;
* emails exportés ;
* pièces jointes ;
* documents utiles.

04_deliverables/

Livrables finaux ou semi-finaux.

Exemples :

* courrier final ;
* rapport ;
* cahier des charges ;
* version livrable ;
* export client ;
* release.

99_archive/

Anciennes versions, documents obsolètes, éléments clôturés.

⸻

12. Extension Life OS

Pour les projets Life, ajouter :

MonProjet/
├── PREUVES.md
├── ECHEANCES.md
├── CORRESPONDANCES.md
├── 05_correspondances/
├── 06_preuves/
├── 07_echeances/
└── 08_modeles/

PREUVES.md

Registre logique des preuves.

ECHEANCES.md

Suivi des dates importantes.

# ECHEANCES
## YYYY-MM-DD — Titre
Type :
Importance :
Action attendue :
Lié à :
Statut :

CORRESPONDANCES.md

Registre des échanges.

# CORRESPONDANCES
## C-0001 — Email au syndic
Date :
Canal : email / courrier / téléphone / réunion
Interlocuteur :
Résumé :
Document source :
Action suivante :

05_correspondances/

Emails, courriers, réponses, brouillons.

06_preuves/

Pièces justificatives importantes.

07_echeances/

Documents liés aux échéances.

08_modeles/

Modèles de courriers, emails, réponses types.

⸻

13. Extension Code OS

Pour les projets Code, ajouter :

MonProjet/
├── AGENTS.md
├── STACK_VALIDATION.md
├── ARCHITECTURE.md
├── SPECS.md
├── TEST_PLAN.md
├── RELEASE.md
├── IMPACT_ANALYSIS.md
├── 05_specs/
├── 06_architecture/
├── 07_tests/
├── 08_releases/
├── 09_scripts/
└── src/

13.1 AGENTS.md

Fichier d’instructions pour Claude Code, Hermes et futurs agents.

Doit expliquer :

* comment travailler dans le repo ;
* quels fichiers lire au démarrage ;
* quelles règles respecter ;
* quelles actions nécessitent validation ;
* comment mettre à jour la documentation ;
* comment gérer Git ;
* comment nommer les fichiers.

13.2 STACK_VALIDATION.md

Obligatoire avant toute première ligne de code.

Doit documenter :

* langage ;
* framework ;
* versions ;
* dépendances ;
* compatibilités ;
* contraintes d’hébergement ;
* contraintes API ;
* risques ;
* alternatives rejetées ;
* sources de validation.

Objectif :

éviter de découvrir trop tard qu’une version est incompatible avec un module.

Format recommandé :

# STACK_VALIDATION
## Stack proposée
...
## Versions
...
## Dépendances critiques
...
## Compatibilités vérifiées
...
## Incompatibilités connues
...
## Contraintes d’environnement
...
## Risques
...
## Alternatives étudiées
...
## Décision finale
...

13.3 ARCHITECTURE.md

Décrit :

* organisation du code ;
* modules ;
* responsabilités ;
* flux principaux ;
* décisions architecturales ;
* zones à ne pas modifier sans validation.

13.4 SPECS.md

Décrit les fonctionnalités attendues.

Peut être complété par 05_specs/.

13.5 TEST_PLAN.md

Décrit :

* tests manuels ;
* tests automatisés ;
* cas critiques ;
* critères de validation.

13.6 IMPACT_ANALYSIS.md

Utilisé avant toute nouvelle fonctionnalité ou modification.

L’agent doit y indiquer :

Quels fichiers sont concernés ?
Quels fichiers ne doivent pas être modifiés ?
Quels impacts sont attendus ?
Quels risques ?
Quels tests lancer ?

13.7 RELEASE.md

Prépare la livraison :

* version ;
* changements inclus ;
* checklist ;
* tests validés ;
* rollback ;
* notes de release.

⸻

14. Exigence spécifique aux projets Code

Le repository doit être organisé pour être lisible par l’humain et navigable par l’agent.

Ce n’est pas seulement une question de rangement.

C’est une condition de maintenabilité.

Le projet doit permettre à l’agent de déterminer rapidement :

où se trouve la logique métier ;
où sont les intégrations ;
où sont les contrats API ;
où sont les tests ;
où sont les décisions ;
quels fichiers modifier ;
quels fichiers ne pas toucher ;
quelles conventions respecter.

Le projet doit être maintenable par :

* un humain non-développeur ;
* Claude Code ;
* Hermes ;
* un futur agent IA.

⸻

15. Fonctionnement attendu des agents

15.1 Au démarrage d’une session

L’agent doit :

1. identifier le projet courant ;
2. lire les fichiers sacrés ;
3. lire les extensions Life ou Code si présentes ;
4. produire un résumé court ;
5. proposer la prochaine action.

15.2 Pendant une session

L’agent doit :

* suivre les tâches ;
* maintenir le progress ;
* logger les actions importantes ;
* signaler les risques ;
* demander validation pour les actions sensibles ;
* éviter les modifications hors périmètre.

15.3 En fin de session

L’agent doit mettre à jour :

* PROGRESS.md
* CHANGELOG.md
* TASKS.md
* DECISIONS.md si nécessaire
* fichiers spécifiques Life ou Code si nécessaire.

Il doit produire un résumé :

Ce qui a été fait
Ce qui reste à faire
Décisions prises
Risques ouverts
Prochaine action recommandée

⸻

16. Repository GitHub à créer

Créer un repository dédié, par exemple :

project-os-ai

Objectif du repository :

* documenter la méthode ;
* stocker les templates ;
* stocker les règles agents ;
* stocker les exemples ;
* permettre l’évolution du système ;
* permettre l’installation dans de futurs projets.

Structure recommandée du repository :

project-os-ai/
├── README.md
├── ROADMAP.md
├── CHANGELOG.md
├── LICENSE
├── docs/
│   ├── vision.md
│   ├── principles.md
│   ├── governance.md
│   ├── lifecycle.md
│   ├── naming-conventions.md
│   └── glossary.md
├── templates/
│   ├── core/
│   │   ├── PROJECT.md
│   │   ├── PROGRESS.md
│   │   ├── CHANGELOG.md
│   │   ├── TASKS.md
│   │   └── DECISIONS.md
│   ├── life/
│   │   ├── PREUVES.md
│   │   ├── ECHEANCES.md
│   │   └── CORRESPONDANCES.md
│   └── code/
│       ├── AGENTS.md
│       ├── STACK_VALIDATION.md
│       ├── ARCHITECTURE.md
│       ├── SPECS.md
│       ├── TEST_PLAN.md
│       ├── IMPACT_ANALYSIS.md
│       └── RELEASE.md
├── structures/
│   ├── core-tree.md
│   ├── life-tree.md
│   └── code-tree.md
├── agents/
│   ├── claude-code.md
│   ├── hermes.md
│   └── meta-skill.md
├── examples/
│   ├── life-copropriete/
│   ├── life-comptabilite/
│   └── code-wordpress-plugin/
└── scripts/
    └── init-project.sh

⸻

17. Rôle futur des outils identifiés

Ne pas installer ni intégrer immédiatement sans analyse.

Les outils déjà identifiés sont :

17.1 GitHub Spec Kit

Rôle potentiel :

* clarification du besoin ;
* génération de specs ;
* plan ;
* tâches.

Pertinent surtout pour Project OS Code.

17.2 Claude Code Harness

Rôle potentiel :

* encadrement de Claude Code ;
* workflow plan / work / review / release ;
* sécurité ;
* review ;
* garde-fous.

Pertinent surtout pour Project OS Code.

17.3 Matt Pocock Skills

Rôle potentiel :

* skills ciblées ;
* review ;
* transformation en issues ;
* challenge de documentation ;
* amélioration architecture.

Pertinent pour Project OS Code et possiblement pour la méta-skill.

17.4 Inspiration Company OS sur GitHub

Rôle conceptuel :

* documentation Markdown ;
* source de vérité ;
* Git comme historique ;
* structure lisible par l’IA ;
* documentation vivante.

Très pertinent pour la philosophie générale du Project OS.

17.5 Boilerplates IA type Melvynx

Rôle potentiel :

* inspiration pour repo code agent-friendly ;
* structuration stricte ;
* réduction de perte de contexte ;
* conventions agent.

À étudier plus tard.

⸻

18. Ce que Claude Code doit faire maintenant

Étape 1 — Créer le repository local

Créer un nouveau dossier :

project-os-ai

Initialiser Git.

Créer la structure de fichiers proposée.

Étape 2 — Créer les documents de vision

Créer :

README.md
docs/vision.md
docs/principles.md
docs/governance.md
docs/lifecycle.md

Ces documents doivent expliquer :

* le problème ;
* la vision ;
* la différence entre Core, Life et Code ;
* les règles de gouvernance ;
* le cycle de vie d’un projet.

Étape 3 — Créer les templates Markdown

Créer tous les templates Core, Life et Code.

Chaque template doit contenir :

* son rôle ;
* quand le mettre à jour ;
* comment l’utiliser ;
* un modèle remplissable.

Étape 4 — Créer les structures de dossiers

Créer :

structures/core-tree.md
structures/life-tree.md
structures/code-tree.md

Chaque fichier doit expliquer :

* l’arborescence ;
* le rôle de chaque dossier ;
* les fichiers attendus ;
* les règles de nommage.

Étape 5 — Créer les instructions agents

Créer :

agents/claude-code.md
agents/hermes.md
agents/meta-skill.md

La meta-skill doit expliquer comment l’agent doit accompagner l’utilisateur :

* au démarrage ;
* pendant la session ;
* à la fin ;
* lors d’une reprise ;
* lors d’une décision ;
* lors d’une action critique.

Étape 6 — Créer des exemples

Créer au moins trois exemples :

examples/life-copropriete/
examples/life-comptabilite/
examples/code-wordpress-plugin/

Chaque exemple doit contenir une mini version réaliste du Project OS.

Étape 7 — Préparer un script d’initialisation

Créer éventuellement :

scripts/init-project.sh

Objectif :

permettre de générer rapidement un nouveau projet :

./scripts/init-project.sh --type life --name "Copropriété"
./scripts/init-project.sh --type code --name "Plugin Gelato"

Le script peut être simple au départ.

⸻

19. Contraintes importantes

Simplicité

Ne pas créer une usine à gaz.

Le système doit rester maintenable.

Markdown-first

Tous les fichiers de pilotage doivent être en Markdown.

Git-friendly

Les fichiers doivent être lisibles dans GitHub.

Agent-friendly

Les fichiers doivent être faciles à lire par Claude Code et Hermes.

Human-friendly

L’utilisateur doit comprendre la structure sans être développeur.

Évolutif

La structure doit pouvoir changer avec le temps.

Validation humaine

L’agent ne doit pas effectuer d’action critique sans validation.

⸻

20. Définition du succès

Le projet sera réussi si :

1. un nouveau projet peut être créé à partir d’un template ;
2. l’utilisateur peut comprendre où ranger chaque information ;
3. Claude Code peut reprendre un projet sans historique de conversation ;
4. Hermes peut reprendre le même projet sur VPS ;
5. PROGRESS.md permet de savoir où on en est ;
6. CHANGELOG.md permet de savoir ce qui a été fait ;
7. DECISIONS.md permet de savoir pourquoi ;
8. les projets Life peuvent relier les informations aux preuves ;
9. les projets Code peuvent valider la stack avant développement ;
10. les projets Code peuvent identifier les fichiers impactés avant modification.

⸻

21. Première tâche demandée à Claude Code

Créer la première version du repository project-os-ai.

Ne pas chercher encore à intégrer Spec Kit, Harness ou Skills.

L’objectif immédiat est de créer la fondation :

Core Project OS
Life Extension
Code Extension
Templates
Documentation
Agent Instructions
Examples

Ensuite seulement, une phase d’analyse pourra comparer les outils externes :

* Spec Kit ;
* Claude Code Harness ;
* Matt Pocock Skills ;
* Melvynx boilerplate ;
* autres solutions.

⸻

22. Instruction finale pour Claude Code

Tu dois travailler comme un architecte de système documentaire et un assistant chef de projet.

Ne commence pas par coder un outil complexe.

Commence par créer une base claire, lisible, maintenable et évolutive.

Priorité absolue :

Organisation
Contexte
Traçabilité
Reprise
Décisions
Preuves
Maintenabilité

Le code viendra plus tard.

La première livraison doit être un repository bien structuré, documenté et exploitable immédiatement.
