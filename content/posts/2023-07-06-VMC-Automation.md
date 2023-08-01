---
title: "VMC Automation"
date: 2023-07-06T13:00:00+01:00
author: Guillaume Moulard
url: /vmc-automation
draft: true
type: post
tags:
  - blogging
  - AWS
  - VMC
  - NSX
  - vsphere
  - terraform 
  - API
categories:
  - tutoriel
---

# Comment faire mettre en place de Infrastructure as code (IaC) pour VMWare Cloud on AWS (VMC) avec Terraform et les API de NSX. 

Pour mettre en oeuvre de l'IaC pour VMC, j'ai choisie de separé en 3 couches distinct le code 
- deployement du SDDC
- parametrage de la couche reseau NSX
- deployement des VM dans vsphere

Lors de mes mise en oeuvre j'ai utilisé les liens suivant : 
- Architecture generale
    - [vmware : deploy-and-configure-vmware-cloud-on-aws](https://blogs.vmware.com/cloud/2022/06/30/using-terraform-with-multiple-providers-to-deploy-and-configure-vmware-cloud-on-aws/)
    - [vMusketeers : NSX-T Automation using Terraform: The how (VMC)!](https://vmusketeers.com/2020/08/10/nsx-t-automation-using-terraform-the-how-vmc/)
- tips and trick NSX
    - [NicoVibert : Provider version](https://nicovibert.com/2020/02/04/terraform-provider-for-nsx-t-policy-and-vmware-cloud-on-aws/)
    - [catrouillet : NSX API usage](https://blog.catrouillet.net/2022/06/19/automate-authentication-token-on-vmware-cloud-vmc-on-aws-in-postman/)
- Generique documentation
    - [vmware : vmc documentation](https://docs.vmware.com/fr/VMware-Cloud-on-AWS/index.html)
    - [vmware : nsxt API reference]()
    - [provider terraform for vmc](https://registry.terraform.io/providers/vmware/vmc/latest/docs)
    - [provider terraform for nsx-t](https://registry.terraform.io/providers/vmware/nsxt/latest/docs)
- Autre liens utile
    - [Console VMC](https://vmc.vmware.com/console/sddcs)
    - [VMC CLI](https://flings.vmware.com/python-client-for-vmc-on-aws)

# Deployement du SDDC    

Habituellement il n'est pas obligatoire d'automatisé de deployement car c'est généralement fait une fois. cela a en plus le probleme de pouvoir automatiser la destruction du SDDC. En une commande vous avez alors perdu votre SDDC et donc toutes vos VM, cela est dangereux. Toutefois, il y a deux interet a l'automatisaiton: 
- Mise ne place d'infrastructure a la demande pour faire des testes
    - teste de paramettrage du SDDC
    - teste de paramettrage NSX et VSphere sans impacter la production
- Sauvegarde de la configuration du SDDC et des ses reseaux

confere : 

# Deployement du SDDC. 