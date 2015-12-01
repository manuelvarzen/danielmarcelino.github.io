---
layout: post
title: "Ternary plots in politics" 
date: 2015-08-04
category: R
tags: [R, ternary plot]
---

When we study elections with this geometric figure, each point of the triangle intuitively represents 3 coordinates, parties, or candidates.

<!--more-->

<hr/>

This week, I skin a [post](http://www.r-bloggers.com/ternary-interpolation-smoothing) by Nicholas Hamilton about ternary plots that made me think, how this geometric diagram has many different application in science fields. Couple weeks ago, I was reading a book by [Donald Saari](http://math.uci.edu/~dsaari/), who uses ternary charts massively to project election outcomes in different electoral settings.

Perhaps, most common, ternary diagrams are used for projecting 3-parties elections; the same idea can be generalized for more parties, though it gets more complex. When we study elections with this geometric figure, each point of the triangle intuitively represents 3 coordinates (say A, B, C, because I’m creative today) that correspond to the percentage of votes each political organization obtained. From this, we may speculate the composition of the legislative body. Here I use colors to make it fancier.

The whole point of the book is not about visualize election outcomes, but that election outcomes may be depend on the formula in use to aggregate votes and the number of seats available. Every election result involving three candidates expressed in therm of votes shares is a weighted average or probability mixture of the corner points. For instance, if we have a constituency of M=5 seats, a possible outcome is:


![Ternary Plot for Seats Allocation](/images/blog/2015/ternary1.png)

If party "A" has 60% of the popular preference, party “B” 20%, and “C” other 20%, then a system using a d'Hondt method to distribute seats proportionally to the parties will give: *A(3), B(1), C(1)*. In general, the closer a point is to the vertex representing a candidate's or parties' 100% vote share, the larger is its vote share.

![Ternary plot](/images/blog/2015/ternary_dhondt.png)

Rather than think on edges, we can draw "regions" to make it more intuitive to understanding how electoral formulas can cause small, but consistent changes in constituencies. In the long run, even small changes can affect the number of parties and incentives for coordination among party supporters. The following was drawn exactly as the former, only changing the formula of seat allocation to Saint-Laguë, which produced slightly narrow areas in the edges but in the center.

![Ternary plot](/images/blog/2015/ternary_St_Lague.png)
