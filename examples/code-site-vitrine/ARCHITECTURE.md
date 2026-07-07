# ARCHITECTURE.md — Site vitrine Atelier Verne

> Comment le site est organisé, par domaine fonctionnel. Sert de carte avant toute modification.

## Vue d'ensemble

```text
Site Atelier Verne
├── Pages statiques        # accueil, atelier, mentions légales (éditées par le client)
├── Réalisations           # type de contenu dédié + galerie (F-002)
├── Devis / contact        # formulaire + notification email (F-003)
└── Socle                  # thème enfant, réglages, référencement local
```

## Domaines et responsabilités

| Domaine | Contenu | Qui modifie |
|---|---|---|
| Pages statiques | textes et photos de présentation | le client, en autonomie |
| Réalisations | type de contenu « réalisation » (titre, photos, description) | le client |
| Devis / contact | formulaire, destinataire, anti-spam, page de confirmation | prestataire uniquement |
| Socle | thème enfant (styles, en-têtes), réglages, sauvegardes | prestataire uniquement |

## Règles

- Toute personnalisation vit dans le thème enfant : jamais dans le thème parent ni le cœur.
- Une modification du domaine « Devis / contact » ou « Socle » exige une `IMPACT_ANALYSIS.md` (`IA-XXX`) avant action.
- Recette d'ajout d'une feature : spec `F-XXX` → analyse `IA-XXX` → implémentation → cas de `TEST_PLAN.md` → recette client.
