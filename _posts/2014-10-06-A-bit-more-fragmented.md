---
layout: post
title: "A bit more fragmented" 
date: 2014-10-06
category: R
tags: [R, Brazil, Golosov, Effective number of parties]
image: crocodile-zebra.png
---

The election gave rise to an even more fragmented lower chamber in Brazil.

<!--more-->

![The Golosov effective number of parties](/images/blog/2015/EffectiveNumberParties.png)

<hr/>

#### The 2014 legislative election
This year, the election gave rise to an even more fragmented House. The way political scientists measure how fragmented is political system or a legislative body is by applying a formula for calculating the Effective Number of Parties. It's a measure that helps researchers to go beyond the simple (absolute) number of parties. A widely accepted formula was proposed by M. Laakso and R. Taagepera: 

\\[ N =\frac{1}{sum_{i=1}^{n}p_{i}^{2}} \\]

 where N denotes the effective number of parties and p_i denotes the $i^{th}$ party’s fraction of the seats. The problem with this method is that it produces distortions, particularly for small parties.

Some years ago, Grigorii Golosov proposed a new method for computing the effective number of parties in which both larger and smaller parties are not attributed unrealistic scores as those believed with the Laakso—Taagepera index.

\\[ N = sum_{i=1}^{n}\frac{p_{i}}{p_{i}+p{i}^{2}-p_{i}^{2}} \\]
 
To compare the evolution of the effective number of parties in the Brazilian lower chamber between 2002 to 2014 elections, I wrote a small function that computes some political diversity measures including the new proposed method of counting parties by [Golosov (2010)](http://ppq.sagepub.com/content/16/2/171.abstract). 
The results suggest we had a big jump between 2010 to 2014, from 10.5 to 14.5 in the Golosov scale. The results using the standard method by Laakso and Taagepera were also computed.

{% highlight r %}
library(SciencesPo)

### 2010 Election outcome as proportion of seats
 seats_2010 = c(88, 79, 53, 43, 41, 41, 34, 28, 21,
17, 15, 15, 12, 8, 4, 3, 3, 2, 2, 2, 1, 1)/513

### 2014 Election outcome as proportion of seats
 seats_2014 = c(70, 66, 55, 37, 38, 34, 34, 26, 22, 20, 19, 15, 12, 11, 10, 9, 8, 5, 4, 3, 3, 3, 2, 2, 2, 1, 1, 1)/513

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

