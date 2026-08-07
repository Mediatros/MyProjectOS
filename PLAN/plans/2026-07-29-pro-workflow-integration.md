# Plan d’amélioration — Apports de Pro Workflow pour MyProjectOS

> **Statut :** document de travail — aucune décision appliquée  
> **Date :** 2026-07-29  
> **Zone :** `PLAN/plans/`  
> **Source externe étudiée :** https://github.com/rohitg00/pro-workflow  
> **Repo cible :** https://github.com/Mediatros/MyProjectOS  
> **Objectif :** identifier les mécanismes de Pro Workflow qui peuvent renforcer MyProjectOS sans remplacer son socle Markdown-first, sa gouvernance humaine ni sa portabilité multi-agent.

---

## 1. Résumé décisionnel

Pro Workflow et MyProjectOS ne répondent pas au même besoin :

- **MyProjectOS** est un système de continuité et de gouvernance projet : fichiers sacrés, reprise à froid, décisions, tâches, preuves, extensions et validation humaine.
- **Pro Workflow** est surtout un runtime de développement pour Claude Code : mémoire SQLite, recherche FTS5, hooks nombreux, protections Git/secrets, quality gates et commandes agentiques.

La bonne stratégie n’est donc pas de fusionner les deux systèmes. Elle consiste à reprendre quelques mécanismes déterministes et à les traduire selon les principes MyProjectOS :

1. ajouter une protection Git contre les commandes destructrices ;
2. ajouter un détecteur local de secrets avant écriture ou commit ;
3. formaliser une boucle de correction gouvernée, sans apprentissage automatique ;
4. renforcer la clôture déterministe des itérations Code ;
5. expérimenter un index FTS5 uniquement comme cache reconstructible de l’extension Knowledge ;
6. rendre les hooks installés plus lisibles et auditables.

**À ne pas reprendre :** base SQLite comme source de vérité, capture automatique de « learnings », bundle complet d’agents/commands/skills, dépendance Node obligatoire, métriques de coût dans le Core et promesses de compatibilité multi-agent non vérifiées.

---

## 2. Preuves observées dans Pro Workflow

Les éléments suivants sont fondés sur des fichiers inspectés dans le dépôt externe :

| Mécanisme | Preuve | Nature |
|---|---|---|
| Base SQLite locale | `src/db/index.ts`, `src/db/schema.sql` | Code déterministe, dépend de `better-sqlite3` |
| Recherche FTS5/BM25 | `src/db/schema.sql`, `src/db/store.ts` | Code déterministe |
| Capture de blocs `[LEARN]` | `scripts/learn-capture.js`, `hooks/hooks.json` | Écriture automatique en base depuis une réponse assistant |
| Configuration `require_approval: true` | `config.json` | Intention déclarative, non respectée par le chemin de capture observé |
| Détection de secrets | `scripts/secret-scan.js` | Regex déterministes |
| Protection Git destructif | `scripts/git-blast-radius.js` | Liste déterministe de commandes bloquées |
| Quality gates | `config.json` | Configuration ; exécution complète à confirmer mécanisme par mécanisme |
| Distribution plugin | `.claude-plugin/`, `package.json` | Principalement Claude Code, Node ≥ 18 |

### Limites de preuve

- Les dizaines de skills, agents, commandes et hooks annoncés n’ont pas tous été audités individuellement.
- La compatibilité fonctionnelle annoncée avec Cursor, Codex et d’autres agents n’est pas démontrée par un test de bout en bout.
- Le dépôt déclare `MIT` dans `package.json`, mais aucun fichier `LICENSE` racine n’a été trouvé lors de l’audit. Ne copier aucun code avant clarification ; ne reprendre que les concepts ou réimplémenter proprement.
- Une mémoire alimentée depuis les réponses de l’agent peut persister une erreur, une hallucination ou une instruction injectée.

---

## 3. Invariants MyProjectOS à préserver

Toute amélioration issue de ce plan doit respecter les invariants suivants :

