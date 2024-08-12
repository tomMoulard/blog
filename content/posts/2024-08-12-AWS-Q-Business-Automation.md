---
title: "Amazon Q Business Automation"
date: 2024-08-12T13:00:00+01:00
author: Guillaume Moulard
url: /AWSQBusiness
draft: false
type: post
tags:
  - blogging
  - AWS
  - Amazon Q Business
  - terraform
  - API
categories:
  - tutoriel
---


# Terraform for Amazon Q Business


Amazon Q business et l'offre SaaS d’IA Générative permettant d'implémenter des algorithmes de génération augmentée de récupération (RAG)
. 
La mise en place ce fait au travers la création d'une application dans lequel on crée une utilise un index. On a alors la possibilité de créer des data source. Il faut ensuite ce qui permet d'utiliser l'agent déployer. À ce jour il n'est possible de le faire que dans les régions de Virginie du Nord et d'oregon.

Le code que vous trouverez les ci-dessous permet de créer tout cela automatiquement. Seule des documents qui sont indexés dans bucket  S3 peuvent être intégrés au RAG.


## Organisation du code IaC

Pour la simplicité de lecture tout le code est intégré dans un fichier main.tf. Au futur les pratiques il serait plus intéressant de le découper dans une architecture classique de terraform.
Toute la configuration du data source S3 et intégré dans le fichier datasourceS3.tf. 
Pour une simplicité seule et l'une pour connecter L’IAM identity center local au compte qui est dans la même région que Amazon Q Business. L'autre variable et juste pour l'utiliser nom de bucket S3 accessible à toutes les régions

## appel de terrafrom

```
$ export AWS_REGION=us-east-1
$ export AWS_ACCESS_KEY_ID="...................."
export AWS_SECRET_ACCESS_KEY="........................................"
export AWS_SESSION_TOKEN="............................................................"

$ terraform init
$ terraform plan
$ terraform apply  

## test and destroy

$ terraform destroy

```
## Fichier terrafrom  

### main.tf

```
terraform {
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.0"
    }
  }
}

# Configure the AWS CC Provider
provider "awscc" {
  region = "us-east-1"
}

#provider "aws" {
#  region = "us-west-1"
#}

resource "random_id" "id" {
  byte_length = 8
}


resource "awscc_qbusiness_application" "demo_app" {
  description                  = "Demo QBusiness Application"
  display_name                 = "Demo_AmazonQ_Business_IaC"
  identity_center_instance_arn = var.identity_center_instance_arn
  attachments_configuration = {
    attachments_control_mode = "ENABLED"
  }

  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]

}


resource "awscc_qbusiness_index" "demo_idx" {
  application_id = awscc_qbusiness_application.demo_app.application_id
  display_name   = "example_q_index"
  description    = "Example QBusiness Index"
  #type           = "ENTERPRISE"
  type           = "STARTER"
  capacity_configuration = {
    units = 1
  }

  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]

}


resource "awscc_qbusiness_retriever" "example" {
  application_id = awscc_qbusiness_application.demo_app.application_id
  display_name   = "example_q_retriever"
  type           = "NATIVE_INDEX"

  configuration = {
    native_index_configuration = {
      index_id = awscc_qbusiness_index.demo_idx.index_id
    }
  }
  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]

}


resource "awscc_qbusiness_web_experience" "webExperienceDemo" {
  application_id              = awscc_qbusiness_application.demo_app.application_id
  role_arn                    = awscc_iam_role.iamDemoRole.arn
  sample_prompts_control_mode = "ENABLED"
  subtitle                    = "Drop a file and ask questions"
  title                       = "Sample Amazon Q Business App"
  welcome_message             = "Welcome, please enter your questions"

  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]
}

resource "awscc_iam_role" "iamDemoRole" {
  role_name   = "Amazon-QBusiness-WebExperience-Role"
  description = "Grants permissions to AWS Services and Resources used or managed by Amazon Q Business"
  assume_role_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "QBusinessTrustPolicy"
        Effect = "Allow"
        Principal = {
          Service = "application.qbusiness.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:SetContext"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnEquals = {
            "aws:SourceArn" = awscc_qbusiness_application.demo_app.application_arn
          }
        }
      }
    ]
  })
  policies = [{
    policy_name = "qbusiness_policy"
    policy_document = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid = "QBusinessConversationPermission"
          Effect = "Allow"
          Action = [
            "qbusiness:Chat",
            "qbusiness:ChatSync",
            "qbusiness:ListMessages",
            "qbusiness:ListConversations",
            "qbusiness:DeleteConversation",
            "qbusiness:PutFeedback",
            "qbusiness:GetWebExperience",
            "qbusiness:GetApplication",
            "qbusiness:ListPlugins",
            "qbusiness:GetChatControlsConfiguration"
          ]
          Resource = awscc_qbusiness_application.demo_app.application_arn
        }
      ]
    })
  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]
}
]
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

```

