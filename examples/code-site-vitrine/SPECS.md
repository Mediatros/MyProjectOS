# SPECS.md — Site vitrine Atelier Verne

> Fonctionnalités spécifiées avant implémentation, identifiants `F-XXX`. Ambiguïté = question posée, jamais un choix silencieux.

### F-003 — Formulaire de devis

- **Besoin** : un visiteur demande un devis sans appeler ; le client reçoit la demande par email.
- **Champs** : nom, email, téléphone (optionnel), description du projet (obligatoire).
- **Comportement** : validation des champs, anti-spam invisible, page de confirmation, notification email au client avec copie d'archivage.
- **Clarifié** : pas de stockage en base ni d'interface d'administration (question posée au client, voir DEC-0002).
- **Statut** : spécifiée, analyse IA-002 faite, à implémenter (T3.1).

### F-002 — Galerie de réalisations

- **Besoin** : le client publie ses chantiers (photos + description courte) sans assistance.
- **Comportement** : type de contenu « réalisation », page liste, page détail, publication en 3 étapes maximum.
- **Statut** : livrée et recettée (CHG-20260625-1710).

### F-001 — Structure et pages

- **Besoin** : les 5 pages du périmètre, navigation claire, mentions légales conformes.
- **Statut** : livrée (CHG-20260528-0940).
