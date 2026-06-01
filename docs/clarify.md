# Clarify — le réflexe de levée d'ambiguïté

> Avant d'approuver un plan ou d'écrire du code, on lève les inconnues par des questions ciblées. Emprunt à Spec Kit, réimplémenté comme réflexe de méthode (pas un outil).

## Le principe

Le coût d'une ambiguïté non levée explose plus on avance : une inconnue oubliée au moment du plan devient du rework au moment du code. Le réflexe clarify consiste à **transformer chaque inconnue en question avant de s'engager**, plutôt qu'à choisir silencieusement une interprétation.

Pour un porteur non-développeur, c'est aussi une protection : l'agent ne décide pas à sa place sur un point structurant, il l'interroge.

## Quand l'appliquer

- Parcours complet : entre `/harness-plan` (qui génère `spec.md` avec une section « inconnues ») et l'approbation. On ne valide pas un plan tant que ses inconnues ne sont pas levées ou explicitement assumées.
- Parcours allégé : au moment de remplir `IMPACT_ANALYSIS.md`, si le périmètre ou un risque reste flou.
- Plus généralement : dès qu'une spec admet plusieurs interprétations raisonnables.

## Comment clarifier

1. **Repérer les inconnues** : reprendre la section « inconnues » de `spec.md`, ou lister les points où plusieurs interprétations existent.
2. **Poser des questions ciblées, une à la fois** sur ce qui change réellement la suite. Ne pas noyer le porteur sous une liste.
3. **Éclairer avant de demander de trancher** : pour chaque question structurante, présenter les options avec avantages, inconvénients et une recommandation. L'humain décide.
4. **Consigner la réponse à sa place** : un choix structurant va dans `DECISIONS.md` (`DEC-XXXX`) ; une précision de périmètre met à jour `spec.md` / `SPECS.md` (`F-XXX`).
5. **Conditions d'arrêt** : noter ce qui ferait suspendre le travail (dépendance manquante, validation externe attendue). Harness les attend dans `spec.md`.

## Ce que clarify n'est pas

- Ce n'est pas un interrogatoire systématique : on ne clarifie que ce qui change la suite. Les détails sans conséquence se tranchent par défaut, sans question.
- Ce n'est pas une décision de l'agent : clarify aboutit à une décision **humaine** éclairée, tracée si elle est structurante.

## Voir aussi

- `docs/harness.md` — le cycle Plan → Work → Review où s'insère clarify.
- `docs/stack-validation-gate.md` — la levée d'ambiguïté sur la compatibilité de stack.
- `templates/code/CONSTITUTION.md` — le cadre qui borne les réponses acceptables.
