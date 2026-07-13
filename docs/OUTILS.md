# Catalogue des outils MyProjectOS

> Les outils que la méthode sait proposer et outiller nativement. Tout est **optionnel** : l'agent propose, l'utilisateur décide. Pour un outil hors catalogue (Trello, Notion...), utiliser le gabarit générique `templates/configuration/GOUVERNANCE_INTEGRATION.md` ; la règle de préséance reste : une variante pré-remplie par outil prime sur le gabarit générique.
>
> Vocabulaire (DEC-0030) : « outil » est le mot employé face à l'utilisateur ; « brique » désigne en interne le pattern complet qui outille un outil (gouvernance + skill portable + protocole d'équipage).

## Les deux familles

1. **Outils à compte** : un service externe avec compte et clé API. Chaque outil livre une gouvernance pré-remplie (`templates/configuration/GOUVERNANCE_<OUTIL>.md`), une skill portable agent-agnostique (`templates/skills/<outil>/`, standard agentskills.io : Claude Code, Codex, Hermès) et un protocole d'équipage (tableau d'équipement + handoff « Équiper un agent »).
2. **Skills utilitaires sans compte** : des skills prêtes à installer, sans secret ni gouvernance d'intégration, que l'utilisateur installe s'il le souhaite sur l'agent de son choix.

## Outils à compte

