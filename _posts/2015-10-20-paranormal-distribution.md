---
layout: post
title: "Paranormal Distribution"
date: 2015-10-20
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, polls]
excerpt: "This is funny."
published: true
comments: true
header-img: "img/website/rain-room.jpg"
---

What if, instead of a normal, you got a paranormal distribution?
In case you want to read an influential paper on this matter, you can find it [here](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2465539/).

 ![Paranormal Distribution]({{ site.url }}/img/2015/paranormal.png)


#### Load packages and set up the theme 
{% highlight r %}
library(ggplot2)
library(gridExtra)

theme_old <- theme(panel.grid.minor = element_blank(),
                   panel.grid.major = element_blank(),
                   panel.background = element_blank(),
                   plot.background = element_rect(fill="#F9F0Ea"),
                   panel.border =  element_blank(),
                   axis.line = element_blank(),
                   axis.text.x = element_blank(),
                   axis.text.y = element_text(colour=NA),
                   # axis.text.y = element_blank(),
                   axis.ticks = element_blank(),
                   axis.title.x = element_blank(),
                   axis.title.y = element_blank(),
# I'm using xkcd fonts, replace or install if you don't have it.
                   text = element_text(size=14, family="xkcd"),
                   axis.line = element_line(colour = "black", linetype = "solid", size = 1),
                   axis.line.y = element_blank(),
                   plot.title = element_text(size=22))
{% endhighlight %}

{% highlight r %}
#### Make a "normal" normal distribution 
gplot1 <- ggplot(data.frame(x = c(-3, 3)), aes(x)) + stat_function(fun = dnorm) + labs(title = "Normal Distribution") + theme_old
{% endhighlight %}

#### Make a floating dress for the paranormal distribution
{% highlight r %}
 
a <- c(-3, -1.5, -0.9, -0.3, 0.6, 1, 1.5, 2, 3)
b <- c(0.004431848, 0.03, 0.0044, 0.03, 0.01, 0.030, 0.0044, 0.015, 0.004431848)

data <- data.frame(a = a, b = b)
c <- c(-0.40, 0.04)
d <- c(0.27, 0.27)
data2 <- data.frame(c = c, d = d)
{% endhighlight %}

#### Plot paranormal distribution 
{% highlight r %}

gplot2 <- ggplot(data, aes(x=a, y=b)) + geom_line()
gplot2 <- gplot2 + stat_function(fun = dnorm) +
  geom_point(data = data2, aes(x=c, y=d), pch=0x30, size=6) +
  geom_point(data = data2, aes(x=c-0.008, y=d-0.006), pch=19, size=1) +
  labs(title = "Paranormal Distribution") + theme_old
{% endhighlight %}


#### Put them together
{% highlight r %}
grid.arrange(gplot1, gplot2)
{% endhighlight %}