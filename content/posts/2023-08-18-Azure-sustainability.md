---
title: "Azure Sustainability"
date: 2023-12-10T13:00:00+01:00
author: Guillaume Moulard
url: /azure-sustainability
draft: false
type: post
tags:
  - blogging
  - Azure
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

# Cet article est embryonnaire. L'article sur AWS a beaucoup plus d'intérêt : https://blog.moulard.org/aws-sustainability/

# Azure and Sustainability

## MICROSOFT ASSESSMENTS: Sustainability | Well-Architected Review

AWS a créer un assessments dedier a la sustainability


### Les question de l'ASSESSMENTS: Sustainability | Well-Architected Review

- Sustainability Configuration
    - What kind of workloads do you want to assess for sustainability?
        - Core workloads
        - Azure Kubernetes Service (AKS) workloads
- Sustainability: Application design
    - What is your approach to improving code efficiency?
        - We evaluated the move from monoliths to a microservices architecture and carefully considered all the trade-offs this model entails.
        - We've implemented request throttling, response caching, and message encoding to improve reliability and performance in Azure API Management.  
        - Software backward compatibility is prioritized whenever possible to ensure it works on legacy hardware.
        - Legacy hardware may include end-user consumer devices like older browsers and operating systems.
        - Cloud-native design patterns are always leveraged when writing or updating the application to reduce its resource utilization and carbon emissions.
        - The application logic handles exceptions and errors by leveraging circuit breaker patterns and Azure Monitor.
        - The code is optimized for efficient resource usage, such as reduced CPU cycles and number of resources needed by the application.
        - Requests that don't require immediate processing are queued and buffered, then processed in batch to achieve a stable utilization and flatten consumption to avoid spiky requests.
        - We've evaluated server-side rendering vs. client-side rendering when building the application, and chose the most sustainable solution.
        - We considered the UX design impact on sustainability and made decisions to improve energy efficiency and reduce unnecessary network load, data processing, and compute resources.
        - We identified inefficient legacy code suited for modernization, and we reviewed options to move to serverless or any of the optimized PaaS options.
        - None of the above.
