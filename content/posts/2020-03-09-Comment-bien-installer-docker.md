---
title: "Comment bien installer docker ?"
date: 2020-03-09T21:32:48+01:00
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
## Sur une Distro basée sur Debian
```bash
sudo apt install -y docker docker.io docker-compose
sudo groupadd docker
sudo gpasswd -a $USER docker
newgrp docker # Or reboot
docker run hello-world
```

On peux voir que la première ligne sert à installer docker et docker-compose, tandis que celles d'après permettent d'utiliser docker sans avoir à le préfixer de `sudo`.
