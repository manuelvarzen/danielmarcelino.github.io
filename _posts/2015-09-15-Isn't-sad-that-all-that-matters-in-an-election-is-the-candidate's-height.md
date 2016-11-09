---
layout: post
title: "Isn't sad that all that matters in an election is the candidate's height?"
date: 2015-09-15
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats]
excerpt: "This post discusses the importance of candidates' stature in US presidential elections."
published: true
comments: true
---

A candidate's stature may be more important in elections than we 've realized. I came across this claim in the US [press](http://www.usnews.com/news/articles/2015/07/08/how-tall-are-the-2016-presidential-candidates) suggesting that the taller the candidate, the better his/her chances to succeed in the presidential elections. 

After a little search, I found this [Wikipedia](https://en.wikipedia.org/wiki/Heights_of_presidents_and_presidential_candidates_of_the_United_States) entry, and even some academic research on this topic [here](http://onlinelibrary.wiley.com/doi/10.1111/j.1540-6237.2011.00815.x/full) and [here](http://www.sciencedirect.com/science/article/pii/S1048984312000884), mainly relating this phenomenon to some sort of evolutionary instinctual preference (positive selection). At least in the US, it does make sense to ask how tall is your favorite presidential candidate. The plot below presents the evidence. 

![Linear Regression]({{ site.url }}/img/2015/Presidentsheight.png)

The association is significant, indeed (F**ing love science!), though the relationship may lose some power if other factors is to be included, such as age, party etc. 

## The data
I gathered some data on the presidential candidates’ height and popular vote support to test the strength of such claim with a regression analysis. The observations consist of the height of president divided by height of most successful opponent. Data and scripts are [here](https://gist.github.com/danielmarcelino/b2cc9f3964d7608f29b5).

**UPDATE:** After have seen this post on the R-Bloggers aggregator, I realized that the engineer indexed a related postage by [Arthur Charpentier](http://www.r-bloggers.com/who-will-be-the-next-president-of-the-us/), published a few years before.