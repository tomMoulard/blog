---
title: "Un schéma AWS qui tient une API Go LLM éveillée"
date: 2025-12-19T17:00:00+01:00
description: "Expérience exploratoire sur une architecture AWS multi-région pour API Go LLM, quotas Bedrock et workflow dev."
author: Tom Moulard
tags: ["aws", "go", "llm", "architecture", "ha", "bedrock", "observability", "appconfig", "opentelemetry"]
categories: ["AWS", "Architecture", "exploration"]
draft: false
type: post
---

Une API Go qui reste éveillée même quand une région AWS s’effondre.

De plus en plus d'équipes SaaS cherchent à sortir de l'architecture «
mono-région us-east-1 + OpenAI par défaut » pour garder le service en ligne
même quand une région AWS tombe en plein lancement produit.

Je parle donc d'Amazon Web Services (AWS), de Large Language Models (LLM) et de
haute disponibilité (HA) appliquée à une API Go. En clair : je décris ici une
architecture multi-région AWS pensée pour garder une API Go branchée sur
plusieurs LLM, sans dépendre d'un fournisseur et en assumant des pannes totales
de région. L'objectif est double : haute disponibilité en lecture/écriture
(avec un Recovery Time Objective, RTO, de quelques minutes pour les écritures,
cf. A1) et possibilité de basculer vers un concurrent (ou un modèle moins cher)
sans redéployer le backend.

Avant d'empiler des services, j'aime poser noir sur blanc ce qui doit survivre
à une panne de région. Le schéma qui suit est donc une exploration théorique
prête à être déployée telle quelle sur un projet d'API Go + LLM multi-région.

### Hypothèses affichées dès le départ

