# SUJETS.md — <NomDuProjet>

> Routeur métier : relie le vocabulaire de l'utilisateur aux bons fichiers, dans le bon ordre.
> Règle agent : pour une demande métier ou ambiguë, lire ce fichier **avant** `docs/INDEX.md`.
> La **source fraîche prioritaire** d'un sujet fait foi : une synthèse peut être en retard sur elle.

## Comment l'utiliser

Chaque sujet suivi par le projet a une fiche : les mots que l'utilisateur emploie (alias), le nom canonique du sujet, l'ordre de lecture des fichiers (source fraîche d'abord), les dépendances vers d'autres sujets, et les preuves ou décisions liées. Quand un sujet apparaît ou change de source fraîche, mettre la fiche à jour.

## Sujets

### <sujet-canonique>

- **Alias utilisateur** : <les formulations naturelles : « dépenses maison », « le budget », « les frais de X »>
- **Ordre de lecture** :
  1. `<chemin/vers/la-source-fraiche.md>` — source fraîche prioritaire, fait foi
  2. `docs/02_domains/<domaine>.md` — synthèse, à lire ensuite
- **Dépendances transverses** : <autres sujets ou domaines impactés par une modification>
- **Preuves / décisions liées** : <P-XXXX, DEC-XXXX>
- **Pièges connus** : <ex : la synthèse peut être moins fraîche que le fichier source>
