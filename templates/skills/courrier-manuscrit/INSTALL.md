# Installation de la skill `courrier-manuscrit`

> Source canonique dans un projet : `98_configuration/skills/courrier-manuscrit/`. Skill utilitaire sans compte ni secret : l'installation se résume aux prérequis, au choix de la police et à la copie chez l'agent.

## Prérequis

1. **WeasyPrint** (rendu HTML → PDF) :
   - Mac : `brew install weasyprint` (ou `pipx install weasyprint`)
   - Debian/Ubuntu : `sudo apt-get install -y weasyprint` (ou `pipx install weasyprint`)
   - Vérification : `weasyprint --version`
2. **Outils d'aperçu** (contrôle visuel du PDF) : Mac : `sips` et `mdls` (fournis par le système) ; Linux : `pdfinfo` et `pdftoppm` (`sudo apt-get install -y poppler-utils`).

## Onboarding : choisir et installer la police manuscrite

La police n'est pas fournie avec la skill (les polices manuscrites sont souvent en licence « Personal Use Only », non redistribuable). À dérouler par l'agent avec l'utilisateur :

1. **Vérifier l'existant** : l'utilisateur a-t-il déjà une police manuscrite qu'il aime ? (Mac : `ls ~/Library/Fonts` ; Linux : `fc-list | grep -ii hand`)
2. **Sinon, guider le choix** : proposer les liens — Google Fonts, catégorie « Handwriting » (licences libres, ex. Caveat, Homemade Apple) : `https://fonts.google.com/?category=Handwriting` ; ou dafont catégorie « Script > École » : `https://www.dafont.com/fr/` (vérifier la licence de chaque police avant usage).
3. **Installer le fichier `.ttf`/`.otf`** : Mac : double-clic ou copie dans `~/Library/Fonts/` ; Linux : copie dans `~/.local/share/fonts/` puis `fc-cache -f`.
4. **Renseigner la skill** : remplacer dans `template.html` (les deux occurrences dans le `@font-face` et les `font-family`) et dans la section « Police » du `SKILL.md` :
   - `<NOM_POLICE>` : le nom de famille interne de la police (visible dans l'aperçu de la police, ex. « Caveat ») ;
   - `<CHEMIN_POLICE>` / `<CHEMIN_POLICE_ENCODE_URL>` : le chemin absolu du fichier, encodé URL dans `template.html` (espaces = `%20`).
5. **Répercuter dans le canon** : si la skill est installée depuis `98_configuration/skills/courrier-manuscrit/`, faire la modification dans cette copie canonique d'abord, puis la recopier chez l'agent.

## Installation par agent

### Claude Code

```sh
mkdir -p <projet>/.claude/skills
cp -r <projet>/98_configuration/skills/courrier-manuscrit <projet>/.claude/skills/courrier-manuscrit
```

Installation globale possible (`~/.claude/skills/courrier-manuscrit/`) si la skill doit servir hors du projet.

### Codex

```sh
mkdir -p <projet>/.codex/skills
cp -r <projet>/98_configuration/skills/courrier-manuscrit <projet>/.codex/skills/courrier-manuscrit
```

### Hermès

```sh
cp -r <projet>/98_configuration/skills/courrier-manuscrit ~/.hermes/skills/courrier-manuscrit
```

Vérification de découverte : `hermes skills list`. Note : la génération PDF exige WeasyPrint et la police sur la machine d'Hermès (VPS) ; sans eux, la skill reste utilisable pour l'étape 1 (brouillon Markdown) seulement.

## Vérification post-installation (smoke test)

Générer un PDF d'essai d'une ligne et contrôler le rendu :

```sh
printf '<!DOCTYPE html><html><head><meta charset="utf-8"><style>@font-face{font-family:"<NOM_POLICE>";src:url("file://<CHEMIN_POLICE_ENCODE_URL>");}body{font-family:"<NOM_POLICE>";color:#1e2a78;}</style></head><body><p>Essai de police manuscrite.</p></body></html>' > /tmp/essai-manuscrit.html
weasyprint /tmp/essai-manuscrit.html /tmp/essai-manuscrit.pdf
```

Ouvrir ou convertir le PDF en image et vérifier que la police manuscrite est bien appliquée (un rendu en police standard = chemin ou nom de police incorrect). Supprimer les fichiers d'essai ensuite. Une fois vérifié, renseigner sa ligne au tableau d'équipement du projet si une gouvernance existe (sinon, noter l'installation dans le `CHANGELOG.md` du projet).
