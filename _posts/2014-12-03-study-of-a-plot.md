---
layout: post
title: "Study of a Plot: The Manhattan Plot"
date: 2014-12-03
category: R
tags: [R, manhattan plot]
---

I was thinking on a nice way of plotting campaign expenditures in a paper I’m working on. I thought this would be something like the following, simple, but meaningful even in the context of lots of outliers in both tails.

<!--more-->

![Manhattan Plot](/images/blog/2014/manhattan.jpeg)


Although I like the seniors Tukey’s boxplot and scatter plots, I had already used them, so I want to oxygenate my figures. The  [Manhattan plot](http://en.wikipedia.org/wiki/Manhattan_plot) is a potential replacement candidate.

The very idea is to have types of elections, districts or parties along the X-axis, with the negative logarithm of the association (p-value) between a candidate’s spending and votes displayed on the Y-axis. Hence, each dot on the plot indicates a candidate’s position on this metric. 

Because stronger associations have the smallest p-values (a log of 0.05 = -1.30103), their negative logarithms will be positive and higher (e.g., 1.3), while those with p-values not [statistically significant](http://www.nature.com/news/scientific-method-statistical-errors-1.14700) (whatever that means these days, maybe nothing ) will stay below this line.

The positive thing of this version is that it draws our attention to the upper outliers instead to the average association, which tends to be left-skewed because Brazilian elections attract many sacrificial lamb candidates who expend nearly nothing in their campaigns.