- Sustainability: Application platform
    - How do you ensure your platform and services are up to date and benefit from the latest performance improvements and energy optimizations?
        - We review platform and service updates regularly and apply them as they become available through a well-defined, documented, and tested process.
        - We use a single and comprehensive managed solution, such as Update Management in Azure Automation or Automatic VM guest patching, to ensure operating system updates are deployed to Azure virtual machines.
        - None of the above.
    - How do you leverage regional differences to reduce the emissions produced by your solution?
        We've identified Azure regions with a low carbon footprint and have deployed our workload there.
        - We run processing-intensive workload tasks when we know that the energy mix comes mostly from renewable energy sources and/or move the workload dynamically when the energy conditions change so that processes run when the carbon intensity is low.
        - We've considered the physical distance from the datacenters to our main customer base and deployed the workload to the closest datacenters to reduce network traversal time and use the least amount of energy possible.
        - We proactively design batch processing of workloads to help with scheduling intensive work during low-carbon periods.
        - None of the above
    - What platform design decisions have you made for operations to contribute to a better sustainability posture?
        - We've considered workload containerization options to reduce unnecessary resource allocation and make better use of deployed resources.
        - We've evaluated moving to highly optimized managed services that operate on more efficient hardware to contribute to a lower carbon impact.
        - Managed services such as PaaS and serverless are highly optimized and operate on more efficient hardware than other options, contributing to a lower carbon impact.
        - We're aware of potential unused capacity in Azure data centers and therefore use Azure Spot Virtual Machines whenever possible to utilize this otherwise wasted capacity and contribute to a more sustainable platform design. 
        - None of the above.
    - How do you ensure your workload isn't oversized and make the best use of allocated resources to avoid energy waste and added carbon emissions?
        - We turn off unused virtual machines outside of business hours.
        - We've enabled and integrated auto-scaling with Azure Monitor and utilize B-series burstable virtual machine sizes for machines that are idle most of the time and have high usage only in certain periods.
        - We've considered the application platform and ensured that it meets the scalability needs of the solution.
        - We've evaluated and identified Ampere Altra Arm-based processors for virtual machines as a power-efficient option to reduce energy waste without compromise on the required performance.
        - We continuously assess our subscriptions to identify and delete unutilized and orphaned resources.
        - None of the above.
    - What considerations have you made for a more sustainable testing model?
        - We have a well-crafted design for testing the deployed workload and we run integration, performance, load, or any other intense testing during low-carbon periods to ensure full utilization of the available resources and reduced carbon emissions.
        - Continuous testing is implemented and CI/CD worker agents scale as needed avoiding unnecessary capacity allocation.
        - None of the above.
    - How do you measure, profile, and test your workload to ensure it makes the best use of the allocated resources?
        - We're able to know if the workload makes the best use of the underlying platform and deployed resources, and we assess where parallelization is possible by profiling and testing it properly.
        - We assess the workload with load testing and chaos engineering to improve its reliability to recover gracefully from failures and with fewer wasted resources.
        - Key metrics, thresholds, and indicators are defined and captured to find abnormally high resource consumption areas in the application code to help avoid deploying non-sustainable workloads.
        - None of the above
    - What practices and tools have you implemented to measure and track the sustainability impact of your workload?
        - We measure the carbon impact of all our services and resources groups in our Azure subscription(s) with the Emissions Impact Dashboard to record our current and future environmental impact and quantify the achievement of our technical, business, and sustainability outcomes.
        - We've defined our emissions target along with cost constraints and track progress with Service Level Objectives (SLO), Service Level Agreements (SLA), or other performance metrics to optimize emissions.
        - We've identified metrics to prove changes have a positive effect on efficiency, and we've agreed upon and communicated any plan that impacts performance to the app users so that they know that a lower performance may be necessary for the greater good of fewer carbon emissions.
        - We've reviewed the concept of using a proxy solution to define our Sustainability Carbon Intensity and linked cost to performance metrics and carbon efficiency to reduce unnecessary spending and lower the number of excessive emissions from deployed workloads.
        - We've defined one or more Azure policies to keep our Azure virtual data center continuously optimized.
        - None of the above.
    - How do you foster awareness and a culture of cloud efficiency in your organization?
        - There is a Core Cloud Efficiency team in our organization that stays up to date with of all the tools and principles that determine the cost and carbon footprint of our Azure workload, sets policies and goals, and communicates its efforts and its objectives to the rest of the organization
        - Each member of the organization has already started thinking about green software and how to contribute to the sustainability picture, and the Core Cloud Efficiency Team has dedicated time to learn more and share the advancements in sustainable operations to the rest of the organization.
        - Collaboration and knowledge-sharing through internal webinars or other type of sessions to share best practices and tested guidance are promoted and encouraged for getting everyone up to speed.
        - Incentives to improve the sustainability of the workload environment by promoting cloud-efficient and carbon-aware applications are defined as quick ways to enforce policies and create the right culture.
        - None of the above.
    - What are you doing to enhance and optimize network efficiency to reduce unnecessary carbon emissions?
        - The workload uses Azure Content Delivery Network as a global CDN solution to help minimize latency through storing frequently read static data closer to consumers, and to help reduce the network traversal and server load.
        - We are familiar with caching best practices, and we use a high-performance caching solution to improve performance, reduce network traversal and server load, and increase compute density of resources that are already allocated.
        - We selected Azure regions based on where customers reside to serve requests with good performance and energy efficiency.
        - We've carefully selected managed streaming services with built-in compression to reduce the carbon footprint resulting from streaming media over the internet.
        - We've enabled network file compression to improve file transfer speed, increase page-load performance, and reduce network payload.
        - We avoid spreading resources unnecessarily between different cloud service providers and maximize network utilization within the same cloud and region, whenever possible, to optimize network routing and reduce network traversals between components.
        - None of the above.
    - What design considerations have you made for a more sustainable data storage architecture?
        - We're familiar with storage compression and have enabled it to increase performance, lower the required bandwidth, and minimize unnecessary storage design climate impact.
        - The application is optimized for database query performance to reduce the latency of data retrieval while also reducing the load on the database and improving energy efficiency.
        - We've designed our solution with the correct data-access pattern to enhance the application's carbon efficiency.Different types of data fit more naturally into different data store types such as relational databases, key/value stores, or document databases.
        - We've considered how to plan backup storage retention to avoid storing backups indefinitely and allocating much unnecessary disk space.
        - The application doesn't store blob data, or we've reviewed the different Azure storage access tiers (hot, cool, and archive) and selected the most cost-effective and energy efficient manner to store the data.
        - We've considered where soft delete is enabled for Azure Backup and we regularly review and clean up expired recovery points.
        - We've defined and implemented backup policies and retention periods for backups to avoid storing unnecessary data.
        - We retain only data that is relevant to our needs to optimize the collection of logs.
        - None of the above.
