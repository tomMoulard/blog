---
title: "AWS Sustainability"
date: 2023-12-12T13:00:00+01:00
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
  - GreenIT
categories:
  - state of the art
---

# Sustainability / développement durable  

Comment définir la sustainability 
Pour les nation unis "sustainable development" c'est 17 objectifs a vers lesquelles nos sociétés doivent tendres [EN](https://www.un.org/sustainabledevelopment/) / [FR](https://www.un.org/sustainabledevelopment/fr/)
« Les objectifs de développement durable sont un appel à l’action de tous les pays – pauvres, riches et à revenu intermédiaire – afin de promouvoir la prospérité tout en protégeant la planète. Ils reconnaissent que mettre fin à la pauvreté doit aller de pair avec des stratégies qui développent la croissance économique et répondent à une série de besoins sociaux, notamment l’éducation, la santé, la protection sociale et les possibilités d’emploi, tout en luttant contre le changement climatique et la protection de l’environnement. »

## Le numérique représente pour l'instant 3 % de la consommation d’énergie finale

En France, la consommation énergétique est de 476 TWh et l’électricité représente environ 25 % de l’énergie finale. Les prévisions de GreenIT d'augementations de 50% du besoin electrique sont forte de 3% en 2020 a entre 5% et 6% en 2025.
 
GreenIT estimait qu’en 2015 le numérique consommait environ 56 TWh, ce qui représente environ 12 % de la consommation électrique du pays et 3 % de la consommation d’énergie finale.

Sur les 56 TWh :
- 43 TWh pour les équipements utilisateurs à usage personnel ou professionnel (ordinateurs, tablettes, smartphones, box d’accès à internet, etc.)
- 3,5 TWh pour le cœur du réseau (composants techniques pour relier les datacenters aux usagers, 3G, 4G, etc.)
- 10 TWh pour les « datacenters » => 2.1% de l'électricité total !

