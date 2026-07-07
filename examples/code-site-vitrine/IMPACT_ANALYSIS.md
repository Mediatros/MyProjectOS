# IMPACT_ANALYSIS.md — Site vitrine Atelier Verne

> Avant toute modification : ce qui est touché, ce qui ne l'est pas, comment revenir en arrière. Identifiants `IA-XXX`.

### IA-002 — Implémentation de F-003 (formulaire de devis)

- **Composants impactés** : domaine « Devis / contact » (nouvelle page), réglages email (extension SMTP).
- **Composants explicitement non impactés** : pages statiques, réalisations, thème enfant (aucun style nouveau hors formulaire).
- **Fichiers / éléments à modifier** : page devis, configuration de l'extension formulaire, configuration SMTP.
- **Dépendances** : limite d'envoi de l'hébergeur (100/jour) ; DEC-0002 (pas de stockage en base).
- **Validations** : les 4 cas F-003 du `TEST_PLAN.md`, puis recette client (T3.2).
- **Rollback** : désactivation de la page et de l'extension ; le reste du site n'est pas affecté.

### IA-001 — Mise en place de F-001 (structure et pages)

- **Composants impactés** : socle (thème enfant, navigation), 5 pages.
- **Composants explicitement non impactés** : rien d'existant (site neuf).
- **Validations** : cas F-001 du `TEST_PLAN.md`. Passées le 2026-05-28.
- **Rollback** : sans objet (préproduction).
