---
layout: post
title: "Retrieving Data from Google Books with `ngramr`"
date: 2015-11-15
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats]
excerpt: "The post explores the Google Ngram Viewer service requested from."
published: true
comments: true
header-img: "img/website/spaghetti.png"
fb-img: "http://danielmarcelino.github.io/img/code-2015-11-15-retrieving-data-from-google-books-with-ngramr/sociologists-1.png"
---

[Karl Marx](https://en.wikipedia.org/wiki/Karl_Marx) is the most famous founding fathers of modern sociology with a popularity peak in 1975-6, but declining ever since my little research using the [Google Ngram Viewer](https://books.google.com/ngrams) suggests.

## Introduction 
Google has a tool for tracking the frequency of words or phrases across its vast collection of scanned texts, the Google Books. The [Google Ngram Viewer](https://books.google.com/ngrams) reports data and graphs the frequency of words encountered in one or across several *corpus* over time. For instance, the chart below campares the appearance in the English *corpus* of following bigrams names: "Karl Marx", "Max Weber", "Emile Durkheim". 

![center]({{ site.url }}/img/code-2015-11-15-retrieving-data-from-google-books-with-ngramr/GoogleNgram.png)


The y-axis shows of all the bigrams contained in the sample of books written in English, what percentage of them are "Karl Marx" or "Max Weber" or "Emile Durkheim"? From the chart above, we can conclude that Marx is the most famous sociologist among the others founding fathers, with a peak in popularity about 1975-6, but his influence has been declining ever since. These thinkers are considered the founding fathers of sociology because they set out to develop practical and scientifically sound methods of research to examine theories of the social world rooted in a specific historical and cultural context. 

## Using R with Google Ngram Viewer

There is a package to query the Google Ngram called [ngramr](https://cran.r-project.org/web/packages/ngramr/index.html) written by Sean Carmody. With this package, one can retrieve data from Ngram pages in the form of data frame.  

## Getting Started
The first thing to do is to load the `ggplot2` and `ngramr` packages. In case you don't have them installed, an installation is required.


## Write a Query and Do the Plots

The following is equivalent to the chart above for the three sociologists bigrams, except that I'm applying a smoothed line--or moving average of 5 years, so trends become more apparent. For instance, the data shown for 2000 is an average of the raw count for 2000 plus 5 values on either side: ("count for 1995" + "count for 2000" + "count for 2005"), divided by 3. So a smoothing of 5 means that 11 values will be averaged: 5 on either side, plus the target value in the center of them.


{% highlight r %}
ng <- c("(Karl Marx)", "(Max Weber)", "(Emile Durkheim)") 
ggram(ng, year_start = 1800, 
      year_end = 2012,  
      smoothing = 5,
      google_theme = FALSE) +
  ggtitle("Marx, Weber, Durkheim")+
    theme_538(legend.position = "bottom")
{% endhighlight %}

![center]({{ site.url }}/img/code-2015-11-15-retrieving-data-from-google-books-with-ngramr/sociologists-1.png) 


## Complex Queries

I test the trend in popularity of the unigran "Capitalism" vis-à-vis other two unigrans ("Socialism", "Communism") from 1850 to 2012. Here's how we might combine + and / to show how the unigram "Capitalism" has blossomed at the expense of "Socialism" and "Communism" terms in the literature published in English.


{% highlight r %}
ng <- c("Capitalism /(Capitalism + Socialism + Communism)")
cap <- ggram(ng, year_start = 1850, 
      year_end = 2012,  
      smoothing = 3,
      google_theme = FALSE) +
  ggtitle("Capitalism over (Capitalism + Socialism + Communism)")+
    theme_538()

ng <- c("Socialism /(Capitalism + Socialism + Communism)")
soc <- ggram(ng, year_start = 1850, 
      year_end = 2012,  
      smoothing = 3,
      google_theme = FALSE) +
  ggtitle("Socialism over (Capitalism + Socialism + Communism)")+
    theme_538()

ng <- c("Communism /(Capitalism + Socialism + Communism)")
com <- ggram(ng, year_start = 1850, 
      year_end = 2012,  
      smoothing = 3,
      google_theme = FALSE) +
  ggtitle("Communism over (Capitalism + Socialism + Communism)")+
    theme_538()
multiplot(cap, soc, com, ncols=1)
ggfootnote(size = .5)
{% endhighlight %}

![center]({{ site.url }}/img/code-2015-11-15-retrieving-data-from-google-books-with-ngramr/Capitalism Popularity-1.png) 

In the following, I retrieve the frequency for the unigram "Capitalism" in the Russian *corpus*, French, and British English. Note that the results can be case-insensitive variants.

Below is a plot of the unigram "Capitalism" ("капитализм") in the Russian language *corpus*.


{% highlight r %}
ng <- "капитализм"
rus=ggram(ng, year_start = 1850, 
      corpus = "rus_2012",
      ignore_case = TRUE, 
      google_theme = TRUE) +
    ggtitle("Russian: капитализм")+
     theme_538()

ng <- "capitalisme"
fre=ggram(ng, year_start = 1850, 
      corpus = "fre_2012",
      ignore_case = TRUE, 
      google_theme = TRUE) +
    ggtitle("French: Capitalisme")+
     theme_538()

ng <- "capitalism"
eng=ggram(ng, year_start = 1850, 
      corpus = "eng_gb_2012",
      ignore_case = TRUE, 
      google_theme = TRUE) +
    ggtitle("English: Capitalism")+
     theme_538()

multiplot(rus, fre, eng, ncols=1)
ggfootnote(size = .5)
{% endhighlight %}

![center]({{ site.url }}/img/code-2015-11-15-retrieving-data-from-google-books-with-ngramr/capitalism-1.png) 

    
    
