---
layout: post
title: "A Talk About Campaign Finance in Brazil"
date: 2015-10-17
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats]
excerpt: "This post provides some unsolicited comments on the campaign finance issue."
published: true
comments: true
header-img: "img/website/rain-room.jpg"
---

Last week, I delivered a talk at [University of Brasilia](http://www.unb.br) about my past research on the topic of campaign finance. I didn't know in advance about the existence of this seminar. Indeed, it was a big surprise receiving the invitation from Prof. Marcelo Pimentel, who is teaching on Fridays afternoon a class on this topic with more than 50 registered students. I became his fan after seeing his syllabus. He did managed to assemble a handful studies covering why, what, how, and when money affects politics and elections in Brazil.

Though I covered a lot of factors in my talk, I think, I had the wrong pictures to show for a heterogeneous crowd. Instead of wasting time showing regression tables, and trying to solve understanding issues after showing them, I should have shown simple yet powerful pictures like the following ones, so to give the intuition about the relationship between money and votes, generally debated in the literature and media.

![Linear Relationship with SS]({{ site.url }}/img/2015/linearSS.png)

![U-Shape Relationship]({{ site.url }}/img/2015/u-shape.png)

Of course, the biggest challenge of this scholarship is how to disentangle any existing confounders in this rather seemingly relationship: votes ~ money.

Overall, we know the recipe, preparing the dishy is different  thing. Studies being conducted on this area try to find the "treatment effect" of money on votes: What would have happened if the candidate had spent only a fraction of his budget, or What would have happened if the candidate who spent only a fraction could spend more? 

The problem arises because we can see one condition, but never both at the same time. The suboptimal solution is to measure the average effect `(Y_1i - Y_0i)`, or the average of groups of candidates, such as incumbents vs non-incumbents. It turns out that comparisons of who spend more or less in elections are likely to be a poor measure of the causal effect of campaign spending simply because selection bias should be extremely high (Morton and Williams, 2010). It's not trivial to argue that those who has more money to spend would have earned more votes anyway. 

As Angrist and Pischke point out in their 2009's book, if selection bias is positive, the naïve comparison `E(Y_1i | c_i=1) - E(Y_0i | c_i=0)` can be a real problem, since the benefits of spending extra money is exaggerated. 

![U-Shape Relationship]({{ site.url }}/img/2015/Angrist_Pischke_bias.png)

It could be "easier" to provide causal inference on this if we run a randomized experiment. If the treatment of campaign spending levels is randomly assigned, selection bias would be zero. The experiment don't need to be that large, if treated units are random selection from the population of candidates, then the impact on treated also applies to the population. Isn't cool?

