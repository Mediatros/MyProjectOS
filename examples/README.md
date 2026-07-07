# Exemples — MyProjectOS

Deux projets d'exemple complets, aux contenus réalistes et anonymisés. Ils montrent à quoi ressemblent les fichiers sacrés et les registres **une fois remplis**, là où `templates/` montre les gabarits vides.

| Exemple | Type | Ce qu'il illustre |
|---|---|---|
| [`life-copropriete/`](life-copropriete/) | Life | Suivi d'une copropriété : correspondances avec le syndic (`C-XXXX`), preuves datées (`P-XXXX`), échéances légales, décisions argumentées |
| [`code-site-vitrine/`](code-site-vitrine/) | Code | Site vitrine pour un client : gate `STACK_VALIDATION` validé et sourcé, specs `F-XXX`, analyses d'impact `IA-XXX`, plan de test, checklist de release |

Les deux respectent les conventions (`docs/NAMING-CONVENTIONS.md`), la frontière des fichiers sacrés (`docs/governance.md`) et le cycle de travail (`docs/cycle-de-travail.md`) : chaque entrée de `CHANGELOG.md` correspond à une itération close, chaque affirmation engageante du projet Life pointe vers une preuve.

Les identifiants (`CHG-`, `DEC-`, `P-`, `C-`, `F-`, `IA-`) sont internes à chaque exemple : ils référencent les registres de l'exemple, pas ceux du repo méthode.
