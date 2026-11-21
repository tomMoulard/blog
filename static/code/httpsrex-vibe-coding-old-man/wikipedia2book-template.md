TODO — Wikipedia2Book

«Backlog et consignes de travail pour Claude Code.

État initial repris du TODO historique : 18/11/2026.
Version de production Toolforge indiquée : 1.13.1.

Les éléments historiques sont conservés. Les tâches déjà réalisées ne doivent pas être recommencées.»

1. Instructions pour Claude Code

1.1 Rôle

Tu es responsable de l'analyse, de la réalisation, de l'intégration et de la validation des tâches de ce projet.

Avant toute intervention :

1. Lire ce fichier en entier.
2. Examiner le code et la documentation concernés.
3. Vérifier les issues et pull requests associées si nécessaire.
4. Identifier les dépendances et les éventuels travaux déjà réalisés.
5. Ne pas refaire une fonctionnalité déjà présente.

1.2 Orchestration des agents

Tu choisis le mode d'exécution adapté au travail :

- Exécution directe pour une tâche simple.
- Sous-agent spécialisé pour une tâche autonome et bien délimitée.
- Agent Teams lorsque plusieurs tâches indépendantes nécessitent une coordination entre agents.

Avant de paralléliser :

- Identifier les dépendances.
- Définir précisément le périmètre de chaque agent.
- Éviter que plusieurs agents modifient les mêmes fichiers.
- Garder l'intégration et la validation finales sous la responsabilité de l'agent coordinateur.

Ne pas paralléliser artificiellement des tâches dépendantes.

1.3 Qualité et validation

Pour chaque modification :

- Ajouter ou adapter les tests.
- Lancer les tests pertinents.
- Vérifier les éventuelles régressions.
- Distinguer les tests automatisés des essais sur Toolforge et des validations manuelles.
- Ne jamais déclarer une tâche totalement terminée si une validation nécessaire reste à faire.

1.4 Mise à jour du TODO

Après chaque intervention :

- Conserver les références et les informations historiques utiles.
- Conserver les identifiants existants.
- Mettre à jour les statuts et les résultats.
- Ajouter les nouvelles tâches avec un identifiant stable.
- Ne jamais supprimer une tâche sans expliquer pourquoi.
- Signaler les blocages et les dépendances.
- Mettre à jour la synthèse.

2. Règles de statut

- "[ ]" À faire.
- "[~]" En cours.
- "[x]" Réalisé et vérifié au niveau indiqué.
- "[!]" Bloqué.

Une tâche peut être réalisée côté code tout en conservant des validations manuelles ouvertes.

Dans ce cas, garder la tâche principale et détailler les validations restantes dans ses sous-tâches.

3. Réglages et actions manuelles

W2B-M1 — Auteur des commits en session cloud

- Statut : "[x]"
- Nature : Configuration manuelle
- Date de validation : 18/11/2026

Variables définies dans l'environnement cloud « W2B » :

- "GIT_AUTHOR_NAME"
- "GIT_AUTHOR_EMAIL"
- "GIT_COMMITTER_NAME"
- "GIT_COMMITTER_EMAIL"

Vérification effectuée avec "git var GIT_AUTHOR_IDENT" et "git var GIT_COMMITTER_IDENT".

Les variables d'environnement prennent le pas sur "user.name = Claude" dans "/root/.gitconfig".

Référence : paramètres "release" du "CLAUDE.md".

W2B-M2 — Secrets GitHub du déploiement

- Statut : "[~]"
- Nature : Configuration manuelle
- Dernière vérification : 18/11/2026

Secrets présents dans les secrets du dépôt GitHub :

- "WIKIPEDIA2BOOK_OAUTH_CLIENT_SECRET"
- "WIKIPEDIA2BOOK_MONITOR_TOKEN"
- "WIKIPEDIA2BOOK_OAUTH_CLIENT_ID"

Vérification effectuée avec "gh secret list".

Reste à faire :

- [ ] Poser les trois valeurs sur Toolforge au prochain déploiement.
- [ ] Vérifier leur bonne prise en compte par le déploiement.

