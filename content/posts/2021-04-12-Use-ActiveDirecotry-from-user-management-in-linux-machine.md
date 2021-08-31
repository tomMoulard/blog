---
title: "Use Active Direcotry from user management in linux machine"
date: 2022-04-12T13:19:36+01:00
author: Guillaume Moulard
url: /ADLinux
draft: false
type: post
tags:
  - active directory
  - AWS
categories:
  - tutoriel
---

## Step to setup

```bash
ssh -i youKey root@machineIP
```

- install required packages
```bash
sudo yum -y update
sudo yum -y install sssd realmd krb5-workstation samba-common-tools
````
- Setup DNS servers - add the two DNS address on Directory details in web console

change  /etc/resolv.conf
```bash
nameserver //DNS address 1 of Directory
nameserver //DNS address 2 of Directory
```
- join the domain
```bash
sudo realm join -U Administrator@my.domaine.name my.domaine.name --verbose
```

Set the SSH service to allow password authentication
- change /etc/ssh/sshd_config
```bash
PasswordAuthentication yes
```

- Add the following to the bottom of the sudoers file and save it
```bash
sudo nano /etc/sudoers
#Add the "Delegated Administrators" group from the my.domaine.name domain.
%AWS\ Delegated\ Administrators@my.domaine.name ALL=(ALL:ALL) ALL
```

- restart the sssd service
```bash
sudo systemctl restart sshd.service
sudo systemctl restart sssd.service
```

- Disconnect and Reconnect using AD credentials
```bash
ssh -l Administrator@my.domaine.name machineIP
```


