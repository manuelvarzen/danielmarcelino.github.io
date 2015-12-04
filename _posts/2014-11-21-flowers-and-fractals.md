---
layout: post
title: "Flowers Fractals, or Fractal Flowers" 
date: 2014-11-21
category: R
tags: [fractals]
comments: true
---

Last week I attended a "Flower Festival" in Joinville, where I had opportunity to admire several of among the most beautiful and awarded flowers, orchids, and decoration plants. Surprisingly, though, I never had thought on flowers like  fractals the way I did this time.

<!--more-->

![Flower]({{ site.url }}/img/2014/flower_joinville1.jpeg)

## Introduction
Fractals attract lots of interest, especially from mathematicians who actually spend time studying about their structures and combinations. But what makes something a fractal? A fractal is defined as an object that displays self-similarity on all scales. But the object doesn’t need to have exactly the same structure at all scales only the same sort of structure must be visible or recognizable any how. 

![Flower]({{ site.url }}/img/2014/flower_joinville.jpeg)

The structure or the equation that defines a fractal is most of the time very simple. For instance, the formula for the famous [Mandelbrot](https://en.wikipedia.org/wiki/Mandelbrot_set) is \\[ z_{n+1}=z_n^2+c \\].


## How can we start?
We start by plugging in a constant value for $c$, $z$ can start at zero. After one iteration, the equation gives us a new value for $z$; then we plug this back into the equation at old $z$ and iterate it again, it can proceed infinitely.

As a very simple example, let’s start this with c = 1.

\\[ z_{1} = z_{02} + c= 0 + 1 = 1 \\]
\\[ z_{2} = z_{12} + c = 1 + 1 = 2 \\]
\\[ z_{3} = z_{22} + c = 4 + 1 = 5 \\]

Graphing these results against *n* would create an upward parabolic curve because the numbers increase exponentially (to infinity). But if we start with c = -1 for instance, $z$ will behave completely different. That is, it will oscillate between two fixed points as:

\\[ z_{1} = z_{02} + c= 0 + -1 = -1 \\]
\\[ z_{2} = z_{12} + c = 1 + (-1) = 0 \\]
\\[ z_{3} = z_{22} + c = 0 + (- 1) = -1 \\]
\\[ z_{4} = z_{32} + c = 1 + (- 1) = 0 \\]


And this movement back and forth will continue forever as we can imagine. I figured out, that the Mandelbrot set is made up of all the values for $z$ that stay finite, thus a solution such as the first example for $c = 1$ is not valid and will be thrown out because $z$ in those cases goes to infinity and Mandelbrot lives in a finite world. The following is an example of such set.

![Mandelbroat]({{ site.url }}/img/2014/Mandelbrot.gif)


#### The script for this set:

{% highlight r %}
library(caTools) 
# caTools is handy because it provides write.gif function

cols <- colorRampPalette(c("#00007F", "brown", "blue", "#007FFF", "green", "#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000", "magenta"))
m <- 1200 # define size
C <- complex( real=rep(seq(-1.8,0.6, length.out=m), each=m ),
              imag=rep(seq(-1.2,1.2, length.out=m), m ) )
C <- matrix(C,m,m) # reshape as square matrix
Z <- 0 # initialize Z to zero
X <- array(0, c(m,m,20)) # initialize output 3D array
for (k in 1:20) { # loop with 20 iterations
    Z <- Z^2+C # The equation
    X[,,k] <- exp(-abs(Z)) # capture results
}
write.gif(X, "Mandelbrot.gif", col=cols, delay=1000)
{% endhighlight %}