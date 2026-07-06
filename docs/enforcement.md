# Enforcement — MyProjectOS

> Comment les règles sont tenues. La couche déterministe du système : ce qui ne doit pas dépendre de la mémoire de l'agent.

## L'enforcement à trois couches

Rappel du principe 9 (`docs/principles.md`) : une règle qui dépend de la bonne volonté de l'agent finit appliquée de façon inégale. D'où trois couches, de la plus souple à la plus stricte.

| Couche | Mécanisme | Force | Exemple |
|---|---|---|---|
| Documentation | `docs/`, templates, conventions | Informe | « PROGRESS n'est pas un journal » |
| Skill assistant | `skills/my-project-os/SKILL.md` | Accompagne | Range l'info au bon endroit, produit l'état |
| **Hooks** | scripts déterministes Claude Code | **Garantit** | Bloque un nom de fichier interdit |

Les règles vraiment non négociables vivent dans la couche hooks.

## Choix d'implémentation

- **Runtime** : `sh` POSIX, sans dépendance obligatoire. Portable Mac et VPS (Hermès). Extraction JSON via `python3` ou `jq` si présents ; sinon le hook ne bloque rien (dégradation silencieuse, jamais de blocage du flux de travail).
- **Portée** : par projet. Les scripts vivent dans `scripts/hooks/` du repo méthode ; ils sont câblés dans le `.claude/settings.json` de chaque projet, posé par `scripts/init-project.sh`. La config globale de l'utilisateur n'est pas touchée.
- **Fermeté** : hybride. On bloque ce qui est clair et peu coûteux ; on avertit (sans bloquer) ce qui relève du jugement.
- **Garde-fou** : tout hook ne s'active que si le dossier est un projet MyProjectOS (présence de `PROJECT.md`).

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
- **Limite assumée** : le hook ne couvre que l'outil `Write` de Claude Code. Un fichier créé par `Edit`, par une commande shell (`cp`, `mv`, redirection) ou par un autre agent échappe au contrôle en temps réel ; c'est `check-project.sh` (contrôle à la demande) qui rattrape ces cas. Étendre le matcher à `Edit` bloquerait la modification de fichiers existants mal nommés, ce qu'on ne veut pas.

### 3. Placement — `hook-pre-write.sh` (même hook)
- **Bloque** le cas évident : un document ou fichier binaire (`.pdf`, `.png`, `.eml`, `.docx`, `.xlsx`, `.zip`...) écrit directement à la racine du projet au lieu de `00_inbox/` ou d'un dossier numéroté.

## Câblage

Le projet reste autonome, insensible à un déplacement ou à la disparition du repo méthode : `scripts/init-project.sh` copie les hooks dans `.claude/hooks/` du projet cible, puis écrit (ou fusionne) un `.claude/settings.json` qui les référence via `$CLAUDE_PROJECT_DIR` :

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Write",
        "hooks": [{ "type": "command", "command": "sh \"$CLAUDE_PROJECT_DIR/.claude/hooks/hook-pre-write.sh\"" }] }
    ],
    "Stop": [
      { "matcher": "",
        "hooks": [{ "type": "command", "command": "sh \"$CLAUDE_PROJECT_DIR/.claude/hooks/hook-stop-progress.sh\"" }] }
    ]
  }
}
```

Si le projet a déjà un `.claude/settings.json`, le script fusionne ce bloc dedans (via `python3`, sans écraser la config existante) au lieu de l'écraser. Sans `python3`, il affiche le bloc à fusionner à la main.

Pour mettre à jour les hooks (et tous les autres artefacts méthode : skill, `check-project.sh`, `check-update.sh`, `VERSION`) d'un projet après une évolution de la méthode, utiliser `init-project.sh --update-method` : les artefacts sont sauvegardés dans `99_archive/methode-avant-vX.Y.Z/` puis remplacés, le contenu du projet n'est jamais touché. `--into-existing` reste le mode « greffe » : il ne pose que les fichiers manquants et n'écrase rien.

## Vérification à la demande — `scripts/check-project.sh`

Les hooks agissent pendant le travail. Le script `check-project.sh` complète le dispositif par un contrôle global, lancé à la main quand on veut faire le point sur un projet. `init-project.sh` en pose une copie dans `scripts/check-project.sh` du projet cible, accompagnée d'une empreinte `VERSION` figée : le contrôle reste utilisable même si le repo méthode a disparu (voir `docs/versioning.md`).

```sh
sh <REPO>/scripts/check-project.sh [chemin-projet]   # défaut : dossier courant
# ou, depuis la copie locale posée dans le projet :
sh scripts/check-project.sh
```

Il signale, sans rien modifier :
- **alignement de version** : l'empreinte `version_methode` du projet comparée à `VERSION` ;
- **fichiers sacrés** manquants (Core, puis extensions Life / Code / Knowledge selon le `type:` déclaré dans `PROJECT.md`) ;
- **PROGRESS périmé** : `derniere_maj` absent, illisible, ou plus vieux que 14 jours ;
- **placeholders** non substitués (`<NomDuProjet>`) ;
- **références cassées** : un `DEC-XXXX` ou `CHG-YYYYMMDD-HHMM` cité quelque part mais absent du registre correspondant ;
- **format de date** : dates `JJ/MM/AAAA`, mois en toutes lettres, champs datés hors `YYYY-MM-DD`.

Sortie : `[ok]` / `[!]` avertissement / `[X]` bloquant, puis un bilan. Code de sortie 1 s'il existe au moins un bloquant, 0 sinon. Comme les hooks, le script reste informatif et ne bloque jamais un flux de travail.

## Protocole des hooks (référence)

- **Bloquer** (PreToolUse) : émettre sur stdout
  `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}` et sortir en code 0.
- **Avertir** (Stop) : émettre `{"systemMessage":"..."}` et sortir en code 0.
- **Laisser passer** : sortir en code 0 sans rien émettre.

Cible Claude Code v2.1+.
