---
layout: post
title: "Argentina's 2015 Presidential Election Forecasts"
date: 2015-10-21
category: R
tags: [R, polls, Argentina, elections]
comments: true
---

The model indicates the official candidate have chance of making it right way this Sunday, but the odds are short.

<!--more-->


### Predictions
The model I'm using indicates the official candidate have some chance of making it right way this Sunday, avoiding a runoff with Mauricio Macri in late November. The electoral preference distributions are quite apart from each other, with the distribution of Daniel Scioli about 40% of the positive vote, while Macri's about 30%. 

![Preference Distributions](/img/2015/probs_argentine.png)

The model built on more than 115 polls by 24 pollsters suggests he has 86% of probability of finishing above 40% of the positive votes. To avoid a runoff, he must obtain more than 45% of the valid votes, or more than 40% with a difference greater than 10% from the second candidate. The typical  difference the model predicts is about 12%; not too loose, but a double digit difference.

![Simulated differences](/img/2015/FPV_PRO_differences.png)

[The models I posted for the primaries](http://danielmarcelino.com/r/08-2015/Argentine-general-election-2015/), predicted quite well the proportion of votes each major candidate eventually received. If fact, the model with a Dirichlet trendline did appreciate slightly the frontrunner candidate while the simple loess model just made it to the point. 

### When did the presidential election approach its tipping point?

The first poll I've in my database dates back to March 2014. From this period, the only significant movement in the preference distribution happened before the primaries, in August, and this was true for both Scioli and Macri. Though for Macri, the upward movement was imperceptible. Because nothing change since then, it's hard to say the candidate gained momentum,as his numbers have neither risen nor fallen ever since.

![Full Filter](/img/2015/Kalman_Argentine_21_oct.png)

### The model
The polls were modeled using a Kalman Filter, then the probabilities were computed using a Dirichlet Multinomial Distribution. Details on the model can be found within [my gists](https://gist.github.com/danielmarcelino).