---
title: "Comment bien installer docker ?"
date: 2020-10-06T12:00:00+01:00
author: Tom Moulard
url: /installer-docker
draft: false
type: post
tags:
  - installation
  - script
  - docker
categories:
  - setup
---

Vu que c'est une question que me revient souvent, voila un petit tutoriel sur comment installer docker proprement et surtout comment le configurer.

# Comment installer docker ?
## Sur windows ou Mac
[Docker Desktop](https://www.docker.com/products/docker-desktop) est pour moi un bon compromis pour l'installation de Docker sur Windows ou Mac.

Le GUI apporte une manière simple de visualiser se qui se passe dans docker.

## Sur une Distro basée sur Debian
```bash
sudo apt install -y docker docker.io
sudo groupadd docker
sudo gpasswd -a $USER docker
newgrp docker
reboot
```
La commande `newgrp docker` permet d'utiliser docker sans avoir à le préfixer de `sudo`.

## Sur une Distro basée sur Arch
Avec l'user `root` (`sudo su`), faire:
```zsh
pacman -Syu docker docker-compose
groupadd docker
gpasswd -a $USER docker
systemctl enable docker
systemctl start docker
newgrp docker
reboot
```

La commande `newgrp docker` permet d'utiliser docker sans avoir à le préfixer de `sudo`.

## Sur une Distro basée sur Centos
Avec l'user `root` (`sudo su`), faire:
```bash
yum install -y yum-utils

yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

yum install --allowerasing -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl start docker
```

# Tester son installation:
```bash
docker run hello-world
```

# Comment installer docker-compose ?
On peut utiliser la dernière version de `docker-compose`
```bash
curl -L https://github.com/docker/compose/releases/download/$(curl -Ls https://www.servercow.de/docker-compose/latest.php)/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

Sinon, il faut utiliser la dernière version présente sur les repository de la distro que vous utilisez.
