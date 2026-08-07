# Plan d’intégration — Mémoire dérivée multi-niveaux pour MyProjectOS

> **Statut :** document de travail — aucune intégration appliquée  
> **Date :** 2026-07-31  
> **Zone :** `PLAN/plans/`  
> **Source d’inspiration :** https://x.com/engmoelgaraihy/status/2082741601026117699  
> **Dépôt officiel étudié :** https://github.com/TencentCloud/TencentDB-Agent-Memory  
> **Repo cible :** https://github.com/Mediatros/MyProjectOS  
> **Objectif :** étudier une mémoire dérivée multi-niveaux qui complète MyProjectOS sans remplacer Markdown/Git, sans concurrencer directement Mnemosyne et sans promouvoir automatiquement les productions d’un modèle en vérité projet.

---

## 1. Résumé décisionnel

TencentDB Agent Memory apporte une idée pertinente : transformer progressivement les conversations et journaux d’agents en actifs plus compacts et réutilisables. Le projet distingue notamment une mémoire court terme symbolique et une mémoire long terme structurée, avec des sorties de type mémoire de conversation, skill, wiki et graphe de code.

MyProjectOS répond à un besoin différent : garantir une continuité projet explicite, humaine, versionnée et vérifiable grâce aux fichiers sacrés, aux extensions, aux décisions et aux contrôles déterministes.

L’identité d’intégration retenue pour ce plan est donc :

> **MyProjectOS reste la mémoire explicite et canonique du projet. Une mémoire agentique peut devenir une couche dérivée, optionnelle, reconstructible et soumise à validation humaine.**

La stratégie candidate comporte deux niveaux :

1. **reprendre les concepts utiles** dans la méthode MyProjectOS, sans dépendre du logiciel TencentDB Agent Memory ;
2. **autoriser plus tard un POC isolé** du logiciel ou de son plugin Hermes uniquement si sa compatibilité, sa sécurité et sa valeur ajoutée face à Mnemosyne sont démontrées.

Aucune installation, dépendance, modification Hermes ou activation automatique n’est couverte par le présent ajout de plan.

---

## 2. Ce qui a été vérifié dans la source

| Élément | Observation | Conséquence pour MyProjectOS |
|---|---|---|
| Architecture mémoire | Mémoire court terme symbolique + mémoire long terme structurée, pipeline L0 → L3 | Concept intéressant pour distinguer signal brut, candidat et connaissance validée |
| Stockage | SQLite et recherche vectorielle locale ; backend Tencent VDB également disponible | Toute base doit rester un cache dérivé, jamais la source de vérité |
| Actifs produits | Chat Memory, Skill, LLM-Wiki, Code-Graph | Correspondances possibles avec Core, skills, Knowledge et Code, mais sans écriture autonome |
| Intégration Hermes | Un répertoire `hermes-plugin/` existe | Existence confirmée ; maturité et compatibilité avec Hermes Agent v0.19.0 non démontrées |
| Cible principale | Le package se présente principalement comme plugin OpenClaw | Ne pas considérer le support Hermes comme production-ready sans banc d’essai |
| Runtime | Node.js `>=22.16.0` déclaré | Le VPS satisfait actuellement la version Node, mais cela ne valide pas l’intégration |
| Embeddings | Configuration OpenAI-compatible documentée ; voie locale possible via dépendance optionnelle | Risque d’envoi externe de contenu projet ; un POC devra être local-only |
| Licence | MIT affichée dans le dépôt | Autorise l’étude et l’adaptation sous réserve de vérifier les composants incorporés |
| Benchmarks | Jusqu’à 61,38 % de réduction de tokens et gains de réussite revendiqués | Résultats éditeur, non indépendamment reproduits ; ne pas les utiliser comme critère acquis |
| Maturité | Dépôt actif, mais branche/version en évolution avec `v2.0.0-beta.1` visible lors de l’étude | Éviter toute dépendance officielle avant stabilisation et tests de migration |

### Limites de preuve

- Le contenu détaillé du plugin Hermes n’a pas été audité fichier par fichier.
- L’import/export Markdown avec chemins, frontmatter, provenance et diffs Git stables n’est pas démontré.
- Le comportement réseau, la télémétrie, la rétention, la concurrence SQLite et la restauration après corruption restent à vérifier.
- Les benchmarks n’ont pas été reproduits.
- La résistance aux souvenirs faux, aux contenus injectés et aux instructions mémorisées n’est pas établie.

---

## 3. Positionnement dans MyProjectOS

### 3.1 Les deux mémoires à ne pas confondre

| Couche | Rôle | Source de vérité |
|---|---|---|
| **Mémoire projet explicite** | État, tâches, décisions, preuves, contexte stable, procédures | Markdown + Git MyProjectOS |
| **Mémoire agentique dérivée** | Rappel sémantique, condensation, suggestions, rapprochements, candidats à capitaliser | Aucune ; index/base supprimable et reconstructible |