1. **Markdown reste la source de vérité durable.** Une base ou un index local est supprimable et reconstructible.
2. **Le Core reste minimal.** Les protections propres au développement vivent dans l’extension Code ou dans une option explicitement activée.
3. **Aucune correction ne devient une règle automatiquement.** L’humain valide toute promotion vers runbook, skill, hook ou règle globale.
4. **Les fichiers sacrés restent inchangés dans leur rôle.** Aucun nouveau registre obligatoire n’est ajouté sans RETEX démontrant le besoin.
5. **Portabilité multi-agent.** Ne pas dépendre exclusivement du protocole de hooks Claude Code ; prévoir contrôle à la demande pour Hermes et Codex.
6. **Dépendances minimales.** Préférer `sh` POSIX et Python standard déjà disponible ; aucune dépendance Node obligatoire dans le Core.
7. **Chirurgie et rollback.** Chaque mécanisme est activable séparément, testé séparément et supprimable sans toucher au contenu métier du projet.
8. **Fail closed uniquement quand le signal est certain.** Les heuristiques avertissent ; les opérations clairement destructrices peuvent être bloquées.

---

## 4. Améliorations candidates

## A1 — Garde-fou Git « blast radius » pour l’extension Code

### Problème traité

Un agent peut exécuter une commande Git destructrice ou difficilement réversible : `push --force`, `reset --hard`, `clean -fd`, suppression de branche, réécriture d’historique ou restauration écrasante. Les règles documentaires seules ne garantissent pas l’interception.

### Proposition MyProjectOS

Créer un garde-fou déterministe optionnel pour les projets Code/Hybrid :

- analyser la commande avant exécution lorsqu’un runtime agent fournit un événement `PreToolUse` ;
- refuser les commandes explicitement dangereuses ;
- expliquer ce qui est bloqué et proposer une alternative non destructive ;
- exiger une validation humaine traçable pour une dérogation ;
- compléter le hook temps réel par un contrôle/audit portable à la demande lorsque Hermes ou Codex ne fournit pas le même protocole.

### Bénéfice

- réduit le risque de perte de travail ou de réécriture distante accidentelle ;
- transforme une règle de prudence en protection réelle ;
- protège particulièrement l’utilisateur non-développeur contre une commande générée par l’agent.

### Fichiers candidats

- créer `scripts/hooks/hook-pre-git.sh` ou un script dédié sous `scripts/hooks/` ;
- modifier `scripts/init-project.sh` pour une activation **optionnelle Code uniquement** ;
- modifier `docs/enforcement.md` ;
- modifier `templates/core/AGENTS.md` et, si nécessaire, la section Code ;
- modifier `scripts/check-project.sh` pour vérifier le câblage lorsqu’activé ;
- ajouter des tests de fumée dans `.github/workflows/ci.yml` ou le banc de test existant.

### Décisions avant implémentation

1. Quelles commandes sont bloquées, averties ou autorisées ?
2. La dérogation doit-elle être ponctuelle par commande, ou via un fichier de décision temporaire ?
3. Comment assurer une protection équivalente sur Claude Code, Codex et Hermes sans prétendre que leurs hooks sont identiques ?

### Critères de validation

- les commandes sûres (`git status`, `git diff`, commit normal) passent ;
- chaque commande destructrice de la matrice de test est refusée ;
- aucune simple variable d’environnement globale ne neutralise silencieusement le contrôle ;
- l’activation et la désactivation sont idempotentes ;
- rollback : retirer le câblage du hook et restaurer les artefacts méthode sauvegardés.

**Priorité proposée : haute.**

---

## A2 — Détection locale de secrets avant écriture et avant commit

### Problème traité

Les projets Code peuvent recevoir accidentellement des tokens, clés privées, mots de passe ou fichiers `.env` dans des fichiers suivis par Git. MyProjectOS documente la gouvernance des secrets, mais ne fournit pas encore un contrôle générique de contenu dans chaque projet.

### Proposition MyProjectOS

Ajouter une protection en deux niveaux :

1. **Hook temps réel optionnel** : inspecter le chemin et le contenu transmis avant `Write`/`Edit` lorsqu’un runtime le permet.
2. **Contrôle portable** : un script à la demande ou appelé par `check-project.sh` inspecte uniquement les fichiers suivis ou candidats au commit.

Le scanner doit :

- détecter les formes fortement caractéristiques : clés privées, tokens GitHub/OpenAI/Anthropic/AWS connus, affectations sensibles évidentes ;
- signaler les fichiers à risque : `.env`, `.pem`, `.key`, dossiers `secrets/` ;
- ne jamais afficher la valeur détectée ;
- produire seulement type de secret, fichier et ligne masquée ;
- distinguer blocage certain et avertissement heuristique ;
- permettre une exclusion explicite et documentée pour les fixtures de test.

