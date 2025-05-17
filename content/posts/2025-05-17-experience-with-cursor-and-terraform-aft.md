---
title: "Notre expérience fascinante avec Cursor : Génération de code pour Terraform AFT"
date: 2025-05-17T00:00:00+02:00
draft: false
---

Dans le monde en constante évolution du développement logiciel, les outils d'intelligence artificielle pour la génération de code gagnent rapidement en popularité. Aujourd'hui, nous allons partager notre expérience passionnante avec Cursor, un outil de génération de code IA, que nous avons utilisé pour créer un cas d'utilisation intéressant avec Terraform AFT (Account Factory for Terraform).

## Qu'est-ce que Cursor ?

Cursor est un outil innovant qui permet aux développeurs d'écrire du code en utilisant des instructions en langage naturel. Il offre la possibilité de mettre à jour des classes ou des fonctions entières avec un simple prompt, promettant d'accélérer considérablement le processus de développement logiciel.

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

4. **Potentiel d'apprentissage** : Cette expérience nous a montré que des outils comme Cursor peuvent potentiellement être utilisés comme aide à l'apprentissage, en générant des exemples de code dans des langages ou des domaines moins familiers.

## Conclusion

Notre expérience avec Cursor pour générer du code pour un cas d'utilisation Terraform AFT a été à la fois fascinante et instructive. Bien que l'outil ait démontré sa capacité à produire rapidement du code structuré, notre expérience souligne également l'importance cruciale de l'expertise humaine dans le processus de développement.

À l'avenir, nous envisageons d'explorer davantage les capacités de Cursor, peut-être en collaboration avec des experts en Python et Terraform AFT pour valider et optimiser le code généré. Cette expérience nous a ouvert les yeux sur le potentiel des outils de génération de code IA, tout en nous rappelant que ces outils sont des assistants puissants, mais ne remplacent pas (encore) l'expertise et le jugement humains.

## Prompte

Ce blog post a été généré à partir du prompt suivant :

"Crée un blog post pour expliquer notre expérience très intéressante d'un outil de génération de code : cursor. Nous avons généré un use case très intéressant avec terraform AFT. Nous avons prompté la demande de génération du README, corrigé les étapes d'implémentation et généré le code de chaque implémentation spécifiée dans le README. Le code est disponible dans ce repo là: https://github.com/tomMoulard/aft-orange (il n'a jamais été testé par un humain, et je ne sais pas faire du python)"

Ce prompt illustre parfaitement comment nous avons utilisé Cursor pour générer non seulement le code, mais aussi la documentation de notre projet. Il met en évidence le potentiel de ces outils d'IA pour accélérer le développement de projets, même dans des domaines où nous n'avons pas d'expertise préalable. Cependant, il souligne également l'importance de la validation et des tests humains, surtout lorsqu'on travaille avec des technologies peu familières.