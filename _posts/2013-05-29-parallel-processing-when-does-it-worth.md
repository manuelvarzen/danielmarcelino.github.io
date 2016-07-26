---
layout: post
title: "Parallel Processing: When does it worth?"
date: 2013-05-29
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, parallel]
excerpt: "This post shows parallel computing is incredibly useful, but not every thing worths being distributed across as many cores as possible."
published: true
status: published
comments: true
header-img: "img/website/rain-room.jpg"
---

This post shows parallel computing is incredibly useful, but not every thing worths being distributed across as many cores as possible.

Most computers nowadays have few cores that incredibly help us with our daily computing duties. However, when statistical softwares do use parallelization for analyzing data faster? R, my preferred analytical software, does not take too much advantage of multicore processing by default. 

In fact, R has been inherently a "single-processor" package until nowadays. Stata, another decent statistical package, allows for multicore processing, but not yet implemented for the default version. Additionally, Stata versions for multicore are quite expensive, for instance, if I want to use all of my quad-core computer power, I have to pay out $1,095 for a 4-core single license.

Fortunately, several packages exploiting the resources of parallel processing began to gain attention in the R community lately. Specially, because of many computationally demanding statistical procedures, such as bootstrapping and Markov Chain Monte Carlo, I guess. Nonetheless, the myth of fast computation has also leading for (miss)understanding by ordinary R users like me. Yet before distributing patches among CPUs, it is important to have it clear when and why parallel processing is helpful and which functions performs better for a given job.

First, what does exactly parallel do? Despite its complex implementation, the idea is incredible simple: parallelization simply distribute the work among two or more cores. It is done by packages that provide backend for the “foreach” function to work. The foreach function allows R to distribute the processes, each of which having access to the same shared memory; so the computer not get confused. For instance, in the program bellow, several instances of lapply-like function are able to access the processing units and then deal out with all the work.

Since not every task runs better in parallel there is not too many ready to use parallel processing functions in R. Additionally, distributing processes among the cores may cause computation overhead. That means we may lose computer time and memory, firstly by distributing, secondly by gathering the patches shared out among the processing units. Therefore, depending on the task (time and memory demand), parallel computing can be rather inefficient. It may take more time for dispatching the processes and gathering them back than the computation itself. Hence, counterintuitively, one might want to minimize the number of dispatches rather than distribute them.

![Experiment Result]({{ site.url }}/img/2013/parallel.jpg)

Here, I'm testing a nontrivial computation instance for measuring computer performance on four relevant functions: the base **lapply**, **mclapply** from the “multicore“ package, **parLapply** from “snow” package, and **sfLapply** from “snowfall“ package. The last three functions essentially provide parallelized equivalent for the `lapply`. I use these packages for parallel computing the average for each column of a data frame built on the fly, but repeating this procedure 100 times for each data frame trial; so each trial demands different amount of time and memory for computing: the matrix size increases as 1K, 10K, 100K, 1M, and 10M rows. The program I used for simulate the data and perform all the tests can be found [here](https://gist.github.com/danielmarcelino/5668701). I used Emacs on a MacBook pro with 4-core and 8-G memory.

![Final Results]({{ site.url }}/img/2013/parallelfinal.jpeg)

My initial experiment also included the "mpi.parLapply" function from the "Rmpi" package. However, because it is outdated for running on R version 3.0, I decided for not including it in this instance.

Overall, running repetition tasks in parallel incurs overhead. Therefore, only if the process takes a significant amount of time and memory (RAM), parallelization can improve the overall performance. 

The plots above, provide evidence when an individual process takes less than a second (`2.650/100 = 26.5 milliseconds ` comparable to `13.419/100 = 134.2 milliseconds`) to be executed, the overhead of continually patching processes will decay the overall performance. For instance, in the first chart, the lapply function took less than one-third of the time of **sfLapply** to perform the same job. However, the pattern changes dramatically when the computer needs to repeat the same task with large vectors (>= 1 million rows). 

In fact, I noticed that all functions began to consume even more time computing  averages of big matrixes than I expected. But in a setting with 10 millions rows, the **lapply** function was dramatically inefficient: it took `1281.8/100 = 12.82 seconds` for each process, while the **mclapply** only took `525.4/100 = 5.254 seconds`.

