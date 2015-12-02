---
layout: post
title: "Isn't sad that all that matters in an election is the candidate's height?"
date: 2015-09-15
category: [R]
tags: [candidates' height, elections]
comments: true
---

The candidate's height may be very important in elections.

<!--more-->


![Linear Regression]({{ site.url }}/img/2015/Presidentsheight.png)


I came across the claim in the US [press](http://www.usnews.com/news/articles/2015/07/08/how-tall-are-the-2016-presidential-candidates) suggesting that the taller the candidate, the better his/her chances for success in presidential elections. After a little search, I found this [Wikipedia](https://en.wikipedia.org/wiki/Heights_of_presidents_and_presidential_candidates_of_the_United_States) entry, and even some academic research on the issue, mainly relating this phenomenon to some sort of evolutionary instinctual preference. At least in the US, it does make sense to ask how tall is your favorite 2016 presidential candidate.

I gathered some data on the presidential candidates’ height and popular vote support to test the strength of such claim with a regression analysis. The observations consist of the height of president divided by height of most successful opponent. The association is significant, indeed (F**ing love science!), though the relationship may lose power if other factors are included. The graph above presents the relationship found in the data. Data and scripts are [here](https://gist.github.com/danielmarcelino/b2cc9f3964d7608f29b5).


**UPDATE:** After have seen this post on the R-Bloggers aggregator, I realized that the engineer indexed a related postage by [Arthur Charpentier](http://www.r-bloggers.com/who-will-be-the-next-president-of-the-us/), published a few years before.