---
title: "Création de site avec Hugo"
date: 2019-11-13T15:17:21+01:00
author: Tom Moulard
url: /creation-de-site
draft: false
type: post
tags:
  - tutoriel
  - installation
  - hugo
categories:
  - tutoriel
meta_image: 2019/hugo-creation.png
---

Installer un site sur Hugo peux poser des difficultés lors de l'installation.

## La partie sur Hugo
### Installation de Hugo
Sur Ubuntu, un simple `snap install hugo` fonctionne.

### Création du site
Pour créer le site, il suffit de faire la commande
```bash
hugo new site blog
```

### Ajouter un thème
Il faut rechercher dans la [liste des thèmes](https://themes.gohugo.io/) le thème qui plaît. Une fois le thème choisis, il faut l'installer dans `themes/<nom du thème>` et ajouter `theme = "<nom du thème>"` dans le fichier `config.toml`.

#### Installation du thème [`Cactus Plus`](https://themes.gohugo.io/hugo-theme-cactus-plus/)

```bash
# Récupérer le thème sur GitHub
git clone https://github.com/nodejh/hugo-theme-cactus-plus themes/hugo-theme-cactus-plus

# Installer le bon fichier de configuration à la place de l'ancier
cp themes/hugo-theme-cactus-plus/exampleSite/config.toml .
```

### Créer un post sur le blog
#### En utilisant Hugo
```bash
hugo new posts/premier-post.md
```

#### A la main
```bash
$EDITOR content/posts/premier-post.md
```

#### Metadata sur le post
Tout d'abord, les metadata sont ajoutée directement dans le fichier markdown grâce au separateurs `---`. Cela donne un document qui commence par:
```markdown
---
title: "Creation de site avec Hugo"
date: 2019-11-13T15:17:21+01:00
---
```

Voici une liste exhaustive des éléments que l'on peux ajouter dans les metadata:

 - `title`: Spécifie le nom de l'article
 - `date`: Explicite la date de rédaction du document
 - `url`: Permet de définir l'URL utilisé pour le post
 - `draft`: `[true|false]` Permet(ou non) que le post soit visible dans un environnement de production
 - `tags`: Permet de définir les tags de l'article et donc permet de faire le lien entre les post.
 - `author`: Spécifie le nom de l'auteur
 - `meta_image`: Spécifie l'image qui représente l'article
 - `type`: Spécifie le type d'article

Ce qui peux donner une entête comme cela
```markdown
---
title: "Creation de site avec Hugo"
author: Tom Moulard
draft: false
type: post
date: 2019-11-13T15:17:21+01:00
url: /creation-de-site
categories:
  - Uncategorized
tags:
  - tutoriel
  - installation
  - hugo
meta_image: 2019/hugo-creation.png
---
```

### Démarrer le serveur localement
```bash
hugo server
```

#### Démarrer le serveur localement avec les drafts
```bash
hugo server -D
```

### Voir le site web
Il suffit maintenant d'aller voir [localhost:1313](http://localhost:1313) pour observer le travail effectué.

```bash
$BROWSER http://localhost:1313
```

## Paramétrage du site
La prochaine section à pour but de modifier le fichier de configuration `config.toml`.

### Paramètres sur l'auteur
```toml
author = "<Nom de l'auteur>"
description = "<Description du site>"
bio = "<Description de l'auteur>"
```

### Disqus
Il faut avoir un compte sur le site [Disqus](https://disqus.com)(ou en [créer un](https://disqus.com/profile/signup/)). Puis il faut créer un [nouveau site](https://disqus.com/admin/create/) et récupérer le nom court du site.
```toml
enableDisqus = true
disqusShortname = "<nom cours du site>"
```

## Déploiement
### En utilisant docker-compose
```docker-compose
hugo:
  image: jojomi/hugo:latest
  volumes:
    - ./src/:/src
  environment:
    - HUGO_WATCH=true
    - HUGO_REFRESH_TIME=3600
    - HUGO_THEME=<Nom du thème>
    - HUGO_BASEURL=mydomain.com
  restart: always
```

Par exemple:
```docker-compose
hugo:
  image: jojomi/hugo:latest
  volumes:
    - .:/src
  environment:
    - HUGO_WATCH=true
    - HUGO_REFRESH_TIME=3600
    - HUGO_THEME=hugo-theme-cactus-plus
    - HUGO_BASEURL=mydomain.com
  restart: always
```

Puis `docker-compose up`