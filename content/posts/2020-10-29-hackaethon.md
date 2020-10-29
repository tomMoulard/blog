---
title: "A Traefik Hackaethon"
date: 2020-10-27T16:00:00+02:00
author: Tom Moulard, Martin Huvelle
url: /traefik-hackaethon
draft: false
type: post
tags:
  - golang
  - hackathon
  - traefik
  - fun
categories:
  - blogging
---

# The beginning of a long story
At The root of this story, I, one of the author ([Tom Moulard](https://tom.moulard.org)). I used Traefik for my [home server configuration](https://github.com/tomMoulard/make-my-server) and I was looking for an internship. On my journey, I stumbled upon a [Traefik Hackaethon](https://traefik.io/blog/announcing-the-inaugural-traefik-hackaethon-2020-in-october/), a fun project with a cash prize and mainly goodies \o/

Looking for a team, I looked for some of the best student to come working with me. And I found:
 - [Martin Huvelle](https://github.com/nitra-mfs) (the co author)
 - [Alexandre Bossut-Lasry](https://www.linkedin.com/in/alexandre-bossut-lasry/)
 - [Clément David](https://github.com/cledavid)

We are a team of EPITA student in the TCOM major, and we are all working as teachers assistants to prepare and teach practical courses on our fields of studies.

We had a master plan to have fun in this hackaethon. First we build a "small" plugin to warm up on Tuesday and then the big project to really have fun during those three days.

The plan:

| Day       | Task                               |
| --------- | ---------------------------------- |
| Tuesday   | Warm up and try a simple plugin    |
| Wednesday | Implement all main features        |
| Thursday  | Go full hardcore and fix every bug |

During this time, we even did some gophers (Go mascots) for each of us.

| Tom Moulard | Clément David | Martin Huvelle | Alexandre Bossut-Lasry |
|-------------|---------------|----------------|------------------------|
|[![](/img/2020/traefik/gopher-tom_moulard.png)](https://tom.moulard.org)|[![](/img/2020/traefik/gopher-clement_david.png)](https://github.com/cledavid)|[![](/img/2020/traefik/gopher-martin_huvelle.png)](https://github.com/nitra-mfs)|[![](/img/2020/traefik/gopher-alexandre_bossut-lasry.png)](https://www.linkedin.com/in/alexandre-bossut-lasry/)|

# Day 1, The warm up.

We had a [demo](https://traefik.io/resources/plugin-to-traefik-create-and-publish-your-own-middleware-3/) from [Kevin Crawley](https://twitter.com/notsureifkevin) a few days prior the Tuesday.

It was a demo on how to add a Header on a request. Thus, starting from there, managing headers was an easy task for us. Therefore we made [htransformation](https://github.com/tomMoulard/htransformation).

[![htranformation github card](https://gh-card.dev/repos/tommoulard/htransformation.svg)](https://github.com/tomMoulard/htransformation)

By the end of the day, we published the plugin on [traefik pilot](https://pilot.traefik.io/plugins/279923829278507529/header-transformation).

# Day 2, Some dark times
Wednesday morning, the dark time of our hackatheon. We needed an idea, not only an idea that would be fun (believe me we had a lot) but one that would be useful !
We had a lot of chat with one of the organizer (Thank you [Santo](https://twitter.com/manuel_zapf) for all of your help, support and motivation !). After a lot of "Santo! We got an idea !!!" and a "Yeah that's sounds fun but what would be the purpose of this?" we finally extract the idea of "fail2ban" integration.

To be sure that no one had did this, as usual we check github, traefik etc. Nothing, until we check discord, our future teammate Mike had the same idea. So we decided to team up (We didn't know how much it would be a good idea) !

# Day 3, A happy ending
After a lot of hours, thinking about the design and coding every piece of the plugin, combine every part we each created. We had one last bug, we tried everything, review every lines with differents people at each time.
Last helping call, we ask the discord about our issue, of course after few second we post, we managed to solve it and of course the patch was "use caps for your config variables". Typical, we even stumbled upon this reflection for the first plugin.

The plugin worked, all of the tests displayed "[PASSED](https://travis-ci.com/github/tomMoulard/fail2ban/jobs/403817444)", [we did it](https://github.com/tomMoulard/fail2ban/commit/ebea16634226d7846c0c9b576872f76740ef1579) !

The last job we had was to push the plugin [Fail2Ban](https://github.com/tomMoulard/fail2ban) on [traefik pilot](https://pilot.traefik.io/plugins/280093067746214409/fail2-ban).

[![Fail2ban github card](https://gh-card.dev/repos/tommoulard/fail2ban.svg)](https://github.com/tomMoulard/fail2ban)

We were proud and we learn a lot in a very short period of time but what we didn't know was the next mail which arrived at midnight the next day. I looked quickly thinking it was a simple mail which thanks us to participate but the mention "I would like to proudly announce that you have won FIRST PLACE!!" did not sound usual for a "thanks for your participation" kind of mail.

# Wrapping up
We'd like to thanks Traefik for organizing this amazing event !
And [EPITA](https://www.epita.fr) for providing the structure to hold us during theses difficult times.

Thanks to this experience, we became [Traefik Ambassador](https://info.traefik.io/traefik-ambassador-program) !

![We are Traefik Ambassador](/img/2020/traefik/traefik-ambassador-flatten.svg)

