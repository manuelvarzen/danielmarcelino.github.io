---
layout: post
title: "A Bit More Fragmented" 
date: 2014-10-06
category: [Viz, Coding]
tags: [R, Brazil, Golosov, effective number of parties]
comments: true
---

The 2014 election gave rise to an even more fragmented lower house in Brazil, suggesting the political system is less stable than expected.

<!--more-->

![The Golosov effective number of parties]({{ site.url }}/img/2015/EffectiveNumberParties.png)

<hr/>

## The 2014 legislative election
 The election this year gave rise to an even more fragmented lower house. The way political scientists measure how fragmented a political system is or a legislative body is by applying one of the several formulas for calculating the *Effective Number of Parties*. The *Effective Number of Parties* is a statistic that helps researchers to go beyond the simple (absolute) count of the number of parties. A widely accepted formula was proposed by M. [Laakso and R. Taagepera (1979)](http://cps.sagepub.com/content/12/1/3.extract): 

\\[ N =\frac{1}{\sum_{i=1}^{n}p_{i}^{2}} \\]

 where N denotes the effective number of parties and p_i denotes the $i^{th}$ party’s fraction of the seats. The problem with this method is that it produces distortions, particularly for small parties.

Some years ago, [Grigorii Golosov (2010)](http://ppq.sagepub.com/content/16/2/171.abstract) proposed a new method for computing the effective number of parties, in which both larger and smaller parties are not attributed unrealistic scores as those believed with the Laakso—Taagepera index above. The formula can be expressed as:

\\[ N = \sum_{i=1}^{n}\frac{p_{i}}{p_{i}+p{i}^{2}-p_{i}^{2}} \\]
 
To compare the evolution in the effective number of parties in the Brazilian lower chamber between ~~2002~~ 1986 to 2014 elections, I programed a small function that computes some of the political diversity measures, including the method by [Golosov (2010)](http://ppq.sagepub.com/content/16/2/171.abstract). 
The results suggest we had a considerable upward shift between 2010 to 2014, from 10.5 to 14.5 in the Golosov's scale. The numbers using the more standard method by Laakso and Taagepera are also computed for comparison.

#### Sample of data 
{% highlight r %}
library(SciencesPo)

## 2010 Election outcome as proportion of seats
 seats_2010 = c(88, 79, 53, 43, 41, 41, 34, 28, 21,
17, 15, 15, 12, 8, 4, 3, 3, 2, 2, 2, 1, 1)/513

## will give the following props:
> seats_2010
 [1] 0.171539961 0.153996101 0.103313840 0.083820663 0.079922027 0.079922027
 [7] 0.066276803 0.054580897 0.040935673 0.033138402 0.029239766 0.029239766
[13] 0.023391813 0.015594542 0.007797271 0.005847953 0.005847953 0.003898635
[19] 0.003898635 0.003898635 0.001949318 0.001949318

## 2014 Election outcome as proportion of seats
 seats_2014 = c(70, 66, 55, 37, 38, 34, 34, 26, 22, 20, 19, 
15, 12, 11, 10, 9, 8, 5, 4, 3, 3, 3, 2, 2, 2, 1, 1, 1)/513
{% endhighlight %}

#### Compute the indices

{% highlight r %}
> politicalDiversity(seats_2010, index= "laakso/taagepera")
[1] 10.369

> politicalDiversity(seats_2010, index= "golosov")
[1] 10.511

> politicalDiversity(seats_2014, index= "laakso/taagepera")
[1] 13.064
> 
> politicalDiversity(seats_2014, index= "golosov")
[1] 14.472
{% endhighlight %}

### Update
After I published this post, I realized that it would be nicer to extend the series of election as well as compare the two indices in the plot above; so I updated the plot afterwards. The results may differ from other scholars because differences in the number provided. Some uses the *actual outcome* of the election, as I did, others prefer to use the number of representatives that actually *entered* in the office. 