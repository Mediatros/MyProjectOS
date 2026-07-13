# Plan — Catalogue d'outils natifs : `98_configuration/` comme couche d'outillage (Blue, AgentMail, secrets, handoff)

> Statut : **proposition, non appliquée** — décisions D1-D6 (§ 6) à trancher par l'utilisateur ; D3 tranchée le 2026-07-13 (pas de backend unique : priorité à l'existant, sinon proposition par plateforme, jamais obligatoire). Zone PLAN/ = plan de travail isolé avant intégration.
> Date : 2026-07-13, amendé le même jour (secrets : proposition par plateforme, principe de saisie hors-bande). Auteur de l'analyse : Claude Code (session Mac), à la demande de l'utilisateur.
> Origine : demande de l'utilisateur (session du 2026-07-13) : faire de `98_configuration/` non plus seulement un dossier de gouvernance, mais le point d'entrée d'un **catalogue d'outils supportés nativement** par MyProjectOS. Chaque outil = gouvernance + skill portable + onboarding guidé (l'agent guide la création du compte, fait par API ce qu'il peut, l'utilisateur ne fournit que le nécessaire). Ce plan généralise le pattern inauguré par la brique Blue (T-PLAN-4, v0.11.x).

## 1. Objectif

Qu'un projet MyProjectOS (ou un adoptant externe du dépôt public) se voie proposer, au cadrage ou à l'adoption, un catalogue d'outils prêts à l'emploi :

1. **Blue** : interface de suivi/pilotage agent ↔ humain (déjà complet, référence du pattern) ;
2. **AgentMail** : boîte mail de l'agent (free tier suffisant, MCP et skill officiels existants) ;
3. **Gestion des secrets** : brique transverse, prérequis des deux autres. Priorité au gestionnaire que l'utilisateur possède déjà, sinon proposition par plateforme, **toujours gratuite et jamais imposée** ;
4. **Handoff inter-agents** : déjà en place, complété par un relevé systématique au rituel de reprise.

Pour chaque outil natif, le même livrable en trois pièces (pattern Blue) : `GOUVERNANCE_<OUTIL>.md` + skill portable agent-agnostique (standard agentskills.io : Claude Code, Codex, Hermès) + protocole d'équipage (registre + handoff « Équiper un agent »). S'y ajoute une exigence nouvelle : une section **Onboarding** qui permet à l'agent de guider l'utilisateur dans la création et la configuration du compte quand il n'existe pas encore.

Les outils non supportés nativement (Trello, Notion…) restent couverts par le gabarit générique `GOUVERNANCE_INTEGRATION.md` : le catalogue le dit explicitement.

## 2. Faits vérifiés (recherches web du 2026-07-13, sources en bas de section)

### 2.1 AgentMail (agentmail.to)

| Point | Constat |
|---|---|
| Free tier | 3 inboxes, 3 000 emails/mois (~100/jour), 3 Go, pas de domaine custom |
| API | REST, clé `am_…` en Bearer ; SDK Python (`pip install agentmail`) et TypeScript (`npm install agentmail`) |
| Intégrations agent | MCP server officiel (`npx agentmail-mcp`, env `AGENTMAIL_API_KEY`) ; skill officielle au standard agentskills.io (compatible Claude Code, Codex, Cursor…) |
| Notifications entrantes | Webhooks (URL publique requise) ou WebSockets ; événement `message.received` |
| Maturité | Série A 6 M$ (mars 2026, YC/Paul Graham), produit jeune |

Conséquences : le VPS Hermès peut recevoir du temps réel (webhook) ; le Mac reste en relevé par session, cohérent avec le modèle handoff. Alternatives (Resend, Mailslurp, AGmail) écartées : soit transactionnel sans inbox d'agent, soit sans traction.

### 2.2 Secrets : offres hébergées (état mi-2026)

| Solution | Verdict |
|---|---|
| Bitwarden Secrets Manager | La doc affiche toujours un free tier (2 users, 3 projets, 3 machine accounts, secrets illimités) **mais l'expérience de l'utilisateur (juillet 2026) est un essai de 7 jours puis payant**. Divergence non résolue : à revérifier empiriquement, et de toute façon **ne plus en faire une dépendance du catalogue**. |
| Infisical cloud | Free tier : 5 identités (humaines + machines), 3 projets, 3 environnements. Meilleur ratio gratuit/limites des SaaS. Parcours vérifié le 2026-07-13 : CLI installable par l'agent (`brew install infisical/get-cli/infisical` ; Debian : script `artifacts-cli.infisical.com/setup.deb.sh` — l'ancien dépôt Cloudsmith s'arrête le 16/09/2026) ; sur Mac `infisical login` ouvre le navigateur et range le token dans le trousseau (l'agent ne voit jamais les identifiants) ; sur VPS headless, machine identity Universal Auth (client id/secret → token court terme) ; l'agent peut créer un secret avec une valeur placeholder (`infisical secrets set NOM=PLACEHOLDER`) que l'utilisateur remplace ensuite dans l'UI web. Pas de deep link vers un secret individuel : lien vers la page du projet + navigation guidée. Carte bancaire au signup : non confirmée, à vérifier empiriquement. |
| Doppler | Free tier réduit depuis 2025 (logs 3 jours) : écarté. |
| Phase.dev | Free tier 5 users/3 apps, open source : alternative de réserve. |
| EnvKey | Fermé (février 2025). |
| 1Password service accounts | Payant : écarté. |

