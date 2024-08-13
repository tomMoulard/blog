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

Amazon Q business and the SaaS offer of Generative AI allowing to implement algorithms of augmented generation of recovery (RAG)
.
The implementation is done through the creation of an application in which we create a use an index. We then have the possibility of creating data sources. It is then necessary to deploy what allows to use the agent. To date it is only possible to do it in the regions of Northern Virginia and Oregon.

The code that you will find below allows to create all this automatically. Only documents that are indexed in bucket S3 can be integrated into the RAG.

## Organization of the IaC code

For the simplicity of reading all the code is integrated into a main.tf file. In the future practices it would be more interesting to cut it into a classic terraform architecture.
All the configuration of the S3 data source is integrated into the datasourceS3.tf file. For simplicity only and one to connect the local IAM identity center to the account which is in the same region as Amazon Q Business. The other variable is just to use it S3 bucket name accessible to all regions

ref : https://docs.aws.amazon.com/amazonq/
## terrafrom call

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


## some instruction is not available on terraform
Unfortunately in the current version of awscc 1.9.0 all the necessary features seem not to be available. Changes in AWS CLI are necessary after the terraform.
- added groups / user rights
- Launch of data sync

### add group souscription

https://docs.aws.amazon.com/amazonq/latest/qbusiness-ug/adding-users-groups.html

refere ou refere terraform output for parameter and IAM Identity Center from group ID / principal-id
``` shell 

aws sso-admin create-application-assignment \
--application-arn "arn:aws:sso::XXXX97133776:application/ssoins-XXXXf6da3a3ebd60/apl-XXXX4f0f59689bea" \
--principal-id XXXX1488-b0a1-70d5-86f8-d8dc02244955 \
--principal-type GROUP


``` 

### start data source sync

refere terraform output for parameter
``` shell 


aws qbusiness start-data-source-sync-job \
          --application-id  XXXX167a-161d-40ba-971d-31ae61148d6c \
          --index-id XXXXd232-8330-4300-9bd8-9e81f81e886f        \
          --data-source-id XXXXc7b5-dfdf-41a8-9706-2583af439a4e               

```






## Terrafrom file  

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

output "application-id"  { value = awscc_qbusiness_application.demo_app.application_id }
output "index-id"        { value = awscc_qbusiness_index.demo_idx.index_id }

output "application-arn" { value = awscc_qbusiness_application.demo_app.identity_center_application_arn }



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


output "data-source-id"  { value = awscc_qbusiness_data_source.Demo_dss3.data_source_id }


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


