# RETEX — Absence de canon pour l'organisation thématique (« 02_sujets ») dans les projets Life

> Retour d'expérience issu du dogfood MyProjectOS sur `/Users/jb/Documents/MyProjects/SYNC/LaCIOTAT` (type Life).
> Date : 2026-07-14.
> Statut : correction locale appliquée (DEC-0012 dans LaCIOTAT) ; évolution générique intégrée dans MyProjectOS via DEC-0032 (2026-07-14, v0.14.0).

## Objet du RETEX

Documenter le fait que deux projets Life distincts (`Copropriete_Jacques_Dore` et `LaCIOTAT`) ont chacun réinventé, séparément et à des noms légèrement différents, un dossier de rangement thématique — sans qu'aucune règle de la méthode ne le prévoie ni ne les guide. La réorganisation de LaCIOTAT a été faite à la demande explicite de l'utilisateur, sur simple imitation visuelle de Jacques Doré, sans passer par aucune trace de la méthode elle-même.

Grille de lecture habituelle :

```text
problème rencontré dans LaCIOTAT → correction locale appliquée → évolution générique à intégrer dans MyProjectOS
```

## Les faits

1. `Copropriete_Jacques_Dore` (projet Life plus ancien) a créé de lui-même un dossier `02_SUJETS/` avec des sous-dossiers `S01_...` à `S05_...`, un par sujet de fond du dossier de copropriété. Rien dans `structures/life-tree.md` ni `docs/NAMING-CONVENTIONS.md` ne documente ce motif : il a émergé au fil de l'eau dans ce projet précis.
2. Le 2026-07-14, l'utilisateur constate que `LaCIOTAT` (autre projet Life) a accumulé une dizaine de fichiers thématiques en vrac à la racine (`SANTE.md`, `DOSSIER_NOTAIRE.md`, `DOSSIER_VENTE_SMART.md`, `MAX.md`, etc.) et demande explicitement de reproduire l'organisation de Jacques Doré, en nommant ce projet comme modèle.
3. La réorganisation a été faite (création de `02_sujets/` en minuscules, six sous-dossiers `S01_...` à `S06_...`, réécriture de 49 références internes, `DEC-0012` + `CHG-20260714-1945`), mais **entièrement par imitation d'un autre projet**, sans qu'aucun document de la méthode (`structures/life-tree.md`, `docs/NAMING-CONVENTIONS.md`, la skill `my-project-os`) ne mentionne ce motif, ne le recommande, ni même n'aide à choisir un nom cohérent.
4. **Collision de numéro non détectée** : `structures/core-tree.md` réserve déjà `02_work/` (« travail actif en cours ») dans le socle Core commun à tous les projets. Les deux projets Life ont réutilisé le préfixe `02_` pour un concept différent (« sujets » au pluriel, un sous-dossier par thème, pas un espace de travail actif unique). Aucun garde-fou (hook, `check-project.sh`, skill) n'a signalé que `02_` était déjà pris par le canon.
5. La casse diffère sans raison documentée : `02_SUJETS` (Jacques Doré) contre `02_sujets` (LaCIOTAT, choix fait dans cette session en cohérence avec le reste des dossiers numérotés du projet, tous en minuscules). Rien dans `docs/NAMING-CONVENTIONS.md` ne tranche la casse des dossiers numérotés créés hors canon.

## Pourquoi aucun garde-fou ne s'est déclenché

| Couche | Ce qu'elle contrôle aujourd'hui | Pourquoi elle n'a rien vu |
|---|---|---|
| `structures/life-tree.md` | Dossiers ajoutés par l'extension Life (`05_correspondances/` à `08_modeles/`) | Ne couvre pas le besoin, très courant en pratique, de regrouper le contenu de travail par sujet/thème plutôt que par nature de document |
| `structures/core-tree.md` | Réserve `02_work/` pour le travail actif | Le nom et l'intention (« un espace de travail actif », singulier) ne correspondent pas à l'usage réel observé deux fois (« un dossier par sujet », pluriel) ; aucun rapprochement n'est fait entre les deux |
| `docs/NAMING-CONVENTIONS.md` | Nommage des fichiers et dossiers numérotés canoniques | Silencieux sur les dossiers numérotés que les projets créent eux-mêmes au-delà du canon (LaCIOTAT en a déjà trois : `07_fiches_prestataires/`, `08_recherche_mail/`, `09_modeles_courriers/`) |
| Skill `my-project-os` | Mode Orientation (« où je range ça ? »), mode Initialisation | Ne propose jamais l'organisation thématique comme option quand un projet accumule des fichiers en vrac à la racine ; l'agent (Claude Code) a dû se faire expliquer par l'utilisateur qu'un autre projet du portefeuille faisait référence, au lieu de le suggérer lui-même |
| `check-project.sh` | Fraîcheur, fichiers sacrés, placeholders | Aucun contrôle sur l'accumulation de fichiers de travail à la racine (ex. dix fichiers `.md` thématiques hors fichiers sacrés) qui aurait pu déclencher une suggestion de rangement |

