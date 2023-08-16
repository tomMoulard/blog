---
title: "AWS Sustainability"
date: 2023-08-16T13:00:00+01:00
author: Guillaume Moulard
url: /aws-sustainability
draft: false
type: post
tags:
  - blogging
  - AWS
  - sustainability
  - durabilité
  - sobriete
  - sobriété 
  - numerique
  - numérique 
  - Développement durable
categories:
  - state of the art
---


# AWS and Sustainability

Les objectifs affichés par AWS pour son [cloud AWS](https://sustainability.aboutamazon.com/products-services/the-cloud)

- 5 fois plus efficase d'un datacenter europeen
- 2,4 milliards. Des litres d'eau sont retournés aux communautés chaque année à partir de projets de réapprovisionnement achevés ou en cours
- En 2022, 90% de l'électricité consommée par Amazon était attribuable à une source d'énergie renouvelable

## customer carbon footprint tool 

AWS fournis dans la console un outil dans le service de [billing]( https://console.aws.amazon.com/billing/) un Customer Carbon Footprint Tool 

L'unité de mesure des émissions de carbone est la tonne métrique d'équivalent dioxyde de carbone (MTCO2e). Cette mesure tient compte de plusieurs gaz à effet de serre, notamment le dioxyde de carbone, le méthane et l'oxyde nitreux. Toutes les émissions de gaz à effet de serre sont converties en la quantité de dioxyde de carbone qui entraînerait un réchauffement équivalent.

Les données sur les émissions de carbone sont disponibles à partir de janvier 2020. Toute les services d'AWS ne son pas comptés dans ce dashboard. Toutes les valeurs figurant dans l'outil d'empreinte carbone du client sont arrondies au dixième de tonne le plus proche. Si les émissions ne sont pas arrondies à une dixième tonne, le rapport affichera 0.

La documentation du report: https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/what-is-ccft.html

### Services prisent en compte dans le dashboard:
- EC2
- S3

### Région prisent en compte :
- ? 

## well-architected
Aws a ajouté un piliers de la [AWS Well-Architected](https://aws.amazon.com/fr/architecture/well-architected/) 

1. Operational Excellence / Excellence opérationnelle
1. Security / Sécurité
1. Reliability / Fiabilité
1. Performance Efficiency / Efficacité des performances
1. Cost Optimization / Optimisation des coûts
1. Sustainability / Développement durable


Ce pilier Développement durable met l'accent sur la réduction des impacts sur l'environnement de l'exécution des charges de travail dans le cloud. Les points clés incluent un modèle de responsabilité partagée pour plus de durabilité, l'analyse des répercussions et l'optimisation de l'utilisation afin de limiter les ressources nécessaires et de réduire l'impact en aval.  

### Question du Well-Architected Tool
- SUS 1. Comment choisissez-vous les régions pour votre charge de travail ?
    - Options possible
        -   Choisir une région en fonction des exigences et des objectifs de durabilité de l'entreprise
- SUS 2. Comment aligner les ressources du cloud sur votre demande ?
    - Options possible
        - Mettre à l'échelle l'infrastructure de la charge de travail de façon
        dynamique
        - Optimiser le placement géographique des charges de travail en fonction
        de leurs exigences réseau
        - Aligner les SLA sur vos objectifs de durabilité
        - Arrêter la création et la maintenance des ressources inutilisées
        - Optimiser les ressources des membres de l'équipe pour les activités réalisées
        - Mise en oeuvre de la mise en mémoire tampon ou de la limitation pour aplanir la courbe de la demande
- SUS 3. Comment profiter des modèles logiciels et d'architecture afin de soutenir vos objectifs de durabilité ?
    - Options possible
        - Optimiser les logiciels et l'architecture pour les tâches asynchrones et prévues
        - Supprimez ou refactorisez les composants de charges de travail faiblement utilisés ou inutilisés.
        - Optimisez les sections de votre code les plus longues ou qui consomment le plus de ressources.
        - Optimiser l'impact sur les appareils et les équipements
        - Utilisez des modèles logiciels et des architectures qui soutiennent au mieux l'accès aux données et les modèles de stockage.
- SUS 4. Comment tirez-vous parti des politiques et des modèles de gestion des données pour soutenir vos objectifs de durabilité ?
    - Options possible
        - Mettre en œuvre une politique de classification des données
        - Utiliser des politiques pour gérer le cycle de vie de vos jeux de données 
        - Utiliser l'élasticité et l'automatisation pour étendre le stockage par blocs ou le système de fichiers
        - Supprimer les données inutiles ou redondantes
        - Utiliser des systèmes de fichiers partagés ou le stockage pour accéder aux données courantes
        - Réduire le mouvement des données dans les réseaux
        - Sauvegarder des données uniquement lorsqu'elles sont difficiles à recréer
        - Utiliser les technologies qui prennent en charge les modèles d'accès aux données et de stockage
- SUS 5. Comment choisissez-vous et utilisez-vous le matériel et les services du cloud dans votre architecture pour soutenir vos objectifs de durabilité ?
    - Options possible
        - Utiliser la quantité minimale de matériel pour répondre à vos besoins
        - Utiliser des types d'instance ayant le moins d'impact
        - Utiliser des services gérés
        - Optimiser votre utilisation des accélérateurs de calcul matériels
- SUS 6. Comment vos processus organisationnels soutiennent-ils vos objectifs de durabilité ?
    - Options possible
        - Adopter des méthodes qui peuvent rapidement présenter des améliorations en matière de durabilité
        - Garder votre charge de travail à jour
        - Augmenter l'utilisation de vos environnements de création
        - Utiliser des tests Device Farms gérés pour effectuer les tests



Question & reflexion

1. Comment un utilisateur du cloud AWS peut-il choisir le service et la région a utiliser pour minimisé l'impacte carbone de son infrastructure. 
1. Comment AWS peut-il etre 5 foix plus efficase d'un datacenter europeen puisque le cloud AWS est dans des datacenter mutualisé en france. 


Other link 
- https://aws.amazon.com/fr/sustainability/
- https://theshiftproject.org/category/thematiques/numerique/