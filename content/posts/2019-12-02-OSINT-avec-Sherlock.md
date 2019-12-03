---
title: "OSINT Avec Sherlock"
date: 2019-12-02T23:53:04+01:00
author: Tom Moulard
url: /osint-with-sherlock
draft: false
type: post
tags:
  - tutoriel
  - osint
  - sherlock
categories:
  - tutoriel
---

A la recherche d'informations disponible sur les réseaux sociaux grâce à un nom d'utilisateur avec Sherlock

Quand on veux connaître plus d'informations sur une personne, on peux aller chercher sur internet des informations utiles. Mais on peux aussi utiliser des outils qui ont été fait pour ça. Des outils comme [sherlock](https://github.com/sherlock-project/sherlock) sont donc utiles pour rechercher des liens entre les personnes.

# Mais c'est quoi [OSINT](https://en.wikipedia.org/wiki/Open-source_intelligence) ?
> OSINT viens de Open-Source INTelligence

Ce sont des **renseignements de sources ouverts** ou des **Renseignements d'Origine Source Ouverte**(ROSO). Ce sont donc des méthodes d'obtention d'informations qui sont obtenues avec une source publique d'information. Mais il faut dissocier les informations de la méthode d'obtention. En effet, les informations obtenues sont appelées OSIF(Open Source inFormation) alors que la méthode est appelée OSINT.

# Mais à quoi ça sert ?
Sherlock permet de regrouper un ensemble de liens qui sont relatifs à un nom d'utilisateur.

