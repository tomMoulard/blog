---
title: "Rapports en Markdown avec Pandoc"
date: 2019-12-04T13:35:37+01:00
author: Tom Moulard
url: /pandoc-markdown-rapport
draft: false
type: post
tags:
  - tutoriel
  - markdown
  - pandoc
categories:
  - tutoriel
---

Faire un rapport peux être compliqué avec des outils très graphiques. En effet, il est très simple de ne pas être consistent lorsque l'on fait la mise en page du rapport. Et cela ne fait pas un rapport très sérieux. C'est pour cela que séparer le style du contenu du rapport peux être très intéressant.

En effet, la séparation du contenant et du contenu permet d'être conscient de ce que l'on écrit et permet de changer le style global du rapport facilement.

![](/img/2019/hugo-creation.png)

# Qu'est-ce que le Markdown

```markdown
Le Markdown est un langage de markup, il permet donc d'écrire du texte que l'on peux formater. Il faut écrire le texte qu'il contiens avec des marqueurs pour indiquer ce que le texte est sensé vouloir exprimer: un Titre, un texte gras ou une liste.

# Le Basique du texte
Ceci est en *italique* et ceci est en **gras**. Un autre _italique_ et un autre __gras__.

Ceci est un texte `important` et le signe % et `%`

Ceci est un paragraphe avec une note[^note-id].
[^note-id]: c'est le texte de la note.

Ceci est un paragraphe avec une note^[les textes directement à l'interieur de la note sont plus symple à lire et à écrire] qui est directement à l'interieure du paragraphe.

# L'Indentation
> Voila du texte indenté
>> Encore plus indenté

# Les Titres
# Gros Titre (h1)
## Titre moyen (h2)
### Petit Titre (h3)
#### Encore (hX)
##### Encore (hX)
###### encore (hX)

# Les Listes

 - les indicateurs peuvent être `-`, `+`, ou `*`
 - liste 1
 - liste 2
    - sous liste 1
    - sous liste 2

        avec du texte indenté à l’intérieur.

 - liste 3
 + liste 4
 * liste 5

# Liens

Ceci est un [lien à l'intérieur du paragraphe](http://blog.moulard.org/) et [un autre avec un titre](http://blog.moulard.org/ "Voila le lien de mon blog").

Les Liens peuvent aussi être référencés: [référence 1][ref1] or [référence 2 avec un titre][ref2].

 [ref1]: http://blog.moulard.org
 [ref2]: http://blog.moulard.org "Voila le lien de mon blog"

Les Références sont en général placées à la fin du document.

# Les Images

Une image test:

![china](https://tom.moulard.org/assets/img/team/china.jpg "china")

Comme une lien, les images peuvent avoir une référence à la place d'un lien:

![china][china-ref]

 [china-ref]: https://tom.moulard.org/assets/img/team/china.jpg "china"


# Le Code

C'est plutôt facile de montrer du code dans un fichier markdown.
Les `backticks` sont utilisées pour mettre en avant du texte.

Aussi, n'importe quel bloc de texte indenté est considéré comme un bloc de code.

    <script>
        document.location = 'http://lmgtfy.com/?q=markdown+cheat+sheet';
    </script>

On peux spécifier le langage du code après les backticks pour avoir une coloration qui soit en rapport:

    ```python
    import random

    class CardGame(object):
        """ a sample python class """
        NB_CARDS = 32
        def __init__(self, cards=5):
            self.cards = random.sample(range(self.NB_CARDS), 5)
            print 'ready to play'
    ```

Du code en Javascript:

    ```js
    var config = {
        duration: 5,
        comment: 'WTF'
    }
    // callbacks beauty un action
    async_call('/path/to/api', function(json) {
        another_call(json, function(result2) {
            another_another_call(result2, function(result3) {
                another_another_another_call(result3, function(result4) {
                    alert('And if all went well, i got my result :)');
                });
            });
        });
    })
    ```


# Les Math

Des expressions mathématiques peuvent aussi être affichées. Cela permet d'avoir des expression directement dans le texte \\(\frac{\pi}{2}\\) $\pi$.

D'autre part, on paux aussi écrire ses expressions sur leurs propre lignes:

$$F(\omega) = \frac{1}{\sqrt{2\pi}} \int_{-\infty}^{\infty} f(t) \, e^{ - i \omega t}dt$$

\\[\int_0^1 f(t) \mathrm{d}t\\]

\\[\sum_j \gamma_j^2/d_j\\]

```

