# DECISIONS.md — Site vitrine Atelier Verne

> Décisions structurantes uniquement, format `DEC-XXXX`.

### DEC-0002 — Formulaire de devis sans compte ni base de données dédiée

- **Date** : 2026-06-25
- **Contexte** : F-003 peut stocker les demandes en base ou se limiter à une notification email.
- **Options envisagées** : A. stockage en base + interface d'administration ; B. notification email simple avec copie d'archivage.
- **Choix** : option B.
- **Raison** : le client travaille dans sa boîte mail ; une interface de plus ne serait pas utilisée. Moins de données personnelles stockées, moins de surface d'entretien.
- **Conséquences** : la fiabilité de l'envoi d'email devient critique → cas dédiés dans `TEST_PLAN.md`, limite d'envoi de l'hébergeur surveillée.
- **Liens** : CHG-20260625-1710.

### DEC-0001 — WordPress + thème léger plutôt que du sur mesure

- **Date** : 2026-05-12
- **Contexte** : choisir la stack du site vitrine pour un client non technique qui doit éditer ses contenus seul.
- **Options envisagées** : A. framework JS + CMS headless ; B. WordPress + thème léger + constructeur natif ; C. générateur de site statique.
- **Choix** : option B.
- **Raison** : l'édition autonome par le client est le critère n°1 ; WordPress est ce que son entourage professionnel connaît ; A et C exigent un intermédiaire technique à chaque modification.
- **Conséquences** : gate `STACK_VALIDATION.md` sur les compatibilités thème/extensions/PHP ; mises à jour de sécurité déléguées à l'hébergeur infogéré.
- **Liens** : CHG-20260512-1500.
