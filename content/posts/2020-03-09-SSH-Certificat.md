---
title: "Sécurisation SSH : Utilisation de certificat à la place des Clés."
date: 2020-03-09T13:19:36+01:00
author: Guillaume Moulard
url: /SSH-Certificat
draft: false
type: post
tags:
  - SSH
  - Securite
  - certificat
  - sshd
categories:
  - tutoriel
---


# Pourquoi les certificats SSL c'est mieux qu'une clé SSH ?

Mettre en place des certificats pousse encore la sécurité un peu plus loin car il est alors possible:

 - de donner des délais de validité
 - de faire les liste de révocation
 - de faire des restriction d'usage du SSH (`clear`, `force-command=command`, `no-agent-forwarding`, `no-port-forwarding`, `no-pt`, `no-user-rc`, `no-x11-forwarding`, `permit-agent-forwarding`, `permit-port-forwarding`, `permit-pty`, `permit-user-rc`, `permit-x11-forwarding`, `source-address=address_list`)
 - de faire comme [facebook](https://engineering.fb.com/production-engineering/scalable-and-secure-access-with-ssh/) :)


# Comment mettre en oeuvre une CA sur le serveur SSHD ?

## 1. Création de la CA (Certificat Autority)
```
root@pi3:~> ssh-keygen -t rsa -b 4096 -f /etc/ssh/ca
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /etc/ssh/ca.
Your public key has been saved in /etc/ssh/ca.pub.
The key fingerprint is:
SHA256:Ax5NHQgoY8kpb3lNA/zElBFvJhQAt1G+EsJfMXyHPdo root@pi3
The keys randomart image is:
+---[RSA 4096]----+
| ..==O@*.=..     |
|..B.o=B*+ =      |
| +o+o=*o=+ .     |
|  +o.+oB. E      |
| . .o o S        |
|     .   .       |
|                 |
|                 |
|                 |
+----[SHA256]-----+
root@pi3:~> ls -l /etc/ssh/ca*
-rw------- 1 root root 3243 mars   7 12:33 /etc/ssh/ca
-rw-r--r-- 1 root root  734 mars   7 12:33 /etc/ssh/ca.pub
```

## 2. Utilisation des CA dans les serveur SSH (`sshd`)

```
echo "TrustedUserCAKeys /etc/ssh/ca.pub" >> /etc/ssh/sshd_config
root@pi3:~> systemctl restart sshd
```

# Comment créer sa clé et la signer avec la CA ?

Comme précédemment, pour créer sa clé, rien de plus simple:
Avec openssh c'est très simple
```
pi@pi3:~/.ssh $ ssh-keygen -t rsa -b 4096 -f /home/pi/.ssh/cle2
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/pi/.ssh/cle2.
Your public key has been saved in /home/pi/.ssh/cle2.pub.
The key fingerprint is:
SHA256:AAcbm67DjpfcQOS9Ii8JS3H1ZPs9MsCmKA/jXACEeF0 pi@pi3
The keys randomart image is:
+---[RSA 4096]----+
|+. .+oE          |
|+ o .O o         |
|.+ .= * .        |
| ooo.  B         |
| .+ o.o S .      |
|o*o+..   + o     |
|=*X=      o .    |
|+==o.            |
|.o.              |
+----[SHA256]-----+
```

et la signature par le CA :

```
pi@pi3:~/.ssh $ sudo ssh-keygen -s /etc/ssh/ca -n "Signature de la clé" -I 1 -V +365d /home/pi/.ssh/cle2.pub
Signed user key /home/pi/.ssh/cle2-cert.pub: id "1" serial 0 for Signature de la clé valid from 2020-03-07T12:49:00 to 2021-03-07T12:50:00
pi@pi3:~/.ssh $ sudo chown pi:pi /home/pi/.ssh/cle2-cert.pub
```

On a maintenant un ficher `/home/pi/.ssh/cle2-cert.pub` qui est comme une clé publique classique mais avec une durée de validité de 365 jours.

```
pi@pi3:~/.ssh $ cat /home/pi/.ssh/cle2-cert.pub
ssh-rsa-cert-v01@openssh.com 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 pi@pi3
```

# Comment pousser sa clé signée sur un serveur ?

Exactement comme pour une clé publique, il faut la mettre dans le fichier `~/.ssh/authorized_keys`.

```
pi@pi3:~/.ssh $ ssh-copy-id -f -i /home/pi/.ssh/cle2-cert.pub pi@pi4b.home
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/pi/.ssh/cle2-cert.pub"
no such identity: /home/pi/.ssh/identity: No such file or directory

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'pi@pi4b.home'"
and check to make sure that only the key(s) you wanted were added.
```

```
pi@pi3:~/.ssh $ ssh -i cle2 pi@pi4b.home
no such identity: /home/pi/.ssh/identity: No such file or directory
Linux pi4b 4.19.75-v7l+ #1270 SMP Tue Sep 24 18:51:41 BST 2019 armv7l

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sat Mar  7 11:57:23 2020 from 192.168.1.29
pi@pi4b:~ $
```


