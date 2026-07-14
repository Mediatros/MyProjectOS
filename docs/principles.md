# Principes de conception — MyProjectOS

Les principes qui tranchent les arbitrages. En cas de doute, on revient ici.

## 1. Simplicité avant élégance

Couvrir 80 % des besoins avec une base simple. Pas d'abstraction spéculative, pas de fonctionnalité « au cas où ». La complexité doit se mériter par un besoin réel et constaté.

## 2. Markdown-first

Tout fichier de pilotage est en Markdown, lisible directement dans GitHub ou un éditeur de texte, sans outil externe. Pas de format propriétaire pour l'information qui doit survivre.

## 3. Human-friendly

Compréhensible sans être développeur. Le vocabulaire, les rôles de fichiers et les rituels sont explicites. Un porteur de projet doit savoir où ranger chaque information.

## 4. Agent-friendly

Structuré pour être navigable par un agent IA. En-têtes normalisés, fichiers à noms fixes, frontières nettes entre fichiers. Un agent retrouve l'état sans deviner.

## 5. Git-friendly

Versionnable proprement. Fichiers texte, diffs lisibles, identifiants stables. L'historique est une ressource, pas un sous-produit.

## 6. Une information, un seul endroit

Chaque fait vit à un seul endroit ; les autres fichiers le référencent par identifiant. L'état présent dans `PROGRESS.md`, l'historique daté dans `CHANGELOG.md`, le pourquoi dans `DECISIONS.md`, les preuves dans `PREUVES.md`. La duplication est la source numéro un de dérive.

## 7. Reprise à froid

Le critère ultime : un projet doit pouvoir être repris sans aucun historique de conversation. Si une information n'est pas dans les fichiers, elle n'existe pas pour la reprise.

## 8. Validation humaine sur les actions sensibles

L'agent propose, l'humain tranche sur tout ce qui est irréversible ou engageant : suppression massive, réorganisation de dossiers, changement de stack, déploiement, push important, action juridique ou administrative.

## 9. Les règles non négociables sont automatiques

Une règle qui dépend de la mémoire de l'agent finit par être appliquée de façon inégale. Les garde-fous critiques passent par des hooks déterministes, pas par de simples consignes.

## 10. Contexte progressif

Un agent ne doit pas tout lire par défaut. Il commence par les fichiers sacrés et les index, puis descend dans les niveaux documentaires seulement si le besoin l'exige.

## 11. Dépendances transverses avant action

Une modification n'est jamais traitée comme isolée tant que ses dépendances amont, aval et documentaires n'ont pas été explicitées. Le système doit forcer la question : « qu'est-ce que cela touche aussi ? »

## 12. Suggestion, pas prescription unique

MyProjectOS propose une méthode par défaut (noms, structures, rituels), il ne l'impose pas. Un projet peut légitimement s'en écarter — nommage différent, organisation différente — tant que l'écart est explicite et consigné (typiquement dans le `DECISIONS.md` du projet) plutôt que subi silencieusement. Un garde-fou qui détecte un écart assumé et documenté ne le re-signale pas indéfiniment (voir DEC-0033). Il n'y a pas de méthode parfaite et unique : un adoptant peut suivre MyProjectOS à la lettre ou s'en inspirer seulement.