La mémoire agentique ne doit jamais pouvoir :

- modifier seule `PROJECT.md`, `PROGRESS.md`, `TASKS.md`, `CHANGELOG.md` ou `DECISIONS.md` ;
- transformer une réponse LLM en fait validé ;
- créer une skill ou une règle globale sans décision humaine ;
- supplanter une source fraîche déclarée dans l’extension Knowledge ;
- être présentée comme une preuve ;
- rendre le projet dépendant d’un fournisseur de base vectorielle.

### 3.2 Articulation avec Mnemosyne

Hermes utilise déjà Mnemosyne comme mémoire persistante. TencentDB Agent Memory ne doit pas être ajouté comme deuxième mémoire concurrente sans démontrer un besoin distinct.

Répartition candidate :

- **Mnemosyne** : mémoire de l’utilisateur et des conversations au niveau Hermes ;
- **MyProjectOS** : vérité durable et gouvernance de chaque projet ;
- **index projet dérivé éventuel** : recherche et condensation strictement limitées au projet courant, reconstruisibles depuis les sources autorisées.

Avant tout POC, il faudra vérifier si Mnemosyne ou l’index FTS5 Knowledge déjà envisagé couvre le besoin avec moins de complexité.

---

## 4. Modèle d’intégration conceptuelle proposé

### 4.1 Cycle de maturité de l’information

```text
Conversation / outil / document
→ signal brut non fiable
→ candidat structuré et sourcé
→ validation humaine
→ destination MyProjectOS canonique
→ index dérivé reconstructible
```

Trois statuts minimaux :

1. **Brut** : extrait de conversation, résultat d’outil ou contenu externe ; non fiable et non chargé par défaut.
2. **Candidat** : proposition structurée avec provenance, destination suggérée et niveau de confiance ; aucune autorité.
3. **Validé** : information approuvée puis écrite dans la surface MyProjectOS appropriée.

### 4.2 Correspondance des actifs TencentDB avec MyProjectOS

| Actif inspirateur | Adaptation MyProjectOS candidate | Garde-fou |
|---|---|---|
| Chat Memory | Suggestion de mise à jour de l’état ou du contexte | Confirmation avant écriture ; pas de journal infini dans `PROGRESS.md` |
| Skill | Candidat issu d’un RETEX réutilisable | Cycle RETEX → runbook → skill → hook + décision humaine |
| LLM-Wiki | Candidat pour l’extension Knowledge | Provenance obligatoire ; passage par `00_inbox/` ou zone de plan avant intégration |
| Code-Graph | Index technique pour l’extension Code | Reconstructible depuis le dépôt ; jamais vérité d’architecture |
| Mémoire symbolique | Résumé compact d’une exécution ou d’un gros journal d’outils | Temporaire ; ne remplace pas les validations et preuves réelles |

### 4.3 Contrat d’une proposition de capitalisation

Une proposition générée par la couche mémoire devrait contenir au minimum :

```yaml
nature: etat|tache|decision|preuve|contexte|procedure|detail|source
statut: candidat
source: conversation|outil|document|fichier
provenance: reference_verifiable
resume: texte_court
cible_suggeree: PROGRESS|TASKS|DECISIONS|CHANGELOG|KNOWLEDGE|RETEX|SKILL
confiance: faible|moyenne|forte
risques:
  - conflit_avec_source_existante
validation_humaine: requise
```

Ce format reste une hypothèse de conception. Il ne devient ni template ni fichier obligatoire sans arbitrage.

---

## 5. Invariants d’intégration

1. **Markdown et Git restent canoniques.**
2. **Aucune écriture autonome dans les fichiers sacrés.**
3. **Aucun apprentissage automatique depuis une réponse LLM.**
4. **Provenance obligatoire pour chaque candidat.**
5. **Données externes et souvenirs rappelés traités comme données non fiables, jamais comme instructions.**
6. **Isolation stricte par projet.** Aucun mélange de mémoire entre projets, profils ou clients.
7. **Local-first.** Aucun contenu projet envoyé à un fournisseur d’embeddings sans décision explicite et gouvernance dédiée.
8. **Secrets exclus.** Les conversations, sorties d’outils et fichiers contenant des secrets ne doivent pas être capturés.
9. **Index supprimable et reconstructible.** La suppression de la couche dérivée ne doit retirer aucune connaissance canonique.
10. **Portabilité multi-agent.** L’intégration conceptuelle ne dépend pas d’OpenClaw, d’un hook Claude Code ou d’un plugin Hermes unique.
11. **Pas de doublon fonctionnel non justifié avec Mnemosyne ou FTS5.**
12. **Activation optionnelle.** Aucun nouveau composant dans le Core obligatoire.

---

