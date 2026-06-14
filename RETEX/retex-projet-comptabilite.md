# RETEX — Projet Comptabilité globale

> Retour d'expérience issu du dogfood MyProjectOS sur `/home/<user>/projects/Comptabilite_globale`.
> Date : 2026-06-14.
> Statut : constats terrain à convertir en évolutions génériques de MyProjectOS.

## Objet du RETEX

Ce fichier ne documente pas seulement les corrections faites dans Comptabilité globale.

Son objectif est de recenser les **ajustements que nous avons été contraints de faire au cas par cas** pour que MyProjectOS fonctionne correctement sur un vrai projet Life + Knowledge dense, afin de faire évoluer le repository MyProjectOS et d'éviter que les mêmes corrections soient répétées projet par projet.

Chaque point doit donc être lu comme :

```text
problème rencontré dans Comptabilité → correction locale appliquée → évolution générique à intégrer dans MyProjectOS
```

## Contexte terrain

Le projet Comptabilité globale utilise MyProjectOS en mode **Life + Knowledge** pour piloter sept sujets/périmètres (la maison, les membres du foyer et une entité professionnelle).

C'est un bon banc d'essai parce qu'il combine :

- plusieurs sujets métier parallèles ;
- des preuves et montants engageants ;
- des dettes croisées ;
- des synthèses Markdown ;
- des exports bancaires, CSV et SQLite ;
- deux environnements agents : Hermes sur VPS et Claude Code côté projet.

## Synthèse des ajustements contraints

| Ajustement local fait dans Comptabilité | Pourquoi il a été nécessaire | Évolution à intégrer dans MyProjectOS |
|---|---|---|
| Ajout de `SUJETS.md` | Les agents ne routaient pas assez bien les demandes naturelles vers les bons fichiers | Template + règle skill + check optionnel |
| Lecture `SUJETS.md` avant `docs/INDEX.md` | `docs/INDEX.md` décrit la structure mais pas le vocabulaire utilisateur | Modifier skill `my-project-os` et docs Knowledge |
| Réalignement `maison-synthese.md` sur `budget_2026/maison_budget_2026.md` | Une synthèse peut être moins fraîche qu'un fichier métier/source | Ajouter notion de source fraîche prioritaire par sujet |
| Documentation des chemins skills Hermes vs Claude | Une skill disponible dans un environnement agent ne l'est pas forcément dans l'autre | Ajouter section multi-agent skills dans templates/agents |
| Estampille `version_methode: 0.2.0` | Le projet était conforme mais non identifiable comme aligné à une version | Renforcer migration/check version dans méthode |

## Ajustement contraint n°1 — routage métier insuffisant

### Problème rencontré

Une demande utilisateur naturelle comme :

```text
retrouve toutes les infos sur les dépenses de la maison
```

n'a pas été routée directement vers le bon sujet et la bonne source fraîche.

### Cause racine

Le problème n'est pas seulement le nom `docs/`.

- `docs/` est un conteneur documentaire utile : index, gouvernance, niveaux, runbooks, plans.
- Les demandes utilisateur sont formulées par **sujets métier** : « maison », « dépenses maison », « Joy », « frais Julien ».
- `docs/INDEX.md` décrit la carte documentaire, mais ne joue pas assez le rôle de routeur lexical.
- Une synthèse de domaine peut devenir périmée alors qu'un fichier budget/export plus récent contient la source fraîche.

Cas observé :

| Demande | Sujet canonique | Source fraîche attendue | Risque constaté |
|---|---|---|---|
| dépenses maison | `maison_jacques_dore` | `budget_2026/maison_budget_2026.md` | l'agent peut lire `docs/02_domains/maison_jacques_dore/maison-synthese.md` sans vérifier la source fraîche |

### Correction locale appliquée dans Comptabilité

Création d'un fichier racine :

```text
SUJETS.md
```

Rôle :

```text
aliases utilisateur → sujet canonique → fichiers à lire dans l'ordre → dépendances transverses → preuves/décisions liées
```

Règle locale : pour une question métier, l'agent lit `SUJETS.md` avant `docs/INDEX.md`.

### Évolution générique attendue dans MyProjectOS

### 1. Ajouter un concept de routeur de sujets

Proposition méthode : ajouter un fichier optionnel mais recommandé pour les projets Life/Knowledge denses :

```text
SUJETS.md
```

Contenu attendu :

- sujet canonique ;
- aliases utilisateur ;
- ordre de lecture ;
- source fraîche prioritaire ;
- dépendances transverses ;
- preuves/décisions liées ;
- pièges connus.

### 2. Ne pas renommer `docs/` en `sujets/` par défaut

Raison : `docs/` contient plus que des sujets.

À la place :

- garder `docs/` comme conteneur documentaire ;
- introduire `SUJETS.md` comme interface métier ;
- éventuellement renommer la section `Domaines` en `Sujets / Domaines` dans les projets concernés.

### 3. Mettre à jour la skill `my-project-os`

Règle à ajouter :

> Si la demande utilisateur est métier ou ambiguë, lire `SUJETS.md` avant `docs/INDEX.md` quand le fichier existe.

Exemples à intégrer :

- « dépenses maison » → `maison_jacques_dore` → fichier budget frais/charges avant synthèse.
- « dette Joy » → `joy` → synthèse Joy + preuves + décisions.
- « frais Julien » → `julien` → récapitulatif frais + décisions 60/40.

