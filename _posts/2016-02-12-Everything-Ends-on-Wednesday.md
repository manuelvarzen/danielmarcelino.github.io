---
layout: post
title: "Everything Ends on Wednesday"
subtitle: "HIV testing after Carnival"
author: "Daniel Marcelino"
date: 2016-02-12
output:
 html_document: 
   keep_md: yes
   toc: yes
tags: [R]
published: true
---

The Brazilian Carnival just finished this week, but for some people it is time to start worrying about crazy things that may have happened over the days of the flesh festival.

Watching the news, the spoken person of the Test and Prevention Center (CTA) of Brasilia estimated that people seeking test services by this institution increases on average 40% the day after the carnival. By the end the day, the spoken person reveled that 2 out of 124 performed rapid tests (most likely staff finger stick tests) turned out positive. 

I started to thinking about incidence of HIV among Brazilians and how likely it's to be tested positive when incidence levels also change.

After a little research, I found several sources with estimated quantities of the incidence for  several countries. For instance, in 2011, the incidence rate of AIDS (stage when the disease manifests itself in the patient) in Brazil was 17.9 to 100,000 inhabitants. This number varies  significantly across the regions, so it's higher in South-East and lower in the Midwest of the country, with others regions falling in between. The incidence rate also varies between males and females and among age groups. For the sake of simplicity I will not consider those differences here. It would get too complicated for a blog post post-carnival. 

The [enzyme-linked immunosorbent assay (ELISA screening test)](https://en.wikipedia.org/wiki/ELISA)  for testing a blood sample for the HIV antibodies being present in human blood has these properties:

Sensitivity:

$$ P(positive~ELISA~|~person~is~HIV~positive) = .977 $$ 

Specificity:

$$ P(negative~ELISA~|~person~is~HIV~negative) = .926 $$

**Sensitivity** is the percentage of individuals with HIV infection (based on ELISA reading) whom  correctly identified as having infection (aka the true positive rate). **Specificity** is the percentage of individuals without HIV infection (based on ELISA reading) whom correctly identified as being free of infection (aka true negative rate);

Suppose the incidence of HIV in the population being tested is denoted by p . In class *p = 18/100000* -- or *0.00018*. In general we can show this relation using the Law of Total Probability:

$$P(HIV~positive~|~positive~ELISA) = p * .977~/~(p * .977 + (1-p) * .074)$$

Here is the output and R code  computing this for various values of p with a 25 interval.


![center]({{ site.url }}/images/2016/Sensitivity.png)


{% highlight r %}
cases <- seq(0, 10000, 25)

p <- c(cases/100000)
prob <- p*.977 / (p*.977 + (1-p)*.074)

{% endhighlight %}

{% highlight r %}
> head(round(cbind(p,prob),3), 10)
          p  prob
 [1,] 0.000 0.000
 [2,] 0.000 0.003
 [3,] 0.000 0.007
 [4,] 0.001 0.010
 [5,] 0.001 0.013
 [6,] 0.001 0.016
 [7,] 0.002 0.019
 [8,] 0.002 0.023
 [9,] 0.002 0.026
[10,] 0.002 0.029

{% endhighlight %}
 
 {% highlight r %}
 library(SciencesPo) # for using theme_538
ggplot() + 
geom_line(aes(prob, p), size=1) +
    theme_538()

 {% endhighlight %}

I'm not in the field of epidemiology or biostatistics, but this simple experiment teaches two things. First, it is really important to keep the incidence rate low. Assuming we randonly selected you for the test, when *p* is really small, it's much more likely that you got a false positive (you are positive when you are in fact negative). But as *p* gets larger, it becomes more likely that you do have the infection and the test result is accurate. Second, the accuracy of the test "improves" as a by-product of the incidence/prevalence among elements within the population. 
