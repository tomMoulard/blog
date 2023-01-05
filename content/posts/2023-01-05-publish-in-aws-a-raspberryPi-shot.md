---
title: "Publish in AWS a raspberryPi shot"
date: 2023-01-05T13:00:00+01:00
author: Guillaume Moulard
url: /AWS-raspberryPi-shot
draft: false
type: post
tags:
  - blogging
  - AWS
  - raspberryPi
categories:
  - tutoriel
---


The easiest way to forget the photos taken by the Raspberry and of course to take the photos on raspberry then publish them on 
this one directly with a Web server. 

Why it is still necessary here our system in my case the reliability of my internet connection 
of my raspberry prefer do not allow imagine published the photos so simply. 
I had to imagine a system you allowed me to take the photos and then publish them on the AWS Cloud. 
To do this I used on the raspberry side the raspistill software to take the photos, and the AWS CLI to send the documents on S3.
On the AWS side I used the features of S3 which allows you to publish a static website with the storage capacity to scale up and the availability of the Cloud. 
To set up this infrastructure I used terraform

# on AWS  side


```shell
```

# On Raspberry pi

After AWS CLI installation 

```shell
pip3 install awscli --upgrade --user
```

I can use configure for setup my AWS credential.

```shell
aws configure
```

I have add on script on my crontab

###  $ crontab -l

```shell
1 14 * * * /home/pi/photo/img.sh 100
*/15 * * * * /home/pi/photo/img.sh 10
```


### $ cat /home/pi/photo/img.sh
```shell
#!/bin/bash

PHOTO=photoVDL-$1-$(date +"%Y-%m-%d_%H%M").jpg

raspistill -q $1 -rot 270 -o /tmp/$PHOTO

/home/pi/.local/bin/aws s3 cp /tmp/$PHOTO  s3://www.websitegmstatice.moulard.org/vdl-photo/

rm /tmp/$PHOTO

```


