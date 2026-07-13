# Plan — Catalogue d'outils natifs : `98_configuration/` comme couche d'outillage (Blue, AgentMail, secrets, handoff)

> Statut : **en cours — Phase 1 faite le 2026-07-13** (feu vert utilisateur, DEC-0030, CHG-20260713-1330, v0.12.0) ; décisions D1-D6 (§ 6) toutes tranchées. Restent : Phase 2 (Tailscale + Infisical VPS en réel), Phase 3 (AgentMail), Phase 4 (handoff). Zone PLAN/ = plan de travail isolé avant intégration.
> Date : 2026-07-13, amendé le même jour (secrets : proposition par plateforme, principe de saisie hors-bande). Auteur de l'analyse : Claude Code (session Mac), à la demande de l'utilisateur.
> Origine : demande de l'utilisateur (session du 2026-07-13) : faire de `98_configuration/` non plus seulement un dossier de gouvernance, mais le point d'entrée d'un **catalogue d'outils supportés nativement** par MyProjectOS. Chaque outil = gouvernance + skill portable + onboarding guidé (l'agent guide la création du compte, fait par API ce qu'il peut, l'utilisateur ne fournit que le nécessaire). Ce plan généralise le pattern inauguré par la brique Blue (T-PLAN-4, v0.11.x).

## 1. Objectif

Qu'un projet MyProjectOS (ou un adoptant externe du dépôt public) se voie proposer, au cadrage ou à l'adoption, un catalogue d'outils prêts à l'emploi :

1. **Blue** : interface de suivi/pilotage agent ↔ humain (déjà complet, référence du pattern) ;
2. **AgentMail** : boîte mail de l'agent (free tier suffisant, MCP et skill officiels existants) ;
3. **Gestion des secrets** : brique transverse, prérequis des deux autres. Priorité au gestionnaire que l'utilisateur possède déjà, sinon proposition par plateforme, **toujours gratuite et jamais imposée** ;
4. **Handoff inter-agents** : déjà en place, complété par un relevé systématique au rituel de reprise ;
5. **Skills utilitaires sans compte** (ajout demandé le 2026-07-13) : des skills prêtes à installer qui ne nécessitent ni compte ni secret, proposées à l'utilisateur qui le souhaite. Premières : `courrier-manuscrit` et `redaction-humaine-fr` (§ 3.7) ;
6. **Tailscale** (ajout demandé le 2026-07-13) : réseau privé entre les machines de l'utilisateur, prérequis du parcours Infisical auto-hébergé (D2) et utile au-delà (accès sécurisé au VPS). L'agent vérifie sa présence et sa configuration, et sinon guide l'installation, y compris sur iPhone (§ 3.8).

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
| Infisical cloud | Free tier : 5 identités (humaines + machines), 3 projets, 3 environnements. Meilleur ratio gratuit/limites des SaaS. Parcours vérifié le 2026-07-13 : CLI installable par l'agent (`brew install infisical/get-cli/infisical` ; Debian : script `artifacts-cli.infisical.com/setup.deb.sh` — l'ancien dépôt Cloudsmith s'arrête le 2026-09-16) ; sur Mac `infisical login` ouvre le navigateur et range le token dans le trousseau (l'agent ne voit jamais les identifiants) ; sur VPS headless, machine identity Universal Auth (client id/secret → token court terme) ; l'agent peut créer un secret avec une valeur placeholder (`infisical secrets set NOM=PLACEHOLDER`) que l'utilisateur remplace ensuite dans l'UI web. Pas de deep link vers un secret individuel : lien vers la page du projet + navigation guidée. Carte bancaire au signup : non confirmée, à vérifier empiriquement. |
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
| Infisical self-host / OpenBao | Docker + PostgreSQL + Redis, ou usine enterprise : jugés lourds pour un petit VPS lors de la recherche initiale. **Décision utilisateur du 2026-07-13 : Infisical self-host retenu quand même pour le VPS** (D2, § 3.4), sécurisé par Tailscale ; l'empreinte mémoire réelle sur un VPS déjà occupé est un point de vigilance à valider au banc d'essai Phase 2. OpenBao reste écarté. |
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
3. **saisie hors-bande (principe posé par l'utilisateur le 2026-07-13)** : par défaut, la valeur d'un secret ne transite jamais par la conversation avec l'agent. Parcours nominal (backend Infisical) : l'agent crée le secret avec une valeur placeholder par CLI, fournit à l'utilisateur l'URL cliquable de l'UI web (lien Tailscale pour une instance auto-hébergée sur VPS), l'utilisateur y colle la vraie valeur à la main, l'agent relit ensuite le secret par CLI et exécute le smoke test. À défaut (trousseau, age), l'utilisateur saisit la valeur lui-même dans un terminal (commande fournie par l'agent, jamais exécutée par lui). L'utilisateur peut choisir explicitement le mode **full-auto** à la place : il donne les clés à l'agent dans la conversation et l'agent range tout, en acceptant en connaissance de cause le transit par le LLM ;
4. tout ce que l'API permet d'automatiser après coup (créer les inboxes AgentMail, poser un webhook, créer le workspace Blue) est fait par l'agent, avec accord explicite pour les actions au niveau du compte.

### 3.4 Couche secrets transverse

Généralisation de `blue-secrets.sh` en un `secrets.sh` unique, paramétré par préfixe (`BLUE_`, `AGENTMAIL_`…), livré dans le squelette et embarqué par chaque skill. Ordre de résolution inchangé : env > backend natif de la plateforme > backend cloud > fichier.

**Pas de backend canonique unique : un arbre de proposition** (tranché par l'utilisateur le 2026-07-13). La brique secrets est une proposition, jamais une obligation : l'utilisateur décide de l'utiliser ou non. MyProjectOS doit être pensé pour n'importe quel adoptant, pas pour la configuration de son auteur.

1. **L'utilisateur a déjà un gestionnaire de secrets** (Bitwarden Secrets Manager, autre) → on s'appuie dessus, `secrets.sh` le consomme (backend `bws` déjà supporté, extensible).
2. **Sinon, proposition selon la plateforme où vit le projet** :
   - **Mac** → trousseau macOS (`security`) : natif, gratuit, zéro compte à créer. Pas d'Infisical si le projet vit sur Mac.
   - **VPS headless** → **Infisical auto-hébergé sur le VPS** (D2 tranchée le 2026-07-13), installé automatiquement par l'agent (Docker), avec une contrainte de sécurité absolue : l'interface web n'est **jamais accessible depuis l'extérieur**, elle est liée exclusivement à l'interface Tailscale du VPS. Deux modes de gestion au choix de l'utilisateur : (a) **full-auto** : l'agent gère tout, l'utilisateur lui transmet les clés dans la conversation (transit par le LLM accepté explicitement) ; (b) **hors-bande** : l'agent fournit le lien Tailscale de l'UI Infisical, l'utilisateur y renseigne les valeurs lui-même. Prérequis documenté du parcours : Tailscale installé et configuré sur le VPS et sur le terminal de l'utilisateur. Repli léger documenté en une ligne : fichier chiffré age, clé hors du dossier projet ; variante sans hébergement : Infisical cloud.
   - **Windows** → **via WSL** (D6 tranchée le 2026-07-13) : mêmes propositions que Linux (Infisical ou age), zéro portage des scripts POSIX ; le Credential Manager natif est mentionné comme piste non outillée (lecture de secret difficile hors PowerShell, inaccessible proprement depuis WSL), sans support tant qu'aucune machine Windows de test n'existe.
   - **Projet multi-plateformes** → chaque agent utilise le backend de SA plateforme ; ce sont les NOMS de clés qui sont communs (registre `GOUVERNANCE_SECRETS.md`). Si l'utilisateur préfère un point unique multi-machines, Infisical peut couvrir l'ensemble, mais ce n'est pas le défaut.
3. **Refus de toute la brique** → repli documenté : fichier `chmod 600` hors du dossier projet, présenté explicitement comme dégradé.

Bootstrap résiduel à documenter pour Infisical sur VPS : le client id/secret de la machine identity doit être posé une fois (fichier 600 hors du dossier projet ou env de session, saisi par l'humain, pas par l'agent). Sur Mac, si Infisical est retenu quand même, `infisical login` navigateur suffit (token dans le trousseau, aucun credential ne passe par l'agent).

Cas particulier consigné pour mémoire : l'auteur de la méthode utilise déjà BSM côté VPS (branche 1 de l'arbre) et le trousseau côté Mac ; sa configuration personnelle (dont la synchronisation Syncthing entre machines) n'est PAS une hypothèse de la méthode.

`GOUVERNANCE_SECRETS.md` = registre des NOMS de clés (jamais des valeurs), backend choisi par agent, où renouveler chaque token. La règle absolue existante reste : aucun secret dans le dossier projet (qui peut être synchronisé entre machines), aucun secret échoué en sortie.

### 3.5 Outil AgentMail

Skill maison `agentmail` agent-agnostique, **dérivée de la skill officielle** (décision de l'utilisateur, 2026-07-13) : on part du contenu officiel, on l'adapte au pattern MyProjectOS (secrets via `secrets.sh`, gouvernance projet, registre d'équipement, aucune clé en dur). **D4 tranchée le 2026-07-13 : un seul et unique compte AgentMail, utilisable par les trois agents.** Principe directeur : l'agent n'est que le moteur intelligent qui fait fonctionner le projet ; l'identité mail appartient au projet/à l'utilisateur, pas à l'agent, cohérent avec l'objectif agent-agnostique de la méthode. L'attribution des 3 inboxes gratuites n'est donc PAS par agent ; elle se définit par besoin dans `GOUVERNANCE_AGENTMAIL.md` (règles d'usage, qui envoie quoi, relevé des mails en début de session, marquage des mails traités), à affiner au banc d'essai.

### 3.6 Handoff : relevé au rituel de reprise

Demande explicite de l'utilisateur : quand un agent ouvre une session et qu'un handoff `EN_ATTENTE` lui est adressé, il doit le relever et **informer l'utilisateur** qu'une action est demandée ou en cours de la part de son autre agent. **D5 tranchée le 2026-07-13 : pas de notification mail.** Le signal passe par `PROGRESS.md` : au dépôt d'un handoff, l'agent émetteur ajoute une mention à destination de l'agent cible dans `PROGRESS.md` (bloc d'en-tête `prochaine_action`, comme le font déjà les handoffs Blue de MySecretaire). Comme tout agent lit `PROGRESS.md` en tout début de session (règle existante de la méthode), il découvre immédiatement qu'une action l'attend dans le fichier de handoff. Câblage : gabarit `HANDOFF_INTERAGENT.md` (le geste de dépôt inclut la mention PROGRESS), skill assistant `my-project-os` (Mode 1 reprise : relever la mention et le handoff, en informer l'utilisateur), gabarit `AGENTS.md` (rituel de session), même mécanique que le relevé des commentaires Blue (§ 7.3 du plan T-PLAN-4, lui aussi jamais exercé en réel : les deux se testent ensemble).

### 3.7 Skills utilitaires sans compte : `courrier-manuscrit`

Deuxième famille du catalogue, à côté des outils à compte (Blue, AgentMail, Infisical) : des skills autonomes, sans secret ni gouvernance d'intégration, que l'utilisateur installe s'il le souhaite sur l'agent de son choix. Le squelette (§ 3.2) s'applique en version allégée : pas de `GOUVERNANCE_`, pas de `secrets.sh`, mais un `INSTALL.md` par agent et l'inscription au tableau d'équipement restent.

Première skill de cette famille : `courrier-manuscrit` (existante chez l'utilisateur dans `~/.claude/skills/courrier-manuscrit/`, SKILL.md + template.html) : rédaction d'un courrier ou d'une attestation au rendu manuscrit (brouillon Markdown puis PDF A4 via WeasyPrint). Adaptations obligatoires avant d'entrer dans `templates/skills/courrier-manuscrit/` (dépôt public) :

- **la police n'est pas redistribuable** (« Pumpkin Custard », licence Personal Use Only) : le gabarit ne l'embarque pas, il paramètre le nom et le chemin de la police et guide l'utilisateur pour installer une police manuscrite de son choix (l'onboarding § 3.3 s'applique, sans secret) ;
- **dé-personnalisation** : chemins en dur `/Users/jb/...` remplacés par des variables/instructions ;
- **portabilité** : la version actuelle est Mac-first (`mdls`, `sips`, `~/Library/Fonts`) ; documenter les équivalents Linux (`pdfinfo`, `pdftoppm`, `~/.local/share/fonts`) ou assumer « Mac d'abord » dans la fiche catalogue ;
- **prérequis** : WeasyPrint, avec la commande d'installation par plateforme dans `INSTALL.md`.

L'instance personnelle de l'utilisateur reste intacte ; comme pour `blue-app`, le gabarit du dépôt est la version générique.

Deuxième skill de la famille (ajout demandé le 2026-07-13, après la Phase 1 initiale) : `redaction-humaine-fr` (existante chez l'utilisateur dans `~/.claude/skills/redaction-humaine-fr/`) : rédiger des textes en français de France au rendu humain, deux niveaux (1 « soigné » sans faute par défaut, 2 « relâché » avec quelques fautes subtiles crédibles, sur demande explicite uniquement), pour les textes publiés sous le nom de l'utilisateur. Déjà entièrement générique (aucune donnée personnelle, aucune dépendance) : copiée telle quelle dans `templates/skills/redaction-humaine-fr/` avec un `INSTALL.md`. Synergie : `courrier-manuscrit` applique son niveau 1 quand elle est installée (référence rétablie, elle avait été retirée à la générisation initiale).

### 3.8 Outil Tailscale (vérification et onboarding guidé)

Entrée du catalogue sans skill dédiée : la CLI `tailscale` est l'outil lui-même. Fiche `OUTILS.md` + section Onboarding, déroulée par l'agent :

1. **Vérification** : `tailscale status` (ou présence du binaire) sur chaque machine où vit le projet ; sur le VPS, vérifier aussi que l'interface Tailscale porte bien une IP (`tailscale ip -4`).
2. **Si absent, onboarding guidé** : l'agent installe ce qu'il peut lui-même (VPS : script officiel `https://tailscale.com/install.sh` ; Mac : `brew install tailscale` ou App Store) et fournit à l'utilisateur les liens cliquables pour SES appareils : page officielle `https://tailscale.com/download` (Mac, Windows, Linux) et application iPhone (App Store, « Tailscale »). Compte : plan Personal gratuit (à re-vérifier en Phase 2 : limites actuelles d'appareils/utilisateurs), création guidée comme en § 3.3.
3. **Authentification hors-bande par construction** : `tailscale up` renvoie une URL de connexion que l'utilisateur ouvre dans SON navigateur ; aucune clé ne transite par l'agent (les auth keys pré-générées existent mais ne sont proposées qu'en mode full-auto explicite).
4. **Vérification finale** : ping entre machines par nom Tailscale, consignation dans le tableau d'équipement.

Cet onboarding est un préalable systématique du parcours Infisical VPS (§ 3.4) : la Phase 2 le déroule en premier.

## 4. Phases

**Phase 1 — Catalogue et squelette.** `docs/OUTILS.md` (les deux familles : outils à compte, skills utilitaires), `templates/skills/_squelette/` (SKILL.md type, INSTALL.md avec section Onboarding, `secrets.sh` générique), généralisation Mode 5/6 de la skill assistant, et première skill utilitaire `templates/skills/courrier-manuscrit/` (adaptations § 3.7 : police paramétrée non embarquée, dé-personnalisation, prérequis WeasyPrint). Critère de fin : `check-project.sh` inchangé, skill `validate` passée, Blue re-décrit comme première entrée du catalogue sans rien casser, gabarit `courrier-manuscrit` sans chemin personnel ni fichier de police.

**Phase 2 — Brique secrets.** `secrets.sh` générique extrait de `blue-secrets.sh` (rétro-compatible : `blue-app` continue de marcher), `GOUVERNANCE_SECRETS.md`, guides par plateforme. **Préalable : onboarding Tailscale** (§ 3.8) : vérification `tailscale status` sur VPS et Mac, installation guidée si besoin (liens téléchargement ordinateur et iPhone), authentification hors-bande par URL, re-vérification des limites du plan Personal gratuit. Puis **test en réel, parcours Infisical auto-hébergé côté VPS** (c'est la proposition faite aux nouveaux adoptants, elle doit avoir été déroulée une fois en vrai, D2) : déploiement automatique par l'agent (Docker), UI liée exclusivement à l'interface Tailscale (vérifier depuis l'extérieur qu'elle est inaccessible), lien Tailscale fourni à l'utilisateur, secret factice créé en placeholder par l'agent, valeur collée par l'utilisateur dans l'UI, relecture et smoke test par l'agent ; mesurer l'empreinte mémoire réelle (vigilance Docker/PostgreSQL/Redis sur petit VPS). Le trousseau Mac est déjà couvert par `blue-app` ; le mode full-auto et le repli age sont documentés sans nouveau test. Critère de fin : un secret factice fait l'aller-retour saisie hors-bande → lecture agent, sans jamais transiter par la conversation ni toucher le disque en clair, et l'UI est invisible hors Tailscale.

**Phase 3 — Outil AgentMail.** Compte free créé via le parcours Onboarding (déroulé en réel, il EST le test), skill `agentmail` dérivée de l'officielle, gouvernance, banc d'essai (MySecretaire, comme pour Blue) : envoi, réception, relevé en début de session, sur les trois agents si possible. Critère de fin : un mail envoyé et lu par au moins deux agents, clé API rangée dans le backend de chaque plateforme, équipement consigné.

**Phase 4 — Handoff.** Geste de dépôt enrichi (mention à l'agent cible dans le bloc d'en-tête de `PROGRESS.md`, D5) + étape de relevé au Mode 1 de la skill assistant + gabarit `AGENTS.md`, exercés en réel (déposer un handoff avec mention PROGRESS, ouvrir une session de l'agent cible, vérifier qu'il le signale spontanément à l'utilisateur) ; en profiter pour exercer enfin le relevé des commentaires Blue.

Chaque phase se termine par le gate `evolve-method` (CHG, DEC si structurant, bump VERSION, propagation selon la checklist § 8 du dépôt) puis la skill `validate`.

## 5. Impacts méthode (checklist de propagation)

- `templates/configuration/` : + `GOUVERNANCE_SECRETS.md`, + `GOUVERNANCE_AGENTMAIL.md`
- `templates/skills/` : + `_squelette/`, + `agentmail/`, + `courrier-manuscrit/` (générique, sans police embarquée) ; `blue-app` bascule sur `secrets.sh` commun (bump version skill)
- `structures/core-tree.md` : catalogue référencé dans la description de `98_configuration/`
- `skills/my-project-os/SKILL.md` : Mode 5/6 (catalogue au lieu de Blue seul), Mode 1 (relevé handoff)
- `docs/` : + `OUTILS.md` ; `NAMING-CONVENTIONS.md` si le terme retenu (D1) l'exige
- `templates/core/AGENTS.md` : rituel de session (relevé handoff)
- Dogfooding : le dépôt méthode et les projets structurés reçoivent la propagation via `--update-method` (décision humaine, comme d'habitude)

## 6. Décisions (toutes tranchées par l'utilisateur le 2026-07-13)

| # | Décision |
|---|---|
| D1 | **Deux niveaux de vocabulaire** : « outil » partout face à l'utilisateur (catalogue `docs/OUTILS.md`, skill assistant), « brique » reste le terme interne pour le pattern complet (gouvernance + skill + équipage). |
| D2 | **VPS : Infisical auto-hébergé**, installé automatiquement par l'agent, UI jamais exposée à l'extérieur (accès exclusivement via Tailscale, lien Tailscale fourni à l'utilisateur). Deux modes : full-auto (clés confiées à l'agent dans la conversation, transit LLM accepté explicitement) ou hors-bande (saisie dans l'UI). Prérequis documenté : Tailscale configuré sur le VPS et le terminal de l'utilisateur. age relégué en repli léger documenté en une ligne ; Infisical cloud en variante sans hébergement. Vigilance Phase 2 : empreinte Docker/PostgreSQL/Redis sur un petit VPS. |
| D3 | **Pas de backend canonique unique.** Priorité à l'existant (gestionnaire déjà en place chez l'utilisateur, ex. BSM), sinon proposition par plateforme (§ 3.4). Jamais obligatoire : l'utilisateur décide. |
| D4 | **Un seul et unique compte AgentMail**, utilisable par les trois agents. L'agent n'est que le moteur intelligent du projet : l'identité mail appartient au projet/à l'utilisateur, pas à l'agent (cohérence agent-agnostique). Attribution des inboxes par besoin, définie dans la gouvernance au banc d'essai. |
| D5 | **Pas de notification mail des handoffs.** Le signal passe par `PROGRESS.md` : au dépôt d'un handoff, mention à destination de l'agent cible dans le bloc d'en-tête ; l'agent la découvre à la lecture rituelle de `PROGRESS.md` en début de session et va vérifier le handoff (§ 3.6). |
| D6 | **Windows = via WSL**, mêmes propositions que Linux (Infisical ou age), zéro portage des scripts POSIX ; Credential Manager natif mentionné comme piste non outillée, sans support faute de machine de test. |

## 7. Hors périmètre

- Support natif de Trello, Notion ou autres : gabarit générique seulement.
- Domaine custom AgentMail (payant), tiers payants de quoi que ce soit.
- Temps réel côté Mac (webhooks impossibles sans URL publique) : le relevé par session reste le modèle.
- Bascule effective `blue-cli/` (toujours en attente d'une décision explicite, inchangé).
