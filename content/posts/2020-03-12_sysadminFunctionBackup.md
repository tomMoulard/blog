---
title: "sysadmin function bakup"
date: 2020-03-12T10:19:36+01:00
author: Guillaume Moulard
url: /sysadminFunctionBackup
draft: false
type: post
tags:
  - sysadmin
  - function
  - backup
  - script
  - shell
categories:
  - tutoriel
---


# sysadmin function bakup

Dans les règles d'or de tout sysadmin il y a bien sûr la nécessité de mettre en œuvre une politique de backup complet des systèmes.
Ce n'est pas le sujet de cet article !!!
Il existe une bonne pratique pour garantir la traçabilité et la capacité de revenir sur une mauvaise manip.

**Avant de modifier une fichier, il faut en faire une copie !!!**

Alors c'est simple à première vue:

```bash
cp /etc/fstab /etc/fstab.bkp
```

Bon ça c'est la base :)
Franchement ça aide dans bien des cas. On peut aller un peu plus loin et ajouter un horodatage.

```bash
cp /etc/fstab /etc/fstab-bkp200312002553
```

Pour ma part je me suis souvent demandé pourquoi personne n'avait écrit en `cp` avec cette fonction...
Bien probablement car il y a les function en shell :)

Il faut juste la créer dans son environnement et le mettre dans son fichier `$HOME/.bashrc`

```bash
bkp (){ cp -a $1 $1-bkp$(date +"%y%m%d%H%M%S") ; }
```

On peut alors ensuite l'utiliser comme une commande classique

```bash
root@pi3:~> bkp (){ cp -a $1 $1-bkp$(date +"%y%m%d%H%M%S") ; }
root@pi3:~> bkp /etc/fstab
root@pi3:~> ls -l /etc/fstab*
-rw-r--r-- 1 root root 305 nov.  29 18:40 /etc/fstab
-rw-r--r-- 1 root root 305 nov.  29 18:40 /etc/fstab-bkp200312003354
```

> Cool non!!!

Bien sûr l'utilisation des fonctions en bash n'a pas de limite, voilà une autre que j'utilise souvent pour répéter X fois la même commande...

```bash
t10 (){ for x in {01..10}; do $@ ; done }
```
Et à l'utilisation

```bash
pi@pi3:~ $ t10 (){ for x in {01..10}; do $@ ; done }
pi@pi3:~ $ t10 echo g >> /tmp/10g
pi@pi3:~ $ cat /tmp/10g
g
g
g
g
g
g
g
g
g
g
```

On peut faire des choses beaucoup plus sophistiquées... Voila une fonction qui décompresse les principaux fichiers d'archive.

```bash
# Extract the content of an achive
function extract {
 if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    return 1
 else
    for n in $@
    do
      if [ -f "$n" ] ; then
          case "${n%,}" in
            *.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                         tar xvf "$n"       ;;
            *.lzma)      unlzma ./"$n"      ;;
            *.bz2)       bunzip2 ./"$n"     ;;
            *.rar)       unrar x -ad ./"$n" ;;
            *.gz)        gunzip ./"$n"      ;;
            *.zip)       unzip ./"$n"       ;;
            *.z)         uncompress ./"$n"  ;;
            *.7z|*.arj|*.cab|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.rpm|*.udf|*.wim|*.xar)
                         7z x ./"$n"        ;;
            *.xz)        unxz ./"$n"        ;;
            *.exe)       cabextract ./"$n"  ;;
            *)
                         echo "extract: '$n' - unknown archive method"
                         return 1
                         ;;
          esac
      else
          echo "'$n' - file does not exist"
          return 1
      fi
    done
fi
}
```
