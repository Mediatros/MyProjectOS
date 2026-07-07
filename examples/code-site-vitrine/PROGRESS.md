---
projet: code-site-vitrine
type: Code
statut: actif
derniere_maj: 2026-06-25
prochaine_action: Implémenter F-003 (formulaire de devis) selon IA-002 : créer le formulaire, brancher la notification email, dérouler les cas du TEST_PLAN.
prochaine_echeance: 2026-07-10
---

# PROGRESS.md — Site vitrine Atelier Verne

> Source de vérité opérationnelle. Lire en début de session, mettre à jour après chaque avancée significative.

## Objectif du projet

Livrer le site vitrine de l'Atelier Verne : 5 pages, réalisations éditables par le client, formulaire de devis fiable.

## État actuel

Stack validée (gate `STACK_VALIDATION.md` au statut validé le 2026-05-12, DEC-0001). F-001 (structure et pages) et F-002 (galerie de réalisations) terminées et recettées. F-003 (formulaire de devis) spécifiée, analyse d'impact IA-002 rédigée, implémentation non commencée.

## Travail en cours

- Rien en cours : la prochaine itération démarre F-003.

## Problèmes ouverts / points de vigilance

- L'hébergeur limite l'envoi d'emails à 100/jour : suffisant, mais à surveiller si le client ajoute une newsletter (hors périmètre).
- Mise en production = action sensible : validation client explicite requise (voir `RELEASE.md`).

## Prochaines étapes

1. F-003 formulaire de devis (IA-002, puis TEST_PLAN).
2. Recette complète avec le client, corrections.
3. Mise en production et formation du client (1 h).

## Références utiles

- `SPECS.md` (F-001 à F-003), `IMPACT_ANALYSIS.md` (IA-001, IA-002), `TEST_PLAN.md`.

## Contraintes importantes / À ne pas faire

- Aucune ligne de code hors périmètre validé (`CONSTITUTION.md`).
- Pas de déploiement sans passer par `RELEASE.md`.