[![asciicast](https://asciinema.org/a/233089.svg)](https://asciinema.org/a/233089)

Cela permet donc de regrouper rapidement des liens qui sont en rapport avec un nom d'utilisateur.

# Comment s'en servir ?
Je recommande d'utiliser docker pour cela car ça évite d’installer trop de dépendances python.
```bash
docker run theyahya/sherlock user123
```

et si l'on souhaite récupérer le fichier en sortie, il faut créer le fichier `docker-compose.yml`.
```bash
cat > docker-compose.yml << EOF
version: "2"
services:
  sherlock:
    image: theyahya/sherlock
    volumes:
      - "./results:/opt/sherlock/results"
EOF
```

Puis faire:
```bash
docker-compose run sherlock -o /opt/sherlock/results/user123.txt user123
cat results/user123.txt
```

## Pour les irréductibles du fond
On peux directement installer le script via git et pip:
> Il faut donc avoir python3, git et python3-pip d'installé.
```bash
# clone the repo
git clone https://github.com/sherlock-project/sherlock.git

# change the working directory to sherlock
cd sherlock

# install the requirements
python3 -m pip install -r requirements.txt
```

puis on peux faire
```bash
python3 sherlock.py user123
```

# Récupérer des données
Récupérer ses données là peux être importantes car elle permettent d'utiliser d'autres outils qui auront une analyse plus profonde d'un site en particulier par exemple.

On peux, par exemple, utiliser le fichier fourni par Sherlock et ouvrir tous les liens obtenu dans un nouvel onglet de notre navigateur:
```bash
for link in $(grep http results/user123.txt); do $BROWSER $link; done
```

# Les sites qui sont disponible actuellement sont:

  - ` 2Dimensions`
  - `500px`
  - `7Cups`
  - `9GAG`
  - `About.me`
  - `Academia.edu`
  - `Alik.cz`
  - `Anobii`
  - `Aptoide`
  - `Archive.org`
  - `AskFM`
  - `Av\u00edzo.cz`
  - `BLIP.fm`
  - `Badoo`
  - `Bandcamp`
  - `Basecamp`
  - `Bazar.cz`
  - `Behance`
  - `BitBucket`
  - `BitCoinForum`
  - `Blogger`
  - `Bookcrossing`
  - `Brew`
  - `BuyMeACoffee`
  - `BuzzFeed`
  - `CNET`
  - `Canva`
  - `CapFriendly`
  - `Carbonmade`
  - `CashMe`
  - `Cent`
  - `Chatujme.cz`
  - `Cloob`
  - `Codecademy`
  - `Codechef`
  - `Codementor`
  - `Coderwall`
  - `Codewars`
  - `ColourLovers`
  - `Contently`
  - `Coroflot`
  - `Cracked`
  - `CreativeMarket`
  - `Crevado`
  - `Crunchyroll`
  - `DEV Community`
  - `DailyMotion`
  - `Designspiration`
  - `DeviantART`
  - `Discogs`
  - `Discuss.Elastic.co`
  - `Disqus`
  - `Docker Hub`
  - `Dribbble`
  - `Ebay`
  - `Ello`
  - `Etsy`
  - `EyeEm`
  - `Facebook`
  - `Fandom`
  - `Filmogs`
  - `Fiverr`
  - `Flickr`
  - `Flightradar24`
  - `Flipboard`
  - `FortniteTracker`
  - `GDProfiles`
  - `GPSies`
  - `Gamespot`
  - `Giphy`
  - `GitHub`
  - `GitLab`
  - `Gitee`
  - `GoodReads`
  - `Gravatar`
  - `Gumroad`
  - `GuruShots`
  - `HackerNews`
  - `HackerOne`
  - `HackerRank`
  - `House-Mixes.com`
  - `Houzz`
  - `HubPages`
  - `Hubski`
  - `IFTTT`
  - `ImageShack`
  - `ImgUp.cz`
  - `Instagram`
  - `Instructables`
  - `Investing.com`
  - `Issuu`
  - `Itch.io`
  - `Jimdo`
  - `Kaggle`
  - `KanoWorld`
  - `Keybase`
  - `Kik`
  - `Kongregate`
  - `Launchpad`
  - `LeetCode`
  - `Letterboxd`
  - `LiveJournal`
  - `LiveLeak`
  - `Lobsters`
  - `Mastodon`
  - `Medium`
  - `MeetMe`
  - `MixCloud`
  - `MyAnimeList`
  - `Myspace`
  - `NPM`
  - `NPM-Package`
  - `NameMC (Minecraft.net skins)`
  - `NationStates Nation`
  - `NationStates Region`
  - `Newgrounds`
  - `OK`
  - `OpenCollective`
  - `OpenStreetMap`
  - `PSNProfiles.com`
  - `Packagist`
  - `Pastebin`
  - `Patreon`
  - `Pexels`
  - `Photobucket`
  - `Pinterest`
  - `Pixabay`
  - `PlayStore`
  - `Plug.DJ`
  - `Pokemon Showdown`
  - `Polygon`
  - `ProductHunt`
  - `Quora`
  - `Rajce.net`
  - `Rate Your Music`
  - `Reddit`
  - `Repl.it`
  - `ResearchGate`
  - `ReverbNation`
  - `Roblox`
  - `Sbazar.cz`
  - `Scratch`
  - `Scribd`
  - `Signal`
  - `Slack`
  - `SlideShare`
  - `Smashcast`
  - `SoundCloud`
  - `SourceForge`
  - `Speedrun.com`
  - `Splits.io`
  - `Spotify`
  - `Star Citizen`
  - `Steam`
  - `SteamGroup`
  - `T-MobileSupport`
  - `Taringa`
  - `Telegram`
  - `Tellonym.me`
  - `TikTok`
  - `Tinder`
  - `TrackmaniaLadder`
  - `TradingView`
  - `Trakt`
  - `Trello`
  - `Trip`
  - `TripAdvisor`
  - `Twitch`
  - `Twitter`
  - `Ultimate-Guitar`
  - `Unsplash`
  - `VK`
  - `VSCO`
  - `Venmo`
  - `Viadeo`
  - `Vimeo`
  - `Virgool`
  - `VirusTotal`
  - `Wattpad`
  - `We Heart It`
  - `WebNode`
  - `Wikidot`
  - `Wikipedia`
  - `Wix`
  - `WordPress`
  - `WordPressOrg`
  - `YouNow`
  - `YouPic`
  - `YouTube`
  - `Zhihu`
  - `Zomato`
  - `authorSTREAM`
  - `boingboing.net`
  - `devRant`
  - `fanpop`
  - `gfycat`
  - `habr`
  - `iMGSRC.RU`
  - `last.fm`
  - `mixer.com`
  - `osu!`
  - `pikabu`
  - `segmentfault`

Si jamais il vous manque un site, en ajouter un est très facile.
Il faut le faire [ici](https://github.com/sherlock-project/sherlock#adding-new-sites).
