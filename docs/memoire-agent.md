# Mémoire d'agent : cinq couches, en fichiers

> Un agent IA n'a pas de mémoire entre deux sessions. MyProjectOS y répond sans base de données : la mémoire est faite de fichiers Markdown que l'on lit, que l'on versionne et que l'on corrige à la main.

## Le problème

Chaque session démarre avec une fenêtre de contexte vide. Les découvertes de la veille, les décisions et les corrections sont perdues : l'agent relit les mêmes fichiers, retente les mêmes pistes et refait les mêmes erreurs. L'intelligence du modèle ne compense pas cette amnésie.

La recherche sur les architectures d'agents (cadre CoALA) distingue la mémoire de travail (ce que l'agent a sous les yeux) et trois mémoires à long terme : épisodique (ce qui s'est passé), sémantique (ce qui est établi) et procédurale (comment faire). Chacune a un stockage, une lecture et une expiration propres. MyProjectOS y ajoute une cinquième couche, l'oubli, que les architectures d'agents négligent souvent. Les cinq sont tenues par les mêmes fichiers que ceux qui servent à la reprise à froid.

## Les cinq couches

| Couche | Rôle | Dans MyProjectOS | Expiration |
|---|---|---|---|
| Contexte du moment (mémoire de travail) | Ce que l'agent a sous les yeux maintenant | Lecture allégée au démarrage : `PROJECT.md` et `PROGRESS.md` en entier, extraction ciblée du reste (DEC-0051) | Fin de session |
| Historique (mémoire épisodique) | Ce qui s'est passé | `CHANGELOG.md` (registre daté et figé), `PROGRESS.md` de chaque sujet | Archivage vers `99_archive/` |
| Faits établis (mémoire sémantique) | Ce qui est vrai | `DECISIONS.md` (jamais effacée : une décision remplacée reste lisible, une erreur se corrige par une note datée), `PREUVES.md` pour les projets Life | Remplacement explicite |
| Savoir-faire (mémoire procédurale) | Comment faire | Skills du projet dans `98_configuration/skills/` | Mise à jour de la méthode (`--update-method`) |
| Oubli | Ce qu'on laisse partir | `99_archive/` (zone froide, consultée sur demande), `PROGRESS.md` purgé pour rester une photo de l'instant | Continue |

La mémoire d'un projet tient **tout entière dans son dossier** : il se déplace, se donne ou s'archive d'un bloc, et la reprise à froid ne dépend d'aucun état extérieur.

## Les couches, une par une

### Contexte du moment : une ressource rare

Charger tout le projet à chaque session coûte cher et noie le signal. Le démarrage lit en entier ce qui décrit l'état (`PROJECT.md`, `PROGRESS.md`) et n'extrait que le nécessaire des registres longs. Sur ce dépôt, cette lecture ramène environ 225 Ko à environ 35 Ko (DEC-0051). Pour la documentation dense, l'extension Knowledge applique la même idée : le sommaire d'abord, le détail seulement quand l'action l'exige (DEC-0043).

### Historique : ce qui s'est passé, sans le rejouer

`CHANGELOG.md` garde l'historique utile, daté, avec un identifiant stable par entrée (`CHG-YYYYMMDD-HHMM`). Il n'est pas relu en entier : le démarrage en lit les dernières entrées, et on y cherche un identifiant quand une tâche le demande. Dans un projet Life, chaque sujet porte son propre `PROGRESS.md`, projeté en une ligne dans le `PROGRESS.md` racine.

### Faits établis : ne pas se contredire en silence

Une décision ne s'efface jamais. Quand on change d'avis, on écrit une nouvelle décision qui **remplace** l'ancienne : celle-ci reste lisible, avec sa raison, mais marquée comme remplacée. Quand une décision contient une erreur de fait, on ajoute une **note datée de correction** sous son texte d'origine, sans le réécrire. Deux décisions contradictoires ne coexistent donc pas sans qu'un lien les relie. Dans les projets Life, `PREUVES.md` rattache chaque affirmation à un document source.

### Savoir-faire : des méthodes qui ont fait leurs preuves

Une méthode qui revient devient une skill : un dossier avec ses étapes, ses préconditions et ses cas d'échec. Elle est distribuée avec la méthode et installée pour chaque agent par le mécanisme qu'il connaît (`docs/skills-portables.md`). La règle est une seule source canonique par projet, et `check-project.sh` signale une copie qui la masque.

### Oubli : la couche que l'on oublie de construire

Un agent qui ne perd rien accumule les contradictions et les faits périmés. Trois mécanismes jouent ce rôle :

- `99_archive/` est une zone froide : ce qui y est rangé n'est jamais chargé par la reprise, seulement consulté sur demande (DEC-0041) ;
- `PROGRESS.md` est purgé pour rester un état, jamais un journal ;
- `check-project.sh` signale un `PROGRESS.md` ou un sujet actif qui n'a pas été mis à jour depuis plus de 14 jours, et un sujet clos depuis plus de 30 jours à archiver. Ce sont des avertissements, jamais des blocages, et un sujet en pause peut dormir sans être signalé.

## Ce que la méthode choisit de ne pas faire

- **Pas de base vectorielle, pas de graphe de connaissances, pas d'ontologie.** Le porteur du projet n'est pas nécessairement développeur : tout ce que l'agent « sait » doit pouvoir être relu, corrigé et contesté sur GitHub, sans outil.
- **Pas de mémoire cachée dans l'agent.** Ce qui n'est pas dans un fichier du projet n'existe pas pour la session suivante, et c'est voulu : un projet doit pouvoir changer d'agent sans rien perdre.
- **Pas de détection automatique des contradictions entre décisions.** Le remplacement d'une décision par une autre est explicite et décidé par un humain. Une contradiction qui échapperait à cette discipline ne serait pas signalée par un contrôle.

## Quand aller plus loin

Le volume peut un jour justifier un outil de mémoire externe (recherche sémantique sur un très grand historique, par exemple). Les fichiers du projet restent alors la source de vérité, et l'outil n'est qu'un index à côté : la reprise à froid ne dépend jamais de lui.

## Voir aussi

- [Vision](vision.md) : le problème et la promesse « Reprends le projet ».
- [Gouvernance](governance.md) : les rituels de session (démarrage, pendant, clôture).
- [Skills portables](skills-portables.md) : le savoir-faire, agent par agent.
- [Cycle de travail](cycle-de-travail.md) : une tâche par itération, contexte vidé entre deux.
