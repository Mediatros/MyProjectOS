# Enforcement — Project OS AI

> Comment les règles sont tenues. La couche déterministe du système : ce qui ne doit pas dépendre de la mémoire de l'agent.

## L'enforcement à trois couches

Rappel du principe 9 (`docs/principles.md`) : une règle qui dépend de la bonne volonté de l'agent finit appliquée de façon inégale. D'où trois couches, de la plus souple à la plus stricte.

| Couche | Mécanisme | Force | Exemple |
|---|---|---|---|
| Documentation | `docs/`, templates, conventions | Informe | « PROGRESS n'est pas un journal » |
| Skill assistant | `skills/project-os/SKILL.md` | Accompagne | Range l'info au bon endroit, produit l'état |
| **Hooks** | scripts déterministes Claude Code | **Garantit** | Bloque un nom de fichier interdit |

Les règles vraiment non négociables vivent dans la couche hooks.

## Choix d'implémentation

- **Runtime** : `sh` POSIX, sans dépendance obligatoire. Portable Mac et VPS (Hermès). Extraction JSON via `python3` ou `jq` si présents ; sinon le hook ne bloque rien (dégradation silencieuse, jamais de blocage du flux de travail).
- **Portée** : par projet. Les scripts vivent dans `scripts/hooks/` du repo méthode ; ils sont câblés dans le `.claude/settings.json` de chaque projet, posé par `scripts/init-project.sh`. La config globale de l'utilisateur n'est pas touchée.
- **Fermeté** : hybride. On bloque ce qui est clair et peu coûteux ; on avertit (sans bloquer) ce qui relève du jugement.
- **Garde-fou** : tout hook ne s'active que si le dossier est un projet Project OS (présence de `PROJECT.md`).

## Les hooks livrés

### 1. Fraîcheur de PROGRESS — `hook-stop-progress.sh` (Stop)
- **Quand** : fin de réponse de l'agent (événement Stop).
- **Rôle** : si le dépôt a des changements non committés mais que `PROGRESS.md` n'est pas parmi les fichiers modifiés, signaler que l'état n'a pas été mis à jour.
- **Fermeté** : **avertissement** (`systemMessage`), ne bloque pas. C'est un jugement, on ne piège pas un non-développeur.

### 2. Nommage — `hook-pre-write.sh` (PreToolUse `Write`)
- **Quand** : avant la création d'un fichier.
- **Rôle** : faire respecter `docs/NAMING-CONVENTIONS.md`.
- **Bloque** (clair et sans ambiguïté) :
  - espaces dans le nom de fichier ;
  - accents ou caractères non-ASCII dans le nom de fichier.
- L'usage des minuscules pour les fichiers non sacrés reste une convention portée par la skill et la doc (trop de cas légitimes en majuscules pour bloquer).

### 3. Placement — `hook-pre-write.sh` (même hook)
- **Bloque** le cas évident : un document ou fichier binaire (`.pdf`, `.png`, `.eml`, `.docx`, `.xlsx`, `.zip`...) écrit directement à la racine du projet au lieu de `00_inbox/` ou d'un dossier numéroté.

## Câblage

`scripts/init-project.sh` écrit dans le projet un `.claude/settings.json` :

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Write",
        "hooks": [{ "type": "command", "command": "sh <REPO>/scripts/hooks/hook-pre-write.sh" }] }
    ],
    "Stop": [
      { "matcher": "",
        "hooks": [{ "type": "command", "command": "sh <REPO>/scripts/hooks/hook-stop-progress.sh" }] }
    ]
  }
}
```

`<REPO>` est le chemin absolu du repo méthode, résolu par `init-project.sh` au moment de la pose. Si le projet a déjà un `.claude/settings.json`, le script ne l'écrase pas : il affiche le bloc à fusionner à la main.

## Protocole des hooks (référence)

- **Bloquer** (PreToolUse) : émettre sur stdout
  `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}` et sortir en code 0.
- **Avertir** (Stop) : émettre `{"systemMessage":"..."}` et sortir en code 0.
- **Laisser passer** : sortir en code 0 sans rien émettre.

Cible Claude Code v2.1+.
