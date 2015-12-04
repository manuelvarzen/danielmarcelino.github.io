---
layout: post
title: "Argentina's 2015 Presidential Election Forecasts"
date: 2015-10-21
category: R
tags: [polls, Argentina, elections]
comments: true
---

The model indicates the official candidate has some chance of making it right way this Sunday, but the odds are short.

<!--more-->


### Predictions
The model I'm using indicates the official candidate has some chance of making it right way this Sunday, avoiding a runoff with Mauricio Macri in late November. The electoral preference distributions are quite apart from each other, with the distribution of Daniel Scioli about 40% [37-43] of the positive vote, while Macri's about 30% [27-33]. 

![Preference Distributions]({{ site.url }}/img/blog/2015/probs_argentine.png)

The model built on more than 115 polls by 24 pollsters suggests Scioli has 86% of probability of finishing above 40% of the positive votes. But to avoid a runoff, he must obtain more than 45% of the valid votes, or more than 40% with a difference greater than 10% from the second candidate, so he's just around this threshold. 

### Primaries 
[The models I posted for the primaries](http://danielmarcelino.com/r/08-2015/Argentine-general-election-2015/), predicted quite well the proportion of votes each major candidate eventually received. If fact, the model with a Dirichlet trendline appreciated slightly the frontrunner candidate while the simple loess model just made it to the point. In theory, predicting the general vote would be easier because there are fewer candidates to predict.

### When did the presidential election approach its tipping point?

The first poll I've in my database dates back to March 2014. From this period, the only significant movement in the preference distribution happened before the primaries, in August, and this was true for both Scioli and Macri, though the upward movement for Macri was rather small. Because nothing change since then, it's hard to say that either the official or  the opposition candidate gained momentum, as their numbers have neither risen nor fallen ever since.

![Full Filter]({{ site.url }}/img/2015/Kalman_Argentine_21_oct.png)

### The model
The polls were modeled using a Kalman Filter, then the probabilities were computed using a Dirichlet Multinomial Distribution. Details on the model can be found within [my gists](https://gist.github.com/danielmarcelino).