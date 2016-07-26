---
layout: post
title: "House Effects in Argentinian polling"
date: 2015-10-25
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, viz]
excerpt: "This post presents the estimated house effects for the main presidential candidates in Argentina, considering more than 115 polls since 2014."
published: true
comments: true
header-img: "img/website/rain-room.jpg"
---

I've already [posted](http://danielmarcelino.com/r/08-2015/Argentine-general-election-2015/) previously on "house effects", the tendency of polling organizations to systematically vary in their results from one another. In this post, I look specifically at these house effects, and show which polling organizations over or under-estimate support for each candidate--compared to the average--in this presidential election in Argentina.

The graph below plots the house effects for the main presidential candidates considering more than 115 polls that I've collected since 2014.

![House Effects]({{ site.url }}/img/2015/3d-house-effects_argentine.png)

In essence, the house effects measure how far polls by a pollster are from what would be expected based on trends over time for the average polling house. In other words, the average house effect toward each candidate/party is expected to be zero by design. Then, a poll that is systematically 2% below what would be predicted for the date the poll was conducted will have a house effect of -2.0%.

The dots in "red" in the plot represent the pollster whose house effects were negative toward Mauricio Macri, while dots in "blue" represent positive effects toward him. 

The electoral result tonight was a bit of surprise as several pollsters didn't seem to have pick out a crescendo preference for the opposition candidate, Mauricio Macri, among undecided voters over the last week. [This blog](http://us3.campaign-archive1.com/?u=6b1e9fcb4df3eaee1cd635f50&id=0e702eecac&e=c2780c4e4b) has more details. 


{% highlight r %}
library(scatterplot3d)
houseEffects$pcolor[houseEffects$Macri< 0] <- "red"
houseEffects$pcolor[houseEffects$Macri>=0] <- "blue"

with(houseEffects, {
  s3d <- scatterplot3d(Scioli, Massa, Macri, # x y and z axis
                       angle=30, # angle of the plot 
                       color=pcolor, pch=19, # filled blue circles
                       type="h", # vertical lines to the x-y plane
                       main="House Effects",
                       xlab="Daniel Scioli",
                       ylab="Sergio Massa",
                       zlab="Mauricio Macri")

  s3d.coords <- s3d$xyz.convert(Scioli, Massa, Macri) # convert 3D coords to 2D projection
  text(s3d.coords$x, s3d.coords$y,  # x and y coordinates
       labels=Pollster,  # text to plot
       cex=.5, pos=4) # shrink text 50% and place to right of points)
  legend("topleft", inset=0, # location and inset
         bty="n", cex=.7,  # suppress legend box, shrink text 70%
         title="House effects toward\nDaniel Scioli",
         c("-", "+"), fill=c("red", "blue"))
})
{% endhighlight %}