### Bénéfice

- prévention au plus près de l’erreur ;
- protection indépendante du fournisseur de secrets utilisé ;
- complément de BWS/PasteGuard, sans les remplacer : BWS gère le stockage et l’injection, le scanner empêche la persistance accidentelle dans le projet.

### Fichiers candidats

- créer `scripts/check-secrets.sh` ou équivalent sans dépendance lourde ;
- étudier un hook `scripts/hooks/hook-secret-scan.sh` ;
- modifier `scripts/check-project.sh` ;
- modifier `docs/enforcement.md`, `docs/OUTILS.md` et la gouvernance secrets existante ;
- ajouter des fixtures exclusivement factices pour tester détection, masquage et faux positifs.

### Décisions avant implémentation

1. Le scan doit-il être Core, Code uniquement ou option de sécurité transverse ?
2. Quelles signatures sont assez fiables pour bloquer ?
3. Où déclarer les faux positifs légitimes sans créer une porte de contournement trop large ?

### Critères de validation

- détection sur fixtures factices connues ;
- absence de valeur sensible dans stdout, stderr ou logs ;
- fichiers ordinaires non bloqués ;
- comportement vérifié sur macOS et Linux ;
- rollback sans impact sur les fichiers métier.

**Priorité proposée : haute, après définition du périmètre exact.**

---

## A3 — Boucle de correction gouvernée : RETEX → runbook → skill → hook

### Problème traité

MyProjectOS capitalise déjà via `RETEX/`, les décisions, les skills et les hooks, mais la règle de promotion d’une correction vers une protection plus forte n’est pas encore formalisée comme un cycle unique. Une erreur peut donc être corrigée localement sans que l’agent sache quand proposer sa généralisation.

### Proposition MyProjectOS

Formaliser le cycle suivant dans la gouvernance et la skill :

```text
Erreur ou friction constatée
→ correction locale et preuve
→ RETEX si la leçon est réutilisable
→ runbook si c’est une procédure répétable
→ skill si l’agent doit l’appliquer dans plusieurs contextes
→ hook/check uniquement si la règle doit devenir déterministe
```

Pour chaque promotion, exiger :

- fréquence ou impact justifiant la généralisation ;
- preuve du problème réel ;
- périmètre concerné ;
- proposition de règle ;
- faux positifs et effets de bord ;
- décision humaine ;
- test et rollback.

Ne pas créer automatiquement un nouveau fichier `LEARNINGS.md`. Utiliser d’abord les surfaces existantes : `RETEX/`, `DECISIONS.md`, `docs/runbooks/`, skills et hooks. Un nouveau registre ne sera envisagé que si plusieurs RETEX montrent un problème de repérage.

### Bénéfice

- les corrections terrain enrichissent réellement la méthode ;
- évite de transformer chaque incident en règle globale ;
- empêche la persistance automatique d’hallucinations ou d’instructions injectées ;
- rend visible pourquoi une règle est passée de conseil à enforcement.

### Fichiers candidats

- modifier `docs/governance.md` ;
- modifier `docs/enforcement.md` ;
- modifier `docs/lifecycle.md` ou le document de cycle de travail ;
- modifier `skills/my-project-os/SKILL.md` avec un déclencheur de proposition, jamais d’application autonome ;
- ajouter un petit gabarit RETEX seulement si le format actuel n’est pas suffisant.

### Critères de validation

- rejouer trois RETEX existants et vérifier que le cycle les classe correctement ;
- aucune écriture automatique depuis une réponse de modèle ;
- toute promotion vers skill/hook pointe vers une décision et une preuve ;
- l’utilisateur peut refuser la généralisation sans nouvelle sollicitation répétitive.

**Priorité proposée : très haute — faible complexité, bénéfice transversal.**

---

## A4 — Clôture déterministe des itérations Code

### Problème traité

La skill MyProjectOS décrit déjà la clôture : tests, mise à jour du Core, résumé et reprise à froid. Le hook actuel vérifie surtout la fraîcheur de `PROGRESS.md`. Il ne prouve pas qu’une itération Code se termine avec les validations techniques attendues.

### Proposition MyProjectOS

Ajouter un contrôle de clôture optionnel et non intrusif pour Code/Hybrid :