- Sustainability: Security
    - How well are your security monitoring solutions optimized for sustainability?
         - We use cloud-native log collection methods, where applicable, to simplify the integration between services and to remove the overhead of extra infrastructure. Service-to-service integration for data connectors in Azure removes the overhead of extra infrastructure and is a great example of how the integration between the services and Microsoft Sentinel is simplified.
         - We use cloud-native security services to perform localized analysis on relevant security data sources, and we don't transfer large unfiltered data sets from one cloud service provider to another.Cloud-native SIEM solutions such as Microsoft Sentinel can be connected via an API or connector to existing security services to transmit only the relevant security incident or event data.
         - We considered use cases based on Microsoft Sentinel analytics rules required for our environment. We've filtered or excluded log sources before transmission or ingestion into our SIEM to remove unnecessary transmission and storage of log data, and to reduce the carbon emissions.
         - We have a requirement to store log data for an extended period, so we archive them to long-term storage to lower the cost and improve energy efficiency.
         - None of the above.
    - What practices and tools for network security have you implemented to increase efficiency and avoid unnecessary traffic?
        - We use cloud-native network security controls, such as network and application security groups to eliminate unnecessary network traffic.
        - We've carefully reviewed the network security reference architectures and configured routing accordingly so that it's minimized from endpoints to the destination and prevents applications and services from connecting to unauthorized devices.
        - We use network security tools with auto-scaling capabilities, such as Azure Firewall Premium or Web Application Firewall on Application Gateway, to enable right-sizing to meet demand without manual intervention and reduce waste of unnecessary resources.
        - We've evaluated whether to use TLS termination, and made the decision to terminate TLS at our border gateway and continue with non-TLS to our workload load balancer and onwards to our workload whenever possible to reduce unnecessary CPU consumption.
        - We've configured Azure DDoS Protection Standard, combined with application design best practices, to provide enhanced DDoS mitigation features to defend against attacks that flood network and compute resources and to avoid unnecessary spike in usage and cost.
        - None of the above.
    - How well are your endpoint mitigation tactics and reporting optimized to detect and remediate unnecessary resource usage?
        - We've integrated Microsoft Defender for Endpoint with Defender for Cloud to detect and protect against attacks such as botnets and crypto-mining, and to discover and remediate any unnecessary resource usage created by these common attacks without the intervention of a security analyst.
        - We have a well-defined tagging strategy that allows us to get the right information and insights at the right time to produce reports around emissions from our security appliances.
        - None of the above.
- Sustainability for AKS: Application design
    - What is your approach to improving your code efficiency?
        - We separated our application functionality into different microservices using the Dapr framework or other CNCF projects to allow independent scaling of logical components.
        - We use Keda to build event-driven applications that scale down to zero when there's no demand.
        - We considered stateless design to reduce unnecessary network load, data processing, and compute resources.
        - The application logic handles exceptions and errors by leveraging circuit breaker patterns and Azure Monitor.
        - The code is optimized for efficient resource usage, such as reduced CPU cycles and number of resources needed by the application.
        - Requests that don't require immediate processing are queued and buffered, then processed in batch to achieve a stable utilization and flatten consumption to avoid spiky requests.
        - We've evaluated server-side rendering vs. client-side rendering when building the application, and we chose the most sustainable solution.
        - We've considered the UX design impact on sustainability and made decisions to improve energy efficiency, reduce unnecessary network load, data processing, and compute resources.
        - None of the above.
    - How do you ensure your platform and services are up to date and benefit from the latest performance improvements and energy optimizations?
        - We review platform and service updates regularly and upgrade to more efficient services as they become available.
        - We enabled cluster auto-upgrade and apply security updates to nodes automatically using GitHub Actions to ensure our cluster has the latest improvements.
        - We installed add-ons and extensions covered by the AKS support policy to provide additional and supported functionality to our cluster.
        - None of the above.
    - How do you leverage regional differences to reduce the emissions that your solution produces?
        - We've identified Azure regions with a low-carbon footprint and have deployed our workload there.
        - We run processing-intensive workloads when we know that the energy mix comes mostly from renewable energy sources and/or move the workload dynamically when the energy conditions change so that processes run when the carbon intensity is low.
        - We proactively design batch processing of workloads to help with scheduling intensive work during low-carbon periods.
        - None of the above.
    - What platform design decisions have you made for operations that contribute to a better sustainability posture?
        - We've containerized our workload and used tools like Draft to generate Dockerfiles and Kubernetes manifests.
        - We use spot node pools to take advantage of unused capacity in Azure for our interruptible workloads.
        - None of the above.
    - How do you ensure the workload is not oversized and that you make the best use of allocated resources to avoid energy waste and added carbon emissions?
        - We use node pool stop and start to turn off our node pools outside of business hours, and KEDA CRON scaler to scale down our pods based on time.
        - We sized our cluster to match the scalability needs of our application and use cluster auto-scaler in combination with virtual nodes to rapidly scale and maximize compute resource utilization. Enforce resource quotas at the namespace level and scale user node pools to 0 when there's no demand.
        - We've evaluated and identified Ampere Altra Arm-based processors for virtual machines as a power-efficient option to reduce energy waste without compromise on the required performance.
        - None of the above.
