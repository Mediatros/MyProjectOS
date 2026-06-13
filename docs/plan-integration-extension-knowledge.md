# Plan : Intégration de l’extension Knowledge dans Project OS AI

Date : 2026-06-07  
Statut : Ideas  
Priorité : Haute

---

## 1. Objectif

Intégrer dans Project OS AI une extension officielle `knowledge` inspirée du framework Grok et validée par l’organisation réelle du projet `Unjque_Projet`.

But opérationnel : permettre aux agents IA de naviguer dans une base de connaissance projet par niveaux de profondeur, sans charger tout le contexte, tout en analysant explicitement les dépendances transverses avant modification.

---

## 2. Contexte

L’échange avec Grok propose un système documentaire en 3 niveaux :

- `01_Global` : vue d’ensemble ;
- `02_Domaines` : composants/domaines ;
- `03_Details` : détails techniques ;
- `PLANS/` : plans actifs/backlog/completed ;
- `kb_governance.md` : règles de navigation et anti-dérive ;
- outil complémentaire : `Understand-Anything` pour graphe et analyse d’impact.

Après vérification, `Unjque_Projet` applique déjà une version plus mature et opérationnelle de ce modèle :

```text
/home/<user>/projects/Unjque_Projet/docs/
├── kb_governance.md
├── INDEX.md
├── 01_macro/
├── 02_meso/
├── 03_micro/
├── runbooks/
└── plan/
    ├── templates/
    ├── active/
    ├── ideas/
    └── archived/
```

Constat : il ne faut pas remplacer Project OS AI par le framework Grok. Il faut en faire une extension officielle `knowledge`, avec `Unjque_Projet` comme cas de dogfood réel.

---

## 3. Périmètre

### Composants impactés

- `README.md` — présenter l’extension `knowledge` dans l’architecture Project OS.
- `docs/governance.md` — ajouter les règles de navigation documentaire par niveaux.
- `docs/principles.md` — ajouter le principe “charger progressivement le contexte”.
- `docs/lifecycle.md` — préciser quand activer l’extension `knowledge`.
- `docs/glossary.md` — définir `Knowledge`, `Niveau 1`, `Niveau 2`, `Niveau 3`, `runbook`, `plan`.
- `structures/knowledge-tree.md` — nouveau fichier décrivant l’arborescence cible.
- `templates/extensions/knowledge/` — nouveau template d’extension.
- `templates/extensions/knowledge/docs/kb_governance.md` — template générique.
- `templates/extensions/knowledge/docs/INDEX.md` — carte d’entrée générique.
- `templates/extensions/knowledge/docs/plan/templates/plan_template.md` — template de plan enrichi.
- `skills/project-os/SKILL.md` — ajouter le comportement agent pour la navigation Knowledge.
- `TASKS.md` — ajouter une phase ou sous-phase d’intégration Knowledge.
- `CHANGELOG.md` — consigner l’évolution si elle est appliquée.
- `DECISIONS.md` — créer une décision structurante si validée.

### Composants explicitement non impactés

- Hooks existants `scripts/hooks/` : pas de modification v1, sauf décision ultérieure.
- `scripts/init-project.sh` : pas de modification immédiate tant que le template `knowledge` n’est pas stabilisé.
- Templates `life/` et `code/` : ne pas les réorganiser.
- Structure Core existante : ne pas remplacer les fichiers sacrés par `KNOWLEDGE/` ou `PLANS/`.
- `Unjque_Projet` : source d’inspiration/dogfood, pas de modification dans ce plan.

---

## 4. Analyse par niveau

| Niveau | Consulter ? | Justification | Fichiers concernés |
|--------|-------------|---------------|--------------------|
| Core Project OS | Oui | Vérifier la cohérence avec le modèle Core + extensions activables. | `README.md`, `CLAUDE.md`, `PROGRESS.md`, `TASKS.md`, `docs/governance.md` |
| Extension existante Life/Code | Oui partiel | S’assurer que `knowledge` reste orthogonale et ne duplique pas Life/Code. | `structures/life-tree.md`, `structures/code-tree.md`, `templates/extensions/life/`, `templates/extensions/code/` |
| Cas réel Unjque | Oui | Utiliser l’implémentation réelle comme modèle validé. | `/home/<user>/projects/Unjque_Projet/docs/kb_governance.md`, `docs/INDEX.md`, `docs/plan/templates/plan_template.md`, `CLAUDE.md` |
| Détail technique hooks/scripts | Non en v1 | Pas de check déterministe en première intégration. | `scripts/hooks/`, `scripts/init-project.sh` |

---

## 5. Analyse des dépendances transverses

Règle à intégrer explicitement : **avant toute modification documentaire ou technique, l’agent doit analyser les dépendances transverses.**

### Comportement attendu

Avant modification, l’agent doit :