Constat transverse : la méthode encadre bien les fichiers sacrés et les registres, mais laisse chaque projet Life réinventer sa propre solution dès que le nombre de sujets de fond dépasse ce que les extensions Life prévoient (`05` à `08`, orientées par nature de document — correspondance, preuve, échéance, modèle — pas par sujet métier).

## Correction locale appliquée (LaCIOTAT, 2026-07-14)

- Création de `02_sujets/` (six sous-dossiers `S01_...` à `S06_...`), index dans `02_sujets/INDEX.md`.
- Déplacement de dix fichiers/dossiers thématiques depuis la racine, réécriture de 49 références internes.
- `PLAN_AMELIORATION.md` (méta-projet) déplacé dans `98_configuration/`, hors du périmètre `02_sujets/`.
- Tracé dans `CHG-20260714-1945` et `DEC-0012` du projet LaCIOTAT.
- Vérification par sous-agent : tous les nouveaux chemins existent, aucune référence cassée, `anatomy.md` régénéré.

## Évolutions génériques à discuter dans MyProjectOS

Par ordre de valeur décroissante :

### 1. Trancher la collision `02_work/` vs organisation thématique (priorité haute, décision à prendre avant tout le reste)

Deux options distinctes, à arbitrer explicitement plutôt que de laisser chaque projet choisir en aveugle :

- **a)** Renommer/redéfinir `02_work/` du canon Core pour qu'il porte l'organisation thématique par sous-dossiers (`02_work/S01_...`), en documentant clairement que « travail actif » = « sujets de fond », ce qui unifie ce que Jacques Doré et LaCIOTAT ont fait spontanément.
- **b)** Garder `02_work/` tel quel (espace de travail actif, sens différent) et réserver un autre préfixe canonique pour l'organisation thématique (ex. `03_sujets/` si `03_documents/` du Core n'est pas déjà pris dans le projet, ou un numéro dans la plage Life `05`-`08`).

Dans les deux cas, documenter le choix dans `structures/life-tree.md` (et éventuellement `core-tree.md`), avec une règle de nommage explicite pour les sous-dossiers (`Sxx_Nom_Du_Sujet`, casse à trancher).

### 2. `structures/life-tree.md` : ajouter le motif « organisation thématique » comme extension optionnelle documentée (priorité haute)

Une fois 1) tranché, décrire le motif observé deux fois indépendamment : un dossier racine avec un sous-dossier par sujet de fond (succession, santé, vente d'un bien, etc.), à utiliser quand les fichiers de travail dépassent la dizaine et ne rentrent pas naturellement dans `05_correspondances/` à `08_modeles/` (qui classent par nature de document, pas par thème). Donner un exemple concret tiré de Jacques Doré ou LaCIOTAT.

### 3. Skill `my-project-os`, mode Orientation : suggestion proactive (priorité moyenne)

Ajouter au mode Orientation : si un nouveau document de travail arrive et que la racine du projet contient déjà plusieurs fichiers `.md` thématiques hors fichiers sacrés (seuil à définir, ex. 5+), suggérer la création ou l'usage de l'organisation thématique plutôt que d'ajouter un énième fichier à la racine — au lieu d'attendre que l'utilisateur pointe un autre projet du portefeuille comme modèle.

### 4. `check-project.sh` : avertissement doux sur l'accumulation à la racine (priorité basse)

Avertissement (jamais bloquant) si le nombre de fichiers `.md` non sacrés à la racine dépasse un seuil, invitant à considérer un rangement thématique. Cohérent avec la philosophie « avertissement, jamais bloquant » déjà en place pour les dossiers racine (voir `retex-laciotat-doublon-archives.md`).

## Leçon générique

Un motif d'organisation qui fait ses preuves dans un projet et se transmet par imitation humaine directe (« prends exemple sur tel autre projet ») plutôt que par la méthode elle-même est un signal que la méthode a un trou à combler. Ce RETEX, combiné à `retex-laciotat-doublon-archives.md`, montre que la question de la **topologie des dossiers** (pas seulement leur nommage) reste le point le moins mûr de MyProjectOS : le canon encadre bien les fichiers sacrés, beaucoup moins bien la façon dont le contenu de travail se structure une fois que le projet grossit.

## Suite donnée (2026-07-14)

Les quatre évolutions génériques proposées ci-dessus ont été intégrées via DEC-0032 (v0.14.0) :

1. Collision tranchée : slot 02 spécialisé par extension (`02_sujets/` pour Life/Hybrid, `02_work/` inchangé pour Code).
2. `structures/life-tree.md` documente le motif, avec cet exemple réel en référence.
3. Skill `my-project-os`, Mode Orientation : suggestion proactive ajoutée.
4. `check-project.sh` : avertissement doux sur l'accumulation de fichiers thématiques à la racine d'un projet Life.

Rétrofit des projets déjà réorganisés (Jacques Doré, LaCIOTAT) : aucune action requise, ils sont déjà conformes a posteriori. Pour tout autre projet Life existant, la détection reste une suggestion au prochain passage de l'agent ou de `check-project.sh` — jamais un déplacement automatique de fichiers.
