---
projet: <NomDuProjet>
statut_gate: en cours | validé | rejeté
valide_le: YYYY-MM-DD
---

# STACK_VALIDATION.md — <NomDuProjet>

> Gate obligatoire avant la première ligne de code. Objectif : ne pas découvrir trop tard qu'une version est incompatible avec un module, un hébergement ou une API.
> Chaque compatibilité affirmée doit être **sourcée** (lien, date de vérification). Voir le protocole dans `docs/stack-validation-gate.md`.
> Le statut du gate vit dans le bloc d'en-tête. Tant qu'il n'est pas `validé`, on ne code pas.

## Stack proposée

- **Langage** : <...>
- **Framework / runtime** : <...>
- **Base de données / stockage** : <...>
- **Hébergement cible** : <...>

## Versions

| Composant | Version retenue | Pourquoi cette version |
|---|---|---|
| <...> | <...> | <...> |

## Dépendances critiques

- <librairie + version + rôle>

## Compatibilités vérifiées

| Couple vérifié | Compatible ? | Source | Vérifié le |
|---|---|---|---|
| <ex : framework X 5.x + lib Y 3.x> | oui | <lien doc officielle> | YYYY-MM-DD |

## Incompatibilités connues

- <couple incompatible + source>

## Contraintes d'environnement

- <hébergement, runtime, limites mémoire, version de plateforme imposée>

## Contraintes API

- <limites de débit, versions d'API, authentification, échéances de dépréciation>

## Risques

- <risque + probabilité + parade envisagée>

## Alternatives étudiées et rejetées

- <option + raison du rejet>

## Décision finale

- **Verdict** : <validé | rejeté | en attente d'une vérification>
- **Conditions** : <ce qui doit rester vrai pour que la stack tienne>
- **Lien** : <DEC-XXXX>
