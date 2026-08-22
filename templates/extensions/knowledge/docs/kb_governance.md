# Gouvernance Knowledge — <NomDuProjet>

> Règles de navigation documentaire et d'analyse d'impact pour les projets avec extension Knowledge.
> **Principe : l'agent charge toujours la carte, jamais le territoire. Il ne descend dans le territoire que pour répondre à la demande, et n'en ramène que le strict nécessaire.**

## Objectif

Permettre à l'agent de **prendre conscience du contenu du knowledge** sans saturer la fenêtre de contexte avec des informations inutiles. L'agent sait ce que le knowledge contient (la carte), et ne charge que ce qui sert à répondre ou exécuter.

## Vocabulaire — ce que chaque terme veut dire

*La carte n'est pas un niveau. La vision n'est pas le Core. L'archive n'est pas un niveau.*

| Terme | Fichier | Rôle | Chargement |
|---|---|---|---|
| **Carte** | `SUJETS.md` (racine) + `docs/INDEX.md` | routeur métier (alias → sujet → source fraîche) + carte documentaire | **toujours**, après les fichiers sacrés Core |
| **Niveau 1 — Vision** | `docs/01_global/` | architecture, cycle de vie, carte des domaines, règles métier durables | reprise, orientation, décision structurante |
| **Niveau 2 — Domaines** | `docs/02_domains/` | workflows, bases, intégrations, responsabilités, frontières | à la demande, domaine(s) concerné(s) |
| **Niveau 3 — Détails** | `docs/03_details/` | contrats API, schémas, mapping, config fine, edge cases | à la demande, **strict nécessaire** |
| **Zone froide** | `99_archive/` (dont `99_archive/knowledge/<domaine>/`) | historique, N3 révolus, sauvegardes | sur demande explicite, jamais par défaut |

**Frontière Core / Knowledge** : `PROJECT.md` porte le pourquoi, périmètre, objectifs (stable, bouge rarement). `01_global/` porte le comment c'est structuré et comment ça tourne (évolutif). Pas de recouvrement : une information vit à un seul endroit, les autres la référencent par identifiant.

## Source de vérité

La source de vérité reste Markdown : fichiers sacrés Core + documentation active dans `docs/` + preuves système réelles quand l'action touche du code, des données, des workflows ou de la production.

Les indexes, graphes, captures, exports et outils comme Understand-Anything sont reconstructibles ou complémentaires. Ils ne remplacent pas les fichiers Markdown validés.

## SUJETS.md — le routeur métier

`docs/INDEX.md` décrit la carte documentaire ; il ne parle pas le vocabulaire de l'utilisateur. `SUJETS.md`, à la racine du projet, fait ce lien : alias utilisateur → sujet canonique → ordre de lecture → dépendances → preuves et décisions liées.

Règles :

- Pour une demande **métier ou ambiguë**, l'agent lit `SUJETS.md` **avant** `docs/INDEX.md`.
- Chaque sujet déclare sa **source fraîche prioritaire** : le fichier qui fait foi (export, budget, registre), souvent plus récent que la synthèse de domaine. L'agent ne répond jamais depuis une synthèse sans avoir vérifié la source fraîche déclarée.
- Quand une synthèse diverge de sa source fraîche, on réaligne la synthèse et on le note dans `CHANGELOG.md`.

## Règle de chargement (cœur de la doctrine)

1. **Au démarrage** : fichiers sacrés Core + carte (`SUJETS.md` puis `docs/INDEX.md`). Rien d'autre.
2. **Demande métier ou ambiguë** : `SUJETS.md` avant `INDEX.md` ; la source fraîche prioritaire d'un sujet prime sur sa synthèse.
3. **Reprise, orientation ou décision structurante** : lire le niveau Vision concerné.
4. **Charger uniquement les N2 des domaines touchés** — plusieurs si la tâche est multi-domaines, un seul sinon. Jamais un niveau entier par défaut, jamais « au cas où ».
5. **Charger un N3 uniquement** si une modification technique, une vérification précise ou un incident l'exige.
6. **Ce qui ne sert pas à répondre ou exécuter n'est jamais chargé.**

