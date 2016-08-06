---
layout: post
title: "Calculating Memory Requirements"
date: 2016-07-20
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats]
excerpt: "A post about size and memory requirements that a computer must have to deal with a data frame."
published: true
status: published
comments: true
---


I had a conversation with people at the office about size and memory requirements that a computer must have to deal with a data frame. It started like this: suppose you have a data frame with 2,000,000 rows and 250 columns, all of which are numeric data  (2,000,000 × 250 × 8 bytes/numeric). Roughly saying, how much memory is required to store this data?

We can calculate the proximate memory usage using number of rows and columns within the data:

{% highlight r %}
# bytes
> 2000000*250*8 
[1] 4000000000
{% endhighlight %}



{% highlight r %}
> # bytes/MB
> 2000000*250*8/2^{20}
[1] 3814.697
{% endhighlight %}


{% highlight r %}
> # MB
> round(2000000*250*8/2^{20},2)
[1] 3814.7
{% endhighlight %}


{% highlight r %}
> # GB
> round(2000000*250*8/2^{20}/1024, 2)
[1] 3.73
{% endhighlight %}

We also can apply the same approach on other types of data with attention to number of bytes used to store different data types, as character, factors etc. We also can use 10 rather than 8 as the bytes/numeric coefficient, and triple that to figure out how much contiguous space is needed. If the data frame is just character data, the ratio is going to be around 1.1, and reading it in as factor data might be even below this. 

Finally, if you want to get a solid understanding of R's memory management, you will find a section in the Hadley Wickham's [book](http://adv-r.had.co.nz/memory.html) very useful.
