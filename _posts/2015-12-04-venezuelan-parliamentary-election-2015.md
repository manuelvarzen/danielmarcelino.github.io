---
layout: post
title: Venezuela's 2015 Parliamentary Elections
author: Daniel Marcelino
date: 2015-12-04
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, polls]
excerpt: "This post shows the tremendous variability from pollster to pollster about the voting intention among Venezuelans."
published: true
comments: true
header-img: "img/website/spaghetti.png"
---

Next Sunday Venezuelans are heading to the polls once again with international concerns about the clearness of the balloting. To get an idea about the political climate over there, I've collected some polls available on the internet. The surprising thing from those surveys is a tremendous variability from pollster to pollster about the single topic of voting intention. You may find national polls fielded in the same period with estimates varying as much as 20%, isn't it dramatic? If you always wanted to see house bias operating in practice, the Venezuelan elections may provide you a good case then.   

![center]({{ site.url }}/img/2015/venezuela1.png) 

{% highlight r %}
### The data
library(ggplot2)
library(dplyr)
library(SciencesPo) 

source = "https://github.com/danielmarcelino/Polling/raw/master/Venezuela/data/polls.txt"

data <- getdata(source)

data$begin <- as.Date(data$begin, format = "%d-%m-%Y")
# just interested in some period
data <- data %>% 
  filter(begin>as.Date("01-07-2014", format = "%d-%m-%Y"))
{% endhighlight %}



{% highlight r %}
### The plot
ggplot(data) +
  geom_point(aes(x = begin, y = MUD,size=3),color="gray25") +
  geom_point(aes(x = begin, y = PSUV,size=3), color="tomato") +
  geom_hline(yintercept=0,size=1.2,colour="#535353") +
  plotTitleSubtitle(title="Vote Intentions for the Gop (MUD) and Gov't (PSUV)", subtitle="Black = MUD, Red = PSUV") +
  theme_538()
# credits
  plotFootnote("danielmarcelino.github.io")

{% endhighlight %}

