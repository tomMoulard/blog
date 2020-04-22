---
title: "ANSSI et automatisation de MOOC Secnumacademie avec Selenium"
date: 2020-04-13T18:57:41+02:00
author: Tom Moulard
url: /anssi-mooc-on-hacking
draft: false
type: post
tags:
  - ANSSI
  - selenium
  - python
  - automatisation
categories:
  - tutoriel
---

Pour mon école, j'ai eu a faire un [MOOC](https://secnumacademie.gouv.fr/) de l'ANSSI.

Or après avoir fait tous les tests du mooc à 100% sans avoir écouté les cours, j'ai décidé de récupérer l'attestation de réussite du MOOC pour le donner à mon école.
Mais j'ai eu un message d'erreur:

![Erreur de récupération de l'attestation](/img/2020/mooc/error.png)

J'ai donc voulu suivre les cours, mais ils prenaient beaucoup trop de temps à suivre. Voici donc un bot pour suivre les cours de manière semi-automatique:

```python
from selenium import webdriver
import time

user = "REDACTED"
passw = "REDACTED"

def main():
    driver = webdriver.Chrome()
    driver.get("https://secnumacademie.gouv.fr/")
    driver.find_elements_by_id("btn_access_insc")[0].click()
    driver.find_elements_by_id("login")[0].send_keys(user)
    driver.find_elements_by_id("password")[0].send_keys(passw)
    xpath = '/html/body/div[2]/div/div[2]/div/div[1]/div[1]/div[2]/a[1]'
    driver.find_elements_by_xpath(xpath)[0].click()
    while True:
        if input("continue ? [Y/n]") == "n":
            exit(0)
        driver.switch_to.default_content()
        driver.switch_to.frame("DEFAUT")
        driver.switch_to.frame("contents")
        iframe_id = driver.find_elements_by_id("content")[0].find_elements_by_tag_name("iframe")[0].get_attribute("id")
        driver.switch_to.frame(iframe_id)
        driver.execute_script("for(var i = 0; i < 15; i++) {document.querySelector('#Stage_menu_inferieur_bouton_suivant_hit').click()}")

if __name__ == '__main__':
    main()
```

Un bot que vous pourrez trouver sur mon [repository github](https://github.com/tomMoulard/python-projetcs).

Il suffit de:

 - mettre son username et son password dans les variables `user` et `passwd`.
 - lancer le bot
 - attendre que le bot ait connecté le navigateur
 - sélectionner le module, l'unité ainsi que le premier cours
 - entrer `Y` quand le bot demande si on veut continuer (étape à répéter tant qu'il y a un sous module à suivre)

# En images
## Récupérer le code
```bash
mkdir mook-hack && cd mook-hack
wget https://raw.githubusercontent.com/tomMoulard/python-projetcs/master/anssi-mooc/mooc.py
```

## Installer les dépendances
```bash
sudo apt install -y python3-selenium chromium-chromedriver
```

## Mettre son username/password
```bash
$EDITOR +4 mooc.py
```

## Lancer le bot
```bash
python3 mooc.py
```

![le bot qui attends](/img/2020/mooc/waiting.png)

## Sélectionner le module
![Sélectionner le module](/img/2020/mooc/module.png)

## Sélectionner l'unité
![Sélectionner l'unité](/img/2020/mooc/unity.png)

## Sélectionner le premier cours
* angry clicking noise *
![Sélectionner le premier cours](/img/2020/mooc/first-course.png)

## Entrer `Y`
```bash
y
```

# Upgrades
Dans le futur, on pourrait:

 - lire les vidéos
 - ne pas faire `Y` pour chaque cours

# Conclusion
bla bla bla il faut suivre ses cours

Selenium c'est cool pour automatiser l'utilisation d'un site web

* Se blog a été écrit en réalisant un mooc ANSSI *
