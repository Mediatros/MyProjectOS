# HANDOFF_<AGENT-A>_<AGENT-B>.md — <NomDuProjet>

> Boîte aux lettres asynchrone entre agents sans canal de communication direct (ex. Claude Code / Hermès Agent / Codex).
> Append-only : une entrée par demande, jamais de suppression. Le destinataire répond en éditant l'entrée existante, jamais par une nouvelle entrée.
> Limite assumée : aucune notification push. Un agent ne voit une demande que lorsqu'une session s'ouvre sur ce projet et qu'il lit ce fichier — à vérifier en début de session, comme `ECHEANCES.md`.
> Range ce fichier dans `98_configuration/`. Voir `docs/NAMING-CONVENTIONS.md`.

## Format d'une entrée

```
### YYYY-MM-DD-HHMM — <Objet de la demande>
- **De** : <agent émetteur>
- **À** : <agent destinataire>
- **Statut** : EN_ATTENTE | EN_COURS | FAIT | BLOQUÉ
- **Demande** : ce qui est attendu de l'autre agent, en clair et actionnable.
- **Réponse** : <à compléter par le destinataire, en édition-en-place>
- **Vu par l'émetteur** : oui | non
```

---

### YYYY-MM-DD-HHMM — <Première demande>

- **De** : <...>
- **À** : <...>
- **Statut** : EN_ATTENTE
- **Demande** : <...>
- **Réponse** : <...>
- **Vu par l'émetteur** : non
