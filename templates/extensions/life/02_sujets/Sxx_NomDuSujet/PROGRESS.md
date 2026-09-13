---
projet: <NomDuProjet>
sujet: Sxx
titre: <TitreDuSujet>
statut: actif | en pause | clos
derniere_maj: YYYY-MM-DD
etat: <une phrase : où en est le sujet aujourd'hui>
prochaine_action: <une phrase : la prochaine action concrète, ou la condition attendue>
prochaine_echeance: <YYYY-MM-DD ou vide>
---

# PROGRESS.md — Sxx <TitreDuSujet>

> Photo de l'instant du sujet, jamais un journal. Le détail vit ici ; seul l'en-tête remonte dans le `PROGRESS.md` racine (`etat` et `prochaine_action`, une phrase chacun, 200 caractères au plus).
> Règle immuable : toute mise à jour de ce fichier met aussi à jour le bloc d'en-tête ci-dessus. Statuts : `actif` (travail en cours), `en pause` (rien à faire pour l'instant, la raison se lit dans `prochaine_action`), `clos` (réglé, à archiver ensuite).
> Frontière : l'objet du sujet vit dans `../INDEX.md`, l'historique daté dans `CHANGELOG.md`, les tâches dans `TASKS.md`, les analyses dans `NOTES.md` du sujet s'il existe.

## Objectif du sujet

<Une ligne. Le pourquoi et le périmètre vivent dans `../INDEX.md`.>

## Contexte utile

- <ce qu'il faut savoir pour reprendre ce sujet sans historique de conversation>

## État actuel

<Où en est le sujet aujourd'hui, en quelques phrases. Pas d'historique.>

## Travail en cours

- <ce qui est activement en train d'être fait sur ce sujet>

## Problèmes ouverts / points de vigilance

- <ce qui bloque, ce qui reste incertain, ce qui demande une décision>

## Prochaines étapes

1. <prochaine action concrète>
2. <puis>

## Références utiles

- <fichiers, tâches `Tx.y`, preuves `P-XXXX`, correspondances `C-XXXX` du sujet>

## Contraintes importantes / À ne pas faire

- <gardes-fous propres à ce sujet, actions nécessitant validation humaine>