- état Git et fichiers modifiés ;
- tâche `TASKS.md` concernée ;
- `PROGRESS.md` mis à jour ;
- tests ou commandes de validation déclarés exécutés ;
- changements structurants reliés à `CHANGELOG.md`/`DECISIONS.md` si nécessaire ;
- résumé de clôture prêt pour une reprise à froid.

Commencer par une commande explicite, par exemple un mode de la skill ou `scripts/check-iteration.sh`, avant d’envisager un hook Stop. Le hook ne doit pas lancer automatiquement des tests coûteux à chaque réponse.

### Bénéfice

- réduit les sessions terminées avec code modifié mais état documentaire obsolète ;
- relie qualité technique et continuité documentaire ;
- rend le passage Claude Code ↔ Codex ↔ Hermes plus fiable.

### Fichiers candidats

- créer `scripts/check-iteration.sh` si le besoin est validé ;
- modifier `skills/my-project-os/SKILL.md`, mode Clôture ;
- modifier `docs/cycle-de-travail.md` et `docs/enforcement.md` ;
- étudier un champ ou une convention existante pour déclarer les commandes de validation, sans nouveau fichier obligatoire.

### Décisions avant implémentation

1. Où les commandes de validation vivent-elles : `TEST_PLAN.md`, `AGENTS.md`, recette du kit de rails ou configuration dédiée ?
2. Quels contrôles sont bloquants et lesquels sont informatifs ?
3. Le contrôle doit-il rester manuel ou être branché au hook Stop ?

### Critères de validation

- scénario avec tests passés ;
- scénario avec tests absents ;
- scénario documentaire sans code : aucune exigence technique artificielle ;
- aucun test long lancé implicitement à chaque réponse ;
- sortie compréhensible par un non-développeur.

**Priorité proposée : moyenne à haute, après A3.**

---

## A5 — Index local FTS5/BM25 pour l’extension Knowledge

### Problème traité

Sur un projet Knowledge volumineux, la navigation par `SUJETS.md`, `docs/INDEX.md` et niveaux documentaires peut ne plus suffire pour retrouver rapidement un terme, une décision ou une procédure. Pro Workflow démontre l’intérêt d’une recherche locale FTS5/BM25.

### Proposition MyProjectOS

Expérimenter un index local **facultatif et reconstructible** :

- Markdown et Git restent l’unique source durable ;
- la base est placée dans un cache ignoré par Git, par exemple `.myprojectos/cache/` ;
- un script reconstruit l’index depuis les fichiers autorisés ;
- les résultats renvoient toujours chemin, extrait et provenance ;
- les contenus bruts ou externes ne deviennent jamais des instructions ;
- la suppression complète du cache ne fait perdre aucune information.

Cette brique doit réutiliser les leçons du Wiki Veille plutôt que créer un second moteur différent sans raison.

### Bénéfice

- recherche rapide dans les projets documentaires denses ;
- réduction du contexte chargé par l’agent ;
- meilleur repérage des documents avant lecture progressive ;
- aucune dépendance à un SaaS ou format propriétaire.

### Fichiers candidats

- prototype isolé dans un projet pilote ou sous `PLAN/` avant intégration ;
- si validé : scripts optionnels sous `scripts/` ou template Knowledge ;
- modifier `structures/knowledge-tree.md`, `docs/kb_governance.md` et le template associé ;
- modifier `.gitignore`/manifest uniquement après décision.

### Décisions avant implémentation

1. Réutiliser directement l’architecture du Wiki Veille ou extraire une brique générique ?
2. Recherche lexicale seule ou embeddings optionnels ? V1 recommandée : FTS5 uniquement.
3. Quels dossiers sont indexés ou exclus (`99_archive`, `00_inbox`, pièces sensibles) ?
4. Quelle politique de provenance et de traitement du contenu externe ?

### Critères de validation

- reconstruction depuis une copie Markdown seule ;
- résultats avec chemin et extrait vérifiables ;
- cache absent de Git ;
- suppression/rebuild sans perte ;
- benchmark sur un vrai projet Knowledge, pas seulement des fixtures.

**Priorité proposée : moyenne, expérimentation uniquement après les protections et la boucle de correction.**

---

## A6 — Manifest lisible des hooks et capacités installées

### Problème traité

À mesure que MyProjectOS ajoute des hooks optionnels, il devient difficile de savoir ce qui est réellement installé dans un projet, sur quel événement, avec quel niveau de fermeté et pour quel agent. Pro Workflow centralise ses hooks dans `hooks/hooks.json`, mais son volume rend l’ensemble difficile à auditer.

