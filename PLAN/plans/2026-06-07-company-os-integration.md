# Plan d'évolution — intégrer les apports Company OS dans Project OS AI

> **Statut :** plan de travail, non appliqué  
> **Date :** 2026-06-07  
> **Zone :** `PLAN/plans/`  
> **Sources étudiées :**
> - Repo : `Workflowsio/company-os-starter-kit`
> - Article : `https://workflows.io/blogs/how-to-build-a-company-os-on-github`
> - Repo cible : `Mediatros/project-os-ai`

---

## 1. Introduction — réflexion issue de Company OS

### 1.1 Ce que montre le repo `company-os-starter-kit`

Le repo Company OS Starter Kit n'est pas seulement un template de dossiers. C'est un **système d'exploitation documentaire pour Claude Code**.

Structure vérifiée dans le repo :

```text
company-os-starter-kit/
├── CLAUDE.md
├── PLUGIN-GUIDE.md
├── README.md
├── blueprint/
│   ├── INDEX.md
│   ├── company/
│   ├── wiki/
│   ├── raw/
│   ├── archive/
│   ├── hooks/
│   └── skills/
├── gtm-skills/
└── plugin/
    └── commands/workflows/
        ├── brainstorm.md
        ├── compound.md
        ├── plan.md
        ├── review.md
        ├── swarm.md
        └── work.md
```

L'approche forte du repo :

- `CLAUDE.md` : fichier de boot context, chargé en premier.
- `INDEX.md` : carte de navigation.
- `company/` : identité stable de l'organisation.
- `wiki/` : SOPs, playbooks, processus.
- `raw/` : données brutes à structurer.
- `archive/` : mémoire froide, non chargée par défaut.
- `skills/` : procédures activables par Claude.
- `plugin/` : commandes, agents, hooks, workflow opérationnel.

Point clé : **l'information est classée selon son rôle dans le travail de l'agent**, pas seulement selon son thème.

### 1.2 Ce que montre l'article Workflows.io

L'article explicite mieux la philosophie que le repo.

Phrase clé de l'article :

```text
Documentation used to be a record of decisions for a person to read later.
Now it's the interface your AI uses to do work on behalf of your company.
```

Adaptation pour Project OS AI :

```text
La documentation n'est plus seulement une mémoire projet.
Elle devient l'interface opérationnelle entre l'humain, le projet et les agents IA.
```

L'article définit Company OS comme une source de vérité unique, composée de fichiers Markdown, organisée par rôle, versionnée dans Git et connectée à Claude Code par le système de fichiers.

Trois conditions de réussite :

- lisible par Claude : Markdown, texte brut, pas de format propriétaire ;
- facile à chercher : structure et noms de fichiers importants ;
- vivant : un repo statique redevient une documentation morte.

### 1.3 Les 6 dossiers structurants de Company OS

L'article décrit une classification simple :

```text
company/   # identité stable, équipe, voix, design, contexte métier
wiki/      # SOPs, playbooks, processus
clients/   # contexte isolé par client
raw/       # données brutes utiles mais non encore structurées
plugin/    # agents, commandes, hooks
skills/    # procédures exécutables par Claude
```

Lecture Project OS AI :

- `company/` correspond au **contexte stable global**.
- `wiki/` correspond aux **docs de domaine + runbooks**.
- `clients/` confirme le principe : **un projet = un contexte isolé**.
- `raw/` correspond à `00_inbox/` ou à un dossier `raw/` si présent.
- `plugin/` correspond à la couche opératoire : commandes, agents, hooks.
- `skills/` correspond au passage d'une procédure humaine à une procédure agent.

### 1.4 Le vrai concept à retenir : température contextuelle

Company OS ne nomme pas explicitement la notion de température contextuelle, mais son arborescence l'applique.

Toute information n'a pas la même température :

```text
Chaud      → chargé au démarrage, nécessaire à la reprise immédiate
Tiède      → lu pour s'orienter ou travailler sur un domaine
Froid      → consulté seulement sur demande ou pour historique
Brut       → utile mais non encore structuré
Exécutable → utilisé par l'agent pour agir
```

Project OS AI classe déjà par **nature** :

