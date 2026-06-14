# Gate STACK_VALIDATION — protocole

> Le contrôle de compatibilité de stack, sourcé et obligatoire avant tout code. C'est la valeur ajoutée maison : aucun outil amont ne garantit la compatibilité des versions, c'est ce trou qu'on bouche.

## Pourquoi ce gate existe

Le risque le plus coûteux d'un projet Code n'est pas de mal coder : c'est de découvrir trop tard qu'une version de framework est incompatible avec un module, un hébergement ou une API. Le rework est alors massif. Pour un porteur non-développeur, ce risque est invisible jusqu'à ce qu'il explose.

Le gate force à vérifier la compatibilité **avant** d'écrire du code, et à **sourcer** chaque affirmation.

## Règle d'or

Tant que `STACK_VALIDATION.md` n'est pas au statut `validé`, on n'écrit pas une ligne de code applicatif. Le statut vit dans le bloc d'en-tête du fichier.

## Protocole de validation

1. **Déclarer la stack** : langage, framework, runtime, base, hébergement, versions visées.
2. **Lister les couples critiques** : chaque paire qui doit cohabiter (framework + lib majeure, runtime + plateforme, API + version).
3. **Vérifier chaque couple à la source** : documentation officielle, matrice de compatibilité, notes de version. Pas de mémoire, pas de supposition.
4. **Horodater la vérification** : chaque compatibilité affirmée porte un lien **et** une date (`Vérifié le YYYY-MM-DD`). Une vérification ancienne se re-vérifie.
5. **Consigner les incompatibilités connues** et les contraintes d'environnement et d'API (limites, dépréciations).
6. **Évaluer les risques** et noter les alternatives rejetées avec leur raison.
7. **Rendre un verdict** : `validé`, `rejeté` ou `en attente`. Un verdict structurant est aussi tracé en `DEC-XXXX`.

## Ce qui rend une affirmation acceptable

| Affirmation | Acceptable ? |
|---|---|
| « Framework X 5 marche avec lib Y 3 » | Non : pas de source, pas de date. |
| « X 5.4 + Y 3.2 compatibles (doc officielle, vérifié le 2026-06-01) » | Oui : sourcée et datée. |

## Rôle de l'agent

L'agent ne valide pas seul une stack au-delà de ses connaissances : il vérifie aux sources, expose les couples à risque, et **éclaire** le porteur (avantages, inconvénients, recommandation) avant que celui-ci tranche. Le choix d'une stack est une décision humaine assistée, pas une décision de l'agent.

## Re-validation

Le gate n'est pas un événement unique. On le repasse quand : une version majeure d'un composant change, une dépendance critique est ajoutée, ou l'hébergement cible évolue. La date de validation de l'en-tête signale la fraîcheur.
