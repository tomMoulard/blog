#!/usr/bin/env bash

clear
echo -e "\033[1m"   #Bold ON
echo " ==========================="
echo "     VMC deployment"
echo " ==========================="
echo "===== Set Credentials ============="
echo -e "\033[0m"   #Bold OFF

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset TF_VAR_my_org_id
unset TF_VAR_vmc_token
unset TF_VAR_AWS_account
unset TF_VAR_host
unset VM1_DNS

DEF_ORG_ID="3d1c2abe-xxxx-xxxx-bd92-071d48a6b2ab"
#read -p "Enter your ORG ID (long format) [default=$DEF_ORG_ID]: " TF_VAR_my_org_id
TF_VAR_my_org_id="${TF_VAR_my_org_id:-$DEF_ORG_ID}"
#echo ".....Exporting $TF_VAR_my_org_id"
export TF_VAR_my_org_id=$TF_VAR_my_org_id
#echo ""

DEF_TOKEN="qpQ3vZ........"
#read -p "Enter your VMC API token [default=$DEF_TOKEN]: " TF_VAR_vmc_token
TF_VAR_vmc_token="${TF_VAR_vmc_token:-$DEF_TOKEN}"
#echo ".....Exporting $TF_VAR_vmc_token"
export TF_VAR_vmc_token=$TF_VAR_vmc_token
#echo ""

ACCOUNT="0631......"
#read -p "Enter your AWS Account [default=$ACCOUNT]: " TF_VAR_AWS_account
TF_VAR_AWS_account="${TF_VAR_AWS_account:-$ACCOUNT}"
#echo ".....Exporting $TF_VAR_AWS_account"
export TF_VAR_AWS_account=$TF_VAR_AWS_account
#echo ""

ACCESS="xxxxx......"
#read -p "Enter your AWS Access Key [default=$ACCESS]: " TF_VAR_access_key
TF_VAR_access_key="${TF_VAR_access_key:-$ACCESS}"
#echo ".....Exporting $TF_VAR_access_key"
export AWS_ACCESS_KEY_ID=$TF_VAR_access_key
#echo ""

SECRET="xxxxx........"
#read -p "Enter your AWS Secret Key [default=$SECRET]: " TF_VAR_secret_key
TF_VAR_secret_key="${TF_VAR_secret_key:-$SECRET}"
#echo ".....Exporting $TF_VAR_secret_key"
export AWS_SECRET_ACCESS_KEY=$TF_VAR_secret_key

TOKEN="xxxxxx......"
#read -p "Enter your AWS Session Token [default=$TOKEN]: " TF_VAR_AWS_session_token
TF_VAR_token="${TF_VAR_token:-$TOKEN}"
#echo ".....Exporting $TF_VAR_token"
export AWS_SESSION_TOKEN=$TF_VAR_token


#----------------------------------
read  -p $'\nPress enter to continue (^C to stop)...\n'

echo -e "\033[1m"   #Bold ON
echo "===== PHASE 1: Creating SDDC ==========="
echo -e "\033[0m"   #Bold OFF
cd ./p1/main
terraform init
terraform apply
cd ../../
#----------------------------------
#Export proxy URL without "

export TF_VAR_host=$(terraform output -state=./phase1.tfstate proxy_url | sed 's/\"//g')
export TF_VAR_nsxt_username=$(terraform output -state=./phase1.tfstate nsxt_cloudadmin)
export TF_VAR_nsxt_password=$(terraform output -state=./phase1.tfstate nsxt_cloudadmin_password)
read  -p $'\nPress enter to continue (^C to stop)...\n'
cd ./p2/main
terraform  init

echo -e "\033[1m"   #Bold ON
echo "===== PHASE 2: Networking and Security ==========="
echo -e "\033[0m"   #Bold OFF

terraform apply
cd ../..
#----------------------------------

read  -p $'\nPress enter to continue (^C to stop)...\n'
echo -e "\033[1m"   #Bold ON
echo "===== PHASE 3: Create Content Lib and deploy VM  ==========="
echo -e "\033[0m"   #Bold OFF
cd ./p3/main
terraform  init
terraform apply
cd ../..

#----------------------------------