```text
PROJECT.md    → pourquoi
PROGRESS.md   → où on en est
TASKS.md      → que faire
CHANGELOG.md  → ce qui a changé
DECISIONS.md  → pourquoi cette décision
PREUVES.md    → preuves
SPECS.md      → spécifications
```

L'apport Company OS est d'ajouter une seconde coordonnée :

```text
Température : boot, orientation, stable, domaine, détail, brut, archive, exécutable
```

### 1.5 Le second concept : maturité de l'information

L'article insiste sur une boucle de transformation :

```text
raw data → structured docs → SOPs → skills → automation/hooks
```

Adaptation Project OS AI :

```text
Note brute
→ information structurée
→ runbook
→ skill
→ hook/check si critique
```

Cette règle évite deux dérives :

- transformer trop tôt toute procédure en skill ;
- laisser les procédures utiles enterrées dans des documents morts.

### 1.6 Le troisième concept : isolation des contextes

L'article explique que chaque client a son propre repo, pour éviter que Claude mélange les voix, les ICP, les campagnes et les historiques.

Traduction Project OS AI :

```text
Un projet = un Project OS isolé.
La méthode est globale.
La mémoire opérationnelle reste locale au projet.
```

Cela renforce la séparation :

- `project-os-ai` = méthode ;
- projets générés = contextes locaux ;
- Wiki Veille = veille sourcée ;
- Mnemosyne = mémoire utilisateur / préférences durables ;
- pas de second brain fourre-tout qui mélange tout.

### 1.7 Le quatrième concept : documentation vivante

Company OS fonctionne parce que :

- les corrections humaines réinjectent les skills ;
- les données récentes sont synchronisées ;
- les PR gouvernent les changements ;
- les hooks bloquent les actions risquées ;
- les SOPs deviennent progressivement exécutables.

Pour Project OS AI, la boucle de correction devrait devenir explicite :

```text
Si l'agent se trompe :
1. corriger le fichier projet si l'erreur est locale ;
2. corriger le runbook si l'erreur concerne une procédure ;
3. corriger la skill si l'erreur est récurrente ;
4. ajouter un hook/check si l'erreur doit devenir impossible.
```

---

## 2. Diagnostic Project OS AI actuel

### 2.1 Ce qui existe déjà et ne doit pas être remplacé

Project OS AI est déjà plus robuste que Company OS sur :

- fichiers sacrés ;
- reprise à froid ;
- gouvernance ;
- Life / Code / Hybrid ;
- extension Knowledge ;
- hooks déterministes ;
- init script ;
- séparation Claude Code / Hermès ;
- attention aux non-développeurs ;
- prévention du scope creep.

Objectif :

```text
Ajouter à Project OS AI la couche “température + maturité de l'information”
sans casser Core / Life / Code / Knowledge.
```

### 2.2 Ce qui manque ou mérite d'être renforcé

1. **La notion de température contextuelle n'est pas assez explicite.**
   - `01_global / 02_domains / 03_details` existe, mais la règle de chargement peut être plus claire.

2. **Le cycle raw → doc → runbook → skill → hook n'est pas formalisé.**
   - La doc parle de gouvernance / skill / hooks, mais pas encore comme une boucle de maturité.

3. **La couche opératoire pourrait être mieux nommée.**
   - `agents/`, `skills/`, `scripts/hooks/` existent, mais leur rôle commun “exécution agent” doit être explicité.

4. **Le README peut mieux expliquer que la doc devient une interface IA.**
   - C'est une phrase différenciante forte.

5. **La skill Project OS peut mieux aiguiller l'information.**
   - Elle devrait déterminer nature, température et maturité avant de ranger.

---

## 3. Décision candidate