1. Identifier les domaines/composants impactés.
2. Identifier les composants explicitement non impactés.
3. Lire le niveau global avant de descendre dans les domaines.
4. Lire les documents de domaine concernés.
5. Lire les détails techniques uniquement si nécessaire.
6. Vérifier les effets de bord bidirectionnels.
7. Lister la documentation à mettre à jour.
8. Demander GO si l’action modifie structure, gouvernance, code, config ou données sensibles.

### Exemple Unjque

Modifier `WF06` n’est pas seulement une action n8n. Dépendances possibles :

- `N8N-WORKFLOWS.md`
- `NOCODB-DATABASE.md`
- `WORDPRESS-PLUGIN.md`
- `WOOCOMMERCE.md`
- `SYSTEM-LIFECYCLE.md`
- plan actif WF06
- `PROGRESS.md`
- `changelog.md`

Conclusion : l’extension `knowledge` doit empêcher l’agent de traiter un composant isolément quand il appartient à un pipeline.

---

## 6. Structure cible proposée

### 6.1 Extension générique `knowledge`

```text
MonProjet/
├── PROJECT.md
├── PROGRESS.md
├── TASKS.md
├── CHANGELOG.md
├── DECISIONS.md
└── docs/
    ├── kb_governance.md
    ├── INDEX.md
    ├── 01_global/
    ├── 02_domains/
    ├── 03_details/
    ├── runbooks/
    └── plan/
        ├── templates/
        │   └── plan_template.md
        ├── active/
        ├── ideas/
        └── archived/
```

### 6.2 Variantes autorisées

Un projet peut utiliser des noms adaptés, si le mapping est documenté dans `kb_governance.md`.

Exemple `Unjque_Projet` :

```text
01_macro   = 01_global
02_meso    = 02_domains
03_micro   = 03_details
```

Règle : les noms peuvent varier, mais la logique de profondeur doit rester stable.

---

## 7. Plan d’action

### Phase K1 — Formaliser la décision

1. Ajouter une décision candidate dans `DECISIONS.md` : extension `knowledge`.
2. Documenter les options considérées :
   - copier Grok tel quel ;
   - remplacer Project OS ;
   - intégrer comme extension ;
   - utiliser Unjque comme modèle.
3. Choisir officiellement : extension `knowledge`, inspirée Grok + dogfood Unjque.

### Phase K2 — Ajouter la structure documentaire

1. Créer `structures/knowledge-tree.md`.
2. Y documenter :
   - objectif ;
   - structure ;
   - rôles des niveaux ;
   - variantes de nommage ;
   - séparation connaissance / action.
3. Ajouter le lien dans `README.md` et documentation.

### Phase K3 — Créer les templates Knowledge

1. Créer `templates/extensions/knowledge/docs/kb_governance.md`.
2. Créer `templates/extensions/knowledge/docs/INDEX.md`.
3. Créer les dossiers :
   - `templates/extensions/knowledge/docs/01_global/`
   - `templates/extensions/knowledge/docs/02_domains/`
   - `templates/extensions/knowledge/docs/03_details/`
   - `templates/extensions/knowledge/docs/runbooks/`
   - `templates/extensions/knowledge/docs/plan/templates/`
   - `templates/extensions/knowledge/docs/plan/active/`
   - `templates/extensions/knowledge/docs/plan/ideas/`
   - `templates/extensions/knowledge/docs/plan/archived/`
4. Ajouter `.gitkeep` uniquement si nécessaire pour versionner les dossiers vides.

### Phase K4 — Ajouter le template de plan enrichi

1. Créer `templates/extensions/knowledge/docs/plan/templates/plan_template.md`.
2. Inclure :
   - objectif ;
   - contexte ;
   - périmètre ;
   - composants impactés/non impactés ;
   - analyse par niveau ;
   - dépendances transverses ;
   - risques ;
   - critères de succès ;
   - documentation à mettre à jour ;
   - validation / rollback.

### Phase K5 — Mettre à jour la gouvernance Project OS

1. Modifier `docs/governance.md` pour ajouter :
   - extension `knowledge` ;
   - navigation N1/N2/N3 ;
   - obligation d’analyse des dépendances transverses.
2. Modifier `docs/principles.md` pour ajouter :
   - “commencer large, descendre seulement si nécessaire”.
3. Modifier `docs/lifecycle.md` pour indiquer quand activer l’extension.
4. Modifier `docs/glossary.md` avec les nouveaux termes.

### Phase K6 — Mettre à jour le skill assistant

1. Modifier `skills/project-os/SKILL.md`.
2. Ajouter un mode ou comportement `knowledge-navigation`.
3. Règles agent à inclure :
   - lire `docs/INDEX.md` d’abord ;
   - justifier le niveau consulté ;
   - ne pas charger `03_details` sans besoin précis ;
   - analyser les dépendances transverses avant modification ;
   - mettre à jour les liens/index après modification.