### Proposition MyProjectOS

Conserver des hooks simples, mais exposer un inventaire lisible et vérifiable :

- nom du contrôle ;
- événement et outils concernés ;
- `warning` ou `blocking` ;
- agents/runtimes couverts ;
- dépendances ;
- fichiers installés ;
- rollback ;
- version méthode.

Éviter de créer deux sources de vérité. L’option privilégiée doit être soit :

- générer cet inventaire depuis `.myprojectos/manifest` et les settings réels ;
- soit enrichir le manifest existant pour qu’il soit également lisible par `check-project.sh`.

### Bénéfice

- audit rapide de la surface d’enforcement ;
- détection des écarts Claude Code/Codex/Hermes ;
- mises à jour et rollbacks plus sûrs ;
- évite qu’un hook reste actif sans être documenté.

### Fichiers candidats

- `.myprojectos/manifest` et logique de génération dans `scripts/init-project.sh` ;
- `scripts/check-project.sh` ;
- `docs/enforcement.md` ;
- éventuellement sortie dédiée `check-project.sh --hooks` plutôt qu’un nouveau fichier durable.

### Critères de validation

- l’inventaire correspond aux fichiers et settings réellement présents ;
- un hook manquant, inconnu ou cassé est détecté ;
- aucun secret ni commande sensible n’est exposé dans le rapport ;
- le projet sans hooks optionnels reste simple.

**Priorité proposée : moyenne, à traiter avant d’accumuler de nouveaux hooks.**

---

## 5. Éléments explicitement non retenus

### Base SQLite comme mémoire principale

**Rejetée.** Elle contredirait Markdown-first, Git-friendly et la reprise sans dépendance. SQLite peut seulement être un index dérivé.

### Capture automatique de corrections depuis les réponses

**Rejetée.** Le mécanisme `[LEARN]` observé écrit directement en base alors que l’approbation est seulement déclarée dans la configuration. Risques : hallucination persistée, prompt injection, mauvaise généralisation et absence de diff humain clair.

### Import du bundle complet de Pro Workflow

**Rejeté.** Trop centré Claude Code, trop volumineux et trop difficile à auditer pour le besoin MyProjectOS. Les mécanismes doivent être réimplémentés séparément après décision.

### Nouveau fichier sacré de learnings

**Non retenu en première intention.** `RETEX/`, `DECISIONS.md`, runbooks, skills et hooks couvrent déjà les niveaux de maturité. Un nouveau registre ne sera proposé qu’après preuve d’un défaut réel de repérage.

### Cost tracking et télémétrie dans le Core

**Rejetés sans besoin démontré.** Ils ajoutent de la complexité et peuvent collecter des métadonnées sans améliorer directement la reprise à froid.

### Auto-research dans les projets

**Rejetée par défaut.** Toute source externe doit rester sourcée, isolée et analysée comme contenu non fiable. La recherche externe automatique ne doit jamais alimenter directement les règles ou la mémoire projet.

---

## 6. Ordre d’étude et d’implémentation recommandé

### Phase 0 — Arbitrage documentaire

1. Relire ce plan avec `docs/principles.md`, `docs/governance.md`, `docs/enforcement.md` et les RETEX existants.
2. Statuer séparément sur A1 à A6 : `retenir`, `expérimenter`, `reporter` ou `rejeter`.
3. Créer une entrée `DEC-XXXX` uniquement pour les choix validés.
4. Ne pas regrouper les six améliorations dans une seule release.

**Gate :** aucun code ni hook avant décisions séparées.

### Phase 1 — Boucle de correction gouvernée (A3)

Faible risque, forte valeur transverse. Formaliser d’abord comment une leçon devient une règle avant d’ajouter de nouvelles règles techniques.

**Gate :** trois RETEX existants classés avec succès, aucune auto-promotion.

### Phase 2 — Inventaire des hooks (A6)

Rendre la surface actuelle mesurable avant d’ajouter des protections.

**Gate :** inventaire fidèle des hooks réellement installés et test de détection d’un hook cassé.

### Phase 3 — Protections Code (A1 puis A2)

Implémenter chaque protection dans une release séparée, avec tests sur projet jetable et pilote réel.

**Gate A1 :** matrice Git sûre/destructrice validée.  
**Gate A2 :** fixtures factices détectées, aucun secret affiché, faux positifs acceptables.