```markdown
## DEC-XXXX — Classification par température et maturité de l'information

### Contexte

Project OS AI classe déjà l'information par nature : état, tâche, décision,
preuve, contexte, spécification, procédure.

L'analyse de Company OS montre qu'un système documentaire agent-compatible
doit aussi classer l'information par température contextuelle et par maturité
opérationnelle.

### Décision

Project OS AI adopte une double classification complémentaire :

1. Nature de l'information :
   - état
   - tâche
   - décision
   - preuve
   - contexte
   - détail
   - procédure
   - archive

2. Température contextuelle :
   - boot
   - orientation
   - stable
   - domaine
   - détail
   - brut
   - archive
   - exécutable

3. Maturité opérationnelle :
   - raw input
   - doc structurée
   - runbook
   - skill
   - hook/check

### Conséquence

Avant de ranger, déplacer ou créer une information, l'agent doit identifier :
- sa nature ;
- sa température ;
- sa maturité.

### Non-décision

Cette décision ne remplace pas Core / Life / Code / Knowledge.
Elle ajoute une grille d'aiguillage transversale.

### Rollback

Supprimer les sections ajoutées dans la documentation et revenir aux règles
actuelles de classement par fichiers sacrés et extensions.
```

---

## 4. Proposition d'intégration dans Project OS AI

### Phase 1 — Ajouter le concept dans la vision

**Objectif :** inscrire dans Project OS AI l'idée que la documentation est l'interface d'exécution des agents IA.

**Fichiers ciblés :**

```text
README.md
docs/vision.md
docs/principles.md
```

**Ajout proposé dans `README.md` :**

```markdown
## Documentation comme interface IA

Project OS AI part d'un principe simple : la documentation n'est plus seulement
une archive humaine. Elle devient l'interface par laquelle les agents IA
comprennent, reprennent et exécutent le travail.

Un bon Project OS doit donc être :

- lisible par un humain ;
- lisible par un agent ;
- versionné ;
- structuré par rôle ;
- vivant, c'est-à-dire corrigé et amélioré à chaque usage réel.
```

**Validation :** README toujours court, promesse “reprendre à froid” conservée.

### Phase 2 — Formaliser la température contextuelle

**Objectif :** toute information a une température ; l'agent charge d'abord le chaud, puis descend seulement si nécessaire.

**Fichiers ciblés :**

```text
docs/governance.md
docs/glossary.md
structures/knowledge-tree.md
templates/knowledge/docs/kb_governance.md
skills/project-os/SKILL.md
```

**Modèle proposé :**

```text
T0 — Boot context
T1 — Orientation
T2 — Contexte stable
T3 — Domaine actif
T4 — Détail / preuve / spec
T5 — Procédure exécutable
T6 — Entrée brute
T7 — Archive froide
```

**Mapping concret :**

```text
T0 Boot context
├── PROJECT.md
├── PROGRESS.md
├── TASKS.md
├── CHANGELOG.md
├── DECISIONS.md
└── AGENTS.md / CLAUDE.md

T1 Orientation
├── docs/INDEX.md
└── docs/kb_governance.md

T2 Contexte stable
└── docs/01_global/

T3 Domaine actif
└── docs/02_domains/

T4 Détail / preuve / spec
├── docs/03_details/
├── PREUVES.md
├── SPECS.md
├── ARCHITECTURE.md
└── IMPACT_ANALYSIS.md

T5 Procédure exécutable
├── docs/runbooks/
├── skills/
├── agents/
└── scripts/hooks/

T6 Entrée brute
├── 00_inbox/
└── raw/ si présent

T7 Archive froide
└── 99_archive/
```

### Phase 3 — Formaliser la maturité de l'information

**Objectif :** ajouter une règle d'évolution :

```text
raw → doc → runbook → skill → hook/check
```

**Fichiers ciblés :**

```text
docs/governance.md
docs/lifecycle.md
docs/glossary.md
skills/project-os/SKILL.md
```

**Niveaux proposés :**

```text
M0 — Raw input
M1 — Information structurée
M2 — Runbook
M3 — Skill
M4 — Hook/check
```

**Règle pratique :**

- une information unique reste une doc ;
- une procédure répétée plus de trois fois devient candidate runbook ;
- un runbook utilisé régulièrement devient candidat skill ;
- une erreur récurrente ou risquée devient candidate hook/check.

### Phase 4 — Adapter la skill `project-os`

**Objectif :** faire appliquer la grille par l'agent.

**Fichier ciblé :**

```text
skills/project-os/SKILL.md
```

**Ajout proposé :**

```markdown
## Aiguillage par nature, température et maturité

Avant de ranger une information, créer un document ou proposer un déplacement,
identifier trois choses :

1. Nature : état, tâche, décision, preuve, contexte, détail, procédure, archive.
2. Température : boot, orientation, stable, domaine, détail, brut, archive, exécutable.
3. Maturité : raw input, information structurée, runbook, skill, hook/check.
```

