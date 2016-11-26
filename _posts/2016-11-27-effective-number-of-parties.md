---
layout: post
title: "The Effective Number of Parties in the Electorate by Year and Region"
author: "Daniel Marcelino (@dmarcelinobr)"
date: "November 27, 2016"
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, Viz, reproducible]
excerpt: "Using the American National Election Studies, compute the Effective Number of Parties in the electorate across regions and years/waves. "
published: true
status: published
comments: true
---


## Tasks: Compute the Effective Number of Parties by year and region

- Using the American National Election Studies, compute the Effective Number of Parties in the electorate across regions and years/waves.  

## The data

The data come from The American National Election Studies (ANES).
The [ANES](http://www.electionstudies.org/) is a survey that covers voting behavior, public opinion, and political participation. Many other countries have their own version of this survey, for instance see [here](http://ellisp.github.io/blog/2016/09/18/nzes1). 
While the primary mission of these studies is to answer questions about voting behavior, the wealth of variables collected amongst voters means that we can use these data to answer other questions too. If you would like to know about the other variables contained in the ANES questionnaires, you may want to read its [codebook](http://www.electionstudies.org/studypages/anes_timeseries_cdf/anes_timeseries_cdf_codebook_var.pdf). You may also be interested in a [post](http://www.asdfree.com/2013/11/analyze-american-national-election.html) by Anthony Damico on this topic.

There are many ways you can import the version of data I've made. For example, you download it. Then read it.


{% highlight r %}
library(dplyr)
library(ggplot2)
library(RCurl)
library(SciencesPo) 

download.file("https://github.com/danielmarcelino/Datasets/raw/master/ANES/anes-data.RData", destfile = "anes-data.RData")

ANES <- readRDS("anes-data.RData")
{% endhighlight %}

## Data chasing
I'm particularly interested in 3 variables from the list. Party identification (VCF0301), originally measured as 7-point scale, the census region code (VCF0112), and years of the wave (VCF0004). 





{% highlight r %}
ANES$PID3 <- factor(ANES$VCF0301) # Convert to three-level Party ID:
levels(ANES$PID3) <- c("Dem", "Dem", "Dem", "Ind", "Rep", "Rep", "Rep")

ANES$Region <- factor(ANES$VCF0112) # # Convert to factor
levels(ANES$Region) <- c("Northeast", "North Central", "South", "West")

names(ANES)[names(ANES)=="VCF0004"] <- "Year"

# ANES <- ANES[(which(ANES$VCF0004 %in% c(2000, 2002, 2004, 2008,2012))),]
{% endhighlight %}


## The Effective Number of Parties
For those who do not know the concept of an "Effective Number of Parties", you can read a [post back in 2014](http://danielmarcelino.github.io/blog/2014/A-bit-more-fragmented.html), or go to [Wikipedia](https://en.wikipedia.org/wiki/Effective_number_of_parties) for summarizing details. In short, the effective number of parties is the number of viable or important political parties in a party system that includes parties of unequal size.
This measure is given by the inverse of the Herfindahl-Hirschman Index (HHI) or the inverse participation ratio (IPR) in physics. 
The HHI is calculated by taking the voting share of each party in the electorate, squaring them, and summing the result: $HHI = s1^2 + s2^2 + s3^2 + ... + sn^2$ (where *s* is the voting share of each party expressed as a whole number. In mathematical notation, it looks like:

$$HHI = \sum_{i=1}^N s_i^2$$

For now, I'll be using *dplyr* to estimate the effective number of parties by year and region, but the **SciencesPo** package has a function named *politicalDiversity* that can calculate several indices used by political science scholars, which I’ll be addressing in future posts. 


{% highlight r %}
ENPpid3 <- ANES %>% 
group_by(Year, Region) %>%
  summarise(invHHI = sum(table(PID3))^2 / sum(table(PID3)^2)) %>%
filter(!is.na(Region))
{% endhighlight %}



{% highlight text %}
print(ENPpid3)

Source: local data frame [112 x 3]
Groups: Year [28]

    Year        Region   invHHI
   <dbl>        <fctr>    <dbl>
1   1952     Northeast 2.251207
2   1952 North Central 2.231502
3   1952         South 1.538712
4   1952          West 2.119764
5   1956     Northeast 2.352651
6   1956 North Central 2.419891
7   1956         South 1.816944
8   1956          West 2.395399
9   1958     Northeast 2.296220
10  1958 North Central 2.247543
# ... with 102 more rows
{% endhighlight %}



## The plot
The index takes into consideration the relative size distribution of the parties (actually, declared partisanship) in an electorate. It approaches 1 when the distribution of preferences in a region is concentrated around only one party. Conversely, the index increases when the number of parties favored in the region increases.

The analysis suggests a highly concentrated political market in-the-electorate in the South states, around 1 and a half party in the 50s, but then regressing towards the national mean (invHHI = 2.349) after the 60s.


{% highlight r %}
gg <- ggplot(ENPpid3)
gg <- gg + geom_line(aes(x = Year, y = invHHI, colour = Region), size=1.1)
gg <- gg + scale_x_continuous(limits=c(1952, 2012), 
breaks =  round(seq(1952, 2012, by = 4),1)) 
gg <- gg + scale_y_continuous(limits=c(1, 3))
gg <- gg + theme_pub()
gg <- gg + labs(title = "Effective Number of Parties-in-the-Electorate", 
x = "Year of the survey", y = "Index")
gg
{% endhighlight %}

<img src="/img/11-26-2016-effective-number-of-parties/plot-1-1.png" title="center" alt="center" style="display: block; margin: auto;" />

It’s true that majority plurality (single ballot) electoral systems tend to have a low number of effective parties compared to majority second ballot systems and to proportional representation systems. With an average count of effective parties in-the-electorate around 2, there is not much room for a third political force to emerge; and this seems to be quite consolidated among regions.

`#reproducible`