# Qu'est-ce que Pandoc
Selon `man pandoc`

>  Pandoc  is  a  Haskell  library for converting from one markup format to another, and a command-line tool that uses this library.

`Pandoc` permet donc de convertir un `markup language` en un autre.

Et nous allons utiliser `pandoc` pour convertir du `markdown` en `pdf`.

# Les Métadonnées du markdown
Les Métadonnées, en `markdown`, sont entourée par des `---` qui permettent d'exprimer des informations importantes à `pandoc` pour qu'il puisse facilement utiliser certaines valeurs. Ses valeurs sont spécifique au template utilisé([liste de templates non exhaustive](https://github.com/jgm/pandoc/wiki/User-contributed-templates)). Nous allons utiliser le template [Eisvogel](https://github.com/Wandmalfarbe/pandoc-latex-template).

Voici un example des Métadonnées:
```markdown
---
title: Rapport
author: Tom Moulard
date: 2020-01-10
lang: "fr"
toc: true
toc-title: "Sommaire"
fontsize: 14pt
titlepage: true
logo: /tmp/rapport.png
book: true
listings-no-page-break: true
links-as-notes: true
---
```

Ce que veulent dire chaque champs:

 - `title`(string): Correspond au titre du rapport
 - `author`(string): Correspond à l'auteur du rapport
 - `date`(string): Correspond à la date d'écriture du rapport
 - `lang`(string): Correspond à la langue utilisé dans le rapport
 - `toc`(bool): Exprime si l'on veux afficher le sommaire
 - `toc-title`(string): Permet de définir le titre donné au sommaire
 - `fontsize`(string): Correspond à la taille du texte du rapport
 - `titlepage`(bool): Exprime si l'on veux qu'il y ait une page d’accueil avec le titre du document, l'auteur, la date et le logo
 - `logo`(string): Correspond au chemin absolu du logo du rapport
 - `book`(bool): Exprime si l'on veux avoir une page blanche en plus pour avoir les pages avec un nouveau titre à droite dans un livre
 - `listings-no-page-break`(bool): Exprime si l'on ne veux pas qu'une liste d'éléments soit sur plusieurs pages


# La compilation du markdown
Il faut donc avoir `pandoc` d'installé, j'utilise la version `pandoc 2.7.3 Compiled with pandoc-types 1.17.6.1, texmath 0.11.3, skylighting 0.8.2.3` pour cet exemple.

```bash
pandoc \
    --from markdown+inline_notes+footnotes \
    -V papersize:a4paper \
    -s \
    --number-sections \
    --listings \
    --template eisvogel \
    --top-level-division=chapter \
    rapport.md -o rapport.pdf
```

Les arguments utilisés ici permettent d'avoir encore plus de contrôle sur `pandoc` et le fichier de sortie.
Leurs signification:

 - `from`: Permet de définir le langage source et ses spécifications
 - `V`: Permet de définir des variables de la forme CLEF:VALEUR
 - `s`: Permet d'avoir un header et un footer approprié, de ne pas avoir des problèmes d'encodage de fichiers et de ne pas avoir des Métadata dans le corps du texte.
 - `number-sections`: Permet de donner un nombre unique aux sections pour les reconnaître et connaître leurs emplacement dans l'organisation du document.
 - `listings`: Permet d'utiliser le package `listings` pour les blocs de code.
 - `template`: Permet de spécifier le nom du template à utiliser
 - `top-level-division`: Permet de monter les headers à partir d'un certain niveau dans la hiérarchie des sections(de `part`, `chapter` et `section`). `top-level-division=chapter` permet donc de montrer les headers sur les sections `chapter` et `section`.

