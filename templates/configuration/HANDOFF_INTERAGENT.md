# HANDOFF_<AGENT-A>_<AGENT-B>.md — <NomDuProjet>

> Boîte aux lettres asynchrone entre agents sans canal de communication direct (ex. Claude Code / Hermès Agent / Codex).
> Append-only : une entrée par demande, jamais de suppression. Le destinataire répond en éditant l'entrée existante, jamais par une nouvelle entrée.
> Limite assumée : aucune notification push. Un agent ne voit une demande que lorsqu'une session s'ouvre sur ce projet et qu'il lit ce fichier — à vérifier en début de session, comme `ECHEANCES.md`.
> Range ce fichier dans `98_configuration/`. Voir `docs/NAMING-CONVENTIONS.md` (noms d'agents canoniques : `CLAUDECODE`, `HERMES`, `CODEX`).
> **État de l'équipage** (qui a installé quelle skill, avec quel backend de secrets) ne vit pas ici : il vit dans le tableau d'équipement de la gouvernance concernée (ex. section « Accès technique » de `GOUVERNANCE_BLUE.md`). Ce fichier ne porte que les *demandes* — une information, un seul endroit.

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

## Modèle d'entrée « Équiper un agent »

À utiliser quand une skill technique portable (ex. `blue-app`) est posée dans `98_configuration/skills/<skill>/` et qu'un autre agent doit l'installer chez lui.

```
### YYYY-MM-DD-HHMM — Équiper <AGENT-B> avec la skill <nom-skill>

- **De** : <AGENT-A>
- **À** : <AGENT-B>
- **Statut** : EN_ATTENTE
- **Demande** : installer la skill `<nom-skill>` depuis sa source projet `98_configuration/skills/<nom-skill>/`, selon la procédure de son `INSTALL.md`. Choisir et configurer le backend de secrets adapté à ta plateforme (voir `INSTALL.md`, section backends). Une fois installée : vérifier avec la commande de smoke test documentée (ex. `--check`), puis mettre à jour la ligne « <AGENT-B> » du tableau d'équipement dans la gouvernance concernée (ex. `GOUVERNANCE_<OUTIL>.md`, section « Accès technique »).
- **Réponse** : <à compléter par le destinataire : chemin d'installation, backend de secrets retenu, résultat de la vérification>
- **Vu par l'émetteur** : non

Critère de vérification : la ligne du tableau d'équipement existe pour <AGENT-B>, avec un backend renseigné et une date de vérification ; le statut de cette entrée passe à FAIT.
```