## 6. Options d’intégration à arbitrer

### Option A — Reprise conceptuelle uniquement

Intégrer à la méthode :

- la distinction brut → candidat → validé ;
- le contrat de provenance ;
- la proposition de destination MyProjectOS ;
- la règle de non-promotion automatique ;
- l’idée de condensation temporaire des journaux d’outils.

**Avantages :** faible dépendance, portable, cohérent avec la gouvernance actuelle.  
**Limites :** ne fournit pas immédiatement de moteur de rappel ou de réduction de tokens.

### Option B — Étendre les briques existantes

Réutiliser :

- Mnemosyne pour le rappel conversationnel ;
- l’index FTS5 reconstructible envisagé pour Knowledge ;
- le cycle RETEX → runbook → skill → hook ;
- une future commande de revue proposant les candidats à valider.

**Avantages :** complexité minimale, pas de second moteur mémoire.  
**Limites :** nécessite de concevoir une frontière projet stricte et un format de candidats.

### Option C — POC isolé TencentDB Agent Memory

Tester le logiciel uniquement dans un environnement jetable et sur données fictives.

**Avantages :** mesure réelle de la valeur du moteur et du plugin Hermes.  
**Limites :** dette d’exploitation, doublon possible avec Mnemosyne, version bêta, sécurité à auditer.

### Orientation proposée

Commencer par **A + étude de B**. N’autoriser C que si un manque concret subsiste et qu’un protocole de POC est validé séparément.

---

## 7. Phases candidates

### Phase 0 — Arbitrage fonctionnel

Décider précisément le problème à résoudre :

- réduire le contexte consommé ;
- retrouver une information oubliée ;
- proposer la mise à jour des fichiers sacrés ;
- transformer un RETEX en procédure ;
- indexer Knowledge ou le code.

**Gate :** aucun outil évalué tant que le besoin prioritaire n’est pas choisi.

### Phase 1 — Cartographie des capacités existantes

Comparer le besoin retenu avec :

- Mnemosyne ;
- `scripts/build-index.sh` ;
- l’index FTS5 candidat de T-PLAN-6 ;
- l’extension Knowledge ;
- le cycle RETEX/skills/hooks ;
- les modes de reprise et de revue documentaire de la skill MyProjectOS.

**Gate :** démontrer un manque réel, pas seulement une fonctionnalité séduisante.

### Phase 2 — Spécification conceptuelle

Si le manque est confirmé :

- définir le format des candidats ;
- définir les sources autorisées et exclues ;
- définir l’isolation projet ;
- définir la validation et le rejet humains ;
- définir la suppression, reconstruction et traçabilité ;
- réaliser une menace dédiée : fuite de secrets, prompt injection persistée, confusion de projet, mémoire obsolète, corruption.

**Livrable candidat :** décision + spécification, sans installation.

### Phase 3 — Prototype natif minimal

Avant TencentDB, tester une version minimale fondée sur les composants déjà présents :

- lecture ciblée d’un corpus fictif ;
- production de candidats sans écriture canonique ;
- revue humaine ;
- vérification qu’un rejet ne réapparaît pas indéfiniment ;
- suppression complète de l’index puis reconstruction.

**Gate :** valeur mesurable supérieure à une simple recherche FTS5 ou à Mnemosyne seul.

### Phase 4 — POC TencentDB optionnel

Seulement après nouveau GO explicite :

- environnement jetable, séparé de la gateway et des profils réels ;
- données synthétiques sans secret, client ni projet personnel ;
- embeddings locaux uniquement ;
- aucun accès BWS, Mnemosyne, Syncthing, dépôts privés ou fichiers sacrés réels ;
- audit du plugin Hermes et des appels réseau ;
- sauvegarde/restauration SQLite ;
- test d’injection mémorisée ;
- comparaison A/B avec la solution native minimale.

**Gate :** aucun branchement au runtime Hermes de production avant rapport et décision humaine.

### Phase 5 — Décision d’adoption

Issues possibles :

- **rejeter** : valeur insuffisante ou risques trop élevés ;
- **surveiller** : concept pertinent, outil trop immature ;
- **adapter** : reprendre uniquement un mécanisme ;
- **adopter comme outil optionnel** : uniquement avec gouvernance, skill portable, tests et rollback.

---

## 8. Matrice d’évaluation d’un POC

| Critère | Mesure attendue |
|---|---|
| Qualité du rappel | Questions préparées, réponses sourcées, faux positifs et oublis comptés |
| Réduction de contexte | Tokens ou volume de contexte comparés sur mêmes tâches |
| Exactitude | Aucun candidat présenté comme fait sans source |
| Isolation | Zéro rappel croisé entre deux projets fictifs |
| Sécurité | Secrets factices exclus ; injection mémorisée non exécutée |
| Auditabilité | Chaque candidat renvoie à une provenance vérifiable |
| Portabilité | Export lisible et reconstruction sans backend propriétaire |
| Exploitabilité | Backup, restore, migration, concurrence et corruption testés |
| Coût | RAM, CPU, disque, temps d’indexation et latence mesurés |
| Valeur marginale | Gain démontré face à Mnemosyne et FTS5 seuls |

