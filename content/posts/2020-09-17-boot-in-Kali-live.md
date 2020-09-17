---
title: "Boot in Kali Live"
date: 2020-09-17T08:09:31+02:00
author: Tom Moulard
url: /boot-kali-live
draft: false
type: post
tags:
  - tutoriel
  - OS
  - Kali linux
categories:
  - tutoriel
---

Ce "tutoriel" va vous présenter comment installer une clef bootable et comment
l'utiliser avec une version live de kali Linux.

**Attention, par défaut, une version live d'un OS ne va pas sauvegarder vos
données, ni configuration**


## Préparation
Il va falloir télécharger l'image `.iso` que vous allez vouloir installer sur
la clef USB.

### Télécharger l'image
Pour télécharger l'image, il faut aller sur le site de
[Kali](https://www.kali.org/), dans la section
[download](https://www.kali.org/downloads/).

Puis choisir l'image qui correspond a la version voulue:

 - [Kali Linux 64-Bit (installer)](https://cdimage.kali.org/kali-2020.3/kali-linux-2020.3-installer-amd64.iso),
     [torrent](https://images.kali.org/kali-linux-2020.3-installer-amd64.iso.torrent)
 - [Kali Linux 64-Bit (live)](https://cdimage.kali.org/kali-2020.3/kali-linux-2020.3-live-amd64.iso),
     [torrent](https://images.kali.org/kali-linux-2020.3-live-amd64.iso.torrent)
 - [Kali Linux 64-Bit (net installer)](https://cdimage.kali.org/kali-2020.3/kali-linux-2020.3-installer-netinst-amd64.iso),
     [torrent](https://images.kali.org/kali-linux-2020.3-installer-netinst-amd64.iso.torrent)
 - [Kali Linux 32-Bit (installer)](https://cdimage.kali.org/kali-2020.3/kali-linux-2020.3-installer-i386.iso),
     [torrent](https://images.kali.org/kali-linux-2020.3-installer-i386.iso.torrent)
 - [Kali Linux 32-Bit (live)](https://cdimage.kali.org/kali-2020.3/kali-linux-2020.3-live-i386.iso),
     [torrent](https://images.kali.org/kali-linux-2020.3-live-i386.iso.torrent)
 - [Kali Linux 32-Bit (net installer)](https://cdimage.kali.org/kali-2020.3/kali-linux-2020.3-installer-netinst-i386.iso),
     [torrent](https://images.kali.org/kali-linux-2020.3-installer-netinst-i386.iso.torrent)

La version `Kali Linux 64-Bit (live)` est préférée.

### Burn la clef USB
Une fois le fichier `.iso` disponible sur votre PC, il faut l'installer (ou
le burn) sur la clef USB.

**Brancher la Clef USB au PC**

#### Logiciel sur Windows
Utiliser l'outil [rufus](https://rufus.ie/):

![Interface rufus](/img/2020/kali/rufus_fr.png)

 - Télécharger le logiciel, [lien](https://github.com/pbatard/rufus/releases/download/v3.11/rufus-3.11.exe)
 - Choisir de périphérique
 - Sélectionner le fichier image (dans `Type de démarrage`)
 - Choisir un schema de partition `MBR`
 - Utiliser le mode `BIOS ou UEFI` pour le `Système de destination`
 - `DEMARRER`

#### Programme sur Linux
Il faut connaitre le nom du device qui est mount sur votre PC:

```bash
$ lsblk # avant avoir branché la clef
sda      8:0    0 447,1G  0 disk
└─sda1   8:0    0 447,1G  0 part /
$ lsblk # après avoir branché la clef
sda      8:0    0 447,1G  0 disk
└─sda1   8:0    0 447,1G  0 part /
sdb      8:16   0  14,6G  0 disk
├─sdb1   8:17   0     1K  0 part
└─sdb5   8:21   0  14,6K  0 part /media/root/best-usb
```

On remarque que `sdb` viens d'apparaitre.

On va maintenant Burn l'image:

```bash
$ sudo dd status="progress" conv="fdatasync" bs=4M if=/root/Downloads/kali-linux-2020.3-live-amd64.iso of=/dev/sdb
```

Décomposons:

 - `sudo`: il faut être root pour pouvoir utiliser le tool
 - `dd`: (AKA `Disk Destroyer`) outils pour convertir et copier des fichiers
(cf `man dd`)
 - `status="progress"`: Permet de savoir ce qu'est en train de faire `dd`.
 - `conv="fdatasync"`: Permet à `dd` de bien flush les buffers d'écriture a la
fin de l'écriture.
 - `bs=4M`: Décrit la taille des "blocks" à écrire sur le support.
 - `if=<ISO FILE>`: Permet de choisir le fichier à écrire sur la clef USB.
 - `of=<device>`: Choisis le device où on va écrire le fichier
**Attention: ne pas se tromper de device**

## Booter
Re démarrer le PC.

### Entrer dans le BIOS
Lorsque le PC est en train de démarrer, il affiche sur l'écran le logo du
constructeur et une touche sur laquelle appuyer pour entre dans le BIOS.

Ses touches peuvent être:

 - `Suppr`
 - `Del`
 - `F1` (ou les autre touches fonction)
 - `Ctrl + Alt + Echap`
 - `Ctrl + Alt + S`
 - `Ctrl + Alt + Ins`
 - ...

### Choisir le "disque" USB
On va donc aller chercher dans le BIOS l'option qui permet de choisir
l'ordre des disques de boot.
C'est-à-dire l'ordre des devices dans lequel de BIOS va regarder pour
démarrer un OS.

Dans ce menu, il va falloir mettre le device correspondant a la clef USB en
premier.

**Attention: Si vous laissez cette option d'activée, n'importe qui qui
possède une clef bootable va pouvoir utiliser votre ordinateur et pouvoir
utiliser vos disques**

Une fois cette options modifiée, il faut sauvegarder les settings et quitter
le BIOS.

### Choisir l'option de boot en live
L'écran va ensuite afficher le GRUB GNU de Kali.

![GRUB GNU de Kali Linux](/img/2020/kali/grub-kali.jpeg)

Et Voilà, vous avez boot sur une version Live de Kali.

La première chose a faire est de faire un:
```bash
$ sudo apt-get update && apt-get upgrade -y
```

La prochaine fois, si la clef USB est branchée, le PC va démarrer Kali, sinon
il va démarrer sur votre OS de base(celui qui est déjà installé sur votre
machine)