Le job "deploy" ne déclare pas d'environnement GitHub particulier.

W2B-M3 — Visibilité sur les wikis

- Statut : "[~]"
- Nature : Action manuelle et communication externe
- Référence : "communication/todo-mediawiki2latex-visibility.md"

Objectif : faire connaître Wikipedia2Book sur les wikis concernés, en signalant les conflits d'intérêts lorsque nécessaire.

Historique au 18/11/2026 :

- 17 publications réalisées.
- Liste et diffs conservés dans "communication/communication-brouillons.md".
- Action 5 : publication sur "it.wikipedia" depuis le compte CapitaineCanette.
- Action 15 : commentaire sur https://phabricator.wikimedia.org/T224922#12575282.
- Action 14 : dépôt de https://phabricator.wikimedia.org/T445303.
- Action 19 : billet Diff soumis à relecture.
- Actions 20a et 20b : présentations proposées à la WikiConvention francophone et à Wikimania 2027.
- Élément Wikidata créé : https://www.wikidata.org/wiki/Q142203097.
- Déclarations Wikidata ajoutées une par une après un avertissement du filtre n° 11.
- Élément ajouté à la fiche Toolhub.
- "en.wikipedia", page Wikipedia:Books complétée le 18/11/2026 : https://en.wikipedia.org/w/index.php?diff=1386351738&oldid=1383219292.

Reste à faire :

- [ ] Se connecter à Toolhub et terminer l'action correspondante.
- [ ] Signaler le conflit d'intérêts sur la page de discussion de Wikipedia:Books.
- [ ] Suivre les actions qui attendent une réponse.
- [ ] Mettre à jour le fichier de suivi après chaque réponse ou publication.

W2B-M4 — Connecteur GitHub du plugin Claude

- Statut : "[x]"
- Nature : Configuration
- Date : 18/11/2026

Le connecteur "plugin:github:github" échouait avec :

"Authorization header is badly formatted"

Cause : variable "GITHUB_PERSONAL_ACCESS_TOKEN" absente.

Décision : désactivation du plugin, les outils "gh" suffisant au workflow actuel.

Commande exécutée :

"claude plugin disable github@synced --scope user"

Pour le réactiver ultérieurement :

1. Définir "GITHUB_PERSONAL_ACCESS_TOKEN".
2. Réactiver avec "claude plugin enable github@synced".

4. Nouvelles fonctionnalités

W2B-F1 — Langues de Wikilivres

- Statut : "[x]"
- Version : 1.12.4
- Validation : 17/11/2026

Langues acceptées : DE, IT, JA, ID, HI, HU, ZH, PL, EN.

Exemple initial : https://de.wikibooks.org/wiki/Tauchen_in_Hilfeleistungsunternehmen:_-Teil_D-_Tauchermedizin

Vérification sur Toolforge dans le navigateur et par l'API. PDF généré.

W2B-F2 — Langues des autres projets Wikimedia

- Statut : "[x]"
- Validation : 17/11/2026

Projets acceptés :

- Wikipédia
- Wikiversité
- Wikivoyage
- Wikisource
- Wikiquote
- Wiktionnaire
- Wikinews

Exemple initial : https://fr.wikiversity.org/wiki/D%C3%A9veloppement_durable

Vérification sur Toolforge dans le navigateur et par l'API.

W2B-F3 — Inventaire des pages citant mediawiki2latex

- Statut : "[x]"
- Date : 17/11/2026

Liste établie dans "communication/todo-mediawiki2latex-visibility.md".

Recherche effectuée sur 19 wikis.

W2B-F4 — Analyse des possibilités de visibilité sur les wikis

- Statut : "[x]"
- Date : 17/11/2026

Pour chaque ligne de "communication/todo-mediawiki2latex-visibility.md", les possibilités d'ajout d'une information sur Wikipedia2Book ont été étudiées.

Les publications proprement dites restent suivies dans W2B-M3.

W2B-F5 — Conservation du JSON de génération

- Statut : "[x]"
- Version : 1.12.5

