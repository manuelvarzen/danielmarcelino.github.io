---
layout: post
title: Discontinuity Bayesian Forecasting
date: 2014-07-16
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, bayesian, elections, polls]
excerpt: "The post presents some ideas of a more robust Bayesian linear filtering models to forecast Brazilian subnational elections."
published: true
status: published
comments: true
header-img: "img/website/spaghetti.png"
---

Maybe Bayesian linear filtering models are not enough to forecast Brazilian subnational elections.

## Introduction
I'm finalizing a paper presentation for the ABCP meeting, where I do explore poor polling forecast in a local election in Brazil. I drew upon Jackman (2005)’s paper "Pooling the Polls" to explore a bit about "house effects" in the Brazilian local elections. 

## Motivation 
 During the analysis I found myself extending his original model to fit the local election chosen (Sao Paulo) in regarding the local features.
 In Brazil, political parties have incentives for canvassing free of charge in the aired media (radio and TV). The whole point is that this thing sometimes produces drastic changes to the vote distribution in a short period of time, so we can't simply apply a Bayesian linear filtering as a Kalman filter,  because that would break up some linearity assumptions.
 In order to account for the advertising effect on the popular support, I had to develop an extension where the transition component--the random walk--breaks at the last poll before the ads season began, and restarting with the first poll after it, but with a catch-up of the vote preference change. The following chart says more about the problem. The black spots are the observed polls by the major pollsters.

## The Viz
![Center]({{ site.url }}/img/2014/TVeffect.png)


A week of media exposition, made Haddad's popular support increase in more than 5%; it is more than he could achieve in one year campaigning. Over 58 weeks before the ads season has commenced, he shows a weekly growth rate of about 2.6%. Nonetheless, in the next 5 weeks since the beginning of political advertising on radio and TV, the same growth rate went to 9.46%.