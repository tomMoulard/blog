---
title: "Une application Multi Architecture en Golang dans Docker"
date: 2019-11-20T13:19:36+01:00
author: Tom Moulard
url: /multi-arch-golang-app-docker
draft: false
type: post
tags:
  - tutoriel
  - multiple-architecture
  - docker
  - golang
categories:
  - tutoriel
---

# Ce n'est pas un exemple qui fonctionne !

Faire une application en Go et le mettre dans un docker est très important pour la portabilité.

Un `Dockerfile` simple pour une application:
```Dockerfile
FROM scratch
COPY static/ /srv/static/
COPY app /srv/app
CMD ["/srv/app"]
```

Et le `docker-compose` qui va avec:
```docker-compose
version '2'
service:
  app:
    build: .
    port:
      - '80:80'
```

# Golang compilation

J'ai récupéré sur se [gist](https://gist.github.com/asukakenji/f15ba7e588ac42795f421b48b8aede63) une liste des GOOS/GOARCH supportés par go:

- `darwin/386`
- `darwin/amd64`
- `dragonfly/amd64`
- `freebsd/386`
- `freebsd/amd64`
- `freebsd/arm`
- `linux/386`
- `linux/amd64`
- `linux/arm`
- `linux/arm64`
- `linux/ppc64`
- `linux/ppc64le`
- `linux/mips`
- `linux/mipsle`
- `linux/mips64`
- `linux/mips64le`
- `linux/s390x`
- `nacl/386`
- `nacl/amd64p32`
- `nacl/arm`
- `netbsd/386`
- `netbsd/amd64`
- `netbsd/arm`
- `openbsd/386`
- `openbsd/amd64`
- `openbsd/arm`
- `plan9/386`
- `plan9/amd64`
- `plan9/arm`
- `solaris/amd64`
- `windows/386`
- `windows/amd64`

On peux donc construire un script shell simple qui permet de compiler l'application:
```sh
#!/bin/bash
os_archs=( darwin/386 darwin/amd64 dragonfly/amd64 freebsd/386 freebsd/amd64 freebsd/arm linux/386 linux/amd64 linux/arm linux/arm64 linux/ppc64 linux/ppc64le linux/mips linux/mipsle linux/mips64 linux/mips64le linux/s390x nacl/386 nacl/amd64p32 nacl/arm netbsd/386 netbsd/amd64 netbsd/arm openbsd/386 openbsd/amd64 openbsd/arm plan9/386 plan9/amd64 plan9/arm solaris/amd64 windows/386 windows/amd64 )
build="go build -o app"

for os_arch in "${os_archs[@]}"; do
    echo $os_arch
    GOARCH=${os_arch#*/} GOOS=${os_arch%/*} CGO_ENABLED=0 $build
done
```