### Phase 5 — Mettre à jour l'extension Knowledge

**Objectif :** faire de l'extension Knowledge la traduction officielle de la température contextuelle.

**Fichiers ciblés :**

```text
structures/knowledge-tree.md
templates/knowledge/docs/kb_governance.md
templates/knowledge/docs/INDEX.md
docs/governance.md
docs/glossary.md
```

**Règle à ajouter :**

```text
L'agent lit toujours le niveau supérieur avant de descendre.
Il ne charge les détails que si l'action l'exige.
```

### Phase 6 — Ajouter une couche opératoire

**Objectif :** nommer explicitement la partie du système qui permet à l'agent d'agir.

**Fichiers ciblés :**

```text
docs/enforcement.md
docs/glossary.md
README.md
```

**Formulation proposée :**

```markdown
## Couche opératoire

La couche opératoire contient ce qui transforme la documentation en action.

Elle comprend :

- `agents/` — rôles et comportements spécialisés ;
- `skills/` — procédures exécutables par agent ;
- `scripts/hooks/` — garde-fous déterministes ;
- éventuels plugins Claude Code — commandes réutilisables.

Règle :

- une règle documentaire informe ;
- une skill guide ;
- un hook garantit ;
- un agent spécialise.
```

### Phase 7 — Ajouter une règle “projet isolé”

**Objectif :** formaliser l'équivalent des repos clients de Company OS.

**Fichiers ciblés :**

```text
docs/governance.md
docs/principles.md
docs/glossary.md
```

**Règle proposée :**

```markdown
## Isolation des contextes

Un Project OS est local à un projet.

La méthode peut être globale, mais la mémoire opérationnelle doit rester dans
le projet concerné.

Règles :

- ne pas mélanger les décisions de deux projets ;
- ne pas utiliser un wiki global comme mémoire projet ;
- ne pas copier une preuve ou un historique d'un projet vers un autre sans raison ;
- créer un Project OS séparé dès que le contexte, les acteurs ou les décisions divergent.
```

### Phase 8 — Améliorer le README avec une section “inspirations”

**Objectif :** assumer les inspirations sans dépendance forte.

**Fichier ciblé :**

```text
README.md
```

**Section proposée :**

```markdown
## Inspirations

Project OS AI s'inspire de plusieurs approches modernes d'organisation
agent-compatible :

- Company OS : documentation Markdown versionnée, structurée par rôle,
  utilisable par Claude Code comme contexte opérationnel ;
- Spec Kit : clarification amont, planification et tâches structurées ;
- Claude Code Harness : workflows plan → work → review ;
- systèmes de skills : procédures réutilisables et améliorées par usage.

Project OS AI ne copie pas ces systèmes. Il les adapte à un besoin différent :
piloter des projets Life, Code ou Hybrid avec reprise à froid, gouvernance
humaine et compatibilité Claude Code / Hermès.
```

### Phase 9 — Ajouter une checklist de classement

**Objectif :** donner un outil pratique pour l'humain et l'agent.

**Fichier recommandé :**

```text
docs/classification.md
```

**Rôle :** questionnaire simple avant de créer ou déplacer une information.

### Phase 10 — Tests et vérifications

**Commandes :**

```bash
git status --short
sh -n scripts/init-project.sh
sh -n scripts/hooks/*.sh
rm -rf /tmp/project-os-companyos-test
./scripts/init-project.sh /tmp/project-os-companyos-test --code --knowledge
grep -R "Température contextuelle" docs templates skills structures
grep -R "<NomDuProjet>" /tmp/project-os-companyos-test
```

**Attendus :**

- pas d'erreur syntaxique ;
- projet test généré ;
- templates Knowledge générés ;
- pas de placeholder résiduel ;
- git status limité aux fichiers volontairement modifiés.

---

## 5. Plan d'exécution par tâches

### Lot 0 — Préparation

- **T0.1** Lire l'état courant du repo.
- **T0.2** Créer une décision candidate dans `DECISIONS.md`.

### Lot 1 — Vision et principes

- **T1.1** Ajouter “documentation comme interface IA” dans `README.md`, `docs/vision.md`, `docs/principles.md`.

