---
layout: post
title: "Understanding Margin of Error for Small Populations"
date: 2015-10-13
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, polls]
excerpt: "This post discusses margin of error, gives some theoretical reasons and apply them to a real poll."
published: true
comments: true
header-img: "img/website/rain-room.jpg"
---

I got an email inquiring if the margin of sampling error reported in the newest poll by the Brazilian pollster Datafolha would be misleading. The polling firm often report surveys with regular sizes (1000/2400), so the margin of error calculated is in the range of +/-2% to +/-3%. 

However, in its [latest poll](http://www1.folha.uol.com.br/poder/2015/10/1693217-parlamentares-sao-mais-liberais-do-que-o-eleitorado.shtml), the pollster sampled only 340 congressmen, reporting a margin of error of 3%. Which apparently did puzzle the attentive reader, who knows the margin of error is an inverse square root function of the sample size. She asks: "Is the reported margin of error correct? Given such a small sample, shouldn't it be something around 5.3% or so?
  
My answer to the question was "sort of". Firstly, given the fact the population of congressmen is a finite population (594 = 513 deputies + 81 senators), we must apply a Correction Factor for Finite Populations (FPCF), which will reduce the standard error of the mean. Essentially, the correction adjusts for the fact that although the number of elements is small, it comes from a small population too. 

Adjusted by the FPCF, the margin of error is close to what reported by the Datafolha, however, by omitting decimal digits, the pollster arbitrarily narrows the confidence interval (2 * the margin of error) in about 1%. It's not that usual to round margins of error when reporting them, as a decimal digit may imply in substantial differences in the sample size as illustrated in the graph from Marcelino and Angel's paper.

![Sample size vs Confidence Interval]({{ site.url }}/img/2015/sample_size.jpg)

For pedagogical reasons, I won't go through the simplified formula. So, let do it step-by-step.

### Margin of Error for Large (Infinite) Populations 
The derivation of the maximum margin of error formula is given by:
{% highlight text %}

e = zs/sqrt(n)
where:
z = 
2.576 for 99% level of confidence
1.96 for 95% level of confidence
1.645 for 90% level of confidence

s = sqrt(p(1-p))      
p = proportion

n = sample size


e = zs/sqrt(n)
	= (1.96*0.5)/sqrt(340)
	= 0.05314796
{% endhighlight %}

Thus, if we sample n = 340, we get a margin of error of = 5.31%.

### Margin of Error for Finite Populations 

When the population is small (say less than 1 million), or the sample size represents more than 5% of the population, the pollster should multiply the margin of error by the Corrector Factor (FPCF), given the formula: 

{% highlight text %}
e = zs/sqrt(nadj)

where:
z = 
2.576 for 99% level of confidence
1.96 for 95% level of confidence
1.645 for 90% level of confidence

s = sqrt(p(1-p))     
p = proportion 

nadj = (N-1)n/(N-n)   
n = sample size 
N = population size

e = zs/sqrt(nadj)
  = (1.96*0.5)/sqrt((594-1)*340/(594-340))
	= (1.96*0.5)/sqrt(793.7795)
	= 0.03478373

{% endhighlight %}

By adjusting for finite populations, we get a margin of error of = 3.48%. 

### Stretching the concept
Now, take an instant. I've calculated the maximum margin of error--or the global margin--because in several situations we don't know for sure where how the population falls apart on a particular issue. So, by estimating the population as 50/50 divided on the issue, we maximize the margin of error; a sort of conservative backup.

However, if we discover that 74% of the congressmen gave the same answer, as they did on the topic of criminality, then the margin of error of two means for that particular question would be  smaller: 3%.

We compute *s* and plug it in the previous estimation, as:
{% highlight text %}
s = sqrt(p(1-p)) 
  = sqrt(0.74*(1-0.74)) 
  = 0.4386342

e = zs/sqrt(nadj)
  = (1.96*0.44)/sqrt((594-1)*340/(594-340))
	= (1.96*0.44)/sqrt(793.7795)
	= 0.0306097
{% endhighlight %}

I found this poll very interesting. Actually, I think Datafolha should conduct polls like that more often. So, we can get to know more about the  average position of our representatives. 
