---
title: "Notre expérience fascinante avec Cursor : Génération de code pour Terraform AFT"
date: 2025-05-17T00:00:00+02:00
draft: false
author: Tom Moulard 
url: /experience-with-cursor-and-terraform-aft
draft: false
type: post
tags:
  - Cursor
  - Terraform
  - AFT
  - IA
  - Génération de code
categories:
  - Développement
  - Intelligence Artificielle
  - Outils
---

Dans le monde en constante évolution du développement logiciel, les outils d'intelligence artificielle pour la génération de code gagnent rapidement en popularité. Aujourd'hui, nous allons partager notre expérience passionnante avec Cursor, un outil de génération de code IA, que nous avons utilisé pour créer un cas d'utilisation intéressant avec Terraform AFT (Account Factory for Terraform).

## Qu'est-ce que Cursor ?

[Cursor](https://www.cursor.so) est un outil innovant qui permet aux développeurs d'écrire du code en utilisant des instructions en langage naturel. Il offre la possibilité de mettre à jour des classes ou des fonctions entières avec un simple prompt, promettant d'accélérer considérablement le processus de développement logiciel.



## Notre projet : Terraform AFT

Pour tester les capacités de Cursor, nous avons décidé de l'utiliser pour générer un cas d'utilisation avec Terraform AFT. Terraform AFT est un outil puissant pour la gestion des comptes AWS à grande échelle, et nous étions curieux de voir comment Cursor pourrait nous aider dans ce processus.

## Notre approche

1. **Génération du README** : Nous avons commencé par demander à Cursor de générer un README pour notre projet. Cela nous a donné une structure de base et un aperçu de ce que notre projet devrait accomplir.

2. **Correction des étapes d'implémentation** : Après avoir examiné le README généré, nous avons apporté des corrections aux étapes d'implémentation pour nous assurer qu'elles correspondaient à nos besoins spécifiques.

3. **Génération du code** : Pour chaque étape d'implémentation spécifiée dans le README, nous avons utilisé Cursor pour générer le code correspondant.

## Résultats

Le code généré est disponible dans ce repository GitHub : [https://github.com/tomMoulard/aft-orange](https://github.com/tomMoulard/aft-orange)

Il est important de noter que ce code n'a jamais été testé par un humain, et qu'il contient du Python, un langage avec lequel nous ne sommes pas familiers. Cela soulève des questions intéressantes sur la fiabilité et l'utilisabilité du code généré par l'IA, en particulier dans des domaines où l'expertise humaine est limitée.

## Réflexions et observations

1. **Rapidité de génération** : Cursor nous a permis de générer rapidement un squelette de projet et du code pour notre cas d'utilisation Terraform AFT.

2. **Qualité du code** : Bien que nous n'ayons pas pu tester le code en raison de notre manque d'expertise en Python, la structure et la logique semblaient cohérentes à première vue.

3. **Limitations** : L'absence de tests humains et notre manque de familiarité avec le langage généré soulignent l'importance de l'expertise humaine dans la vérification et l'optimisation du code généré par l'IA.

4. **Temps de développement** : Malgré l'utilisation d'un outil d'IA, nous avons quand même mis environ une heure pour générer l'ensemble du code du projet. Cela montre que même avec des outils avancés comme Cursor, un certain temps d'interaction et de réflexion reste nécessaire.

5. **Potentiel d'apprentissage** : Cette expérience nous a montré que des outils comme Cursor peuvent potentiellement être utilisés comme aide à l'apprentissage, en générant des exemples de code dans des langages ou des domaines moins familiers.

## Retours d'expérience de la communauté

En explorant davantage le sujet, nous avons découvert [un post Reddit fascinant](https://www.reddit.com/r/cursor/comments/1kk1mrz/10_brutal_lessons_from_6_months_of_vibe_coding/) partageant 10 leçons brutales tirées de 6 mois d'utilisation intensive de [Cursor](https://www.cursor.so). Voici les points essentiels qui résonnent particulièrement avec notre expérience :

1. **Penser comme un chef de projet, pas comme un "Prompt Monkey"** : Commencer par rédiger un véritable document d'exigences produit, qui servira de boussole face à la perte de contexte rapide de l'IA.

2. **Documenter le déploiement immédiatement** : Anticiper les étapes de mise en production, car on oublie facilement les détails techniques, et Cursor aussi.

3. **Git est indispensable** : Utiliser rigoureusement le contrôle de version, car Cursor peut casser des éléments critiques.

4. **Privilégier des conversations courtes et ciblées** : Éviter d'accumuler des centaines de messages dans une seule conversation. Toujours préciser : "Corrige X uniquement. Ne change rien d'autre."

5. **Planifier avant de coder** : Élaborer le flux complet de la fonctionnalité d'abord, choisir une approche, puis passer à l'exécution dans Cursor.

6. **Nettoyer régulièrement le code** : Effectuer un nettoyage hebdomadaire des fichiers temporaires et de la structure des dossiers.

7. **Utiliser Cursor pour des tâches spécifiques** : Ne pas demander à Cursor de construire l'application entière, mais plutôt des éléments d'interface, des blocs logiques ou des refactoring contrôlés.

8. **Diagnostiquer avant de corriger** : Faire d'abord enquêter le modèle, puis lui demander de suggérer plusieurs solutions avant d'en implémenter une.

9. **La dette technique s'accumule à vitesse IA** : Bien que le développement soit rapide, prendre le temps de refactoriser régulièrement.

10. **Rester le capitaine** : Cursor n'est pas là pour "coder à votre place" mais pour co-piloter. C'est à vous de diriger la machine.

Ces retours d'expérience plus approfondis soulignent l'importance de garder un œil critique lors de l'utilisation de ces outils. Notre expérience d'une heure avec Cursor n'est qu'un aperçu des possibilités et des défis que ces technologies représentent pour les développeurs. La citation finale du post résume bien cette philosophie : "Restez caféiné. Dirigez les machines."

## Conclusion

Notre expérience avec Cursor pour générer du code pour un cas d'utilisation Terraform AFT a été à la fois fascinante et instructive. Bien que l'outil ait démontré sa capacité à produire rapidement du code structuré, notre expérience souligne également l'importance cruciale de l'expertise humaine dans le processus de développement.

À l'avenir, nous envisageons d'explorer davantage les capacités de Cursor, peut-être en collaboration avec des experts en Python et Terraform AFT pour valider et optimiser le code généré. Cette expérience nous a ouvert les yeux sur le potentiel des outils de génération de code IA, tout en nous rappelant que ces outils sont des assistants puissants, mais ne remplacent pas (encore) l'expertise et le jugement humains.

## Prompte

Ce blog post a été généré à partir du prompt suivant :

"Crée un blog post pour expliquer notre expérience très intéressante d'un outil de génération de code : cursor. Nous avons généré un use case très intéressant avec terraform AFT. Nous avons prompté la demande de génération du README, corrigé les étapes d'implémentation et généré le code de chaque implémentation spécifiée dans le README. Le code est disponible dans ce repo là: https://github.com/tomMoulard/aft-orange (il n'a jamais été testé par un humain, et je ne sais pas faire du python)"

Ce prompt illustre parfaitement comment nous avons utilisé Cursor pour générer non seulement le code, mais aussi la documentation de notre projet. Il met en évidence le potentiel de ces outils d'IA pour accélérer le développement de projets, même dans des domaines où nous n'avons pas d'expertise préalable. Cependant, il souligne également l'importance de la validation et des tests humains, surtout lorsqu'on travaille avec des technologies peu familières.
