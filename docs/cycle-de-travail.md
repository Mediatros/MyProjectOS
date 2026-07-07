# Cycle de travail — MyProjectOS

> Le rythme officiel d'exécution : une tâche par itération, clôture, contexte vidé, reprise à froid.
> C'est la règle qui rend la méthode robuste à la limite de contexte des agents.

## Pourquoi ce rythme

La fenêtre de contexte d'un agent est limitée. Quand elle sature, l'agent perd le fil, résume mal, improvise. La méthode ne lutte pas contre cette limite : elle l'organise. Toute l'information durable vit dans les fichiers sacrés, jamais dans la conversation. La conversation est jetable ; les fichiers font foi.

Corollaire : il ne faut jamais avoir besoin de « se souvenir » d'une session précédente. Si une reprise à froid échoue, ce n'est pas la mémoire qui a manqué, c'est `PROGRESS.md` qui n'a pas été tenu.

## L'itération

```text
reprendre → exécuter UNE tâche → clôturer → vider le contexte → recommencer
```

1. **Reprendre.** Lire les fichiers sacrés dans l'ordre (`PROJECT.md`, `PROGRESS.md`, `TASKS.md`, `CHANGELOG.md`, `DECISIONS.md`), produire l'état, puis prendre **une seule** tâche : celle de `prochaine_action` dans l'en-tête de `PROGRESS.md`, ou la première tâche « En cours » de `TASKS.md`.
2. **Exécuter.** La tâche, rien que la tâche. Une découverte en cours de route (bug, idée, tâche manquante) se **note dans `TASKS.md`** et ne détourne pas l'itération en cours.
3. **Clôturer.** Mettre à jour `PROGRESS.md` (état réel + bloc d'en-tête : `derniere_maj`, `prochaine_action`), ajouter l'entrée `CHG-` dans `CHANGELOG.md`, consigner les `DEC-` éventuelles, cocher la tâche dans `TASKS.md`. Produire le résumé : fait / reste / décisions / risques / prochaine action.
4. **Vider le contexte.** `/clear` côté Claude Code, fin de session ailleurs. Ce geste n'est pas une perte : si la clôture est faite, rien d'utile ne vit dans la conversation.
5. **Recommencer.** La reprise à froid suivante doit retomber exactement sur la prochaine action.

## Règles de découpage d'une tâche

Une tâche de `TASKS.md` est bien découpée si :

- elle **tient dans une itération** (une session de travail, sans saturer le contexte) ;
- elle porte un **critère de succès vérifiable**, pas une intention :
  - « corriger le bug » → « écrire un test qui reproduit le bug, puis le faire passer » ;
  - « ajouter une validation » → « les entrées invalides X, Y, Z sont rejetées avec un message » ;
  - « rédiger le courrier » → « courrier relu, daté, classé dans `04_deliverables/` » ;
- elle est **autonome** : on peut la commencer après un `/clear` sans rouvrir la précédente.

Si une tâche ne remplit pas ces conditions, la découper en `Tx.y` **avant** de commencer, pas en cours de route.

Signaux qu'une tâche est trop grosse : plusieurs décisions structurantes surgissent en la traitant ; elle touche plusieurs domaines à la fois ; sa description contient « et » plus de deux fois ; on ne sait pas dire quand elle sera finie.

## Signaux de clôture

L'agent propose la clôture (il n'attend pas que l'humain y pense) quand :

- la tâche en cours est **terminée et vérifiée** ;
- la conversation devient longue et la tâche suivante peut repartir à froid ;
- le sujet change (une autre tâche, un autre projet) ;
- une action sensible attend une validation humaine qui n'arrivera pas dans la session.

Enchaîner une deuxième tâche dans la même fenêtre est l'exception (deux tâches minuscules et liées), jamais le réflexe.

## Ce que garantit le rythme

- **Reprise fiable** : n'importe quel agent (Claude Code, Codex, Hermès), sur n'importe quelle machine, repart des fichiers.
- **Pas de dérive de périmètre** : ce qui n'est pas la tâche de l'itération va dans `TASKS.md`, pas dans l'exécution.
- **Traçabilité** : chaque itération laisse une entrée `CHG-` ; les choix laissent des `DEC-`.
- **Contexte toujours frais** : l'agent travaille en début de fenêtre, là où il est le plus fiable.

## Voir aussi

- `docs/governance.md` — rituels de session et frontière des fichiers sacrés.
- `docs/lifecycle.md` — cycle de vie complet d'un projet.
- `skills/my-project-os/SKILL.md` — la skill qui applique ce rythme (modes reprise et clôture).
