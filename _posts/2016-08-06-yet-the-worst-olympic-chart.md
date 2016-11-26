---
layout: post
title: "Yet the Worst Olympic Chart"
author: "Daniel Marcelino (@dmarcelinobr)"
date: "August 6, 2016"
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, Viz]
excerpt: "The Olympics barely began but we already have the worst chart winner."
published: true
status: published
comments: true
---



Ah, the numbers! The Olympic Games are back in high style in Rio. Despite Brazil's sluggish economy and unfulfilled promises for this Summer Olympic Games, I'd say, my expectations were met yesterday with such a beautiful opening ceremony. Let's follow the competition over the next few days--the pressure to perform has only just begun. 

One interesting aspect about the Olympic games is the way people around the globe cover it. In fact, several news houses are quite excited about telling predictions and showing medals rankings of all sort, starting soon today. Surprisingly, yesterday my eyes catch a stacked bar chart by [NBC](http://www.nbcolympics.com/) with a really bad visualization taste. It's so inaccurate that it deserves the title of *Worst Olympic Chart*. 

<img src="/img/08-06-2016-yet-the-worst-olympic-chart/NBC-olympic-medals.PNG" title="center" alt="center" style="display: block; margin: auto;" />


The colors are fine, but the dimensions are simply misleading. How have the 976 USA Olympic gold medals been given less length in the plot than  797 Russia's medals (silver and bronze), or all 777.5 medals of Great Britain? Yep, that's right; one can get half a medal by tying for a placement. Anyway, I believe it shouldn't be that difficult to make a decent-looking, yet accurate plot for readers. But perhaps the worst is yet to come.

# Top-3 all-time Olympic medals 

<img src="/img/08-06-2016-yet-the-worst-olympic-chart/unnamed-chunk-2-1.png" title="center" alt="center" style="display: block; margin: auto;" />



#### The data points		
{% highlight r %}		
 library(dplyr)		

 country = c(rep('US',3),rep('RUS',3),rep('GB',3))		
 Medal = rep(c('Gold','Silver','Bronze'),3)		
 counts = c(976.0, 759.5, 668.5, 440.0, 357.0,326.0, 233.5, 272.5, 271.5)		

 Olympics = as.data.frame(		
 cbind(country,		
  Medal,		
 counts))		

 Olympics$counts = as.numeric(levels(Olympics$counts))[Olympics$counts]		
Olympics$Medal <- factor(Olympics$Medal,levels = c('Gold','Silver','Bronze'))		

Olympics <- Olympics %>% 		
 group_by(country) %>% 		
 mutate(mid_y=cumsum(counts) - 0.5*counts)		
 
{% endhighlight %}		

#### Do the plot		
Updated: to work properly, please install the ggplot2 development version, otherwise delete the theme setting line.		
{% highlight r %}		

library(ggplot2) # devtools::install_github('haddley/ggplot2')	
library(SciencesPo) # for the theme:
devtools::install_github('danielmarcelino/SciencesPo')		

g <- ggplot(Olympics,aes(x = country, y=counts, fill = Medal)) 	
g <- g + geom_bar(stat = 'identity')		
g <- g + scale_fill_manual(values = c('#FFD700','#C0C0C0','#CD7F32')) 		
g <- g + scale_y_continuous(limits = c(0, 2500))		
g <- g + geom_text(aes(label=counts, y = mid_y), size = 3)		
g <- g + labs(x='',y='Number of Medals', title='Olympic Medals')
g <- g + coord_flip() 		
g <- g + theme_scipo(base_size = 13)		
g <- g + no_y_gridlines()		
print(g)		
{% endhighlight %}