### datasourceS3.tf

```

resource "awscc_qbusiness_data_source" "Demo_dss3" {
  application_id = awscc_qbusiness_application.demo_app.application_id
  display_name   = "example_q_data_source_S3"
  index_id       = awscc_qbusiness_index.demo_idx.index_id
  role_arn       = awscc_iam_role.demoRoleS3.arn
  configuration = jsonencode(
    {
      type     = "S3"
      version  = "1.0.0"
      syncMode = "FORCED_FULL_CRAWL"
      connectionConfiguration = {
        repositoryEndpointMetadata = {
          BucketName = var.bucket_name
        }
      }
      additionalProperties = {
        inclusionPrefixes = ["docs/"]
      }
      repositoryConfigurations = {
        document = {
          fieldMappings = [
            {
              dataSourceFieldName = "s3_document_id"
              indexFieldType      = "STRING"
              indexFieldName      = "s3_document_id"
            }
          ]
        }
      }
    }
  )
  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]
}

resource "awscc_iam_role" "demoRoleS3" {
  role_name   = "QBusiness-DataSource-Role"
  description = "QBusiness Data source role"
  assume_role_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowsAmazonQToAssumeRoleForServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "qbusiness.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })

  tags = [{
    key   = "Modified By"
    value = "AWSCC"
  }]
}

resource "awscc_iam_role_policy" "demoRoleS3_policy" {
  policy_name = "Demo_iam_role_policy"
  role_name   = awscc_iam_role.demoRoleS3.id

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      },
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::${var.bucket_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "qbusiness:BatchPutDocument",
          "qbusiness:BatchDeleteDocument"
        ]
        Resource = "arn:aws:qbusiness:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application/${awscc_qbusiness_application.demo_app.id}/index/${awscc_qbusiness_index.demo_idx.index_id}"
      },
      {
        Effect = "Allow"
        Action = ["qbusiness:PutGroup",
            "qbusiness:CreateUser",
            "qbusiness:DeleteGroup",
            "qbusiness:UpdateUser",
            "qbusiness:ListGroups"]
        Resource = [
          "arn:aws:qbusiness:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application/${awscc_qbusiness_application.demo_app.id}",
          "arn:aws:qbusiness:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application/${awscc_qbusiness_application.demo_app.id}",
          "arn:aws:qbusiness:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application/${awscc_qbusiness_application.demo_app.id}/index/${awscc_qbusiness_index.demo_idx.id}",
          "arn:aws:qbusiness:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:application/${awscc_qbusiness_application.demo_app.id}/index/${awscc_qbusiness_index.demo_idx.id}/data-source/*"
        ]
      }
    ]
  })
}



```

### variable.tf

```

variable "identity_center_instance_arn" {
  description = "can be view on IAM Identity Center, Parameter menu : ARN instance"
  default     = "arn:aws:sso:::instance/ssoins-XXXXXXXXXXXXXXXX"
}

variable "bucket_name" {
  type        = string
  description = "Name of the bucket to be used as the data source input"
  default      = "myS3bucketname"
}



```


Cf : [vmware : deploy-and-configure-vmware-cloud-on-aws Part2](https://blogs.vmware.com/cloud/2022/07/06/vmware-cloud-on-aws-terraform-deployment-phase-2/)

Cf : [vmware : deploy-and-configure-vmware-cloud-on-aws Part3](https://blogs.vmware.com/cloud/2022/07/15/vmware-cloud-on-aws-terraform-deployment-phase-3/)

