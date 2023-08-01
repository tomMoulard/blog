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

Habituellement il n'est pas obligatoire d'automatisé de deployement car c'est généralement fait une fois. cela a en plus le probleme de pouvoir automatiser la destruction du SDDC. En une commande vous avez alors perdu votre SDDC, cela est dangereux. Toutefois, il y a deux interet a l'automatisaiton: 
- Mise ne place d'infrastructure a la demande pour faire des testes
    - teste de paramettrage du SDDC
    - teste de paramettrage NSX et VSphere sans impacter la production
- Sauvegarde de la configuration du SDDC et des ses reseaux





```shell

git clone git@github.com:gmoulard/s3-static-website.git
cd s3-static-website

terraform init

export AWS_PROFILE=default
export TF_VAR_domain_name=to-drop1
export TF_VAR_aws_region=eu-west-1
terraform apply

aws s3 sync dist s3://$TF_VAR_domain_name


```


From backend policy API policy/api/v1/infra/domains/cgw/gateway-policies/ and policy/api/v1/infra/domains/mgw/gateway-policies/, the NSX engineering went ahead and deleted the customer configured default sections and created a default section using below payloads:

 {
      "resource_type" : "GatewayPolicy",
      "id" : "default",
      "display_name" : "default",
      "path" : "/infra/domains/mgw/gateway-policies/default",
      "relative_path" : "default",
      "parent_path" : "/infra/domains/mgw",
      "marked_for_delete" : false,
      "overridden" : false,
      "sequence_number" : 0,
      "internal_sequence_number" : 13000001,
      "category" : "LocalGatewayRules",
      "stateful" : true,
      "tcp_strict" : true,
      "locked" : false,
      "lock_modified_time" : 0,
      "is_default" : false
  }

{
    "resource_type" : "GatewayPolicy",
    "id" : "default",
    "display_name" : "default",
    "path" : "/infra/domains/cgw/gateway-policies/default",
    "relative_path" : "default",
    "parent_path" : "/infra/domains/cgw",
    "marked_for_delete" : false,
    "overridden" : false,
    "sequence_number" : 0,
    "internal_sequence_number" : 13000000,
    "category" : "LocalGatewayRules",
    "stateful" : true,
    "tcp_strict" : true,
    "locked" : false,
    "lock_modified_time" : 0,
    "is_default" : false
}

Post this the engineering have observed customer running some script which has added a lot of rules in these sections which implies it should be resolved for them.

NEXT STEPS:
=======================================================================
1. This article https://nicovibert.com/2020/02/04/terraform-provider-for-nsx-t-policy-and-vmware-cloud-on-aws/ including all third party sites may cause problems as these are not validated and unsupported by VMware.
Please Note: Following these docs/articles may lead to unwanted results.

2. https://www.samakroyd.com/2020/10/15/want-to-start-using-terraform-to-manage-vmc-here-are-some-gotchas/ -> For the customer to avoid this issue in the future.
Please note: The above document provides recommendation on how to prevent objects from being deleted during the Terraform 'destroy' operation . This document is not created by VMware.

3. Does the customer have the ability to recreate this default policy group using the API (ie. could they have fixed this issue themselves)
>>>>Customer should not be able to create/delete the default section as we are not exposing this to them. The engineering have raised a PR/bug ticket to fix the issue. This fix on the PR would be to block customer to be able to do this.

Our next follow-up/meeting/communication will be on: 11-JUL-2023


