---
layout: post
title: "The Butterfly Curve"
date: 2015-10-07
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, viz]
excerpt: "This post shows the implementation of the butterfly curve equation in R, and its output plot produced with ggplot2."
published: true
comments: true
header-img: "img/website/rain-room.jpg"
---

Have you ever thought drawing your own butterfly?
I came across the [butterfly curve](https://en.wikipedia.org/wiki/Butterfly_curve_%28transcendental%29), which was discovered by Temple Fay. The butterfly curve is produced by a parametric equation where:
<mark>x = sin(t) * (e^cos(t)-2cos(λt)-sin(t/12)^5)</mark> and
<mark>y = cos(t) * (e^cos(t)-2cos(λt)-sin(t/12)^5)</mark>.
Where t stands for time and `λ` for a user input variable.

![Linear Relationship]({{ site.url }}/img/2015/butterfly.png)


{% highlight r %}
library(ggplot2)

source("https://raw.githubusercontent.com/danielmarcelino/SciencesPo/master/R/butterfly.R")

p4 = butterfly(100, 1000, title="100 x 1000")

Date of Analysis: Wed Oct 07 2015
Computation time: 0.01444697
—————————————————
{% endhighlight %}




