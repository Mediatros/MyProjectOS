# CONSTITUTION.md — <NomDuProjet>

> Les principes propres à ce projet : les règles qui contraignent toutes les specs, plans et décisions de code.
> Emprunt à Spec Kit, réimplémenté en Markdown figé. Lu par l'agent et par Harness au démarrage (`/harness-setup`).
> Une constitution est courte et stable. Elle dit ce qui ne se négocie pas ici, pas comment coder chaque feature.

## Rôle

La constitution fixe le cadre non négociable du projet, au-dessus des fonctionnalités. Là où `SPECS.md` décrit ce qu'on construit et `ARCHITECTURE.md` comment c'est organisé, la constitution dit ce à quoi on ne déroge pas, quelle que soit la feature. Un plan ou une spec qui la viole est refusé, pas discuté.

## Principes du projet

Énoncer chaque principe en une phrase, vérifiable, au présent. Garder la liste courte (5 à 10 maximum).

- **P1 — <titre>** : <règle non négociable, ex : « toute donnée utilisateur est validée côté serveur avant écriture ».>
- **P2 — <titre>** : <...>
- **P3 — <titre>** : <...>

## Contraintes techniques imposées

Ce qui est imposé d'office et n'est pas rediscuté feature par feature.

- **Stack** : voir `STACK_VALIDATION.md` (la constitution ne duplique pas les versions, elle renvoie au gate).
- **Tests** : <niveau minimal exigé, ex : « toute feature a au moins un test d'acceptation ».>
- **Sécurité / données** : <ex : pas de secret en clair, RGPD, etc.>
- **Compatibilité** : <ex : navigateurs cibles, versions de plateforme.>

## Limites et interdits

- <ce que le projet ne fera jamais, ex : « pas de dépendance non maintenue depuis 12 mois ».>
- <zone de code à ne pas toucher sans validation, renvoyer à `ARCHITECTURE.md`.>

## Validation humaine

Au-delà des actions sensibles globales (`docs/principles.md`, principe 8), ce projet exige une validation humaine pour :

- <ex : tout changement touchant le paiement, l'authentification, la migration de données.>

## Révision

La constitution change rarement. Toute modification est une décision structurante : la tracer en `DEC-XXXX` dans `DECISIONS.md` et la dater ici.

- **Dernière révision** : YYYY-MM-DD (`DEC-XXXX`).
