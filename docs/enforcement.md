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

**Comment une règle arrive dans une couche** : elle n'y naît pas, elle y monte. L'échelle de promotion (correction locale → RETEX → procédure → skill → hook/check) et les cinq exigences de chaque montée de cran sont décrites dans `docs/governance.md`, section « Boucle de correction gouvernée ». Les hooks livrés ci-dessous ont tous cette généalogie : chacun cite le RETEX ou la décision qui l'a fait naître.

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

### 4. Dossiers racine — `hook-pre-write.sh` (même hook)
- **Bloque** l'écriture d'un fichier dont le premier segment de chemin créerait un dossier racine **quasi-doublon** d'un dossier existant : noms équivalents après normalisation (accents translittérés, minuscules, tirets ramenés aux underscores, `s` final retiré), par exemple `99_archives/` à côté de `99_archive/`. Dossiers cachés hors périmètre.
- Origine : un RETEX terrain où un tel doublon a vécu deux jours sans détection. Le contrôle à la demande équivalent (quasi-doublons + collisions de préfixe `NN_`) vit dans `check-project.sh`, section « Dossiers racine ».

### 5. Organisation thématique (Life/Hybrid) — `hook-pre-write.sh` (même hook)
- **Avertit** (`systemMessage`, ne bloque pas) : écrire un nouveau fichier `.md` à la racine d'un projet Life ou Hybrid (`type:` du frontmatter `PROJECT.md`), alors que `02_sujets/` n'existe pas encore et que le compte de fichiers `.md` thématiques à la racine (hors fichiers sacrés et extensions connues) atteint ou dépasse 5 avec ce fichier.
- Origine : un RETEX terrain — l'accumulation n'avait été repérée que visuellement par l'utilisateur, sans aucun garde-fou en temps réel (DEC-0032). Le contrôle à la demande équivalent vit dans `check-project.sh`, section « 2ter ».
- **Fermeté** : avertissement, pas blocage — ranger par sujet reste un jugement humain, comme pour la fraîcheur de `PROGRESS.md`.

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
- **placeholders** de gabarit non substitués (nom du projet resté en balise) ;
- **références cassées** : un `DEC-XXXX` ou `CHG-YYYYMMDD-HHMM` cité quelque part mais absent du registre correspondant ;
  - `99_archive/` est exclu des scans croisés de contenu depuis DEC-0041 : zone froide consultée sur demande, ses identifiants ne déclenchent pas d'avertissement (repo méthode uniquement) ;
- **format de date** : dates `JJ/MM/AAAA`, mois en toutes lettres, champs datés hors `YYYY-MM-DD` ;
- **RETEX** (si un dossier `RETEX/` existe) : statut absent ou hors des cinq valeurs fermées, et RETEX déclaré fermé sans référence `DEC-XXXX`/`CHG-` justifiant la clôture.

Sortie : `[ok]` / `[!]` avertissement / `[X]` bloquant, puis un bilan. Code de sortie 1 s'il existe au moins un bloquant, 0 sinon. Comme les hooks, le script reste informatif et ne bloque jamais un flux de travail.

## Garde-fou Git destructif — `hook-pre-git.sh` (PreToolUse `Bash`, optionnel Code/Hybrid)

Origine : A1 du plan Pro Workflow (CHG-20260822-XXXX). Les règles documentaires seules n'interceptent pas une commande Git destructrice générée par l'agent — risque principal pour un utilisateur non-développeur.