### 4. Mettre à jour les templates Knowledge

Ajouter dans `templates/extensions/knowledge/` :

```text
SUJETS.md
```

Ou, si le fichier doit rester à la racine du projet : l'ajouter dans `templates/core/` uniquement quand `--knowledge` est demandé par `init-project.sh`.

Point à décider :

| Option | Avantage | Risque |
|---|---|---|
| `SUJETS.md` racine | visible immédiatement par l'agent | ajoute un fichier racine |
| `docs/SUJETS.md` | reste dans Knowledge | moins visible au démarrage |

Retex Comptabilité recommande : **racine `SUJETS.md`**, car c'est un fichier de routage, pas une documentation de détail.

### 5. Mettre à jour `init-project.sh`

Si `--knowledge` est actif, créer `SUJETS.md` depuis template.

Critère de succès : un projet créé avec `--life --knowledge` contient :

```text
PROJECT.md
PROGRESS.md
TASKS.md
CHANGELOG.md
DECISIONS.md
SUJETS.md
docs/INDEX.md
docs/kb_governance.md
```

### 6. Mettre à jour `check-project.sh`

Si Knowledge actif (`docs/INDEX.md` présent), vérifier :

- `SUJETS.md` présent ;
- au moins un sujet listé ;
- pas de placeholders évidents ;
- les chemins cités dans `SUJETS.md` existent quand ils sont locaux.

Mode recommandé : warning au début, pas bloquant.

### 7. Clarifier les skills multi-agents

À documenter dans les projets qui cohabitent Hermes + Claude Code :

```text
Hermes profile skills: ~/.hermes/profiles/<profile>/skills/
Claude project skills: <project>/.claude/skills/
MyProjectOS method skill: <repo>/skills/my-project-os/SKILL.md
```

But : éviter qu'un agent suppose qu'une skill disponible côté Claude est automatiquement disponible côté Hermes.

## Ajustement local déjà appliqué dans Comptabilité

- `SUJETS.md` créé à la racine.
- `AGENTS.md` mis à jour : lire `SUJETS.md` avant `docs/INDEX.md` pour les demandes métier.
- `docs/INDEX.md` et `docs/kb_governance.md` mis à jour.
- `maison-synthese.md` réalignée sur `budget_2026/maison_budget_2026.md`.
- `PROJECT.md` estampillé `version_methode: 0.2.0`.

## Ajustement contraint n°2 — source fraîche non explicite

### Problème rencontré

Le sujet `maison_jacques_dore` possédait une synthèse domaine, mais la donnée de dépenses la plus fraîche vivait ailleurs : `budget_2026/maison_budget_2026.md`.

### Correction locale appliquée

- `SUJETS.md` indique explicitement la source fraîche prioritaire.
- `maison-synthese.md` a été réalignée sur `budget_2026/maison_budget_2026.md`.
- `docs/INDEX.md` mentionne désormais le fichier budget comme donnée du sujet maison.

### Évolution générique attendue

MyProjectOS doit permettre à chaque sujet dense de déclarer :

```text
source fraîche prioritaire
synthèse à lire ensuite
preuves/décisions liées
```

Objectif : éviter qu'un agent réponde depuis une synthèse périmée quand un fichier métier plus récent existe.

## Ajustement contraint n°3 — cohabitation Hermes / Claude Code

### Problème rencontré

Le projet est piloté par plusieurs agents, mais les emplacements de skills ne sont pas les mêmes.

### Correction locale appliquée

`AGENTS.md` et `SUJETS.md` documentent maintenant :

```text
Hermes profile skills: /root/.hermes/profiles/comptabilite_globale/skills/
Claude project skills: .claude/skills/
MyProjectOS method skill: skills/my-project-os/SKILL.md
```

### Évolution générique attendue

Les templates MyProjectOS devraient inclure une section standard :

```md
## Skills disponibles selon l'agent

### Hermes
- Profil : <nom>
- CWD : <chemin projet>
- Skills : ~/.hermes/profiles/<profile>/skills/

### Claude Code
- Skills projet : .claude/skills/

### Méthode MyProjectOS
- Skill méthode : <repo>/skills/my-project-os/SKILL.md
```

Objectif : éviter de supposer qu'une skill disponible côté Claude est disponible côté Hermes, ou inversement.

## Ajustement contraint n°4 — conformité méthode non traçable

### Problème rencontré

Le projet était fonctionnellement aligné avec MyProjectOS, mais `PROJECT.md` ne portait pas encore d'empreinte de version.

### Correction locale appliquée

Ajout :

```yaml
version_methode: 0.2.0
```

### Évolution générique attendue

MyProjectOS devrait fournir une mini-procédure de migration pour les projets créés avant le versionnement :

1. vérifier la structure ;
2. corriger les écarts ;
3. ajouter `version_methode` ;
4. journaliser la migration ;
5. lancer `check-project.sh`.

## Critère de validation méthode

Un agent recevant :

```text
Retrouve-moi toutes les dépenses de la maison
```

Doit répondre en lisant au minimum :

1. `SUJETS.md`
2. `budget_2026/maison_budget_2026.md`
3. `docs/02_domains/maison_jacques_dore/maison-synthese.md`
4. `PREUVES.md`
5. `DECISIONS.md`

Et il doit mentionner explicitement que la source fraîche des dépenses maison est `budget_2026/maison_budget_2026.md`.