Ce chargement est un **rituel** inscrit dans `AGENTS.md`/`CLAUDE.md` du projet, pas une injection systémique : c'est l'agent qui l'applique, `check-project.sh` le vérifie.

## Frontmatter standard des documents

Chaque document de `01_global/`, `02_domains/` et `03_details/` porte un en-tête qui permet à l'agent de savoir, depuis l'index, ce qu'il trouvera en descendant, sans charger le contenu :

```yaml
---
niveau: 2
domaine: <domaine parent — niveaux 2 et 3>
resume: <une ligne : ce que couvre ce document>
depend_de: <documents ou sujets amont>
alimente: <documents ou sujets aval>
derniere_maj: YYYY-MM-DD
---
```

**`depend_de` / `alimente` portent le graphe de dépendances** : l'agent lit le graphe depuis l'index et le frontmatter, pas la clôture transitive du contenu.

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

## Budgets de taille

Seuils indicatifs, contrôlés en avertissement par `check-project.sh` :

- **la carte (`SUJETS.md` + `INDEX.md`) ne dépasse pas 200 lignes cumulées** ; elle ne contient que des pointeurs (chemin + rôle en une phrase), jamais de substance ;
- un document de **niveau 1** (`01_global/`) dépasse rarement **200 lignes** : au-delà, scinder vers un domaine ;
- un document de **niveau 2** (`02_domains/`) dépasse rarement **300 lignes** : au-delà, extraire les détails vers le niveau 3 ;
- le niveau 3 est libre ; un détail qui grossit se découpe par sujet (`<domaine>--<sujet>.md`, voir `docs/NAMING-CONVENTIONS.md`).

## Circulation

- **N2 → N3** : une section N2 au-delà du budget devient une fiche N3 ; N2 ne garde qu'un résumé + pointeur.
- **N3 → zone froide** : une fiche N3 devenue historique va dans `99_archive/knowledge/<domaine>/<sujet>.md` (provenance conservée par le sous-dossier). **Une seule zone froide : `99_archive/`.** Pas de second dossier d'archive.
- **Pas de retour froid → actif sans reconstruction** : on recrée dans le niveau actif puis on trace (CHG-). La zone froide sert à comprendre le pourquoi (« comment c'était fait »), pas à relancer l'ancien état.
- **Jamais deux sources du même fait** : une dérive = deux versions du même fait, à réaligner et tracer.
- **Renommage miroir** : si un N2 est renommé, ses N3 le sont dans le même CHG-.
- **Toute sauvegarde `.bak`** va dans `99_archive/` ou est supprimée ; jamais à la racine ni dans `docs/`.

## Anti-dérive de la carte

La carte reste une carte, pas un dump. Garde-fous :

- budget (§ Budgets de taille) et règle « pointeurs uniquement » ;
- chaque ligne de la carte pointe vers au moins un fichier existant (zéro contenu autonome) ;
- si un sujet grandit, il descend en N1/N2 — jamais dans la carte ;
- pas de date de fraîcheur dans la carte (elle vit déjà dans le frontmatter `derniere_maj` des documents) ;
- contrôles `check-project.sh` : carte trop grosse, orphelins, liens cassés (dont `SUJETS.md`), `.bak` hors archive.

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
- aider à construire la carte Niveau 1 ;
- préparer une analyse d'impact.

Limite : il ne décide pas. Il ne remplace pas `docs/INDEX.md`, `kb_governance.md`, les fichiers sacrés, ni la vérification réelle du système.

## Enforcement

`check-project.sh` (§ Navigation Knowledge) vérifie en **avertissement, jamais bloquant** : présence de `INDEX.md`/`kb_governance.md`, `SUJETS.md` non resté en gabarit, orphelins (01_global, 02_domains, 03_details, runbooks), liens cassés (`INDEX.md` **et** `SUJETS.md`), budgets (carte ≤ 200 cumulés, N1 ≤ 200, N2 ≤ 300), `.bak` hors `99_archive/`.