### Phase 4 — Clôture Code (A4)

Commencer par un check explicite. N’ajouter un hook automatique qu’après RETEX montrant qu’il n’est pas trop bruyant.

**Gate :** reprise à froid réussie après une itération Code réelle.

### Phase 5 — POC Knowledge FTS5 (A5)

Prototype isolé, sans câblage installateur ni publication de méthode. Comparer la valeur au simple `rg`/index Markdown et au moteur du Wiki Veille.

**Gate :** bénéfice mesurable sur un projet dense et reconstruction complète depuis Markdown.

---

## 7. Stratégie de tests

Pour chaque amélioration retenue :

1. écrire les scénarios d’échec avant l’implémentation ;
2. tester dans un projet jetable généré par `init-project.sh` ;
3. tester Core seul pour prouver l’absence de régression ;
4. tester Code/Hybrid avec et sans option ;
5. tester `--into-existing` et `--update-method` ;
6. tester installation idempotente ;
7. exécuter `sh scripts/check-project.sh .` ;
8. exécuter la CI et les contrôles shell existants ;
9. faire un dogfood sur un seul projet réel après GO ;
10. documenter le rollback avant propagation.

Les tests doivent prouver ce qui est **bloqué**, ce qui est seulement **averti**, et ce qui reste **hors couverture** selon l’agent utilisé.

---

## 8. Impacts documentaires potentiels

Les fichiers ci-dessous ne doivent être modifiés que pour les améliorations effectivement validées :

- `docs/principles.md` — probablement inchangé ; les principes actuels suffisent ;
- `docs/governance.md` — cycle de correction gouvernée ;
- `docs/enforcement.md` — nouveaux contrôles, fermeté, limites, agents couverts ;
- `docs/cycle-de-travail.md` — clôture Code si retenue ;
- `docs/OUTILS.md` — articulation scan de secrets/BWS/PasteGuard ;
- `structures/code-tree.md` — uniquement si un nouvel artefact Code devient réellement nécessaire ;
- `structures/knowledge-tree.md` et templates Knowledge — uniquement après POC FTS5 concluant ;
- `skills/my-project-os/SKILL.md` — propositions et rituels validés ;
- `scripts/init-project.sh`, `scripts/check-project.sh`, `scripts/hooks/` — mécanismes déterministes ;
- `.github/workflows/ci.yml` — tests de non-régression ;
- `README.md` — seulement si une capacité est réellement publiée.

**Explicitement non impactés à ce stade :** contenu métier des projets, fichiers sacrés de leurs instances, secrets BWS, configuration Hermes globale et Wiki Veille.

---

## 9. Critères globaux de succès

L’intégration est réussie si :

- MyProjectOS reste utilisable sans Node, SQLite ou service externe ;
- le Core ne devient pas plus lourd pour les projets Life ;
- chaque nouvelle protection est compréhensible par l’utilisateur ;
- aucune mémoire ou règle n’est créée automatiquement depuis une réponse LLM ;
- les différences de couverture entre Claude Code, Codex et Hermes sont explicites ;
- les tests prouvent le comportement et le rollback ;
- le projet peut toujours être repris depuis Markdown + Git uniquement ;
- les mécanismes ajoutés répondent à un RETEX réel, pas à une simple possibilité technique.

---

## 10. Décisions à prendre ultérieurement

1. Valider ou rejeter séparément A1 à A6.
2. Choisir si A1/A2 sont réservés à Code ou proposés comme option transverse.
3. Définir le mécanisme de dérogation Git sans bypass silencieux.
4. Définir la politique de faux positifs du scanner de secrets.
5. Valider l’usage exclusif des surfaces existantes pour les learnings avant de créer un nouveau registre.
6. Choisir entre réutilisation du moteur Wiki Veille et POC FTS5 spécifique à MyProjectOS.
7. Désigner un projet pilote pour chaque mécanisme retenu.

---

## 11. Rollback de ce plan

Ce document n’applique aucune évolution. Pour annuler cette piste :

1. supprimer `PLAN/plans/2026-07-29-pro-workflow-integration.md` ;
2. retirer son entrée de `PLAN/README.md` ;
3. retirer la tâche de revue correspondante dans `TASKS.md` ;
4. retirer la note compacte de `PROGRESS.md`.

Aucun code, hook, fichier sacré d’un projet généré, runtime Hermes ou secret n’est modifié par ce plan.
