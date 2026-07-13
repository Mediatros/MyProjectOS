---
name: courrier-manuscrit
description: Rédiger un courrier ou une attestation au rendu manuscrit (police manuscrite configurée à l'installation, encre bleue) en deux temps - (1) générer un brouillon Markdown avec des champs [à compléter] que l'utilisateur finalise lui-même, (2) sur confirmation explicite, générer le PDF A4 d'une page via WeasyPrint, sans aucun soulignage. Activer pour toute demande de courrier « manuscrit », « écrit à la main », « avec la police manuscrite », d'attestation sur l'honneur à imprimer et signer, ou pour régénérer le PDF d'un courrier manuscrit dont le Markdown a été modifié.
---

# Courrier manuscrit (police configurée à l'installation)

Produire un courrier qui, imprimé, ressemble à une lettre écrite à la main au stylo bleu. Le flux est toujours en deux étapes séparées : le brouillon Markdown d'abord, le PDF ensuite, jamais les deux d'un coup.

> Skill utilitaire MyProjectOS, sans compte ni secret. La police manuscrite n'est PAS fournie : elle est choisie et installée par l'utilisateur (voir `INSTALL.md`), puis référencée dans la section « Police » ci-dessous et dans `template.html`.

## Étape 1 — Brouillon Markdown

1. Créer le fichier dans le dossier de courriers du projet courant s'il existe (ex. `08_modeles/`), sinon à la racine du projet. Nom en majuscules : `COURRIER_<OBJET>.md` ou `ATTESTATION_<OBJET>.md`.
2. Structure du fichier :
   - une ligne de titre `# ...` (usage interne, pas rendue dans le PDF) ;
   - un bloc de citation `> Usage : ...` rappelant le destinataire, les pièces à joindre et ce qui reste à faire (non rendu dans le PDF) ;
   - `---` puis le contenu du courrier lui-même : bloc expéditeur (nom, adresse, téléphone, email), destinataire éventuel, titre du courrier en `## ...`, corps en paragraphes, « Fait à <ville>, le <date> », « Signature : », ligne « **Pièces jointes** : ... » si applicable.
3. Toute information inconnue est un champ `[entre crochets]` : `[date de naissance]`, `[date]`, etc. Pré-remplir depuis le contexte du projet (contacts, preuves, mémoire) uniquement ce qui est établi de façon fiable.
4. Style : typographie française (espace avant `:` `;` `!` `?`), dates en toutes lettres, phrases simples, pas de jargon administratif inutile. Si la skill `redaction-humaine-fr` (même catalogue) est installée, appliquer son niveau 1 « soigné ». Pour une attestation sur l'honneur, inclure la mention des articles 441-1 et 441-7 du code pénal.
5. **S'arrêter là.** Montrer le texte à l'utilisateur, lister les champs `[...]` restants, et attendre qu'il complète le Markdown lui-même (ou fournisse les valeurs). Ne jamais générer le PDF à cette étape.

## Étape 2 — Génération du PDF (uniquement sur confirmation)

Déclencheurs : « régénère le PDF », « c'est complété », « génère la version PDF »... Le Markdown est la source de vérité : le relire intégralement avant de générer (il a pu être modifié à la main).

1. S'il reste des champs `[entre crochets]`, le signaler et demander : soit l'utilisateur donne les valeurs, soit ces champs deviennent des lignes en pointillés à compléter au stylo (`<span class="blanc">&nbsp;</span>` dans le template).
2. Construire le HTML à partir de `template.html` (dans le dossier de cette skill) : copier le template dans un dossier temporaire, y injecter les blocs du Markdown (expéditeur, titre, paragraphes, date, signature, pièces jointes). Le bloc de titre `# ...` et la citation `> Usage` du Markdown ne sont **pas** rendus dans le PDF.
3. **Interdictions absolues dans le rendu** :
   - aucun soulignage, nulle part : pas de `text-decoration: underline`, pas de `<u>`, y compris sur le titre du courrier (interdit sur un courrier manuscrit) ;
   - pas de gras ni d'italique (une lettre manuscrite est homogène) : les `**...**` du Markdown sont rendus en texte normal ;
   - pas d'emoji, pas de puces, pas de tableau.
4. Générer : `weasyprint courrier.html <même dossier que le .md>/<même nom>.pdf`.
5. **Contrôles obligatoires avant de rendre la main** :
   - nombre de pages = 1. Mac : `mdls -name kMDItemNumberOfPages <pdf>` ; Linux : `pdfinfo <pdf> | grep Pages`. Si 2 pages : resserrer dans cet ordre `line-height` (1.6 → 1.5), marges `@page` (1.8cm → 1.5cm), `font-size` (15.5pt → 14.5pt), puis regénérer ;
   - aperçu visuel : Mac : `sips -s format png <pdf> --out apercu.png` ; Linux : `pdftoppm -png -r 150 <pdf> apercu`. Lire l'image et vérifier : police manuscrite appliquée partout, aucun soulignage, rien de tronqué, champs pointillés visibles le cas échéant. Attention : le trait de liaison d'un script cursif peut ressembler à un soulignage en basse résolution ; en cas de doute, recadrer en haute résolution avant de conclure.
6. Annoncer le chemin du PDF et rappeler ce qui reste manuel (imprimer, signer à la main, pièces à joindre).

## Police

- Renseignée à l'installation (voir `INSTALL.md`) : fichier `<CHEMIN_POLICE>`, nom de famille interne `<NOM_POLICE>`. Reporter ces deux valeurs ici et dans le `@font-face` de `template.html`.
- Si le fichier est absent au moment de générer, le chercher (Mac : `ls ~/Library/Fonts` ; Linux : `fc-list | grep -i <nom>`) ; s'il est introuvable, demander à l'utilisateur. Ne jamais substituer une autre police sans son accord.
- Vérifier la licence de la police choisie : beaucoup de polices manuscrites sont « Personal Use Only » (pas d'usage commercial sans accord).

## Mise en page de référence (reprise dans template.html)

A4, marges 1.8cm/2.2cm, corps 15.5pt, interligne 1.6, encre bleue `#1e2a78`, titre centré 21pt non souligné, paragraphes justifiés, ligne « Pièces jointes » en 13pt. Champs à compléter au stylo : `span.blanc` (4.2cm) ou `span.blanc-court` (3cm), bordure basse en pointillés.
