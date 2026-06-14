# Gouvernance Knowledge — <NomDuProjet>

> Règles de navigation documentaire et d'analyse d'impact pour les projets avec extension Knowledge.

## Objectif

Permettre une reprise fiable sans charger toute la documentation : l'agent lit progressivement le contexte, identifie les dépendances transverses et ne modifie pas un composant comme s'il était isolé.

## Source de vérité

La source de vérité reste Markdown : fichiers sacrés Core + documentation active dans `docs/` + preuves système réelles quand l'action touche du code, des données, des workflows ou de la production.

Les indexes, graphes, captures, exports et outils comme Understand-Anything sont reconstructibles ou complémentaires. Ils ne remplacent pas les fichiers Markdown validés.

## Niveaux documentaires

```text
docs/
├── INDEX.md
├── kb_governance.md
├── 01_global/      # niveau 1 : vision globale
├── 02_domains/     # niveau 2 : domaines/composants
├── 03_details/     # niveau 3 : détails techniques
├── runbooks/       # procédures d'action
└── plan/           # plans actifs, idées, archives
```

### Niveau 1 — `01_global/`

Lire pour comprendre le projet sans détail technique :

- architecture globale ;
- cycle de vie ;
- carte des domaines ;
- règles métier durables ;
- dépendances majeures.

### Niveau 2 — `02_domains/`

Lire quand l'action concerne un domaine précis :

- workflows ;
- bases de données ;
- intégrations ;
- modules applicatifs ;
- responsabilités et frontières.

### Niveau 3 — `03_details/`

Lire uniquement si une modification technique, une vérification précise ou un incident l'exige :

- contrats API ;
- schémas détaillés ;
- mapping de champs ;
- configuration fine ;
- edge cases.

## Règle de navigation agent

Avant toute réponse structurante ou modification :

1. Lire `PROJECT.md`, `PROGRESS.md`, `TASKS.md`, `CHANGELOG.md`, `DECISIONS.md` si la reprise projet est nécessaire.
2. Lire `docs/INDEX.md`.
3. Lire le niveau global pertinent.
4. Lire les domaines impactés.
5. Lire les détails uniquement si nécessaire.
6. Lister les dépendances transverses avant de proposer ou exécuter une modification.

## Analyse transverse obligatoire

Avant une modification documentaire ou technique, produire :

- composants impactés ;
- composants explicitement non impactés ;
- fichiers à lire avant action ;
- fichiers à modifier ;
- dépendances amont / aval ;
- effets secondaires possibles ;
- validations nécessaires ;
- rollback ou retour arrière si pertinent.

## Plans

Les plans vivent dans `docs/plan/` :

- `active/` : plan validé ou en cours ;
- `ideas/` : proposition non validée ;
- `archived/` : plan terminé, abandonné ou remplacé ;
- `templates/` : modèles.

Un plan n'est pas une source de vérité permanente. Après exécution, mettre à jour les fichiers sacrés et la documentation active concernée.

## Runbooks

Les runbooks vivent dans `docs/runbooks/` et doivent contenir :

- objectif ;
- prérequis ;
- étapes ;
- validation ;
- rollback si action risquée ;
- liens vers documents sources.

## Understand-Anything

Understand-Anything peut servir à :

- visualiser les dépendances ;
- repérer des documents orphelins ;
- aider à construire une carte Niveau 1 ;
- préparer une analyse d'impact.

Limite : il ne décide pas. Il ne remplace pas `docs/INDEX.md`, `kb_governance.md`, les fichiers sacrés, ni la vérification réelle du système.