Conserver le JSON de la demande de génération en complément du journal, avec téléchargement à côté de celui-ci.

W2B-F6 — Tableau des adresses refusées

- Statut : "[x]"
- Version : 1.12.5

Conserver un tableau des adresses refusées par Wikipedia2Book dans la page d'administration.

W2B-F7 — Personnalisation des première et dernière pages

- Statut : "[x]"
- Version : 1.12.5

Permettre de proposer des couleurs pour la première et la dernière page et d'y afficher le logo Wikipédia.

W2B-F8 — Intégration de pages HTML

- Statut : "[x]"
- Version : 1.13.0

Accepter une adresse de page HTML, la convertir en PDF côté serveur et intégrer le PDF au livre.

Fonction disponible à l'étape Organisation, dans le champ d'adresse.

W2B-F9 — Renommage des documents importés

- Statut : "[x]"
- Version : 1.13.0

Permettre de renommer une photo ou un document importé afin que le nom du fichier ne soit pas utilisé à l'impression.

Titre modifiable à l'étape Organisation.

W2B-F10 — Compilations de Wikilivres

- Statut : "[x]"
- Version : 1.13.0

Accepter les compilations de Wikilivres ("Wikilivres:Compilations/…") et interpréter comme un livre toute page constituée de lignes ": [[…]]".

W2B-F11 — Logos et pagination

- Statut : "[x]"
- Version : 1.13.0

Modifications réalisées :

- Logo de licence à fond transparent, en conservant les fichiers d'origine.
- Dernière page sans numéro.
- Logo Wikipédia en bas à droite.
- Logo Wikipedia2Book sur la couverture et la dernière page, puis retiré à la demande.

5. Améliorations et suivi externe

W2B-A1 — Caractères chinois rares dans le PDF officiel de Wikisource

- Statut : "[~]"
- Nature : Suivi externe
- Signalement : 18/11/2026
- Référence : https://phabricator.wikimedia.org/T445303

Problème : caractères chinois rares dans le PDF officiel de Wikisource.

Signalement effectué auprès de Wikimédia, avec les étiquettes Proton et All-and-every-Wikisource.

Reste à faire :

- [ ] Suivre les réponses sur Phabricator.
- [ ] Mettre à jour la spécification, section 18, si une réponse apporte une solution ou une information nouvelle.

6. Bugs et issues GitHub

W2B-B1 — Formulaire d'issue BUG

- Statut : "[x]"
- Date : 20/11/2026
- Fichier : ".github/ISSUE_TEMPLATE/bug.yml"

Type d'issue BUG créé avec les champs :

- "platform"
- "gravity"
- Fichier JSON
- Texte et capture d'écran

W2B-B2 — Analyse et correction des issues existantes

- Statut : "[~]"
- Date d'analyse : 20/11/2026

Issues examinées :

- #2 : PDF d'une page renommée ; redirection suivie.
- #3 : spécification technique numérotée à partir de 1.
- #4 : page web convertie ; second rendu sans styles ; erreur qui nomme le document.

Reste à faire :

- [ ] Vérifier que les correctifs sont intégrés dans le code.
- [ ] Publier une version contenant les correctifs.
- [ ] Vérifier les issues après déploiement.
- [ ] Fermer les issues une fois les correctifs effectivement publiés.

7. Règles de maintenance du backlog

- Les tâches terminées restent dans le fichier pour conserver l'historique.
- Les dates et versions sont conservées.
- Les actions manuelles et les actions automatisables sont distinguées.
- Les validations Toolforge ne sont pas assimilées à de simples tests locaux.
- Les suivis externes restent ouverts tant qu'une réponse ou une action attendue n'a pas été traitée.
- Toute nouvelle fonctionnalité reçoit un identifiant stable.

8. Synthèse

La synthèse doit être recalculée à partir des statuts des tâches et sous-tâches.

Ne pas compter comme totalement terminée une tâche qui conserve des validations ou actions obligatoires ouvertes.

Dernière version de production documentée dans le TODO d'origine : 1.13.1.