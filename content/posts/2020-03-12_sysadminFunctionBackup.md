---
title: "sysadmin function bakup"
date: 2020-03-12T13:19:36+01:00
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

Dans les regles d'or de tout sysadmin il y a bien sur la nécésité de mettre en oeuvre une politique de backup complet des systems. 
Ce n'est pas le sujet de cette article !!!
Il existe bonne pratique pour garantir la traçabilité et la capacité de revenir sur une mauvaise manip. 
**Avant de modifier une fichier, il faut en faire une copie !!!** 
alors c'est simple a premiere vue 

    cp /etc/fstab /etc/fstab.bkp

 Bon sa c'est la base :) 
Franchement sa aide dans bien des cas. On peut allé un peut plus loins et ajouté un horodatage.

    cp /etc/fstab /etc/fstab-bkp200312002553
Pour ma part je me suis souvent demandé pourquoi personne n'avais ecrit en cp avec cette fonction...
Bien justement probablement car il y a les function en shell :)

il faut juste ca créer dans son environement ou le mettre dans son fichier $HOME/.bashrc

	bkp (){ cp -a $1 $1-bkp$(date +"%y%m%d%H%M%S") ; }
ont peut alors ensuite l'utiliser comme une command classique

    root@pi3:~# bkp (){ cp -a $1 $1-bkp$(date +"%y%m%d%H%M%S") ; }
    root@pi3:~# bkp /etc/fstab
    root@pi3:~# ls -l /etc/fstab*
    -rw-r--r-- 1 root root 305 nov.  29 18:40 /etc/fstab
    -rw-r--r-- 1 root root 305 nov.  29 18:40 /etc/fstab-bkp200312003354

cool non!!!

Bien sur l'utilisation des function en bash n'a pas de limite, voila une autre que j'utilise souvent pour repeter X fois la meme commmande...
	
	t10 (){ for x in {01..10}; do $@ ; done }
Et a l'utilisation

    pi@pi3:~ $ t10 (){ for x in guigui{01..10}; do $@ ; done }
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
    pi@pi3:~ $
	
ont peut faire des choses beaucoup plus sophistiqué... Voila une function qui décompresses les principaux fichier d'archive.  


```
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