| Outil | Rôle | Coût | Livrables | Statut |
|---|---|---|---|---|
| **Blue** (blue.cc) | Interface de suivi/pilotage agent ↔ humain : miroir visuel de `TASKS.md`, consultable depuis un téléphone, commentaires de cartes comme canal de demandes | Free tier suffisant pour un usage solo | `GOUVERNANCE_BLUE.md` + skill `blue-app` (CLI + GraphQL + fichiers) | **Disponible**, éprouvé en réel sur plusieurs projets |
| **AgentMail** (agentmail.to) | Boîte mail de l'agent : recevoir et envoyer des emails par API. Un seul compte pour tous les agents (l'identité mail appartient au projet, pas à l'agent) | Free tier : 3 inboxes, 3 000 emails/mois, 3 Go (vérifié 2026-07-13) | `GOUVERNANCE_AGENTMAIL.md` + skill `agentmail` (dérivée de la skill officielle) | Planifié (T-PLAN-5 Phase 3) |
| **Infisical** | Gestion des secrets multi-agents. Sur VPS : instance auto-hébergée par l'agent, UI accessible **uniquement via Tailscale**, saisie hors-bande des valeurs dans l'UI web | Gratuit (auto-hébergé ; cloud : free tier 5 identités / 3 projets) | Backend `infisical` de `secrets.sh` + `GOUVERNANCE_SECRETS.md` | Planifié (T-PLAN-5 Phase 2) |
| **Tailscale** | Réseau privé entre les machines de l'utilisateur (Mac, VPS, iPhone...) : accès sécurisé au VPS, prérequis de l'Infisical auto-hébergé | Plan Personal gratuit (limites à re-vérifier à l'activation) | Fiche d'onboarding ci-dessous (pas de skill : la CLI est l'outil) | **Disponible** (fiche) |

### Gestion des secrets : quelle voie proposer ?

Jamais imposée, toujours gratuite. Dans l'ordre :

1. **L'utilisateur a déjà un gestionnaire de secrets** (Bitwarden Secrets Manager, autre) → s'appuyer dessus (`secrets.sh` supporte `bws` ; extensible).
2. **Sinon, selon la plateforme du projet** : Mac → trousseau (`security`, natif, zéro compte) ; VPS headless → Infisical auto-hébergé via Tailscale (repli léger : fichier chiffré age, clé hors du dossier projet) ; Windows → via WSL, mêmes voies que Linux.
3. **Refus de tout ça** → fichier `chmod 600` hors du dossier projet, explicitement dégradé.

Principe transverse de **saisie hors-bande** : par défaut, la valeur d'un secret ne transite jamais par la conversation avec l'agent (UI web Infisical via lien Tailscale, ou commande exécutée par l'utilisateur dans son terminal). Le mode full-auto (clés confiées à l'agent dans la conversation) n'est possible que sur choix explicite de l'utilisateur. Le projet ne consigne que les NOMS de backend et de clés, jamais une valeur.

### Fiche Tailscale (onboarding par l'agent)

1. **Vérifier** : `tailscale status` sur chaque machine du projet ; sur le VPS, `tailscale ip -4` doit retourner une IP.
2. **Si absent** : l'agent installe ce qu'il peut (VPS : `curl -fsSL https://tailscale.com/install.sh | sh` ; Mac : `brew install tailscale` ou App Store) et fournit à l'utilisateur les liens pour SES appareils : `https://tailscale.com/download` (ordinateur) et l'application « Tailscale » sur l'App Store (iPhone). Compte : plan Personal gratuit, création guidée (email/mot de passe saisis par l'humain).
3. **Authentification hors-bande par construction** : `tailscale up` affiche une URL que l'utilisateur ouvre dans SON navigateur ; aucune clé ne transite par l'agent.
4. **Vérifier et consigner** : ping entre machines par nom Tailscale, ligne au tableau d'équipement du projet.

## Skills utilitaires sans compte

| Skill | Rôle | Prérequis | Statut |
|---|---|---|---|
| **redaction-humaine-fr** | Rédiger des textes en français de France au rendu humain, pour tout ce qui part sous le nom de l'utilisateur (articles, posts, emails, courriers). Niveau 1 « soigné » (défaut, sans faute) ; niveau 2 « relâché » (quelques fautes subtiles crédibles, sur demande explicite uniquement) | Aucun | **Disponible** (`templates/skills/redaction-humaine-fr/`) |
| **courrier-manuscrit** | Courrier ou attestation au rendu manuscrit (brouillon Markdown → PDF A4 une page via WeasyPrint). Applique le niveau 1 de `redaction-humaine-fr` si elle est installée | WeasyPrint + une police manuscrite choisie par l'utilisateur (non fournie, souvent « Personal Use Only ») | **Disponible** (`templates/skills/courrier-manuscrit/`) |

## Vérification d'autonomie avant toute installation (préflight, obligatoire)

Avant de lancer l'installation d'un outil (Tailscale, Infisical, un binaire...), l'agent vérifie qu'il a réellement les droits de la mener au bout. Règle **tout ou rien** : aucune installation entamée sans préflight passé, jamais de chantier abandonné à moitié.

1. **Suis-je en conteneur ?** `[ -f /.dockerenv ]` ou `grep -q docker /proc/1/cgroup 2>/dev/null`. Un agent conteneurisé (ex. déploiement Docker d'Hermès) ne peut généralement pas installer sur l'hôte.
2. **Ai-je les privilèges ?** `id -u` (root ?) ou `sudo -n true` (sudo sans mot de passe ?).
3. **Les prérequis de la cible sont-ils accessibles ?** Ex. pour Infisical auto-hébergé : `docker info` répond ; pour un paquet : `apt-get`/`brew` utilisable ; accès réseau sortant si téléchargement.
4. **Verdict AVANT d'agir** : si tout passe, dérouler l'installation. Sinon, s'arrêter là et dire clairement à l'utilisateur : « je ne suis pas assez autonome pour cette action, voici exactement ce qu'il te reste à faire », avec les commandes prêtes à copier-coller (à exécuter par l'utilisateur sur l'hôte, en SSH ou dans son terminal). Reprendre la main seulement une fois l'action faite, en re-vérifiant.

## Activation dans un projet

Geste de session (jamais un flag d'installation) : la skill assistant propose le catalogue au cadrage (Mode 5) et à l'adoption (Mode 6). Pour un outil à compte : poser la gouvernance dans `98_configuration/`, copier la skill en canon dans `98_configuration/skills/<outil>/`, dérouler l'onboarding de son `INSTALL.md` (création de compte guidée, secrets hors-bande), installer chez chaque agent, consigner au tableau d'équipement. Pour une skill utilitaire : copier, dérouler l'onboarding (prérequis), installer. Pour équiper un autre agent plus tard : entrée de handoff « Équiper un agent » (`templates/configuration/HANDOFF_INTERAGENT.md`).

Pour créer une nouvelle brique : partir de `templates/skills/_squelette/`.
