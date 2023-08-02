---
title: "VMC Automation"
date: 2023-07-06T13:00:00+01:00
author: Guillaume Moulard
url: /vmc-automation
draft: false
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

# Terraform for VMC 
Comment faire mettre en place de Infrastructure as code (IaC) pour VMWare Cloud on AWS (VMC) avec Terraform et les API de NSX. 

Pour mettre en oeuvre de l'IaC pour VMC, j'ai choisie de separé en 3 couches distinct le code 
- deployement du SDDC
- parametrage de la couche reseau NSX
- deployement des VM dans vsphere

Lors de mes mise en oeuvre j'ai utilisé les liens suivant : 
- Architecture generale
    - :heartpulse: [vmware : deploy-and-configure-vmware-cloud-on-aws](https://blogs.vmware.com/cloud/2022/06/30/using-terraform-with-multiple-providers-to-deploy-and-configure-vmware-cloud-on-aws/)
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


# Organisation du code IaC 

La bonne organisation a mettre en place consiste a decoupé le code en 3 parties/repos
- SDDC
- NSX
- vSphere

Chaque partie est independantes. Toutefois des parametres d'entré pour nsx et vsphere sont néccessaire, ils sont generer par le sddc: 

```
provider "nsxt" {
  host                 = data.terraform_remote_state.vmc_sddc.outputs.nsxt_public_url
  username             = data.terraform_remote_state.vmc_sddc.outputs.nsxt_cloudadmin
  password             = data.terraform_remote_state.vmc_sddc.outputs.nsxt_cloudadmin_password
  vmc_auth_mode        = "Bearer"
  vmc_token            = var.api_token
  allow_unverified_ssl = true
  enforcement_point    = "vmc-enforcementpoint"
}

provider "vsphere" {
  user                 = data.terraform_remote_state.vmc_sddc.outputs.cloud_username
  password             = data.terraform_remote_state.vmc_sddc.outputs.cloud_password
  vsphere_server       = trimsuffix(trimprefix(data.terraform_remote_state.vmc_sddc.outputs.vc_url, "https://"), "/")
  allow_unverified_ssl = var.allow_unverified_ssl
}

```
Il est possible comme ici de les réutiliser dynamiquement en utilisant les tfstate. Toutefois l'utilisation de variable d'environemnet est a privilegier. Lors de l'utilisation de plusieurs environement des prod et de test une erreur de manipulation tfstate peut etre fatale. 


# Deployement du SDDC    

Habituellement il n'est pas obligatoire d'automatisé de deployement car c'est généralement fait une fois. cela a en plus le probleme de pouvoir automatiser la destruction du SDDC. En une commande vous avez alors perdu votre SDDC et donc toutes vos VM, cela est dangereux. Toutefois, il y a deux interet a l'automatisaiton: 
- Mise ne place d'infrastructure a la demande pour faire des testes
    - teste de paramettrage du SDDC
    - teste de paramettrage NSX et VSphere sans impacter la production
- Sauvegarde de la configuration du SDDC et des ses reseaux

Cf : [vmware : deploy-and-configure-vmware-cloud-on-aws Part1](https://blogs.vmware.com/cloud/2022/06/30/using-terraform-with-multiple-providers-to-deploy-and-configure-vmware-cloud-on-aws/)

La clef d'api a utiliser doit etre genere dans la console VMWare : https://console.cloud.vmware.com/csp/gateway/portal/#/user/tokens

## Raccordment du SDDC a AWS. 

### Liens avec le connected account
Le liens avec le connexted account se fait lors de la creation du SDDC. Les frais reseau du au debit sur cette inteconextion n'est pas facturé par AWS. Une ENI est crée dans le compte.

### Liens entre SDDC et la transit gateway 

Pour raccorder le SDDC a une transite gateway, le SDDC doit etre raccorder a un SDDC group. C'est lui qui manage le liens entre le SDDC et la transite gateway. 

Pour connecter l'external TGW, il faut avoir les informations : 
- ID du compte : XXXXXXXXXXXX
- ID tgw : tgw-0eXXXXXXXXXX
- region : paris/paris
- Routage a mettre en place dans les SDDC vers les subnet externe.
  

# Deployement dans NSX 

Lors de l'implementation des rêgles il faut ditingué les quelques regles d'infrastructure qui goivent etre porté par la Gateway firewall (GFW) et l'ensembles des autres regles qui doivent etre porté par le Distributed firewall. 

Il faut noter que tout les flux ouvert dans la GFW doivent en plus etre ouvert dans le DFW.

Dans notre projet nous avons opté pour l'intégration des regles via des fichiers CSV, ainsi la creation d'une nouvelle regle n'implique par la modification des fichier terraform. 


### Exemple de creation de rêgles
```
resource "nsxt_policy_gateway_policy" "icmp_from_group" {

  display_name = "icmp_from_group"
  description  = "icmp_from_group"
  category     = "LocalGatewayRules"
  domain       = "cgw"

  rule {
    action                = "ALLOW"
    display_name          = "icmp_from_group"
    source_groups         = [nsxt_policy_group.group["groupeSource"].path]
    sources_excluded      = false
    destination_groups    = [nsxt_policy_group.group["groupeDestination"].path]
    destinations_excluded = false
    services              = [data.nsxt_policy_service.icmp.path]
    direction             = "IN_OUT"
    disabled              = false
    ip_version            = "IPV4_IPV6"
    logged                = true
    scope                 = ["/infra/labels/cgw-direct-connect"]
  }
}
```
- Scope est le paramettre qui definie l'interface ou la rêlge s'applique. Elle peut etre : 
    - /infra/labels/cgw-all
    - /infra/labels/cgw-vpn
    - /infra/labels/cgw-public
    - /infra/labels/cgw-cross-vpc
    - /infra/labels/cgw-direct-connect
- destinations_excluded peut etre a true ou false. Cela permet d'inversé la regle pour la posé sur (tout ce qui n'est pas le groupe) ou ( tout ce qui est dans le groupe) 

## Gateway firewall rules
Lors de la vie du projet nous avons eu a recrér les regles de default gateway qui avais été detruite par Terraforme 

```
nsxt_policy_gateway_policy.mgw_policy: Destroying... [id=default]
nsxt_policy_gateway_policy.cgw_policy: Destroying... [id=default]
nsxt_policy_gateway_policy.mgw_policy: Destruction complete after 1s
nsxt_policy_gateway_policy.cgw_policy: Destruction complete after 2s
```
Pour résoudre le probleme nous avons utiliser les directement les API De NSX-T

```
API PUT policy/api/v1/infra/domains/mgw/gateway-policies/
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

API PUT policy/api/v1/infra/domains/cgw/gateway-policies/ 
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

```

Cf : [vmware : deploy-and-configure-vmware-cloud-on-aws Part2](https://blogs.vmware.com/cloud/2022/07/06/vmware-cloud-on-aws-terraform-deployment-phase-2/)

# Deployement dans vSphere

Lors du deployement vsphere l'utilisation d'un referenciel yaml. Les problme recontrés ont ete sur lors de la construction des images des templates. Ils doivent avoir un attribue spécifique, il faut mettre otherLinux / otherLinux64Guest

Cf : [vmware : deploy-and-configure-vmware-cloud-on-aws Part3](https://blogs.vmware.com/cloud/2022/07/15/vmware-cloud-on-aws-terraform-deployment-phase-3/)



