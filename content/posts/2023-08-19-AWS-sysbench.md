---
title: "AWS sysbench"
date: 2023-08-17T13:00:00+01:00
author: Guillaume Moulard
url: /aws-sysbench
draft: true
type: post
tags:
  - blogging
  - AWS
  - sysbench
  - durabilité
  - sobriete
  - sobriété 
  - numerique
  - numérique 
  - Développement durable
categories:
  - state of the art
---

# Quel perf pour quel instance

## t2.medium	2	4,0	24	0,0464 USD

```
sysbench cpu run
sysbench 1.0.17 (using system LuaJIT 2.0.4)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Prime numbers limit: 10000

Initializing worker threads...

Threads started!

CPU speed:
    events per second:   771.49

General statistics:
    total time:                          10.0007s
    total number of events:              7717

Latency (ms):
         min:                                    1.24
         avg:                                    1.29
         max:                                    1.87
         95th percentile:                        1.32
         sum:                                 9986.10

Threads fairness:
    events (avg/stddev):           7717.0000/0.00
    execution time (avg/stddev):   9.9861/0.00
```
## t4g.medium


## t3a.medium	2	4.0	20%	24 5	Up to 2,085	$0.0376

```
sysbench cpu run
sysbench 1.0.17 (using system LuaJIT 2.0.4)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Prime numbers limit: 10000

Initializing worker threads...

Threads started!

CPU speed:
    events per second:  1239.81

General statistics:
    total time:                          10.0006s
    total number of events:              12401

Latency (ms):
         min:                                    0.78
         avg:                                    0.81
         max:                                    9.23
         95th percentile:                        0.87
         sum:                                 9994.19

Threads fairness:
    events (avg/stddev):           12401.0000/0.00
    execution time (avg/stddev):   9.9942/0.00
    ```