# Docker manifest
Et comme le dit la [doc docker](https://docs.docker.com/engine/reference/commandline/manifest/)

> This command is experimental on the Docker client.

(Cette commande est expérimentale sur le client docker)

Pour activer les fonctions expérimentales du client cli de Docker, il faut ajouter cette ligne `"experimental": "enabled"` dans le fichier de configuration Docker qui à tendance à être ici: `$HOME/.docker/config.json`.

Sur Windows, il faut sélectionner l’icône Docker et sélectionner `Settings`.
Il faut ensuite sélectionner `Daemon` puis cliquer sur la checkbox `Experimental Features` pour les activer

## Mais à quoi ça sert ?
La solution simple pour avoir plusieurs architectures pour une même application est d'utiliser les **tags**(ou repository différents, mais à éviter encore plus).
Il faut donc construire une image par GOOS/GOARCH supportés.
Et on aurait une liste de tags comme ça:

 - my-app/app:latest
 - my-app/app:latest-windows-amd64
 - ...
 - my-app/app:XXXXXXX-windows-amd64

Soit faire:
```sh
#!/bin/bash
os_archs=( darwin/386 darwin/amd64 dragonfly/amd64 freebsd/386 freebsd/amd64 freebsd/arm linux/386 linux/amd64 linux/arm linux/arm64 linux/ppc64 linux/ppc64le linux/mips linux/mipsle linux/mips64 linux/mips64le linux/s390x nacl/386 nacl/amd64p32 nacl/arm netbsd/386 netbsd/amd64 netbsd/arm openbsd/386 openbsd/amd64 openbsd/arm plan9/386 plan9/amd64 plan9/arm solaris/amd64 windows/386 windows/amd64 )
build="go build -o app"
dk_app=my-app/app
hash=$(git rev-parse --short HEAD)

for os_arch in "${os_archs[@]}"; do
    echo $os_arch

    # Compiling
    GOARCH=${os_arch#*/}
    GOOS=${os_arch%/*}
    GOARCH=${GOARCH} GOOS=${GOOS} CGO_ENABLED=0 $build

    # Building and push docker image
    dk_name="${dk_app}:${hash}-${GOOS}-${GOARCH}"
    dk_name_latest="${dk_app}:latest-${GOOS}-${GOARCH}"
    docker build -t ${dk_name} .
    docker tag ${dk_name} ${dk_name_latest}
    docker push ${dk_name} ${dk_name_latest}
done
```

Mais il serait mieux de ne pas remplir la liste des tags comme ça.
Et cela ne permet pas d'être **vraiment** multi architecture: sur une machine ARM, il faut un tag différent d'une machine x86_64.

Les manifest de Docker permettent de créer une image qui soit architecture agnostique: Que l'on récupère l'image sur un ARM ou sur un x86_64, la commande est la même:
```bash
docker pull my-app/app
```

Par exemple, sur ma machine amd64:
```bash
$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://cloud.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/

```

Et sur ma machine arm:
```bash
$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (arm32v7)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

```

Où la différence se trouve juste après la deuxième étape où on peux lire:

`The Docker daemon pulled the [...] image [...] (amd64)` puis

`The Docker daemon pulled the [...] image [...] (arm32v7)`.

## Création du manifest
**Attention, il __faut__ avoir push les images sur un registery avant de créer le manifest**.

```bash
$ docker manifest create -h
Flag shorthand -h has been deprecated, please use --help

Usage:  docker manifest create MANIFEST_LIST MANIFEST [MANIFEST...]

Create a local manifest list for annotating and pushing to a registry

Options:
  -a, --amend      Amend an existing manifest list
      --insecure   Allow communication with an insecure registry
```

Il faut donc faire la commande `docker manifest create` suivi du nom de l'___image___ à créer et enfin suivi des noms des différentes images précédemment crées à ajouter dans le manifest.

Ce qui donne, à la main:
```bash
$ docker push my-app/app:latest-windows-amd64 my-app/app:latest-windows-arm
$ docker manifest create my-app/app:latest my-app/app:latest-windows-amd64 my-app/app:latest-windows-arm ...
Created manifest list docker.io/my-app/app:latest
```

Et on peux donc faire:
```bash
$ docker manifest inspect my-app/app:latest
{
   "schemaVersion": 2,
   "mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",
   "manifests": [
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 42,
         "digest": "sha256:4224",
         "platform": {
            "architecture": "amd64",
            "os": "windows"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 42,
         "digest": "sha256:4224",
         "platform": {
            "architecture": "arm",
            "os": "windows"
         }
      }
   ]
}
```

## Script Shell
```bash
#!/bin/bash
os_archs=( darwin/386 darwin/amd64 dragonfly/amd64 freebsd/386 freebsd/amd64 freebsd/arm linux/386 linux/amd64 linux/arm linux/arm64 linux/ppc64 linux/ppc64le linux/mips linux/mipsle linux/mips64 linux/mips64le linux/s390x nacl/386 nacl/amd64p32 nacl/arm netbsd/386 netbsd/amd64 netbsd/arm openbsd/386 openbsd/amd64 openbsd/arm plan9/386 plan9/amd64 plan9/arm solaris/amd64 windows/386 windows/amd64 )
build="go build -o app"
dk_app=my-app/app
hash=$(git rev-parse --short HEAD)

for os_arch in "${os_archs[@]}"; do
    echo $os_arch

    # Compiling
    GOARCH=${os_arch#*/}
    GOOS=${os_arch%/*}
    GOARCH=${GOARCH} GOOS=${GOOS} CGO_ENABLED=0 $build

    # Building and push docker image
    dk_name="${dk_app}:${hash}-${GOOS}-${GOARCH}"
    dk_name_latest="${dk_app}:latest-${GOOS}-${GOARCH}"
    docker build -t ${dk_name} --platform ${GOOS} . -q
    docker tag  ${dk_name} ${dk_name_latest}
    docker push ${dk_name}
    docker push ${dk_name_latest}
    manifests_latest="${manifests_latest} ${dk_name_latest}"
    manifests="${manifests} ${dk_name}"
done


docker manifest create tommoulard/app:latest ${manifests_latest} --amend
docker manifest create tommoulard/app:${hash} ${manifests} --amend

docker manifest push tommoulard/app:latest
docker manifest push tommoulard/app:${hash}
```

# Ce n'est pas un exemple qui fonctionne !