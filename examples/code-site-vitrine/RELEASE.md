# RELEASE.md — Site vitrine Atelier Verne

> Checklist de mise en production. Le déploiement est une action sensible : validation client explicite requise.

## Prérequis (avant de commencer)

- [ ] Tous les cas de `TEST_PLAN.md` passés en préproduction.
- [ ] Recette client faite et validée par écrit (T3.2).
- [ ] Sauvegarde complète de préproduction téléchargée.

## Mise en production

- [ ] Pointer le domaine du client (DNS) ; vérifier le certificat HTTPS.
- [ ] Rejouer le cas « envoi valide » de F-003 en production réelle.
- [ ] Vérifier les 5 pages et la galerie en production.

## Après mise en ligne

- [ ] Activer les sauvegardes automatiques de l'hébergeur et noter la procédure de restauration.
- [ ] Consigner la release dans `CHANGELOG.md` (entrée `CHG-`) avec la date de mise en ligne.
- [ ] Former le client (T4.2).

## Rollback

- Restaurer la dernière sauvegarde hébergeur ; repointer le DNS si nécessaire. Durée estimée : < 1 h.
