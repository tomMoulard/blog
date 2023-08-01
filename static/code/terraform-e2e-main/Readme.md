Code author: Gilles Chekroun <gchekroun@vmware.com>

## Variables
Some variables need to be defined before we start. 

If you have a Mac with zsh, please move to bash with
`chsh -s /bin/bash`
you can move back to zsh with
`chsh -s /bin/zsh`



Set the proper credentials in `deploy-lab.sh` 
```
deploy-lab.sh
```
 - Org ID
    -   long format like `2a8ac0ba-c93d-xxxx-xxxx-7dc9918beaa5`
 - API Token
    -   Your API Token
 - AWS Account
    -   Account: `xxxxxxxxxx`
 - AWS Access Key
 - AWS Secret Key
 - AWS Token (if used)
  
 #### 1 - Terraform Phase 1 (AWS + VMC)
```
p1/main/variables.tf
```
 - `variable "AWS_region"     {default = "us-west-2"}`
  
  
 #### 2 - Terraform Phase 2 (NSXT)
```
p2/main/variables.tf
```

 #### 3 - Terraform Phase 3 (vSphere)
```
p3/main/variables.tf
```


## Deploy lab
```text
source deploy-lab.sh
```
1 - Confirm ORG and AWS parameters
 
2 - (p1) SDDC deployment
 - outputs are printed
 > pause (press Enter or ^c)
 
3 - (p2) NSXT 
 - FW rules
 > pause (press Enter or ^c)
 
4 - (p3) vSphere + Content Lib
 - VMs deployment
 > pause (press Enter or ^c)