### Lot 2 — Température contextuelle

- **T2.1** Ajouter la grille T0 à T7 dans `docs/governance.md` et `docs/glossary.md`.
- **T2.2** Relier température et Knowledge dans `structures/knowledge-tree.md` et les templates Knowledge.

### Lot 3 — Maturité de l'information

- **T3.1** Ajouter le cycle raw → doc → runbook → skill → hook dans `docs/lifecycle.md`, `docs/governance.md`, `docs/glossary.md`.

### Lot 4 — Skill Project OS

- **T4.1** Ajouter l'aiguillage nature/température/maturité dans `skills/project-os/SKILL.md`.

### Lot 5 — Couche opératoire

- **T5.1** Nommer la couche opératoire dans `docs/enforcement.md` et `docs/glossary.md`.

### Lot 6 — Isolation des contextes

- **T6.1** Ajouter la règle “un projet = contexte local” dans `docs/principles.md`, `docs/governance.md`, `docs/glossary.md`.

### Lot 7 — Checklist pratique

- **T7.1** Créer `docs/classification.md`.

### Lot 8 — Tests

- **T8.1** Vérifier les scripts.
- **T8.2** Générer un projet test.
- **T8.3** Vérifier le contenu généré.
- **T8.4** Vérifier `git status --short`.

### Lot 9 — Mise à jour du pilotage projet

- **T9.1** Mettre à jour `PROGRESS.md`.
- **T9.2** Mettre à jour `TASKS.md`.
- **T9.3** Ajouter une entrée de changement si le repo dispose d'un registre racine approprié.

---

## 6. Fichiers probablement touchés lors de l'intégration

```text
README.md
PROGRESS.md
TASKS.md
DECISIONS.md
docs/vision.md
docs/principles.md
docs/governance.md
docs/lifecycle.md
docs/glossary.md
docs/enforcement.md
docs/classification.md
structures/knowledge-tree.md
templates/knowledge/docs/INDEX.md
templates/knowledge/docs/kb_governance.md
skills/project-os/SKILL.md
```

---

## 7. Risques

### Risque 1 — Surcharge documentaire

Trop de concepts peuvent rendre Project OS AI intimidant.

**Mitigation :** présenter température/maturité comme aide de classement, pas comme bureaucratie.

### Risque 2 — Confusion avec Knowledge

`Knowledge` pourrait sembler obligatoire.

**Mitigation :** rappeler que Knowledge reste optionnel ; Core reste suffisant pour les projets simples.

### Risque 3 — Automatisation trop précoce

Le cycle raw → doc → runbook → skill peut pousser à automatiser trop tôt.

**Mitigation :** écrire “candidate”, pas “obligation”. Skill seulement si procédure répétée et stable. Hook seulement si erreur critique ou récurrente.

### Risque 4 — Mélange entre méthode globale et mémoire projet

Le concept Company OS pourrait pousser vers un gros repo mémoire global.

**Mitigation :** inscrire la règle “un projet = contexte local”.

---

## 8. Rollback

Rollback simple :

1. Revert du commit d'intégration.
2. Supprimer `docs/classification.md` si créé.
3. Restaurer les versions précédentes des fichiers modifiés.
4. Supprimer ou marquer annulée la décision `DEC-XXXX`.
5. Mettre à jour `PROGRESS.md` et `TASKS.md`.

---

## 9. Recommandation finale

Intégrer Company OS dans Project OS AI sous forme de **grille transversale**, pas comme refonte.

Formule cible :

```text
Project OS AI garde son architecture :
Core / Life / Code / Hybrid / Knowledge

Et ajoute trois principes issus de Company OS :
1. documentation = interface d'exécution IA ;
2. information classée par température contextuelle ;
3. maturité progressive : raw → doc → runbook → skill → hook/check.
```

---

## 10. Prochaine action proposée

Appliquer l'intégration par lots, en commençant par :

1. `DECISIONS.md` : décision candidate ;
2. `docs/principles.md` : documentation comme interface IA ;
3. `docs/governance.md` : température contextuelle ;
4. `docs/lifecycle.md` : maturité de l'information ;
5. `skills/project-os/SKILL.md` : aiguillage agent.
