---
title: "Corona et CLI"
date: 2020-03-27T12:22:48+01:00
author: Tom Moulard
url: /coronoa-and-CLI
draft: false
type: post
tags:
  - corona
  - shell
  - script
categories:
  - tutoriel
---

# Comment utiliser des outils "modernes" pour avoir des informations utiles sur l'état actuel des choses

On a des sites qui offrent les données liées au virus accessible grâce à `cURL`:

## Récupérer les informations
```bash
$ curl https://corona-stats.online/fr
╔══════╤═════════════╤══════════════╤═════════════╤══════════════╤══════════════╤═══════════╤═════════╤══════════╤════════════════╗
║ Rank │ Country     │ Total Cases  │ New Cases ▲ │ Total Deaths │ New Deaths ▲ │ Recovered │ Active  │ Critical │ Cases / 1M pop ║
╟──────┼─────────────┼──────────────┼─────────────┼──────────────┼──────────────┼───────────┼─────────┼──────────┼────────────────╢
║ 1    │ France (FR) │       29,155 │             │        1,696 │              │     4,948 │  22,511 │    3,375 │            447 ║
╟──────┼─────────────┼──────────────┼─────────────┼──────────────┼──────────────┼───────────┼─────────┼──────────┼────────────────╢
║      │ World       │      548,806 │    16,996 ▲ │       24,862 │        794 ▲ │   128,599 │ 395,345 │   20,968 │          70.41 ║
╚══════╧═════════════╧══════════════╧═════════════╧══════════════╧══════════════╧═══════════╧═════════╧══════════╧════════════════╝

Stay safe. Stay inside.
Code: https://github.com/sagarkarira/coronavirus-tracker-cli
Twitter: https://twitter.com/ekrysis

Last Updated on: 27-Mar-2020 11:03 UTC

UPDATE: Source 2 is now default source
JHU Source 1 table: https://corona-stats.online?source=1
HELP: https://corona-stats.online/help
```

## Extraire les informations
Extraire des données de ce curl est donc faisable:
```bash
$ curl https://corona-stats.online/fr | grep an
║ Rank │ Country     │ Total Cases  │ New Cases ▲ │ Total Deaths │ New Deaths ▲ │ Recovered │ Active  │ Critical │ Cases / 1M pop ║
║ 1    │ France (FR) │       29,155 │             │        1,696 │              │     4,948 │  22,511 │    3,375 │            447 ║
```

## Nettoyer les informations
Il suffit ensuite de nettoyer avec un coup de `sed`
```bash
$ curl https://corona-stats.online/fr |\
    grep an |\
    sed "s/\s*//g ; s/║//g ; s/│/;/g"
Rank;Country;TotalCases;NewCases▲;TotalDeaths;NewDeaths▲;Recovered;Active;Critical;Cases/1Mpop
1;France(FR);29,155;;1,696;;4,948;22,511;3,375;447
```

Les trois arguments de sed permettent:
 - `s/\s*//g`: supprimer les espaces superflu
 - `s/║//g `: enlever le caractère de fin
 - `s/│/;/g"`: Remplacer les séparateurs par quelque chose d'utilisable

## Formater les informations
On peux mieux voir les informations grâce à `AWK`:
```bash
$ curl https://corona-stats.online/fr |\
    grep France |\
    sed "s/\s*//g ; s/║//g ; s/│/;/g" |\
    awk -F';' '{print $2":"$3"("$7","$8")"}'
Country:TotalCases(Recovered,Active)
France(FR):29,155(4,948,22,511)
```

> Attention: ne pas oublier d'enlever la ligne avec les informations de champ avec une utilisation un peut plus poussée.

# Conclusion
Il ne nous reste plus qu'à utiliser ces informations, dans une barre d'état par exemple.

Pour aller plus loin, on pourrais ne pas utiliser `cURL` à chaque appel, mais utiliser un cache car les informations ne sont pas mises a jours toutes les heures:

```bash
curl https://corona-stats.online/fr > $HOME/.cache/corona_data
grep France $HOME/.cache/corona_data |\
    sed "s/\s*//g ; s/║//g ; s/│/;/g" |\
    awk -F';' '{print $2":"$3"("$7","$8")"}'
```