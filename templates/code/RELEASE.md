# RELEASE.md — <NomDuProjet>

> Préparation et trace des livraisons. Une release n'est validée que checklist verte et tests passés.
> Les versions livrées descendent dans « Historique des releases » ; les fichiers de release peuvent être rangés dans `08_releases/`.

## Release en préparation

- **Version** : <ex : 1.2.0>
- **Date cible** : AAAA-MM-JJ

### Changements inclus

- <feature / fix + lien F-XXX, CHG-, DEC->

### Checklist de livraison

- [ ] Tests automatisés au vert
- [ ] Tests manuels critiques passés (voir `TEST_PLAN.md`)
- [ ] `STACK_VALIDATION.md` toujours valide
- [ ] Documentation à jour (`PROGRESS`, `CHANGELOG`, `ARCHITECTURE` si besoin)
- [ ] Validation humaine obtenue pour le déploiement

### Plan de rollback

- <comment revenir en arrière si la release échoue>

### Notes de release

<Résumé lisible des nouveautés, destiné à l'utilisateur.>

---

## Historique des releases

### <version> — AAAA-MM-JJ

- <résumé court de ce qui a été livré>
