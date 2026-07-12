# GOUVERNANCE_BLUE.md — <NomDuProjet>

> Source unique de vérité pour toute interaction avec Blue (blue.cc) sur ce projet, dans le mode **miroir `TASKS.md` ↔ Blue** : chaque record Blue correspond à une ligne de `TASKS.md`, qui reste la source locale de vérité du contenu. Blue en est la vue partagée/actionnable (accessible depuis d'autres agents ou depuis un téléphone).
>
> Range ce fichier dans `98_configuration/`. Voir `docs/NAMING-CONVENTIONS.md`.
>
> **Règle d'or : tout agent lit ce fichier avant toute opération Blue sur ce projet**, et s'y conforme. Toute évolution de convention est corrigée **ici en premier** (entrée datée dans le journal en bas de fichier), jamais divergée silencieusement dans un seul agent. En cas de doute ou de conflit avec ce qu'un agent croit savoir, ce fichier fait foi.
>
> Ce gabarit est pré-rempli à partir de règles et de pièges CLI confirmés sur plusieurs projets/comptes Blue distincts (voir section « Pièges CLI connus »). Adapter les sections marquées `<...>` à ce projet ; les règles de fond (nommage, checklist, workflow) sont réutilisables telles quelles.

## Portée

- Organisation Blue : `<slug company, ex. myagent>`
- Workspace : `<NomWorkspace>`, ID `<...>`
- Ce workspace est le miroir de `TASKS.md` à la racine du projet.

## Référence — IDs (vérifiés le `<YYYY-MM-DD>`)

### Lists (statut d'avancement, miroir des cases à cocher de `TASKS.md`)

| List | ID | Correspond à |
|---|---|---|
| À faire | `<...>` | `- [ ]` sans avancement noté |
| En cours | `<...>` | `- [ ]` avec une note d'avancement partielle dans `TASKS.md` |
| Terminé | `<...>` | `- [x]` |
| Abandonné | `<...>` | tâche annulée/rendue caduque |

### Tags (domaines, miroir de la numérotation de `TASKS.md`)

| Tag | ID | Domaine `TASKS.md` |
|---|---|---|
| `<Domaine 1>` | `<...>` | `<Tx.x>` |
| ... | | |
| Urgent | `<...>` | tâche marquée ⚠️ **URGENT** dans `TASKS.md` |

### Custom Field

| Champ | ID | Type | Usage |
|---|---|---|---|
| ID | `<...>` | TEXT_SINGLE | Numéro de tâche `TASKS.md` (ex. `T8.16`) — **clé de correspondance** entre les deux systèmes |

### Utilisateurs

<Lister les comptes Blue existants et leur rôle si plusieurs personnes/agents sont assignés. Sinon : compte unique, pas d'assignation à gérer.>

## Règles de nommage et de structure d'un record

1. **Titre** : libellé court et actionnable, **sans** le préfixe `Txx` ni les décorations markdown de `TASKS.md` (pas de `**`, pas de ⚠️). Le texte doit se suffire à lui-même.
2. **Custom field `ID`** : toujours renseigné avec le numéro exact de la tâche `TASKS.md`. C'est la **clé de correspondance** entre les deux systèmes — chercher un record existant par cette valeur avant d'en créer un nouveau, jamais par le titre seul (les titres peuvent être reformulés d'un côté sans l'autre).
3. **Tag(s)** : toujours le tag de domaine correspondant au numéro de la tâche, **plus** le tag `Urgent` si la tâche porte ⚠️ **URGENT** dans `TASKS.md`.
4. **Description** : reprendre le texte complet de la ligne `TASKS.md` (moins le préfixe/numéro déjà porté par le titre et le custom field), pour garder le contexte sans avoir à rouvrir `TASKS.md`.
5. **List** : voir table de correspondance ci-dessus, selon l'état de la case à cocher et la présence d'une note d'avancement.
6. **Due Date** (si le projet tient un fichier d'échéances, ex. `ECHEANCES.md` en extension Life) : `<adapter la règle de correspondance à ce projet, ou supprimer ce point si non pertinent>`.

## Sous-tâches (checklists) — quand et comment

Créer un **checklist « Étapes »** sur le record dès que la tâche comporte plusieurs actions concrètes et discernables, notamment quand :
- la ligne `TASKS.md` liste plusieurs démarches distinctes dans une même tâche ;
- une note d'avancement introduit un **« Reste à faire »** avec plusieurs éléments ;
- la tâche a une séquence logique d'étapes (contacter → obtenir document → transmettre, etc.).

Ne pas créer de checklist pour une tâche à action unique déjà claire par son titre (surcharge inutile).

Un commentaire reste réservé au **contexte/historique ponctuel** ; une checklist sert au **suivi actionnable**. Quand un « Reste à faire » à plusieurs volets apparaît sur une tâche déjà créée sans checklist, **convertir** ce reste-à-faire en items de checklist plutôt que d'accumuler des commentaires narratifs. Cocher un item fait (plutôt que de le supprimer) pour garder l'historique.

## Workflow de synchronisation `TASKS.md` ↔ Blue

À chaque création/modification/clôture/suppression d'une tâche dans `TASKS.md`, quel que soit l'agent :

1. **Chercher le record existant** par le custom field `ID` (jamais par titre seul).
2. **Nouvelle tâche** → créer le record avec titre, description, tag(s) de domaine (+ Urgent si besoin), custom field `ID`, dans la list correspondant à son état.
3. **Tâche modifiée / avancement noté** → mettre à jour titre/description si besoin, et ajouter soit un item de checklist (action concrète restante) soit un commentaire (contexte narratif), selon la règle ci-dessus.
4. **Tâche cochée `[x]`** → déplacer le record vers la list « Terminé ».
5. **Tâche annulée/caduque** → déplacer vers « Abandonné », ne pas supprimer (garder la trace).
6. **Vérifier après coup** l'état du record (list/tags/custom field/checklist).
7. Si Blue est indisponible (credentials manquants, erreur réseau, quel que soit l'agent) : le dire explicitement, laisser une note dans la réponse, **ne jamais prétendre que la synchronisation a eu lieu**.
8. Pas d'envoi ni de suppression massive côté Blue sans validation explicite de l'utilisateur.

## Accès technique (dépend de l'agent, la gouvernance ci-dessus reste identique)

<Décrire par agent le mécanisme d'accès aux credentials (ex. trousseau macOS, wrapper CLI, flag `--company`). Chaque agent garde son propre mode d'accès aux credentials, adapté à son environnement, mais applique les mêmes règles de contenu décrites dans ce fichier.>

## Pièges CLI connus (CLI `blue`, confirmés sur plusieurs projets et comptes Blue distincts)

- `blue records update` **exige toujours `-w/--workspace`**, que ce soit pour le titre, la description ou tout autre champ. Sans ce flag : erreur `Internal server error`.
- Une **description contenant un retour à la ligne littéral ou certains caractères spéciaux** (ex. apostrophes non échappées) fait échouer `records create`/`update -d/--description` avec `GraphQL error: Syntax Error: Unterminated string`. Toujours aplatir la description sur une seule ligne avant envoi, et échapper/éviter les caractères à risque.
- Ne jamais réinjecter tel quel dans un nouveau record du texte de description capturé depuis `records get` : cette commande réécrit à l'affichage les URLs/noms de fichiers nus en `texte [http://texte]` (pur artefact d'affichage terminal, pas la donnée réelle) — le recopier pollue durablement la description stockée.
- Une **checklist ne se crée pas en une seule commande** : créer le checklist d'abord (récupérer son ID), puis ajouter les items un par un.
- `tags create --color` **refuse les noms de couleur** (ex. `red`, `blue`) malgré l'exemple d'aide de la CLI (`--color red`) : erreur `Invalid color: expected a hex string`. Toujours passer un hex (ex. `--color "#EF4444"`).

## Journal des changements

### `<YYYY-MM-DD>` — Création

- Fichier instancié à partir de `templates/configuration/GOUVERNANCE_BLUE.md` (MyProjectOS). IDs vérifiés le `<YYYY-MM-DD>`.
