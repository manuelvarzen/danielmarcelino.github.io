---
layout: post
title: "Looping through factor variables" 
date: 2012-01-10
category: R
tags: [R, looping]
---

Today, I was chatting to a friend who is working on his Ph.D thesis which coincidently is about my favorite topic: campaign contributions. 

<!--more-->

![Looping]({{ site.url }}/img/2012/looping.png)

We discussed about analyzing probabilities of a particular group to grasp more money than the others, particularly, between male and female candidates given the district. 
I thought that a preliminary approach might consider identifying  whether a candidate received less or more money than the district average. In doing so, should be valuable to coding those case as "0 or 1" accordingly, so you can perform a logistic regression to  test for gender effects. 
This task can be performed pretty easy in all statistical packages, Excel included. 

In Stata, for instance, it is enough to type: 
{% highlight text %}
even stat emu = mean(revenue), by(state gender) 
{% endhighlight %}

while in R:
{% highlight r %}
mean <- with(data, aggregate(revenue, by=list(state=state, gender=gender), FUN=mean, na.rm=TRUE)). 
{% endhighlight %}

Problem solved clean and fast.

Despite I’m not a “gaúcho” I’d say: if we can complicate, why simplify? Joke aside, in general I favor to use the most simple solution ever. Thus, why bother with loops across observations and variables? What’s more, create loops, special the nested ones in large-N (i.e. large number of cases) data set, might be a suboptimal choice since loops decrease the computing efficiency. But, suppose that we’re faced to a data bank with wide number of factor variables, which have many categories: ordered or not. So, perhaps a nested loop across those factors could help us much better. That said, let’s go back to the case of my friend to try a different approach to visualize the average differences using a loop.

Below, I scratch a loop to find the average of contributions revenues to female and male for each state. Despite the following example is quite simple as I’m only looping through 2 factor variables, we can add as many factors we want to compute. Also, the outcome values doesn’t necessary should be average, but you can chose among standard error, percentiles et cetera.

After running the loop below, the averages for males and females will be displayed on your Stata screen as the picture shows.

{% highlight text %}

/* Drawing loop across the groups: electoral districts and gender */
/* Note that the command line levels of is necessary for store the levels contained
in the variable "state" and "gender" otherwise I need to provide them by hand */
quietly levels of state, local(states)
foreach s of local states {
quietly levels of gender if state == "`s'", local(genders)
foreach g of local genders {
quietly summarize revenue if gender =="`g'" & state == "`s'", mean only
local mu = r(mean)
display "Meam of Contributions for `g' in `s' = `mu'"
}
}
{% endhighlight %}

For example, regardless my data set is pooled altogether candidates for a variety of offices, in Acre (AC) the first state shown in the picture above, the average of contributions for female is 45,983.57 while for male is around 51,116.96. For miner the outcome we might introduce other factors like office, incumbency, et cetera.


