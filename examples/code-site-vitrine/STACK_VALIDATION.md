---
projet: code-site-vitrine
statut_gate: validé
valide_le: 2026-05-12
---

# STACK_VALIDATION.md — Site vitrine Atelier Verne

> Gate obligatoire avant la première ligne de code. Chaque compatibilité affirmée est sourcée et datée.

## Stack proposée

- **Langage** : PHP (imposé par la plateforme)
- **Framework / runtime** : WordPress + thème léger (édition native par le client)
- **Base de données / stockage** : MySQL de l'hébergeur
- **Hébergement cible** : offre infogérée (sauvegardes et mises à jour de sécurité incluses)

## Versions

| Composant | Version retenue | Pourquoi cette version |
|---|---|---|
| WordPress | dernière stable de la branche courante | correctifs de sécurité actifs |
| PHP | version recommandée par WordPress au jour de la vérification | compatibilité officielle documentée |
| Thème | dernière stable | maintenu, compatible avec la version WordPress retenue |

## Dépendances critiques

- Extension de formulaire : une seule, maintenue, compatible avec la version WordPress retenue.
- Extension SMTP : fiabilise l'envoi des notifications (F-003).

## Compatibilités vérifiées

| Couple vérifié | Compatible ? | Source | Vérifié le |
|---|---|---|---|
| WordPress retenu + PHP hébergeur | oui | matrice officielle wordpress.org | 2026-05-12 |
| Thème + WordPress retenu | oui | page du thème (testé jusqu'à la version courante) | 2026-05-12 |
| Extension formulaire + WordPress retenu | oui | fiche de l'extension | 2026-05-12 |

## Incompatibilités connues

- Aucune identifiée sur ce périmètre au 2026-05-12.

## Contraintes d'environnement

- Hébergeur : limite d'envoi de 100 emails/jour (suffisant pour un formulaire de devis).

## Contraintes API

- Aucune API externe sur ce périmètre.

## Risques

- Extension de formulaire abandonnée par son auteur → parade : choisir une extension à large base d'utilisateurs, réévaluer à chaque release.

## Alternatives étudiées et rejetées

- Framework JS + CMS headless, générateur statique : voir DEC-0001 (édition autonome impossible pour le client).

## Décision finale

- **Verdict** : validé
- **Conditions** : rester sur les versions stables courantes ; toute nouvelle extension repasse par ce gate.
- **Lien** : DEC-0001