- **Quand** : avant toute commande Bash contenant un `git` (chaque segment d'une commande composée est évalué séparément).
- **Bloque** (matrice des 5 irréversibles, DEC-0044) :
  - `git push --force` / `-f` (alternative proposée : `--force-with-lease`) ;
  - `git reset --hard` (alternatives : `git stash`, commit avant reset) ;
  - `git clean -fd` / `-x` et variantes (alternative : `git clean -nd` pour prévisualiser) ;
  - `git branch -D` (alternative : `git branch -d`, qui refuse si non fusionnée) ;
  - `git rebase` d'une branche présente sur `origin/` (alternative : `git merge`). Le rebase interactif ou `--onto` reste hors matrice (jugement).
- **Dérogation** : ponctuelle et traçable. L'humain valide en session, puis l'agent relance avec `MYPROJECTOS_GIT_OVERRIDE=1` ; le hook affiche un rappel de consigner l'opération dans `CHANGELOG.md` (entrée `CHG-`). Aucune variable d'environnement posée en dur ne neutralise le contrôle silencieusement.
- **Fermeté** : bloquant sur la matrice, jamais sur le reste. Commandes sûres (`status`, `diff`, `add`, `commit`, `push` simple, `branch -d`, `reset` doux) non affectées.
- **Activation** : optionnelle, projets Code/Hybrid uniquement (`init-project.sh` copie et câble le hook ; Core et Life n'y ont pas droit).
- **Couverture multi-agents** : le hook temps réel ne couvre que Claude Code (protocole PreToolUse). Pour Hermès et Codex, `check-project.sh` (section 12) signale un projet Code/Hybrid sans `hook-pre-git.sh` — le contrôle y reste documentaire, à la demande.
- **Limite assumée** : le hook est un garde-fou lexical, pas un parser shell complet (guillemets complexes, alias git, sous-shells imbriqués peuvent l'échapper). Il ne remplace pas la prudence, il intercepte les cas évidents.
- **Rollback** : retirer `.claude/hooks/hook-pre-git.sh` et son entrée du `.claude/settings.json` du projet.

## Clôture déterministe d'itération — `check-iteration.sh` (A4, DEC-0046)

Commande **explicite** (`sh scripts/check-iteration.sh`), lancée par l'agent en clôture d'une itération Code/Hybrid (étape 4 du mode 4 de la skill). Jamais branchée au hook Stop : un contrôle automatique à chaque fin de réponse serait trop bruyant ; il faudra un RETEX démontrant le contraire.

- **Vérifie** : dépôt git propre ; fichiers modifiés consignés dans `PROGRESS.md` ; fraîcheur de `PROGRESS.md` ; prochaine action déclarée ; si `TEST_PLAN.md` existe, rappel des commandes de validation à exécuter.
- **Bloque** seulement deux cas (arbitrage l'utilisateur) : fichiers modifiés absents de `PROGRESS.md`, et `PROGRESS.md` périmé (> 14 jours). Tout le reste est informatif — un check de clôture ne juge pas des tests qu'il ne peut pas évaluer.
- **Aucune exigence artificielle** pour les projets documentaires : sans git ni TEST_PLAN, la section correspondante est silencieuse.
- **Rollback** : retirer `scripts/check-iteration.sh` du projet et son entrée du manifest.

## Détection locale de secrets — `check-secrets.sh` (A2, DEC-0045)

Posé par `init-project.sh` à côté de `check-project.sh`, appelé par sa section 13. Contrôle **à la demande** (pas de hook temps réel : l'analyse de contenu avant chaque Write serait trop coûteuse et trop bruyante).

- **Bloque** (formes certaines) : clés privées PEM, tokens à préfixe connu (`ghp_`/`gho_`/`ghs_` GitHub, `sk-[proj-]…` OpenAI, `AKIA…` AWS, `xox…` Slack, `AIza…` Google, `sk_live_`/`rk_live_` Stripe). Un secret certain = code de sortie 1 + bloquant dans le bilan du check.
- **Avertit** (suspect mais incertain) : affectations `password=`/`api_key=`/etc. avec valeur plausible ; fichiers `.env*`, `*.env`, `*.pem`, `*.key` suivis par git.
- **Jamais la valeur affichée** : type de secret, fichier, ligne. La sortie ne fuit pas ce qu'elle détecte.
- **Exclusions** : `.myprojectos/secrets-allow` (un chemin relatif par ligne), pour fixtures factices et exemples documentés — porte étroite, explicite, auditable.
- **Limites assumées** : signatures lexicales (un token sans préfixe standard passe) ; scan des fichiers suivis/candidats git seulement ; ne remplace ni BWS/SOPS (stockage) ni une revue de staging.
- **Rollback** : retirer `scripts/check-secrets.sh` du projet et son entrée du manifest.

## Inventaire de l'enforcement — section « Hooks » de `check-project.sh`

Depuis le plan Pro Workflow (A6, CHG-20260822-2354), `check-project.sh` expose la surface d'enforcement réellement installée dans un projet (section 12) : chaque hook câblé dans `.claude/settings.json` doit exister dans `.claude/hooks/`, et réciproquement tout script de hooks non câblé est signalé (`_lib.sh`, bibliothèque sourcée, est hors périmètre). Les écarts sont des avertissements, jamais des bloquants — un hook absent dégrade en contrôle documentaire, il ne doit pas empêcher de travailler. Extraction des commandes sans dépendance obligatoire : `python3` ou `jq` si présents, sinon `grep`. Limite assumée : l'inventaire décrit le câblage Claude Code ; il ne prouve pas qu'un agent tiers (Hermès, Codex) exécute ces contrôles.

## Protocole des hooks (référence)

- **Bloquer** (PreToolUse) : émettre sur stdout
  `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}` et sortir en code 0.
- **Avertir** (Stop, ou PreToolUse sans bloquer depuis DEC-0032) : émettre `{"systemMessage":"..."}` et sortir en code 0. Sur un hook PreToolUse, l'absence de `permissionDecision` vaut laisser-passer : le `systemMessage` s'affiche sans empêcher l'action.
- **Laisser passer** : sortir en code 0 sans rien émettre.

Cible Claude Code v2.1+.
