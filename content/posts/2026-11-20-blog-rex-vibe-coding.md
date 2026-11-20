---
title: "Vibe coding : le REX d'un vieux bonhomme"
date: 2026-11-20
tags: [vibe coding, IA, Claude Code, wikipedia2book, pi-appliance]
---

# Vibe coding : le REX d'un vieux bonhomme

J'ai commencé l'informatique à une époque où le HTML n'existait que dans le laboratoire de Tim Berners-Lee, au CERN de Genève. Depuis, j'ai vu passer beaucoup de « révolutions » qui allaient tuer le métier de développeur. Aucune ne l'a tué ; toutes l'ont changé. Le vibe coding est la dernière en date, et c'est la première fois que je me sens vraiment *augmenté*. Voici mon retour d'expérience, sans enthousiasme béat ni catastrophisme.

## L'année passée : tâtonnements

[[À COMPLÉTER : tes expériences de l'année passée en génération de code — outils essayés (ChatGPT, Copilot, autre ?), ce qui marchait, ce qui ne marchait pas, une anecdote. Exemple de trame ci-dessous, à corriger.]]

Pendant un an, j'ai utilisé l'IA comme on utilise un collègue un peu trop sûr de lui : je lui demandais une fonction, je la copiais-collais dans mon éditeur, je corrigeais ce qui ne compilait pas, et je recommençais. Ça dépannait. Ça faisait gagner du temps sur le code répétitif. Mais dès que le projet dépassait quelques fichiers, l'IA perdait le fil : elle ne voyait pas le reste du code, elle inventait des fonctions qui n'existaient pas, et je passais autant de temps à relire qu'à écrire.

La leçon de cette année-là : le problème n'était pas la qualité du code généré, c'était l'absence de cadre. Je demandais du code sans avoir dit clairement ce que je voulais.

## Wikipedia2Book : douze jours, 370 modifications

Le déclic est venu en novembre 2026 avec [Wikipedia2Book](https://wikipedia2book.toolforge.org/).

Le point de départ était modeste. Wikipédia permettait autrefois de rassembler des articles dans un « livre » et de le télécharger en PDF. Cette fonction a été arrêtée en 2017. Moi, je voulais juste réunir en un seul PDF les articles que j'avais écrits sur les épaves de la rade de Saint-Pierre, en Martinique, coulées lors de l'éruption de la montagne Pelée en 1902. L'idée tenait en une ligne : une sorte de `cat pdf2 >> pdf1`.

Sauf qu'avec ces outils, ajouter une fonctionnalité de plus est si facile que j'en ai ajouté beaucoup : couverture, table des matières, chapitres, huit projets Wikimédia, douze langues, volumes… Oups ! C'est peut-être trop !

Les chiffres :

- première ligne écrite le **7 novembre 2026**, à partir d'une spécification d'abord rédigée avec ChatGPT ;
- version 1.0 en ligne sur Toolforge le **12 novembre** ;
- en douze jours, **plus de 370 modifications et 13 versions** ;
- environ **12 000 requêtes** reçues entre le 12 et le 17 novembre.

J'ai raconté l'outil lui-même dans un billet sur [Diff](https://diff.wikimedia.org/), le blog de la communauté Wikimédia. Ici, je veux parler de la façon de travailler.

Ce qui a changé par rapport à l'année d'avant, c'est le harnais : Claude Code n'est pas une fenêtre de discussion, c'est un environnement où l'IA lit tout le code, le modifie, lance les tests et vérifie le résultat dans un navigateur. Une fonctionnalité décrite le matin est en général écrite, testée, documentée et en ligne le soir.

Vitesse ne veut pas dire raccourcis : tout est dans un [dépôt public](https://github.com/gmoulard/wikipedia2book/), chaque modification est un commit lisible, une trentaine de fichiers de tests tournent avant chaque déploiement, et la spécification suit le code.

## Ma méthode aujourd'hui, en cinq étapes

Avec Wikipedia2Book, puis avec mon projet suivant, [pi-appliance](https://www.pi-appliance.com/) (transformer un Raspberry Pi en petit serveur personnel, pour le grand public), j'ai fini par stabiliser une manière de faire. Elle tient en cinq étapes.

### 1. La spécification du produit, dans un fichier Markdown

Tout commence par un fichier `specification.md` : à qui s'adresse le produit, ce qu'il doit faire, ce qu'il ne fait pas. Pas de code, pas de choix techniques au départ : le *quoi* et le *pour qui*. Pour pi-appliance, la première phrase qui compte est : « le public visé est le grand public ; tout se fait depuis une console web, sans ligne de commande ».

Ce fichier est la référence. Il vit dans le dépôt, à côté du code, et l'IA le lit avant chaque modification.

### 2. Demander à Claude de me poser des questions

C'est l'étape que je sous-estimais le plus. Plutôt que de demander « écris-moi ça », je demande : « pose-moi toutes les questions nécessaires pour préciser cette spécification ».

Et les questions tombent : quel matériel minimum ? Que se passe-t-il si l'utilisateur oublie son mot de passe ? Les mises à jour sont-elles automatiques ? Faut-il demander avant d'effacer les données d'une application désinstallée ?

Chaque réponse devient une décision, notée dans la spécification. Sur pi-appliance, cette étape a produit **une trentaine de décisions** avant la première ligne de code : Go pour la console, Pi 5, 4, 3 B+ et Zero 2 W, point d'accès Wi-Fi au premier démarrage, mises à jour proposées mais jamais automatiques, sauvegarde chaque nuit, etc.

L'IA est bien meilleure pour trouver les trous d'une spécification que pour deviner ce que j'ai en tête.

### 3. Une TODO par thèmes, dans un fichier Markdown

Une fois la spécification stable, je fais construire un `TODO.md`, découpé par thèmes et dans l'ordre de construction. Pour pi-appliance :

- **0. Ménage du dépôt** — le projet existait depuis 2018 sous forme de prototypes ; il fallait retirer l'ancien, changer les secrets qui traînaient dans l'historique, choisir une licence (AGPL-3.0) ;
- **1. Décisions** — toutes les réponses de l'étape 2, cochées une à une ;
- **2. Étape 1 — Local** : l'image système, la console, la marketplace d'applications (Nextcloud, site web, DokuWiki, Etherpad, WireGuard) ;
- **3. Étape 2 — Internet** : l'adresse `<nom>.pi-appliance.com`, l'ouverture vers internet, le relais quand la box ne coopère pas ;
- **4. Étape 3 — Le reste** : sauvegardes, mises à jour, alertes… ;
- **5. Le site www.pi-appliance.com**.

Chaque ligne a un identifiant (`TODO-2.51`…) et renvoie à la section de la spécification qu'elle réalise. Quand une tâche est faite, elle est cochée et la spécification passe de « cible » à « réalisé ».

### 4. Laisser Claude traiter tous les thèmes en sous-tâches

Là, je lâche la bride : je demande à Claude de prendre un thème entier et de le traiter en sous-tâches, chacune dans sa propre session, avec ses tests et son commit.

C'est spectaculaire. C'est aussi là que **ça brûle tous mes jetons**. Plusieurs agents qui lisent la spécification, le code et la TODO, qui lancent les tests, qui se relisent : la facture d'usage grimpe vite. C'est le vrai coût de la méthode, et il faut le savoir avant de se lancer.

Pour rendre ça tenable, j'ai écrit des *skills* partagés entre mes projets (règles de style, synchronisation de la spécification, publication d'une version) : l'IA ne réinvente pas les règles à chaque session.

### 5. Je teste, et j'ajoute des entrées dans la TODO

Puis je reprends la main. Je teste, pour de vrai : sur de vrais livres pour Wikipedia2Book, sur un vrai Raspberry Pi pour pi-appliance. Et chaque problème, chaque idée devient une nouvelle ligne dans la TODO. La boucle repart à l'étape 4.

C'est d'ailleurs là que j'en suis sur pi-appliance : près d'une centaine de tâches cochées, une quarantaine ouvertes, et j'ai décidé d'**arrêter d'ajouter des fonctionnalités** tant que tout n'a pas été éprouvé sur un vrai Pi. Le code écrit par l'IA passe les tests ; le matériel réel, lui, ne lit pas la spécification.

## Ce que j'en retiens

- **Je fais plus d'ingénierie logicielle que de code.** Je passe moins de temps à écrire et plus de temps à décider, vérifier, garder l'ensemble cohérent.
- **La spécification est le vrai code source.** Si elle est floue, l'IA produit du flou, très vite.
- **Faire poser les questions par l'IA** est l'astuce la plus rentable que j'aie trouvée.
- **La vitesse est réelle, le coût aussi.** Les jetons, mais surtout le risque d'empiler des fonctionnalités parce que c'est facile. Savoir s'arrêter est une compétence.
- **Les tests sur le terrain restent humains.** L'IA vérifie que le code fait ce qui est écrit ; moi, je vérifie que ce qui est écrit sert à quelque chose.

Il faut apprendre à se servir de ces nouveaux outils. Mais apprendre de nouveaux outils, c'est mon quotidien d'informaticien depuis le début. Le vieux bonhomme a encore de beaux jours devant lui.