- Sustainability for AKS: Operational procedures
    - What practices and tools have you implemented to measure and track the sustainability impact of your workload?
        - We measure the carbon impact of our workload with the Emissions Impact Dashboard to record our current and future environmental impact and quantify the achievement of our technical, business, and sustainability outcomes
        - We have defined our emissions target along with cost constraints and track progress with service level objectives (SLO), service level agreements (SLA), or other performance metrics to optimize emissions.
        - We have identified metrics to prove changes have a positive effect on efficiency, and we've agreed upon and communicated any plan that impacts performance to the app users so that they know that a lower performance may be necessary for the greater good of fewer carbon emissions.
        - We have reviewed the concept of using a proxy solution to define our Sustainability Carbon Intensity, and linked cost-to-performance metrics to carbon efficiency to reduce unnecessary spending and lower the number of excessive emissions from our workload.
        - We use Azure Advisor to identify unused resources and ImageCleaner to clean up stale images and remove an area of risk in our cluster.
        - We have defined one or more Azure policies to keep our workload optimized.
        - We set Azure tags on our cluster to enable monitoring of our workload.
        - None of the above.
    - How do you foster awareness and a culture of cloud efficiency in your organization?
        - There is a Core Cloud Efficiency team in our organization that stays up to date with of all the tools and principles that determine the cost and carbon footprint of our workload, sets policies and goals, and communicates its efforts and its objectives to the rest of the organization.
        - Each member of the organization has already started thinking about green software and how to contribute to the sustainability picture, and the Core Cloud Efficiency Team has dedicated time to learn more and share the advancements in sustainable operations with the rest of the organization.
        - Collaboration and knowledge sharing through internal webinars or other type of sessions to share best practices and tested guidance are promoted and encouraged for getting everyone up to speed.
        - Incentives to improve the sustainability of the workload environment by promoting cloud efficient and carbon-aware applications are defined as quick ways to enforce policies and create the right culture.
        - None of the above.
- Sustainability for AKS: Networking and connectivity
    - What considerations have you made to enhance and optimize network efficiency to reduce unnecessary carbon emissions?
        - We followed best practices for CDN and considered using Azure CDN to lower the consumed bandwidth and keep costs down.
        - We reviewed our application requirements and Azure geographies to choose the region that is the closest to the majority of where the network packets are going.
        - We considered deploying our nodes within a proximity placement group and using availability zones based on the criticality of our workload to reduce the network traversal.
        - We considered the increase in CPU usage and network traffic generated by service mesh communication components before making the decision to use one.
        - We configured data collection rules and optimized our Log Analytics workspace to collect and retain only the data necessary to support our requirements.
        - None of the above.
- Sustainability for AKS: Security
    - What practices and tools for network security have you implemented to increase efficiency and avoid unnecessary traffic?
        - We use cloud-native log collection methods, where applicable, to simply the integration between services and remove the overhead of extra infrastructure.
        - We use a cloud-native security service, such as Application Gateway Ingress Controller, that filters and offloads traffic at the network edge to keep it from reaching our origin and to reduce energy consumption and carbon emissions.
        - We have a requirement to store log data for an extended period, so we archive it in long-term storage to lower the cost and improve energy efficiency.
        - We've carefully reviewed the network security reference architectures and configured routing accordingly so that it's minimized from endpoints to the destination and prevents applications and services from connecting to unauthorized devices.
        - We use network security tools with auto-scaling capabilities, such as Web Application Firewall on Azure Front Door or Application Gateway, to enable right-sizing, meet demand, and reduce unnecessary waste of resources.
        - We've evaluated whether to use TLS termination and made the decision to terminate TLS at our border gateway and continue with non-TLS to our workload load balancer and onwards to our workload.
        - We've configured Azure DDoS Protection Standard, combined with application design best practices, to provide enhanced DDoS mitigation features.
        - None of the above.
    - How well are your endpoint mitigation tactics and reporting optimized to detect and remediate unnecessary resource usage?
        - We have integrated Microsoft Defender for Endpoint with Defender for Cloud to detect and protect against misuse attacks.
        - We follow the recommendations from Microsoft Defender for Cloud and run automated vulnerability scanning tools, such as Defender for Containers, to avoid unnecessary resource usage.
        - None of the above.
- Sustainability for AKS: Storage
    - What design considerations for a more sustainable data storage architecture have you made?
        - We are familiar with storage compression and have enabled it to increase performance, lower the required bandwidth, and minimize unnecessary storage design climate impact.
        - The application is optimized for database query performance to reduce the latency of data retrieval while also reducing the load on the database and improve energy efficiency.
        - We chose and defined the appropriate storage using storage classes and provision volumes dynamically to automatically scale the number of storage resources and avoid underutilization.
        - We have considered how to plan backup storage retention to avoid storing backups indefinitely and allocating much unnecessary disk space.
        - None of the above.


# Other link

- Azure
    - https://learn.microsoft.com/en-us/assessments/f236012a-0070-45db-b94c-fe8de0799f38/