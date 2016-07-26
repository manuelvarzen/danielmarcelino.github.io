---
layout: post
title: "Parallel computing in R"
date: 2014-07-01
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, parallel]
excerpt: "This post shows parallel computing is incredibly useful, but not every thing worths being distributed across as many cores as possible."
published: true
comments: true
header-img: "img/website/rain-room.jpg"
---


Roughly a year ago I published an article about parallel computing in R [here](http://danielmarcelino.com/r/05-2013/parallel-processing-when-does-it-worth/), in which I compared computation performance among 4 packages that provide R with parallel features once R is essentially a single-thread task package.

![Experiment Result]({{ site.url }}/img/2014/parallel.png)

Parallel computing is incredibly useful, but not every thing worths distribute across as many cores as possible. Actually, there are cases without enough repetitions that R will gain in performance through serial computation. That is, R takes time to distribute tasks across the processors; conversely, it will need time for binding them all together later on. Therefore, if the time for distributing and gathering pieces together is greater than the time need for single-thread computing, it doesn’t worth parallelize.

In this post I’ll perform the same experiment using the same physical resources, except that I will perform it in the Rstudio instead of Emacs. So I want to check whether the packages improved anything significant so far.

I tested a nontrivial computation instance using four critical R functions: the base **lapply**, **mclapply** from the “multicore” package, **parLapply** from the “snow” package, and **sfLapply** from the “snowfall” package. The last three functions essentially provide parallelized equivalent for the lapply.

#### The Experiment
These packages were used for distributing tasks across four CPUs of my MacBook pro with 8-G memory. The duty was to average out each column of a data frame built on the fly, but repeating this procedure 100 times for each trial because I don’t want to rely on one single round estimate. In addition, each trial demands different amount of memory allocation and time for computing once the matrix size varies as 1K, 10K, 100K, 1M, and 10M rows. The program I used to perform the tests is left [here](https://gist.github.com/danielmarcelino/5668701).

Overall, every function is doing a better job now than one year ago, but the **mclapply** from the “multicore” package rocks! **parLapply** from the “snow” package comes second. In my former experiment, the lapply function was the way to go when dealing with matrix just as big as 10k rows. The second best alternative was then **mclapply**. **parLapply** from “snow”, and **sfLapply** from the “snowfall” package were simply too slow.

Now, comparing the older graph with the following one suggests that a “microrevolution” is taking place; the figures changed a big deal upon parallelizing small data vectors < 10k; distributing across CPUs seems to be less time consuming now than let it go serialized. Single-core computing (lapply function) is still an alternative when datasets are very small 1k to 10k. Nonetheless, if your data is greater than 10k rows, lapply will be your last desirable performance function.

![Linear Relationship]({{ site.url }}/img/2014/parallelfinal.png)