---

## 9. Composants potentiellement impactés

### Si seule l’idée est retenue

- `docs/governance.md` : statut candidat et validation humaine ;
- `docs/principles.md` : mémoire dérivée non canonique ;
- `docs/lifecycle.md` ou `docs/cycle-de-travail.md` : revue des candidats ;
- `skills/my-project-os/SKILL.md` : proposition de capitalisation, jamais écriture autonome ;
- documentation Knowledge : provenance et index reconstructible.

### Si un outil optionnel est adopté plus tard

- `docs/OUTILS.md` ;
- `templates/configuration/GOUVERNANCE_AGENT_MEMORY.md` ;
- `templates/skills/agent-memory/` ;
- `98_configuration/` dans les projets équipés ;
- scripts de vérification, backup, restore et désinstallation ;
- documentation Hermes et multi-agent.

### Explicitement non impacté à ce stade

- fichiers sacrés et leurs rôles ;
- structure Core obligatoire ;
- configuration Hermes ;
- provider Mnemosyne ;
- gateway et profils actifs ;
- projets utilisateurs existants ;
- `docs/OUTILS.md` stable ;
- scripts, hooks et templates actuels.

---

## 10. Risques principaux

1. **Mémoire fausse mais persistante** : une hallucination devient rappelée comme vérité.
2. **Prompt injection différée** : une instruction hostile est stockée puis réinjectée plus tard.
3. **Fuite de secrets** : capture trop large des conversations ou sorties d’outils.
4. **Mélange de projets** : contamination entre clients, profils ou contextes.
5. **Conflit avec la source fraîche** : un souvenir ancien supplante un document actuel.
6. **Double mémoire** : divergences entre Mnemosyne et un second moteur.
7. **Lock-in** : dépendance au schéma SQLite, au backend Tencent ou à un format non exportable.
8. **Complexité disproportionnée** : exploitation d’un service pour un besoin couvert par Markdown + FTS5.
9. **Compatibilité trompeuse** : présence d’un badge ou dossier Hermes sans intégration réellement maintenue.
10. **Suppression automatique** : rétention ou déduplication détruisant des éléments utiles de la couche dérivée sans visibilité.

---

## 11. Critères de succès de l’intégration conceptuelle

- Une information suit explicitement le cycle brut → candidat → validé.
- Aucun candidat ne modifie un fichier sacré sans validation humaine.
- Chaque connaissance validée possède une provenance.
- Un souvenir obsolète ne prime jamais sur une source fraîche.
- Les composants dérivés peuvent être supprimés et reconstruits.
- Le système fonctionne sans TencentDB Agent Memory.
- Le besoin de Mnemosyne, FTS5 et d’un éventuel outil tiers est clairement séparé.
- Le comportement est compréhensible par un non-développeur.
- Le refus d’un candidat est respecté sans sollicitations répétitives.
- Aucun secret ni contenu inter-projet n’entre dans la couche mémoire.

---

## 12. Rollback

### Rollback du présent plan

Supprimer ce fichier et retirer ses références de `PLAN/README.md`, `PROGRESS.md`, `TASKS.md` et `CHANGELOG.md`. Aucun composant runtime ou document stable n’est affecté.

### Rollback d’une future expérimentation

- arrêter et supprimer uniquement l’environnement jetable ;
- supprimer la base et les index dérivés ;
- restaurer les configurations sauvegardées si une configuration a été testée ;
- vérifier que Markdown/Git contient toujours toute l’information canonique ;
- vérifier Hermes, Mnemosyne et les projets existants inchangés ;
- consigner le résultat et la cause d’abandon dans un RETEX.

---

## 13. Décisions à prendre ultérieurement

1. Quel problème prioritaire doit être traité : compression, rappel, capitalisation, Knowledge ou Code-Graph ?
2. Mnemosyne et FTS5 suffisent-ils après adaptation ?
3. Faut-il formaliser un objet « candidat de capitalisation » dans la méthode ?
4. Où vit temporairement un candidat sans créer un nouveau registre permanent ?
5. Comment l’utilisateur valide-t-il ou rejette-t-il les candidats simplement ?
6. Le rejet doit-il être mémorisé, où et combien de temps ?
7. Un POC TencentDB apporte-t-il une valeur mesurable suffisante pour justifier un second moteur mémoire ?
8. Le plugin Hermes est-il compatible avec la version et le provider mémoire réellement utilisés ?

Aucune de ces décisions n’est prise par la création du présent plan.
