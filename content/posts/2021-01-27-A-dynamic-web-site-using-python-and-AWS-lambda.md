---
title: "A Dynamic Web Site using Python and AWS Lambda"
date: 2021-01-27T10:40:17+01:00
author: Tom Moulard
url: /serverless-python
draft: false
type: post
tags:
  - python
  - Cloud
  - AWS
  - lambda
categories:
  - tuto
---

Nous allons voir comment utiliser les Lambda d'AWS pour servir un site web
dynamique et en mode serverless.

# Python

La fonction python que l'on va utiliser pour la lambda doit avoir deux
paramètres : `event` et `context`.

```python
def my_lambda_function(event, context):
    return "Hello world !"
```

Pour donner une idée de ce que contiennent `event` et `context`, j'ai créé
cette fonction :
```python
import os
import json

def debug_lambda(event, context):
    json_region = os.environ['AWS_REGION']
    return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
                },
            "body": json.dumps({
                "Region ": json_region,
                'event' : str(event),
                'context': str(context)
                })
            }
```

Où la réponse de la lambda donne :
```json
{
    "Region ": "eu-west-3",
    "event": "{'resource': '/', 'path': '/', 'httpMethod': 'GET', 'headers': {'Accept': 'text/html', 'Accept-Encoding': 'gzip, deflate, br', 'cache-control': 'max-age=0', 'CloudFront-Forwarded-Proto': 'https', 'CloudFront-Is-Desktop-Viewer': 'true', 'CloudFront-Is-Mobile-Viewer': 'false', 'CloudFront-Is-SmartTV-Viewer': 'false', 'CloudFront-Is-Tablet-Viewer': 'false', 'CloudFront-Viewer-Country': 'FR', 'dnt': '1', 'Host': '[REDACTED]', 'sec-fetch-dest': 'document', 'sec-fetch-mode': 'navigate', 'sec-fetch-site': 'none', 'sec-fetch-user': '?1', 'sec-gpc': '1', 'upgrade-insecure-requests': '1', 'User-Agent': '[REDACTED]', 'Via': '[REDACTED]', 'X-Amz-Cf-Id': '[REDACTED]', 'X-Amzn-Trace-Id': 'Root=1-[REDACTED]', 'X-Forwarded-For': '[REDACTED]', 'X-Forwarded-Port': '443', 'X-Forwarded-Proto': 'https'}, 'multiValueHeaders': {'Accept': ['text/html'], 'Accept-Encoding': ['gzip, deflate, br'], 'Accept-Language': ['fr-FR'], 'cache-control': ['max-age=0'], 'CloudFront-Forwarded-Proto': ['https'], 'CloudFront-Is-Desktop-Viewer': ['true'], 'CloudFront-Is-Mobile-Viewer': ['false'], 'CloudFront-Is-SmartTV-Viewer': ['false'], 'CloudFront-Is-Tablet-Viewer': ['false'], 'CloudFront-Viewer-Country': ['FR'], 'dnt': ['1'], 'Host': ['[REDACTED]'], 'sec-fetch-dest': ['document'], 'sec-fetch-mode': ['navigate'], 'sec-fetch-site': ['none'], 'sec-fetch-user': ['?1'], 'sec-gpc': ['1'], 'upgrade-insecure-requests': ['1'], 'User-Agent': ['[REDACTED]'], 'Via': ['[REDACTED]'], 'X-Amz-Cf-Id': ['[REDACTED]'], 'X-Amzn-Trace-Id': ['Root=1-[REDACTED]'], 'X-Forwarded-For': ['[REDACTED]'], 'X-Forwarded-Port': ['443'], 'X-Forwarded-Proto': ['https']}, 'queryStringParameters': None, 'multiValueQueryStringParameters': None, 'pathParameters': None, 'stageVariables': None, 'requestContext': {'resourceId': '[REDACTED]', 'resourcePath': '/', 'httpMethod': 'GET', 'extendedRequestId': '[REDACTED]', 'requestTime': '[REDACTED]', 'path': '/test', 'accountId': '[REDACTED]', 'protocol': 'HTTP/1.1', 'stage': 'test', 'domainPrefix': '[REDACTED]', 'requestTimeEpoch': 1611741450517, 'requestId': '[REDACTED]', 'identity': {'cognitoIdentityPoolId': None, 'accountId': None, 'cognitoIdentityId': None, 'caller': None, 'sourceIp': '[REDACTED]', 'principalOrgId': None, 'accessKey': None, 'cognitoAuthenticationType': None, 'cognitoAuthenticationProvider': None, 'userArn': None, 'userAgent': '[REDACTED]', 'user': None}, 'domainName': '[REDACTED]', 'apiId': '[REDACTED]'}, 'body': None, 'isBase64Encoded': False}",
    "context": "<__main__.LambdaContext object at 0x7f0f14df07c0>"
}
```

Maintenant qu'on a ça, on peut faire tous ce qu'on veut :-)

Pour pouvoir utiliser le code, il va falloir créer une archive zip.

```bash
$ zip python.zip *.py
```

# Terraform
Maintenant qu'on a une fonction python à faire tourner, il faut la déployer !
Dans ce tuto, nous utiliserons Terraform.

Pour déployer sur AWS il faut avoir une clef d'accès avec son ID et son secret.
Cette clef peut être récupérée dans la partie IAM de la console AWS.

## Setup Terraform
Pour commencer, il faut dire a Terraform quel `provider` utiliser:
```terraform
provider "aws" {
    region = "eu-west-3"
}
```

J'utilise `eu-west-3`, mais vous pouvez utiliser n'importe quelle région :)

## La Lambda
Pour la resource de la lambda, il faut avoir une resource de type `aws_lambda_function`:
```terraform
resource "aws_lambda_function" "lambda_function" {
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = var.handler
  runtime          = var.runtime       # le type de code utilisé (i.e. python3.8)
  filename         = var.src_zip       # le nom du ficher .zip contentant le code
  function_name    = var.function_name # le nom de la fonction
  source_code_hash = filebase64sha256(var.src_zip)
}
```

Il faut aussi une resource de type `aws_iam_role`:
```terraform
resource "aws_iam_role" "lambda_exec_role" {
  name        = "lambda_exec"
  path        = "/"
  description = "Allows Lambda Function to call AWS services on your behalf."

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
```

## La gateway
Pour pouvoir accéder au code de la lambda, il faut mettre une gateway API en tant que proxy.

```terraform
resource "aws_api_gateway_rest_api" "example" {
  name        = "ServerlessExample"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "proxy"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_rest_api.example.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = "test"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.example.execution_arn}/*/*"
}
```

Et pour enfin avoir l'url sur laquelle tapper pour voir le résultat de la fonction.
```terraform
output "base_url" {
  value = aws_api_gateway_deployment.example.invoke_url
}
```

Cela va donner:
```
Outputs:

base_url = https://wncgbhu7te.execute-api.eu-west-3.amazonaws.com/test
```

La source du blog est disponible sur [github](https://github.com/tomMoulard/LambdaCSVChart/tree/blog).
Et la lambda est accessible sur [aws](https://wncgbhu7te.execute-api.eu-west-3.amazonaws.com/test).

# Aller plus loin

 - [github action publish](https://github.com/tomMoulard/LambdaCSVChart/blob/main/.github/workflows/terraform.yml)
 - Utiliser un DNS (R53)
