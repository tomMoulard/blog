---
title: "Comment bien installer docker ?"
date: 2020-09-26T08:30:00+01:00
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
sudo apt install -y docker docker.io docker-compose
sudo groupadd docker
sudo gpasswd -a $USER docker
newgrp docker
reboot
docker run hello-world
```
On peux voir que la première ligne sert à installer docker et docker-compose, tandis que celles d'après permettent d'utiliser docker sans avoir à le préfixer de `sudo`.

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

Tester son installation:
```zsh
docker run hello-world
```

