---
layout: post
title: "Gender Effect in Conference Talks"
date: 2015-12-22
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats]
excerpt: "The entry discuss a study that finds strong gender effects in conference talks"
published: true
comments: true
header-img: "img/website/spaghetti.png"
---

I was searching in the arXiv repository for an interesting paper to read over the weekend, when I found this: ["Studying Gender in Conference Talks -- data from the 223rd meeting of the American Astronomical Society"](http://arxiv.org/abs/1403.3091). The title and figures caught my attention more than the subject of the conference, I've to confess.
 
The plot below, taken from the paper, displays the most significant finding from the analysis: *a strong dependence on session chair gender*. Overall, males ask more question than females, but there is a large difference in number of questions asked by males vis-à-vis number asked by females, given a male or female chair. I'm wondering if this also holds for other science fields where the gap between male and female researchers is that not abnormal.

![Main Findings]({{ site.url }}/img/2015/gender_chairs_n_questions.png)

The paper is stuffed with figures, but in this case I would prefer a table with residuals; way more telling.

{% highlight r %}

tab = as.table(matrix(c(63, 90, 122, 359),nrow=2,ncol=2,
dimnames=list(chairs=c('FC','MC'),
questions=c('FQ', 'MQ'))))

> tab
     questions
chairs  FQ  MQ
   FC  63 122
   MC  90 359
      
dat = SciencesPo::untable(tab)

> head(dat)
  chairs questions
1    FC       FQ
2    FC       FQ
3    FC       FQ
4    FC       FQ
5    FC       FQ
6    FC       FQ

{% endhighlight %}

{% highlight r %}
> crosstabs(dat, "chairs", "questions",
+            row.pct = TRUE,
+            chisq = TRUE,
+            sresid = TRUE)

Table of chairs by questions

                         |questions  
-------------------------+-----------+-----------+-----------+
chairs                   |FQ         |MQ         |Total      |
-------------------------+-----------+-----------+-----------+
FC      |Obs Freq        |         63|        122|        185|
        |% within chairs |    34.0541|    65.9459|   100.0000|
-------------------------+-----------+-----------+-----------+
MC      |Obs Freq        |         90|        359|        449|
        |% within chairs |    20.0445|    79.9555|   100.0000|
-------------------------+-----------+-----------+-----------+
Total   |Obs Freq        |        153|        481|        634|
-------------------------+-----------+-----------+-----------+

Statistics for Table chairs by questions

Statistics                   DF      Value     Prob
---------------------------------------------------
Pearson Chi-Square           1     13.2901  0.0003
Likelihood Ratio Chi-Square  1     13.4689  0.0002
Fisher's Exact Test                         0.0003
---------------------------------------------------

Residuals for Table chairs by questions

         |questions  
---------+-----------+-----------+
chairs   |FQ         |MQ         |
---------+-----------+-----------+
FC       |     2.7470|    -1.5493|
MC       |    -1.7633|     0.9945|
---------+-----------+-----------+

{% endhighlight %}