- **A1 — HA = RTO de quelques minutes pour l'écriture :** Aurora Global
Database n'a qu'un seul writer. AWS annonce un Recovery Point Objective (RPO)
généralement <1 seconde et un RTO <1 minute pour la promotion d'une région
([Aurora Global Database failover](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-global-database-failover.html),
consulté le 8 décembre 2025). Je parle donc d'une HA “lecture/écriture” qui
tolère cette pause et je prévois les tampons nécessaires pour absorber un
scénario pessimiste où la promotion dépasserait la minute.
- **A2 — Couverture Bedrock :** au 8 décembre 2025, AWS liste Amazon Bedrock
dans plusieurs régions (us-east-1/2, us-west-2, eu-central-1, eu-west-1,
ap-south-1, ap-northeast-1, ap-southeast-1/2, etc.) ([Amazon Bedrock endpoints and quotas](https://docs.aws.amazon.com/general/latest/gr/bedrock.html),
consulté le 8 décembre 2025). Je pars donc du principe qu'un deuxième quota est
provisionné dans l'une de ces régions (ou chez un fournisseur tiers) pour que
la région de secours serve les prompts.
- **A3 — Idempotence côté client :** tous les POST exposés par l'API peuvent
être rejoués grâce à un `request_id`, sinon CloudFront ne pourrait rien faire
pour nous.
- **A4 — Budget HA assumé :** trois NAT Gateway par région, des quotas Bedrock
provisionnés et un Redis par région sont financés par le métier.
- **A5 — Runbooks mono-cloud :** les équipes produit/opérations restent sur AWS
mais savent suivre un plan de bascule multi-région.

Le schéma ci-dessous illustre le flux complet : des utilisateurs au bord du
réseau jusqu'aux bases de données globales, avec les points de bascule.

{{< mermaid >}}
flowchart TB

    %% ==== Edge ====
    subgraph Edge[Edge Global]
        R53[Route 53 ALIAS] --> CF[CloudFront<br>WAF<br>Origin Failover]
    end

    %% ==== ALB ====
    CF --> ALB1[ALB us-east-1<br>origin primaire]
    CF -. failover .-> ALB2[ALB eu-west-1<br>origin secondaire]

    %% ==== us-east-1 ====
    subgraph E1[us-east-1 region active]

        ALB1 --> ECS1[ECS Fargate]

        subgraph E1Net[Sortie et Configuration]
            ECS1 --> NAT1a[NAT a]
            ECS1 --> NAT1b[NAT b]
            ECS1 --> NAT1c[NAT c]
            ECS1 --> AppCfg1[AppConfig<br>Secrets]
        end

        subgraph E1Ops[Ops locaux]
            ECS1 --> Redis1[Redis quota<br>Lua]
            ECS1 --> SQS1[SQS<br>DLQ]
        end

        subgraph E1LLM[Acces LLM]
            ECS1 --> VPCE1[VPC Endpoint Bedrock]
            VPCE1 --> BR1[Bedrock<br>provisionne]
        end
    end

    %% ==== eu-west-1 ====
    subgraph W1[eu-west-1 region DR]

        ALB2 --> ECS2[ECS Fargate]

        subgraph W1Net[Sortie et Configuration]
            ECS2 --> NAT2a[NAT a]
            ECS2 --> NAT2b[NAT b]
            ECS2 --> NAT2c[NAT c]
            ECS2 --> AppCfg2[AppConfig<br>Secrets]
        end

        subgraph W1Ops[Ops locaux]
            ECS2 --> Redis2[Redis quota<br>Lua]
            ECS2 --> SQS2[SQS<br>DLQ]
        end

        subgraph W1LLM[Acces LLM]
            ECS2 --> VPCE2[VPC Endpoint Bedrock]
            VPCE2 --> BR2[Bedrock<br>provisionne]
        end
    end

    %% ==== Cross-region ====
    SQS1 <-. Lambda sync .-> SQS2
    AppCfg1 <-. CI CD .-> AppCfg2

    %% ==== Donnees globales ====
    ECS1 --> DDB[DynamoDB<br>Global Tables]
    ECS2 --> DDB

    ECS1 --> RDS[Aurora Global<br>writer]
    ECS2 --> RDSReader[Aurora Global<br>reader]

    %% ==== Observabilite ====
    ECS1 -. traces logs .-> CW[CloudWatch<br>X-Ray]
    ECS2 -.-> CW
    CW --> Graf[Managed Grafana]
    CW --> Alerting[EventBridge<br>Chatbot<br>SNS]

    Redis1 --> Telemetry[Quota<br>metrics]
    Redis2 --> Telemetry
{{< /mermaid >}}

> Lecture du diagramme : Route 53 renvoie tout vers CloudFront, qui combine un
> Web Application Firewall (WAF) et l'Origin Failover pour choisir entre deux
> Application Load Balancer (ALB). Chaque colonne régionale embarque ses
> propres tâches ECS Fargate, NAT Gateway (NAT GW a/b/c), Redis “quota local +
> Lua”, Simple Queue Service (SQS) + Dead Letter Queue (DLQ) et AWS AppConfig
> (AppCfg) avant de rejoindre Bedrock via des VPC Endpoints (VPCE), DynamoDB
> Global Tables et Aurora Global Database côté données. La flèche “Pipeline
> CI/CD” rappelle qu'une même chaîne d'intégration continue/déploiement continu
> (CI/CD) alimente les deux AppConfig. Si Bedrock n'est pas disponible dans la
> région de secours, ce bloc représente un fournisseur tiers ou un routage vers
> une région Bedrock existante (cf. A2).

Comme montré ci-dessus, le trafic entre dans CloudFront (le Content Delivery
Network, CDN, d'AWS), passe l'Application Load Balancer (ALB) primaire en
us-east-1 et, pour les requêtes GET/HEAD/OPTIONS, tombe automatiquement sur
l'ALB secondaire en eu-west-1 si la santé de l'origine bascule.

Tous les services annexes (Redis quotas, Simple Queue Service \(SQS\),
AppConfig, secrets) restent locaux à chaque région pour éviter les points
uniques de défaillance.

En deux mots : Route 53 pointe vers CloudFront, qui choisit entre deux
Application Load Balancer (ALB), chacun s'appuyant sur ses propres queues,
quotas Redis, AppConfig et secrets régionaux.

## Pourquoi cette architecture me semble pertinente

Je cherche une approche qui soit crédible pour un blog de R&D : multi-région
par défaut, aucun composant unique, et la possibilité de brancher n'importe
quel fournisseur de LLM ou d'observabilité sans réécrire tout le socle. Les
sections suivantes détaillent les hypothèses que j'explorerais avant même de
commencer à coder.

## Anatomie d'un chemin LLM qui ne casse pas

### Edge géré par CloudFront

Une seule distribution applique AWS WAF avec [AWS Bot Control](https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-bot.html)
(consulté le 8 décembre 2025). Elle s'appuie sur **[Origin Failover](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/high_availability_origin_failover.html)**
(consulté le 8 décembre 2025) pour basculer de l'origin primaire (us-east-1)
vers l'origin eu-west-1 avant même qu'on touche au DNS Route 53. Route 53 reste
un **enregistrement ALIAS A/AAAA** (ou un CNAME si l'on parle d'un
sous-domaine) pointé vers CloudFront : je préfère déplacer l'intelligence côté
CDN où la propagation est quasi instantanée.

Important : CloudFront ne refait un Origin Failover automatique que pour les
requêtes GET/HEAD/OPTIONS (voir la doc ci-dessus). Tous les autres verbes
reçoivent simplement l'erreur du backend.
 Comme mon API LLM encaisse surtout des POST, j'ai rendu tous les appels
idempotents (replay d'un même `request_id` ignoré, cf. A3) et je documente noir
sur blanc que la bascule doit être effectuée par les clients ou par un SDK
maison qui retente côté secondaire après un 5xx.

Lambda@Edge n'a pas la possibilité de “rejouer” un POST vers une autre origine
après échec ; il ne sert ici qu'à ajouter des en-têtes de traçage. Ce compromis
est préférable à un failover DNS lent, mais il faut accepter que la fenêtre
d'indisponibilité POST se joue côté client.

Si l'on veut réellement un RTO sub-60s côté serveur pour tous les verbes HTTP,
il faudra placer un [AWS Global Accelerator](https://docs.aws.amazon.com/global-accelerator/latest/dg/what-is-global-accelerator.html)
(consulté le 8 décembre 2025) devant les deux ALB ou utiliser [Route 53 Application Recovery Controller (ARC)](https://aws.amazon.com/route53/application-recovery-controller/)
(consulté le 8 décembre 2025) pour piloter la bascule active/active. Je ne l'ai
pas encore fait sur ce prototype, mais le runbook note explicitement ce manque
pour éviter les promesses intenables. Tant que cette couche réseau n'existe
pas, je considère l'archi “HA partielle” et je m'appuie sur un SDK client (cf.
section produit) qui applique un backoff exponentiel et coupe les retries après
trois échecs pour ne pas saturer Redis/SQS.

### Application Load Balancer public mais filtré

Chaque origin est un Application Load Balancer (ALB) internet-facing dans trois
subnets publics, conformément à [Application Load Balancer Subnets](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-subnets.html)
(consulté le 8 décembre 2025). Les Security Groups s'appuient sur les [prefix lists managées](https://docs.aws.amazon.com/vpc/latest/userguide/managed-prefix-lists.html)
(consulté le 8 décembre 2025) pour autoriser CloudFront et la plage IP Route 53
Health Check. Pas de trafic direct venant d'Internet, pas de surprises côté
monitoring.

### Egress aligné sur les AZ

Chaque subnet privé a sa route table qui pointe vers “son” Network Address
Translation (NAT) Gateway, comme décrit dans [NAT Gateway Route Tables](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html#nat-gateway-route-tables)
(consulté le 8 décembre 2025). Tous les appels vers les services internes AWS
(Secrets Manager, Parameter Store, CloudWatch Logs, S3, KMS) utilisent des VPC
Endpoints privés (VPCE) pour rester sur le réseau Amazon et ne pas consommer le
throughput des NAT. Bedrock obtient son endpoint dédié afin d'éviter de saturer
les NAT ou de faire exploser la facture inter-AZ quand les tokens partent en
flèche. Quand une région AWS n'héberge pas encore Bedrock (ex. eu-west-3 à la
date de rédaction), je remplace ce VPCE par un fournisseur tiers (OpenAI/Azure)
ou par un routage vers une région où Bedrock est disponible en assumant la
latence supplémentaire.
Oui, trois NAT par région coûtent un rein (cf. A4), mais c'est le prix à payer
pour que chaque zone de dispo continue de sortir sur Internet si une voisine
tombe.

### Quotas Bedrock pilotés localement

L'API
[`ListProvisionedModelThroughputs`](https://docs.aws.amazon.com/bedrock/latest/APIReference/API_ListProvisionedModelThroughputs.html)
(consulté le 8 décembre 2025) me sert à lister les `modelUnits` actifs. Chaque
région AWS négocie son propre throughput (il n'y a pas de “quota global”
partagé, cf. [Bedrock provisioned throughput](https://docs.aws.amazon.com/bedrock/latest/userguide/prov-throughput.html#prov-throughput-capacity),
consulté le 8 décembre 2025). Je convertis ces unités en tokens/s puis je
stocke ce budget dans un Redis local.

Un service Elastic Container Service (ECS) “refill” par région calcule
`deltaTokens = rate * elapsed` et applique un script Lua atomique sur Redis ;
chaque requête Bedrock décrémente ce bucket. Avant de rouvrir une région de
secours je rafraîchis systématiquement le quota local via
`ListProvisionedModelThroughputs` pour éviter de “dépenser deux fois” le même
modelUnit : pas question que la région DR parte avec un bucket plein alors que
le quota global a déjà été tapé par la région active. Les métriques
`InvocationThrottled` et `ProvisionedModelThroughputUtilization` servent de
garde-fous externes et déclenchent un plan B (déport des requêtes vers
OpenAI/Anthropic ou passage en file SQS batch) avant que les 429 ne pleuvent.

### Elastic Container Service (ECS) Fargate discipliné

Les tâches embarquent OpenTelemetry (section dédiée ci-dessous) et injectent
leurs secrets via `valueFrom`, comme recommandé dans [ECS Sensitive Data](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html)
(consulté le 8 décembre 2025). `HandleCompletion` est un metric CloudWatch
maison qui mesure le temps passé à post-traiter les réponses LLM (gestion des
webhooks, notifications, facturation). L'idée est de ne pas scaler tant que
`HandleCompletion` est rouge ou que le bucket Redis est vide : ces garde-fous
évitent de surprovisionner quand la plateforme LLM est déjà au bord du
throttling.

### Files SQS régionales

Deux queues (temps réel + DLQ, Dead Letter Queue) par région suivent les
[bonnes pratiques SQS](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-best-practices.html)
(consulté le 8 décembre 2025). Les messages critiques déclenchent une règle
EventBridge qui publie sur un bus croisé ([Cross-Region Event Buses](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-bus-cross-region.html),
consulté le 8 décembre 2025) ; une fonction AWS Lambda dédiée y écrit
directement dans SQS2.
J'assume la livraison “at least once” : pas d'ordre garanti ni de duplication
zéro, d'où l'usage d'un `request_id` pour dédupliquer côté consommateurs et de
métriques `ApproximateAgeOfOldestMessage` pour surveiller la latence. Si le bus
principal tombe, le [Global Endpoint EventBridge](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-global-endpoints.html)
(consulté le 8 décembre 2025) bascule vers la région de secours. Ce n'est pas
parfait, mais c'est “best effort” avant la bascule DNS.

### Données persistantes alignées

Les sessions vivent dans [DynamoDB Global Tables](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GlobalTables.html)
(consulté le 8 décembre 2025) avec une clé `tenant#session#rand` inspirée des
[Partition Key Design](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-design.html)
(consulté le 8 décembre 2025). Les conversations agrégées se déversent dans
[Aurora Global Database](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-global-database.html)
(consulté le 8 décembre 2025) : writer en us-east-1, reader en eu-west-1, et un
runbook documente un `GlobalDatabaseFailover` qui prend quelques minutes (mes
relevés lors du GameDay de février 2025) pour promouvoir la région de secours
(Disaster Recovery, DR). AWS précise que la latence de réplication globale
reste généralement <1 seconde mais que le RTO peut grimper jusqu'à 5 minutes
selon la taille du cluster ; je conserve donc un tampon SQS + DynamoDB pour
rejouer les écritures perdues en cas de failover brutal.

### Runbook Route 53 concret

Route 53 reste un enregistrement ALIAS A/AAAA (ou un CNAME hors apex) vers
CloudFront. Quand je dois isoler un tenant (un espace client dédié) ou un pays,
je garde une distribution secondaire et une entrée DNS prête à être promue via
[`ChangeResourceRecordSets`](https://docs.aws.amazon.com/Route53/latest/APIReference/API_ChangeResourceRecordSets.html)
(consulté le 8 décembre 2025). Les health checks HTTP ciblent directement la
distribution CloudFront (pas l'ALB), n'activent aucun failover Route 53
automatique et servent uniquement à déclencher mes alertes internes avant que
le runbook (cf. A5) ne prenne la main.

### Configuration managée et répliquée

[AWS AppConfig](https://docs.aws.amazon.com/appconfig/latest/userguide/what-is-appconfig.html)
(consulté le 8 décembre 2025) déploie les feature flags dans chaque région via
la même pipeline CodePipeline/CodeDeploy. Secrets Manager offre la [rotation automatique](https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets.html)
(consulté le 8 décembre 2025) ; Parameter Store est synchronisé par un runbook
[Systems Manager Automation](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-automation.html)
(consulté le 8 décembre 2025) qui copie les paramètres vers la région de
secours. Tout est versionné, histoire de savoir qui a cassé quoi.

## Router plusieurs LLM sans se marier avec un fournisseur

Je refuse d'écrire du code applicatif spécifique à un LLM. L'idée est d'avoir
un routeur métier qui parle aux SDK Bedrock, OpenAI et Anthropic de manière
homogène. J'utilise une couche d'abstraction maison (en Go) qui standardise les
prompts, les tokens et les stratégies de streaming. Les SDK officiels sont
référencés ici : [Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html)
(consulté le 8 décembre 2025), [OpenAI API](https://platform.openai.com/docs/api-reference/introduction) (consulté le
8 décembre 2025) et [Anthropic API](https://docs.anthropic.com/claude/docs)
(consulté le 8 décembre 2025).

Le diagramme ci-dessous montre comment le routeur Go choisit le fournisseur
tout en gardant la traçabilité et les mémoires vectorielles.

{{< mermaid >}}
flowchart LR
    ClientPrompts --> Router[Service Go : Prompt Orchestrator]
    Router -->|Policies| Bedrock
    Router -->|Fallback| OpenAI
    Router -->|Use-case ciblé| Anthropic
    Router --> Cache[Vector store / mémoires]
    Router --> Audit[S3 + DynamoDB traces]
{{< /mermaid >}}

> Lecture du diagramme : le service Go central reçoit les prompts, les enrichit
> avec des politiques métier puis sélectionne Bedrock, OpenAI ou Anthropic
> avant d'écrire les traces dans S3/DynamoDB et de ranger les mémoires
> vectorielles dans un cache dédié.

Comme sur le schéma, chaque requête passe par un “Prompt Orchestrator” qui sait
quel modèle utiliser, comment appliquer les limites de tokens, quelles
garanties promettre, et comment retomber sur une version plus cheap si la
première refuse de répondre. J'insiste sur la traçabilité : chaque appel logge
la provenance, la politique appliquée, et la facture estimée.

### Interfaces Go pour garder le code propre

Je ne veux pas d'un routeur monolithique, donc je formalise les abstractions
suivantes :

```go
type LLMProvider interface {
    Name() string
    Supports(ctx context.Context, intent string) bool
    Complete(ctx context.Context, prompt Prompt) (Response, error)
    CostEstimator(ctx context.Context, prompt Prompt) (TokenEstimate, error)
}

type PromptRouter interface {
    RegisterProvider(provider LLMProvider)
    Route(ctx context.Context, prompt Prompt) (Response, error)
}

type QuotaLimiter interface {
    Allow(ctx context.Context, tenant string, tokens int) error
    ObserveUsage(ctx context.Context, tenant string, tokens int)
}

type TelemetrySink interface {
    EmitTrace(ctx context.Context, span SpanData)
    EmitLog(ctx context.Context, entry LogEntry)
    EmitMetric(ctx context.Context, metric MetricData)
}
```

`LLMProvider` masque les API Bedrock/OpenAI/Anthropic, `PromptRouter` orchestre
l'ensemble, `QuotaLimiter` encapsule Redis + métriques, et `TelemetrySink` se
branche sur OpenTelemetry/OTLP sans enfermer l'app dans un APM précis.

## Observabilité unifiée avec OpenTelemetry

Pour éviter le vendor lock-in (et parce qu'on finit toujours par migrer d'outil
APM tôt ou tard), je pousse tout sur
[OpenTelemetry](https://opentelemetry.io/docs/) (consulté le 8 décembre 2025).
Les agents OTEL tournent comme sidecars sur ECS, collectent logs / traces /
métriques et les envoient vers CloudWatch, Grafana Cloud ou n'importe quel
endpoint OTLP. Ça me laisse la porte ouverte à une migration vers Tempo, Jaeger
ou New Relic sans toucher aux binaires.

{{< mermaid >}}
flowchart LR
    AppGo --> OTEL[OTel Collector]
    OTEL --> CWLogs[CloudWatch Logs]
    OTEL --> XRay
    OTEL --> GrafanaCloud
    OTEL --> S3ColdStorage
{{< /mermaid >}}

> Lecture du diagramme : l'app Go expédie ses traces, logs et métriques vers un
> collector OpenTelemetry qui les duplique vers CloudWatch Logs, X-Ray, Grafana
> Cloud et même S3 froid afin de ne pas dépendre d'un seul outil.

Dans la pratique, j'uniformise les attributs (`tenant_id`, `prompt_type`,
`llm_vendor`) pour pouvoir corréler une saturation de quota Bedrock avec un pic
de latence sur OpenAI, ou détecter qu'un run AppConfig a dégradé l'expérience.
Le collector tourne côté cluster et exporte via OTLP + TLS, ce qui évite de
lier l'avenir de l'observabilité à un seul fournisseur.

## Optimiser les coûts LLM / Infra / ECS

Même en mode exploration, je garde l'œil sur la facture.

### Gérer le coût LLM

Je passe toutes les requêtes par un `Prompt Budgeter` qui estime les tokens
avant d'appeler un modèle onéreux. Bedrock couvrirait les intégrations AWS,
OpenAI la partie plus créative, Anthropic les prompts verbeux. Toute demande
qui dépasse un seuil part sur un traitement batch (SQS + Lambda) avec un modèle
moins coûteux.

### Contenir la facture infra

ECS Fargate est confortable mais je prévois déjà des tâches “spot” pour les
workers non critiques et je définis un `Service Quota` sur les NAT, parce que
chaque Go qui sort coûte son poids en or. Les métriques CloudWatch budgétaires
restent ouvertes en permanence.

### Ajuster la consommation ECS

Je serre les images (scratch), j'active le `CPU bursting` quand c'est
pertinent et je programme l'arrêt automatique des environnements de test. Rien
de glamour, juste une discipline quotidienne pour éviter les surprises sur la
ligne AWS.

## Pourquoi cette architecture tient la route sur le papier

- **Scalabilité réaliste.** Deux quotas Bedrock indépendants et observables
(`InvocationThrottled`, `bedrock_throttle_rate`) limitent le risque de
sur-scaler quand le fournisseur LLM est déjà au bord du throttling. Les limites
sont connues, affichées dans Grafana et se déclenchent avant l'Auto Scaling.
- **Observabilité plurielle.** Traces X-Ray, logs JSON avec `trace_id`,
dashboards [Amazon Managed Grafana](https://docs.aws.amazon.com/grafana/latest/userguide/what-is-AMG.html)
(consulté le 8 décembre 2025), canaries Synthetics et alarmes CloudWatch
forment un triptyque. Les métriques critiques sont routées vers EventBridge →
AWS Chatbot/SNS pour éviter de dépendre d'un seul outil.
- **Sécurité et secrets alignés.** IAM reste à privilèges minimaux, les accès
Bedrock passent par VPC endpoint et les secrets sont injectés dynamiquement.
Pas de port public côté ECS et les NAT gardent leurs route tables locales à
chaque AZ.
- **Résilience multi-région assumée.** CloudFront gère l'origine failover en
quelques secondes pour les GET/HEAD/OPTIONS tandis qu'Aurora Global a besoin de
quelques minutes pour promouvoir le writer (cf. A1).
Les queues/SNS, Redis et AppConfig existent dans chaque région ; Route 53 ne
change que si l'on veut isoler complètement un tenant. Pour des POST sub-60s
sans dépendre du client, il faudra ajouter Global Accelerator ou une autre
passerelle active/active : le runbook l'assume clairement.

### Sources officielles

Chaque brique citée s'appuie sur les docs AWS correspondantes :
[Well-Architected](https://docs.aws.amazon.com/wellarchitected/latest/framework/)
et [Bedrock Provisioned Throughput](https://docs.aws.amazon.com/bedrock/latest/userguide/prov-throughput.html)
(toutes deux consultées le 8 décembre 2025) servent de garde-fous conceptuels.

## Ce que j'espère obtenir avec ce schéma

Le découpage ci-dessus m'intéresse parce qu'il isole chaque préoccupation :
CloudFront absorbe et filtre, les quotas restent locaux et observables, les
données longues vivent dans des systèmes globaux, et le runbook assume les
limites (quelques minutes pour promouvoir le writer Aurora selon les scénarios
précédents). Si un quota Bedrock se met à crier famine, je sais quel composant
doit siffler la fin de la récré.

## Ce que je demande aux équipes produit et dev

- **Collaboration métriques.** Transparence sur les métriques métier
(`prompt_per_user`, `llm_retry_rate`, `bedrock_token_cost`) exposées dans
CloudWatch et Grafana, sans quoi impossible de prioriser les quotas.
- **SDK commun.** Un Software Development Kit (SDK) Go/TypeScript partagé qui
gère instrumentation X-Ray, lecture des quotas Redis, un flag
`failover_in_progress` issu d'AppConfig et un backoff standard (3 tentatives
max) pour éviter les implémentations maison.
- **Discipline AppConfig.** Des feature flags pilotés par AppConfig avec
déploiement progressif et rollback automatique documenté ; pas question de
toggles copiés-collés dans les variables d'environnement.

{{< mermaid >}}
flowchart LR
    EventBridge --> cb[AWS ChatBot] --> OpsGenie
    EventBridge --> SNS --> SMS
{{< /mermaid >}}

Quand une alerte tombe, EventBridge → AWS Chatbot → Opsgenie prend le relais,
et les SMS SNS rappellent tout le monde si `ApproximateAgeOfOldestMessage`
dérape.

En explorant cette architecture “sur le papier”, je préfère miser sur un
diagramme honnête plutôt que sur un runbook de 30 pages. Si cette réflexion
vous évite ne serait-ce qu'un redéploiement panique un vendredi soir, elle aura
servi. L'objectif reste de dompter les quotas avant qu'eux ne domptent votre
pager.