[![](/img/2023/sus/r1-conso-energie-electronique-4b5ae.jpg) 

source : 

- [www.notre-environnement.gouv.fr/rapport-sur-l-etat-de-l-environnement](https://www.notre-environnement.gouv.fr/rapport-sur-l-etat-de-l-environnement/themes-ree/pressions-exercees-par-les-modes-de-production-et-de-consommation/prelevements-de-ressources-naturelles/energie/article/numerique-et-consommation-energetique)
- [Empreinte environnementale du numérique mondial](https://www.greenit.fr/etude-empreinte-environnementale-du-numerique-mondial/) 
- [iNUM : impacts environnementaux du numérique en France](https://www.greenit.fr/impacts-environnementaux-du-numerique-en-france/)
    

[![](/img/2023/sus/LeMondeSansFinImpactDigital.jpg)Le monde sans fin - impacte du numérique](/img/2023/sus/Le-monde-sans-fin_impacte-digital.pdf)

## Eco-conception

Si une large part de l'impactes viens des terminaux, c'est ici qu'une grosse partie des gains doivent être fait. Diminuer la fabrication de téléphone portable, d'ordinateur physique d'IoT et d'écrans de toutes sorte est très impactant.  

En tant qu'utilisateur : chercher a minimisé le nombre de matériel utilisé, a en augmenter la durée de vie, a chercher une seconde vie au matériel  

En tant que professionnelle il faut chercher à ne générer ni obsolescence ni nouveau besoin. Avoir une démarche d'éco-conception de nos usages / solutions / services / logiciel c'est chercher à ne pas générer de renouvellement ou d'achat chez les utilisateurs.

# AWS and Sustainability

Les objectifs affichés par AWS pour son [cloud AWS](https://sustainability.aboutamazon.com/products-services/the-cloud)

- 5 fois plus efficace d'un datacenter européen
- 2,4 milliards. Des litres d'eau sont retournés aux communautés chaque année à partir de projets de réapprovisionnement achevés ou en cours
- En 2022, 90% de l'électricité consommée par Amazon était attribuable à une source d'énergie renouvelable

Les outils proposés par AWS pour que ses clients utilisent au mieux les services d’AWS  
## customer carbon footprint tool 

AWS fournis dans la console un outil dans le service de [billing]( https://console.aws.amazon.com/billing/) un Customer Carbon Footprint Tool. Des outils similaires existe chez [Azure]( https://learn.microsoft.com/en-us/power-bi/connect-data/service-connect-to-emissions-impact-dashboard) et chez [GCP]( https://cloud.google.com/carbon-footprint/docs/methodology)

L'unité de mesure des émissions de carbone est la tonne métrique d'équivalent dioxyde de carbone (MTCO2e). Cette mesure tient compte de plusieurs gaz à effet de serre, notamment le dioxyde de carbone, le méthane et l'oxyde nitreux. Toutes les émissions de gaz à effet de serre sont converties en la quantité de dioxyde de carbone qui entraînerait un réchauffement équivalent.

Les données sur les émissions de carbone sont disponibles à partir de janvier 2020. Toute les services d'AWS ne sont pas comptés dans ce dashboard. Toutes les valeurs figurant dans l'outil d'empreinte carbone du client sont arrondies au dixième de tonne le plus proche. Si les émissions ne sont pas arrondies à une dixième tonne, le rapport affichera 0.

La documentation du report: https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/what-is-ccft.html

### Services prisent en compte dans le dashboard

- EC2
- S3

## well-architected
AWS a ajouté un piliers a sa méthodologie d'optimisation des architectures technique [AWS Well-Architected](https://aws.amazon.com/fr/architecture/well-architected/) 

1. Operational Excellence / Excellence opérationnelle
1. Security / Sécurité
1. Reliability / Fiabilité
1. Performance Efficiency / Efficacité des performances
1. Cost Optimization / Optimisation des coûts
1. Sustainability / Développement durable

Ce pilier Développement durable met l'accent sur la réduction des impacts sur l'environnement de l'exécution des charges de travail dans le cloud. Les points clés incluent un modèle de responsabilité partagée pour plus de durabilité, l'analyse des répercussions et l'optimisation de l'utilisation afin de limiter les ressources nécessaires et de réduire l'impact en aval.  

### Les question du Well-Architected Tool
- SUS 1. Comment choisissez-vous les régions pour votre charge de travail ?
    - Options possible
        -   Choisir une région en fonction des exigences et des objectifs de durabilité de l'entreprise
- SUS 2. Comment aligner les ressources du cloud sur votre demande ?
    - Options possible
        - Mettre à l'échelle l'infrastructure de la charge de travail de façon dynamique
        - Optimiser le placement géographique des charges de travail en fonction de leurs exigences réseau
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

# Comment choisir le bon service, la bonne région

## Les Régions AWS

AWS ne communique pas sur les indicateurs détaillés de performance de ses régions, de ses datacenters. Ils ne communiquent que sur une valeur mondiale !!!

Photo de décembre 2023

[![](/img/2023/sus/awsDCdec23.jpg)](https://www.climatiq.io/blog/measure-greenhouse-gas-emissions-carbon-data-centres-cloud-computing)

Source : https://www.climatiq.io/blog/measure-greenhouse-gas-emissions-carbon-data-centres-cloud-computing

## Les services AWS

Quand l'impact carbone d'un produit n'est pas donné par AWS. La proposition est de chercher l'économie financière. Les outils d’optimisation qui propose d’utiliser des instances plus petites sont dans bien des cas utiles pour identifier des gains en terme d’impact carbone

Quelles réglés d'utilisation de l'infrastructure :
- Questionner les usages, les RPO et les RTO pour n'utiliser que des infrastructures nécessaires.  
- Utiliser des services en mode serverless autant que possible. 
- Utiliser quand cela est possible des instances SPOT pour n'utiliser que du matériel sous-utilisé.
- La taille : lorsque vous utilisez des VM (machines virtuelles), pensez toujours à adapter la taille de la VM à vos besoins d’application, puis surveillez et réduisez si nécessaire.
- Les processeurs basés sur ARM : envisagez d’utiliser des processeurs ARM (comme le processeur AWS Graviton, les processeurs Azure Ampere Altra basés sur ARM, les processeurs GCP Ampere Altra également, etc.) chaque fois que votre application prend en charge la technologie ARM (pour de meilleures performances et des coûts plus bas).
- Concernant les ressources inutilisées : surveillez et éteignez (voire supprimez) les ressources inutilisées ou inactives (VM, bases de données, etc.). 
- Concernant les GPU : utilisez les GPU uniquement pour les tâches considérées comme plus efficaces que les CPU (telles que l’apprentissage automatique, le rendu graphique, le transcodage, etc.).
- Le démarrage et l’arrêt automatique des VM : utilisez les capacités de planification (SSM Automation et [Instance scheduler](https://aws.amazon.com/solutions/implementations/instance-scheduler-on-aws/) pour AWS, le démarrage / arrêt des VM Azure, le démarrage et l’arrêt des instances de machines virtuelles GCP, etc.) pour contrôler le comportement de vos VM de charge de travail.
- Mise à l’échelle automatique : utilisez les capacités intégrées au cloud pour mettre à l’échelle horizontalement en fonction de la charge de votre application.
- Réseau de diffusion de contenu : utilisez un CDN (comme Amazon CloudFront, Azure Content Delivery Network, Google Cloud CDN, etc.) pour réduire la quantité de trafic client vers vos services exposés publiquement.
- Des ressources à jour : lorsque vous utilisez des VM, choisissez toujours les derniers types de famille de VM et le type de stockage par bloc pour répondre aux besoins de votre application et respecter la politique de votre organisation.

# Outil de management 

Il existe des outils externes a AWS qui peuvent avoir une pertinence en plus de ce que propose en natif AWS.

- https://www.cloudcarbonfootprint.org/

# Question & Réflexion

1. La vision seul de l'impacte carbone est-elle suffisante ? Les nations unies ont définie [17 objectifs de développement durable](https://www.un.org/sustainabledevelopment/fr/objectifs-de-developpement-durable/) la [France a suivie](https://www.agenda-2030.fr/17-objectifs-de-developpement-durable). Les analyses du cycle de vie (ACV/LCA) tel que définie par les normes ISO 14040 & 14044 seraient plus adaptées au contexte IT. 
1. Les datas et les indicateurs sur le développement durable des services AWS ne sont pas disponible. Quelques indicateurs environnementaux pertinent : 
   - GWP : Changement climatique (kg éq. CO₂), 
   - PM : Emissions de particules (incidence des maladies), 
   - AD : Acidification (mol éq. H+), 
   - IR : Radiations ionisantes, santé humaine (kBq éq. U235), 
   - ADPe : Utilisation des ressources, minéraux et métaux (kg Sb éq), 
   - ADPf : Utilisation des ressources, fossiles (MJ), 
   - WU : Utilisation des ressources en eau (m3 éq), 
   - CED : flux Energie primaire, 
   - EoL : Fin de vie 
   
    cf [Benchmark Green IT 2022 P7](https://club.greenit.fr/doc/2022-09-Benchmark_Green_IT-2022-rapport.0.5_FR.pdf)
1. Comment avoir l'impact carbone d'un service utilisé ? L'impact carbone est fonction de chaque service, de la localisation lors de l'utilisation ainsi que de l'instant où il est utilisé. 
Des choix techniques pourraient découler de cette information. Lors du choix d'un service on regarde ses fonctionnalités, ses couts, mais pas son impacte carbone. Avec ces informations il deviendrait possible de faire un choix éclairé. 
1. Comment AWS peut-il être 5 fois plus efficace d'un datacenter européen ? Pour sa région Paris, le cloud AWS est dans des datacenter mutualisé en France. L’implantation ressente d’AWS dans des datacenters performants permet probablement de se distinguer de la moyenne européen. 
Le JDD publie un initiative d'AWS de datacenter géant en [ZI de Vilemilan à WISSOUS (91320)](https://www.journaldunet.com/web-tech/cloud/1515711-exclu-jdn-le-projet-secret-du-data-center-geant-d-amazon-en-ile-de-france-devoile/)
Pour [archimag](https://www.archimag.com/univers-data/2023/04/12/datacenter-ou-sont-cachees-installations-qui-font-tourner-france) gérer par Cyrus One : 15 000 m2 / 83 mégawatts (MW) 
    - La région française d'AWS qui compte trois zones de disponibilité se répartit entre le datacenter d'Interxion à La Courneuve, le DC3 de Scaleway à Vitry-sur-Seine et les centres de données de Data4 à Paris-Saclay/Marcoussis. AWS prévoit d'occuper une quatrième infrastructure située à Wissous. Propriété de Cyrus One, elle est actuellement en cours de construction. Source [JDD](https://www.journaldunet.fr/web-tech/guide-de-l-entreprise-digitale/1514137-la-carte-secrete-des-data-centers-des-clouds-providers-americains-en-france/) et [Archimag](https://www.archimag.com/univers-data/2023/04/12/datacenter-ou-sont-cachees-installations-qui-font-tourner-france)
    - La région française de Google s’appuie sur trois datacenters dont ceux de Global Switch à Clichy-La-Garenne et de Digital Realty à Ferrières-en-Brie en Seine-et-Marne.
    - La région française d’IBM est installée chez Global Switch à Clichy.
    - La région française de Microsoft Azure s'appuie sur quatre datacenters dont celui d’Interxion à La Courneuve et de Colt aux Ulis. La région Azure France Sud, elle, déployée dans le datacenter MRS1 d'Interxion à Marseille.
    - Oracle a aussi opté pour deux régions cloud pour la France via Interxion : l'une à la Courneuve, l'autre à Marseille avec le datacenter MSR2.

Other link

- Reference
    - [Green IT](https://www.greenit.fr/)
    - [Theshiftproject.org thematique-numerique](https://theshiftproject.org/category/thematiques/numerique/)
    - [Electricity maps](https://app.electricitymaps.com/)

- Blogs
    - Une vision critique de la communication 0 carbone des hyperscalers par [carbone4](https://www.carbone4.com/analyse-empreinte-carbone-du-cloud)
    - [frugalité numérique centres de calcul](https://nauges.typepad.com/my_weblog/2020/01/frugalit%C3%A9-num%C3%A9rique-centres-de-calcul-deuxi%C3%A8me-partie.html)
   - [calculettes carbone des clouds providers]( https://boavizta.org/blog/calculettes-carbone-clouds-providers)

- AWS
    - https://aws.amazon.com/sustainability/
    - https://sustainability.aboutamazon.com/
    - https://aws.amazon.com/aws-cost-management/aws-customer-carbon-footprint-tool/
  

- linkedin
    - https://www.linkedin.com/posts/guillaumemoulard_je-recherche-toutes-les-informations-possibles-activity-7104767296656547841-7zux
    - https://www.linkedin.com/posts/guillaumemoulard_parfois-il-ne-faut-pas-trop-dire-de-b%C3%AAtise-activity-7097703932839260160-myO0
    - https://www.linkedin.com/posts/guillaumemoulard_aws-climat-giec-activity-6932612478140874754-9pd6



