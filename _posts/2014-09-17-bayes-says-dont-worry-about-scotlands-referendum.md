---
layout: post
title: "Bayes says `don't worry` about Scotland's Referendum" 
date: 2014-09-17
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, polls]
excerpt: "This post uses Bayesian methods to show the anti-independence vote has an overwhelming advantage over the pro-independence side."
published: true
comments: true
header-img: "img/website/rain-room.jpg"
---


Just few hours before Scots head to the polls, there is not an overwhelming advantage of the anti-independence vote. Actually, the margin is shorter than last time [I looked at it](http://danielmarcelino.com/what-are-the-odds-of-an-independent-scotland/), but despite such a growing trend in favor of the "Yes" campaign in the last weeks, the "NO" side has an edge still. To frame this in terms of probabilities that \\( \theta_{No} \\) exceeds \\( \theta_{Yes} \\), I write a short function (replicated [here](https://gist.github.com/danielmarcelino/9cab589e474dd09dadbc)) that will use simulation from the Dirichlet distributions to compute the posterior probability that "No" exceeds "Yes" shown in the lovely chart below.


![Loess]({{ site.url }}/img/2014/referendum.jpeg)


The data used here to draw the distributions were gathered from a series of polls and available at the wikipedia. The polls employ different methodologies and phrase questions differently. For instance, some surveys ask respondents how they would vote if this referendum were held today, others ask them how they intend to vote on 18th September. By aggregating them, any swing could be the by-product of the random variation to which all polls are subject.