### Phase K7 — Ajouter Unjque comme exemple de référence

1. Ajouter une section dans `structures/knowledge-tree.md` : “Exemple réel : Unjque_Projet”.
2. Référencer :
   - `docs/kb_governance.md` ;
   - `docs/INDEX.md` ;
   - `docs/01_macro/`, `02_meso/`, `03_micro/` ;
   - `docs/plan/` ;
   - `docs/.understand-anything/` comme artefact complémentaire.
3. Ne pas copier les contenus métier Unjque dans ProjectOS.

### Phase K8 — Préparer le check futur

Ne pas implémenter en v1, mais documenter un futur `check-project.sh` v2/v3 :

- vérifier présence `docs/kb_governance.md` si extension `knowledge` activée ;
- vérifier présence `docs/INDEX.md` ;
- vérifier structure niveaux ;
- détecter plans actifs non indexés ;
- avertir si détails techniques placés en Niveau 1 ;
- avertir si plan placé dans les niveaux de connaissance.

---

## 8. Risques et effets de bord

### Risque 1 — Alourdir le Core

Mitigation : `knowledge` doit rester une extension activable, pas obligatoire pour tous les projets.

### Risque 2 — Dupliquer Life/Code/Ops

Mitigation : `knowledge` classe la connaissance ; Life/Code/Ops définissent le domaine métier du projet. Les axes sont orthogonaux.

### Risque 3 — Trop de dossiers vides

Mitigation : comme le Core, les dossiers peuvent être créés à la demande. Le template peut montrer la structure sans imposer tous les dossiers vides.

### Risque 4 — Confusion plans / connaissance

Mitigation : `plan/` et `runbooks/` sont hors niveaux. Les niveaux `01/02/03` servent à comprendre ; `runbooks/` et `plan/` servent à faire/préparer.

### Risque 5 — Understand-Anything pris pour source de vérité

Mitigation : documenter que l’outil est complémentaire. La source de vérité reste Markdown + système réel.

### Risque 6 — Règles non appliquées par les agents

Mitigation : mettre à jour le skill assistant et prévoir un check script futur.

---

## 9. Critères de succès

- Une décision `DEC-XXXX` valide l’extension `knowledge`.
- `structures/knowledge-tree.md` existe et explique clairement le modèle.
- `templates/extensions/knowledge/` contient la structure générique.
- `templates/extensions/knowledge/docs/kb_governance.md` est réutilisable par nouveau projet.
- `templates/extensions/knowledge/docs/plan/templates/plan_template.md` inclut l’analyse par niveau et les dépendances transverses.
- `README.md` présente `knowledge` comme extension optionnelle.
- `docs/governance.md` décrit la navigation progressive et l’analyse d’impact.
- `skills/project-os/SKILL.md` impose le comportement agent attendu.
- `TASKS.md` reflète la phase d’intégration.
- `CHANGELOG.md` trace l’évolution.

---

## 10. Documentation à mettre à jour

- `DECISIONS.md`
- `CHANGELOG.md`
- `TASKS.md`
- `README.md`
- `docs/governance.md`
- `docs/principles.md`
- `docs/lifecycle.md`
- `docs/glossary.md`
- `structures/knowledge-tree.md`
- `skills/project-os/SKILL.md`

---

## 11. Validation / rollback

### Validation

Après implémentation :

1. Lire `README.md` et vérifier que l’architecture Core + extensions reste claire.
2. Lire `structures/knowledge-tree.md` et vérifier que le modèle est autonome.
3. Lire le template `kb_governance.md` et vérifier qu’il n’est pas spécifique à Unjque.
4. Lire le template de plan et vérifier qu’il inclut les dépendances transverses.
5. Vérifier que `Unjque_Projet` reste un exemple, pas une dépendance obligatoire.
6. Vérifier que les fichiers Markdown ont des liens relatifs corrects.

### Rollback

Si l’extension alourdit trop le système :

1. Supprimer la référence à `knowledge` dans `README.md`.
2. Retirer les ajouts de `docs/governance.md`, `principles`, `lifecycle`, `glossary`.
3. Archiver ou supprimer `templates/extensions/knowledge/` selon décision.
4. Archiver ou supprimer `structures/knowledge-tree.md` selon décision.
5. Ajouter une entrée `CHANGELOG.md` indiquant l’abandon ou le report.

---

## 12. Notes

- `Unjque_Projet` est le meilleur banc d’essai réel : pipeline NocoDB → n8n → Gelato → WooCommerce → plugin WP.
- Le framework Grok est utile comme formulation générique, mais moins propre que l’implémentation Unjque.
- La valeur ajoutée Project OS est de transformer cette pratique en extension réutilisable, pas de multiplier les squelettes.
- La règle la plus importante à préserver : **l’agent doit analyser les dépendances transverses avant modification.**
