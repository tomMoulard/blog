---
title: "iptable : Comment debug iptables ?"
date: 2020-11-20T13:19:36+01:00
author: Guillaume Moulard
url: /iptablesDebug
draft: false
type: post
tags:
  - iptables
  - debug
categories:
  - tutoriel
---

# iptables, comment ça fonctionne ?

Mes deux URLs de références :

 - Le livre:  https://inetdoc.net/pdf/iptables-tutorial.pdf
 - Le man: http://www.delafond.org/traducmanfr/man/man8/iptables.8.html

# Comment savoir si un filtre est utilisé ?

Le paramètre magique est `-vnL`

```bash
# iptables -vnL
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
34250 1884K ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            state RELATED,ESTABLISHED
    0     0 ACCEPT     icmp --  *      *       0.0.0.0/0            0.0.0.0/0
    0     0 ACCEPT     all  --  lo     *       0.0.0.0/0            0.0.0.0/0
   13   780 ACCEPT     tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            state NEW tcp dpt:22
 3068 1194K REJECT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            reject-with icmp-host-prohibited

Chain FORWARD (policy ACCEPT 25664 packets, 4647K bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 30801 packets, 4552K bytes)
 pkts bytes target     prot opt in     out     source               destination
```
On peut voir que 3068 paquets ont été `REJECT` par la règle `5` lors de l'entrée sur le system `INPUT`.

```bash
# iptables -t nat -vnL
Chain PREROUTING (policy ACCEPT 73305 packets, 4104K bytes)
 pkts bytes target     prot opt in     out     source               destination
   23 11316 DNAT       udp  --  eth1   *       xxx.xxx.xxx.xxx       0.0.0.0/0            udp dpt:500 to:yyy.yyy.yyy.yyy:500
    1   384 DNAT       udp  --  eth1   *       xxx.xxx.xxx.xxx       0.0.0.0/0            udp dpt:4500 to:yyy.yyy.yyy.yyy:4500
    0     0 DNAT       udp  --  eth1   *       yyy.yyy.yyy.yyy       0.0.0.0/0            udp dpt:500 to:xxx.xxx.xxx.xxx:500
    0     0 DNAT       udp  --  eth1   *       yyy.yyy.yyy.yyy       0.0.0.0/0            udp dpt:4500 to:xxx.xxx.xxx.xxx:4500

Chain INPUT (policy ACCEPT 4 packets, 240 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 128 packets, 10244 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
  130 11120 MASQUERADE  all  --  *      *       0.0.0.0/0            0.0.0.0/0
```

Ici on peut voir que la règle de NAT 1 a été appliquée sur 23 paquets.
Les règles `3` et `4` n'ont traité aucun paquet.

# Comment demander a iptables de loger les paquets ?

```bash
iptables -I INPUT 1              -j LOG --log-level 7 --log-prefix "INPUT : "
iptables -I FORWARD 1            -j LOG --log-level 7 --log-prefix "FORWARD : "
iptables -I OUTPUT 1             -j LOG --log-level 7 --log-prefix "OUTPUT : "
```

Avec ces filtres positionnés, `iptables` va envoyer les logs pour les paquets qui arrivent `INPUT`, ils sont retransmit `FORWARD` ou envoyés `OUTPUT`.

```bash
iptables -t nat -I PREROUTING 1  -j LOG --log-level 7 --log-prefix "PREROUTING : "
iptables -t nat -I POSTROUTING 1 -j LOG --log-level 7 --log-prefix "POSTROUTING : "
iptables -t nat -I OUTPUT 1      -j LOG --log-level 7 --log-prefix "NAT OUTPUT : "
```

Ici les paquets qui passent par les tables de NAT seront envoyés dans les logs de la machine.

Depuis la version 3.x il est possible d'utiliser **-j TRACE** 
```bash
iptables -t raw -A OUTPUT -p icmp -j TRACE
```
merci **Ludo** pour le liens : https://www.opensourcerers.org/2016/05/27/how-to-trace-iptables-in-rhel7-centos7/


## Comment consulter les logs?

```bash
$ dmesg -H
[Nov19 14:49] FORWARD : IN=eth1 OUT=eth1 MAC=fa:16:3e:e6:11:db:fa:16:3e:cc:4b:7e:08:00 SRC=195.25.2
[  +0.079319] FORWARD : IN=eth1 OUT=eth1 MAC=fa:16:3e:e6:11:db:fa:16:3e:cc:4b:7e:08:00 SRC=90.115.1
[  +3.939384] FORWARD : IN=eth1 OUT=eth1 MAC=fa:16:3e:e6:11:db:fa:16:3e:cc:4b:7e:08:00 SRC=195.25.2
```

