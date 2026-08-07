# Skills du projet `<Projet>`

> Gabarit MyProjectOS. Destination : `98_configuration/skills/README.md`. Remplacer chaque bloc `<...>` puis supprimer cette note.
> Ce fichier est le **tableau de bord du parc de skills** du projet : il répond à « qu'est-ce que chaque agent peut faire aujourd'hui ? » sans ouvrir une seule skill.
> Il n'y a pas d'autre registre : le détail par opération vit dans l'`INSTALL.md` de chaque skill (tableau « limites par environnement »), le pourquoi d'une non-portabilité décidée dans le `DECISIONS.md` du projet.
> Référence du dispositif : `docs/skills-portables.md` du dépôt méthode.

## Inventaire

| Skill | `portable:` | `platforms:` | Secret | Agents équipés | Blocage résiduel |
|---|---|---|---|---|---|
| `<outil>` | oui | (aucun) | `<PREFIXE>_<CLE>` | Claude Code, Codex, Hermès | — |
| `<outil>` | partiel | (aucun) | `<PREFIXE>_<CLE>` | Claude Code, Codex | `<l'opération qui ne passe pas, et pourquoi>` |
| `<outil>` | conditionnel | `[macos]` | `<à migrer>` | Claude Code | `<le prérequis à poser, et le chemin pour y arriver>` |
| `<outil>` | non | (aucun) | `<clé privée locale>` | Claude Code uniquement, **par décision** | `<renvoi au document qui porte la décision>` |

Colonne `portable:` : `oui` (défaut, champ absent), `partiel`, `conditionnel`, `non`. Définitions dans `templates/skills/_squelette/SKILL.md`.
Colonne `platforms:` : recopier la valeur du frontmatter, ou « (aucun) » si le champ est absent, ce qui signifie compatible partout.

Règle de cohérence à vérifier en relisant ce tableau : une ligne `non` ou `partiel` **d'origine technique** doit porter un `platforms:` restrictif. Si la colonne est à « (aucun) », soit la restriction est une décision et il faut le dire dans la dernière colonne, soit le frontmatter est incomplet.

## Quand mettre ce tableau à jour

- à la création d'une skill dans `98_configuration/skills/` ;
- quand un agent s'équipe ou se dé-équipe ;
- quand un blocage résiduel est levé ;
- **quand le projet change d'environnement d'exécution** : passage de `LOCAL/` à `SYNC/`, arrivée d'un second agent, nouvelle machine. C'est le moment où un parc écrit pour une seule machine devient muet sans prévenir, et le seul moment où il faut relire toutes les lignes d'un coup.

## Historique du parc

<Facultatif. Les mouvements datés (skill ajoutée, portabilité corrigée, agent équipé) vont dans le `CHANGELOG.md` du projet sous un identifiant `CHG-`. N'écrire ici que ce qui aide à comprendre l'état présent.>
