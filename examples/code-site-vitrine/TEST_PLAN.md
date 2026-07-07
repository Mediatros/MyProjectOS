# TEST_PLAN.md — Site vitrine Atelier Verne

> Ce qui est vérifié avant de déclarer une fonctionnalité livrée. Un cas non passé = fonctionnalité non livrée.

## F-003 — Formulaire de devis (à dérouler en préproduction)

| Cas | Attendu | Statut |
|---|---|---|
| Envoi valide (tous champs corrects) | email reçu par le client < 1 min, copie archivée, page de confirmation | à faire |
| Champ obligatoire manquant | blocage avec message clair sous le champ | à faire |
| Email invalide | blocage avec message clair | à faire |
| Soumission robot (anti-spam) | rejet silencieux, aucune notification | à faire |

## F-002 — Galerie (passés le 2026-06-25)

| Cas | Attendu | Statut |
|---|---|---|
| Publication d'une réalisation par le client | visible en liste et en détail sans intervention | passé |
| Photo lourde (> 5 Mo) | redimensionnée automatiquement, page fluide | passé |

## F-001 — Pages (passés le 2026-05-28)

| Cas | Attendu | Statut |
|---|---|---|
| Navigation sur mobile | menu utilisable, aucune page orpheline | passé |
| Mentions légales | accessibles depuis le pied de page | passé |
