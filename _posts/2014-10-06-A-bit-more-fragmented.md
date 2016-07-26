---
layout: post
title: "A Bit More Fragmented" 
date: 2014-10-06
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, polls]
excerpt: "This entry discusses the legislative elections in Brazil, which turned out to produce one of the most fragmented parliament in the world."
published: true
comments: true
header-img: "img/website/rain-room.jpg"
---

The 2014 election gave rise to an even more fragmented lower house in Brazil. This is important because higher values of political fragmentation suggest a less stable political environment in comparison with previous years.

![The Golosov effective number of parties]({{ site.url }}/img/2014/EffectiveNumberParties.png)

## The 2014 legislative election
This year, the election gave rise to an even more fragmented lower house. The way political scientists measure how fragmented is a political system is by applying one of the several formulas for calculating the *Effective Number of Parties*. The *Effective Number of Parties* is a statistic that helps researchers to go beyond the simple (absolute) count of the number of parties for further analysis. A widely accepted formula was proposed by M. [Laakso and R. Taagepera
 (1979)](http://cps.sagepub.com/content/12/1/3.extract): 

$$N =\frac{1}{\sum_{i=1}^{n}p_{i}^{2}}$$

 where N denotes the effective number of parties and p_i denotes the $i^{th}$ party’s fraction of the seats. The problem with this method is that it produces distortions, particularly for small parties.

Few years ago, [Grigorii Golosov (2010)](http://ppq.sagepub.com/content/16/2/171.abstract) suggested a new formula for estimating the effective number of parties in which both larger and smaller parties are not attributed unrealistic scores as produced by the Laakso—Taagepera index above. Golosov's formula can be expressed as:

$$ N = \sum_{i=1}^{n}\frac{p_{i}}{p_{i}+p{i}^{2}-p_{i}^{2}} $$
 
To compare the evolution in the effective number of parties between ~~2002~~ 1986 to 2014 in the Brazilian lower house, I programed a small function which computes some of the most standard political diversity measures, including the [Golosov (2010)](http://ppq.sagepub.com/content/16/2/171.abstract)'s formula above. The function is part of the [SciencesPo](https://cran.r-project.org/web/packages/SciencesPo/index.html) R package. For a more complete overview of the indices performed by the package, refer to this [vignette](https://cran.r-project.org/web/packages/SciencesPo/vignettes/Indices.html).

The results displayed below and summarized in the plot at the top of this post, indicate the effective number of parties had a considerable upward shift between 2010 to 2014, moving from 10.5 to 14.5 using the Golosov's scale or from 10.4 to 13.1 using the more standard method by Laakso and Taagepera.

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
PoliticalDiversity(seats_2010, index= "laakso/taagepera")
[1] 10.369

PoliticalDiversity(seats_2010, index= "golosov")
[1] 10.511

PoliticalDiversity(seats_2014, index= "laakso/taagepera")
[1] 13.064
 
PoliticalDiversity(seats_2014, index= "golosov")
[1] 14.472
{% endhighlight %}

### Update
After I published this post, I realized it would be nicer to extend the election series as well as compare the two indices mentioned above. So, I did update the original plot, which contained only values computed under the Golosov's method. Also notice that the results may differ from other scholars because the overall sum of votes used or the number of elected candidates may be different. Some may use the *actual outcome* of the election, as I did, others may use the number of representatives that actually entered the office after any recounting or judicial decisions.