### 2.3 Secrets : VPS headless, gratuit, sans SaaS

| Solution | Verdict |
|---|---|
| **age** (+ sops optionnel) | **Alternative hors-SaaS recommandée sur VPS** (amendement 2026-07-13 : Infisical proposé en premier sur VPS, § 3.4) : un binaire, une clé = un fichier texte stocké hors du dossier projet, fichier de secrets chiffré au repos, déchiffrement en une ligne shell. Complexité faible. |
| pass + GPG | Solide mais la gestion de clé GPG est trop technique pour un non-dev : alternative documentée seulement. |
| systemd-creds | Élégant mais exige root + units systemd : écarté du parcours par défaut. |
| Vaultwarden | Ne supporte PAS le module Secrets Manager (propriétaire Bitwarden) : écarté. |
| Infisical self-host / OpenBao | Docker + PostgreSQL + Redis, ou usine enterprise : trop lourds pour un petit VPS. |
| gnome-keyring headless | D-Bus sans GUI : écarté. |

Sources : agentmail.to (pricing, docs, blog webhooks), github.com/agentmail-to/agentmail-mcp, techcrunch.com (levée mars 2026), bitwarden.com/help/secrets-manager-plans, infisical.com/pricing, doppler.com/pricing, phase.dev/pricing, getsops.io, github.com/FiloSottile/age, github.com/dani-garcia/vaultwarden (discussion #3368), systemd.io/CREDENTIALS, openbao.org.

## 3. Architecture proposée

### 3.1 Le catalogue

Une page `docs/OUTILS.md` (nom définitif selon D1) : un tableau des outils supportés nativement (outil, rôle, coût du free tier, gouvernance, skill, statut), la règle de préséance (variante pré-remplie > gabarit générique, déjà posée en v0.9.0), et le renvoi vers `GOUVERNANCE_INTEGRATION.md` pour tout outil hors catalogue. La skill assistant (Mode 5 étape 8, Mode 6 étape 6) généralise ce qu'elle fait déjà pour Blue : proposer le catalogue, pas un seul outil.

### 3.2 Anatomie d'un outil natif (pattern figé)

```
templates/configuration/GOUVERNANCE_<OUTIL>.md   # gouvernance pré-remplie (nommage, workflow, pièges)
templates/skills/<outil>/
├── SKILL.md          # skill portable agentskills.io, < 20 000 caractères (troncature Hermès)
├── INSTALL.md        # installation par agent + ONBOARDING (création de compte guidée)
└── scripts/          # wrappers POSIX, secrets via la couche commune, jamais de secret sur disque
```

Copie canonique projet dans `98_configuration/skills/<outil>/`, installation par agent chez lui, inscription au tableau d'équipement, entrée de handoff « Équiper un agent ». Un squelette `templates/skills/_squelette/` fige ce pattern pour les outils futurs.

### 3.3 Onboarding guidé (exigence nouvelle)

Chaque `INSTALL.md` gagne une section « Onboarding : créer le compte » écrite pour être déroulée par l'agent avec l'utilisateur :

1. l'agent vérifie si le compte/l'accès existe (smoke test) ;
2. sinon il guide la création : URL d'inscription, choix du plan gratuit, informations à saisir par l'humain (email, mot de passe : jamais manipulés par l'agent) ;
3. **saisie hors-bande (principe posé par l'utilisateur le 2026-07-13)** : la valeur d'un secret ne transite jamais par la conversation avec l'agent. Parcours nominal (backend Infisical) : l'agent crée le secret avec une valeur placeholder par CLI, fournit à l'utilisateur l'URL cliquable de la page du projet dans l'UI web, l'utilisateur y colle la vraie valeur à la main, l'agent relit ensuite le secret par CLI et exécute le smoke test. À défaut (trousseau, age), l'utilisateur saisit la valeur lui-même dans un terminal (commande fournie par l'agent, jamais exécutée par lui) ;
4. tout ce que l'API permet d'automatiser après coup (créer les inboxes AgentMail, poser un webhook, créer le workspace Blue) est fait par l'agent, avec accord explicite pour les actions au niveau du compte.

### 3.4 Couche secrets transverse

Généralisation de `blue-secrets.sh` en un `secrets.sh` unique, paramétré par préfixe (`BLUE_`, `AGENTMAIL_`…), livré dans le squelette et embarqué par chaque skill. Ordre de résolution inchangé : env > backend natif de la plateforme > backend cloud > fichier.

**Pas de backend canonique unique : un arbre de proposition** (tranché par l'utilisateur le 2026-07-13). La brique secrets est une proposition, jamais une obligation : l'utilisateur décide de l'utiliser ou non. MyProjectOS doit être pensé pour n'importe quel adoptant, pas pour la configuration de son auteur.

1. **L'utilisateur a déjà un gestionnaire de secrets** (Bitwarden Secrets Manager, autre) → on s'appuie dessus, `secrets.sh` le consomme (backend `bws` déjà supporté, extensible).
2. **Sinon, proposition selon la plateforme où vit le projet** :
   - **Mac** → trousseau macOS (`security`) : natif, gratuit, zéro compte à créer. Pas d'Infisical si le projet vit sur Mac.
   - **VPS headless** → **Infisical cloud** (machine identity) : gratuit (5 identités, 3 projets), installable et administrable automatiquement par l'agent, saisie hors-bande via l'UI web. Alternative hors-SaaS : fichier chiffré age, clé hors du dossier projet (`~/.config/age/`).
   - **Windows** → solution à déterminer (D6) : Credential Manager natif (`cmdkey`/PowerShell) ou Infisical ; documentation seule tant qu'aucune machine Windows n'est disponible pour tester.
   - **Projet multi-plateformes** → chaque agent utilise le backend de SA plateforme ; ce sont les NOMS de clés qui sont communs (registre `GOUVERNANCE_SECRETS.md`). Si l'utilisateur préfère un point unique multi-machines, Infisical peut couvrir l'ensemble, mais ce n'est pas le défaut.
3. **Refus de toute la brique** → repli documenté : fichier `chmod 600` hors du dossier projet, présenté explicitement comme dégradé.

Bootstrap résiduel à documenter pour Infisical sur VPS : le client id/secret de la machine identity doit être posé une fois (fichier 600 hors du dossier projet ou env de session, saisi par l'humain, pas par l'agent). Sur Mac, si Infisical est retenu quand même, `infisical login` navigateur suffit (token dans le trousseau, aucun credential ne passe par l'agent).

Cas particulier consigné pour mémoire : l'auteur de la méthode utilise déjà BSM côté VPS (branche 1 de l'arbre) et le trousseau côté Mac ; sa configuration personnelle (dont la synchronisation Syncthing entre machines) n'est PAS une hypothèse de la méthode.

`GOUVERNANCE_SECRETS.md` = registre des NOMS de clés (jamais des valeurs), backend choisi par agent, où renouveler chaque token. La règle absolue existante reste : aucun secret dans le dossier projet (qui peut être synchronisé entre machines), aucun secret échoué en sortie.

### 3.5 Outil AgentMail

Skill maison `agentmail` agent-agnostique, **dérivée de la skill officielle** (décision de l'utilisateur, 2026-07-13) : on part du contenu officiel, on l'adapte au pattern MyProjectOS (secrets via `secrets.sh`, gouvernance projet, registre d'équipement, aucune clé en dur). `GOUVERNANCE_AGENTMAIL.md` pré-remplie : attribution des 3 inboxes gratuites (D4), règles d'usage (qui envoie quoi, signature agent), relevé des mails en début de session, webhook éventuel côté VPS uniquement.

### 3.6 Handoff : relevé au rituel de reprise

Demande explicite de l'utilisateur : quand un agent ouvre une session et qu'un handoff `EN_ATTENTE` lui est adressé, il doit le relever et **informer l'utilisateur** qu'une action est demandée ou en cours de la part de son autre agent. Câblage : skill assistant `my-project-os` (Mode 1 reprise : ajout d'une étape « relever `98_configuration/HANDOFF_*.md` »), gabarit `AGENTS.md` (rituel de session), même mécanique que le relevé des commentaires Blue (§ 7.3 du plan T-PLAN-4, lui aussi jamais exercé en réel : les deux se testent ensemble). Option (D5) : notification par mail AgentMail au dépôt d'un handoff urgent.

## 4. Phases

**Phase 1 — Catalogue et squelette.** `docs/OUTILS.md`, `templates/skills/_squelette/` (SKILL.md type, INSTALL.md avec section Onboarding, `secrets.sh` générique), généralisation Mode 5/6 de la skill assistant. Critère de fin : `check-project.sh` inchangé, skill `validate` passée, Blue re-décrit comme première entrée du catalogue sans rien casser.

**Phase 2 — Brique secrets.** `secrets.sh` générique extrait de `blue-secrets.sh` (rétro-compatible : `blue-app` continue de marcher), `GOUVERNANCE_SECRETS.md`, guides par plateforme. **Test en réel, parcours Infisical côté VPS** (c'est la proposition faite aux nouveaux adoptants, elle doit avoir été déroulée une fois en vrai) : création du compte via le parcours Onboarding (il EST le test ; vérifier au passage la question de la carte bancaire, D3), installation CLI par l'agent, machine identity, secret factice créé en placeholder par l'agent, valeur collée par l'utilisateur dans l'UI web, relecture et smoke test par l'agent. Le trousseau Mac est déjà couvert par `blue-app` ; en complément : age exercé sur le VPS comme voie hors-SaaS documentée. Critère de fin : un secret factice fait l'aller-retour saisie hors-bande → lecture agent, sans jamais transiter par la conversation ni toucher le disque en clair.

**Phase 3 — Outil AgentMail.** Compte free créé via le parcours Onboarding (déroulé en réel, il EST le test), skill `agentmail` dérivée de l'officielle, gouvernance, banc d'essai (MySecretaire, comme pour Blue) : envoi, réception, relevé en début de session, sur les trois agents si possible. Critère de fin : un mail envoyé et lu par au moins deux agents, clé API rangée dans le backend de chaque plateforme, équipement consigné.

**Phase 4 — Handoff.** Étape de relevé au Mode 1 de la skill assistant + gabarit `AGENTS.md`, exercée en réel (déposer un handoff, ouvrir une session, vérifier que l'agent le signale spontanément) ; en profiter pour exercer enfin le relevé des commentaires Blue. Si D5 = oui : notification mail au dépôt d'un handoff urgent.

Chaque phase se termine par le gate `evolve-method` (CHG, DEC si structurant, bump VERSION, propagation selon la checklist § 8 du dépôt) puis la skill `validate`.

## 5. Impacts méthode (checklist de propagation)

- `templates/configuration/` : + `GOUVERNANCE_SECRETS.md`, + `GOUVERNANCE_AGENTMAIL.md`
- `templates/skills/` : + `_squelette/`, + `agentmail/` ; `blue-app` bascule sur `secrets.sh` commun (bump version skill)
- `structures/core-tree.md` : catalogue référencé dans la description de `98_configuration/`
- `skills/my-project-os/SKILL.md` : Mode 5/6 (catalogue au lieu de Blue seul), Mode 1 (relevé handoff)
- `docs/` : + `OUTILS.md` ; `NAMING-CONVENTIONS.md` si le terme retenu (D1) l'exige
- `templates/core/AGENTS.md` : rituel de session (relevé handoff)
- Dogfooding : le dépôt méthode et les projets structurés reçoivent la propagation via `--update-method` (décision humaine, comme d'habitude)

## 6. Décisions à trancher (D1-D5)

| # | Question | Recommandation |
|---|---|---|
| D1 | Terme et nom du catalogue : « outil » (`docs/OUTILS.md`) ou « brique » ? L'utilisateur penche pour « outil » ; « brique » resterait le mot interne pour le pattern (gouvernance+skill+équipage). | `docs/OUTILS.md`, terme « outil » face à l'utilisateur |
| D2 | Alternative hors-SaaS sur VPS (pour qui refuse Infisical) : age seul, ou sops+age ? | age seul (sops en option avancée documentée) |
| D3 | **Tranchée par l'utilisateur le 2026-07-13** : pas de backend canonique unique. Priorité à l'existant (gestionnaire déjà en place chez l'utilisateur, ex. BSM), sinon proposition par plateforme : trousseau sur Mac, Infisical sur VPS, Windows à déterminer (D6). Jamais obligatoire : l'utilisateur décide. Le parcours Infisical VPS reste à valider en Phase 2 par le test réel (dont : carte bancaire exigée ou non au signup). | Actée (§ 3.4) |
| D6 | Solution proposée sur Windows : Credential Manager natif ou Infisical ? Documentation seule tant qu'aucune machine Windows de test. | Credential Manager en premier (natif, zéro compte), Infisical en alternative |
| D4 | Les 3 inboxes AgentMail gratuites : une inbox partagée « agents » + réserve, ou une par agent (CLAUDECODE/HERMES/CODEX) ? | Une par agent, identité claire de l'émetteur |
| D5 | Notification mail au dépôt d'un handoff urgent (couplage handoff → AgentMail → webhook VPS) : Phase 4 ou reporté ? | Reporter après validation de la Phase 3 en réel |

## 7. Hors périmètre

- Support natif de Trello, Notion ou autres : gabarit générique seulement.
- Domaine custom AgentMail (payant), tiers payants de quoi que ce soit.
- Temps réel côté Mac (webhooks impossibles sans URL publique) : le relevé par session reste le modèle.
- Bascule effective `blue-cli/` (toujours en attente d'une décision explicite, inchangé).
