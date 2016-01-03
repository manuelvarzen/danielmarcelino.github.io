---
layout: post
title: "Argentine general election, 2015" 
date: 2015-08-07
category: Analysis
tags: [R, elections, Argentina, polls]
---

The Argentina's 2015 presidential election to be held next October 25th is approaching and the dispute is now more stable  as the major parties announced their candidates last June.

<!--more-->

In the next Sunday, political parties are holding their primaries for the upcoming presidential election. Like in the US, in Argentine  primaries are important for the parties to solve internal disputes, so the winning candidate can run more comfortable with a united party.

I set up a forecasting model to track down the vote intentions in my neighboring country–the land of tango. I'm still consolidating opinion polls data while trying to get some clues about past pollster’s performance, so I can account for the likely house effect.

The following graph was adjusted using simple loess techniques. As I already have a reasonable population of polls, I could also adjust a Dirichlet regression, which produces a more robust picture of the dispute (the second graph below). At this stage, however, the model is an oversimplification as some pollsters are more reliable than others. So, I hope next time to posting a more robust forecast.

![Loess Regression](/images/blog/2015/loess.png)


![Dirichlet Regression](/images/blog/2015/dirichletreg.png)


From the figures above, we can see that some polls have quite weird sinusoidal artifacts. Considering those are wrong compared to the others, they can influence the trend line estimates if on a particular day the deviating poll is the only measurement we have.


#### House Effects
I want to improve the estimates over the next weeks by using better priors for the house effects of each polling firm. For example, in the picture below, pollster “OPSM” polled favorably for Mauricio Macri (blue line/dots) while worst for the official candidate, Daniel Scioli. On the other hand, house "Hugo Haime & Asc." underestimated the principal opposition candidate (M. Macri) while overestimating Daniel Scioli and the PJ’s dissident, Sergio Massa.


![House Effects](/images/blog/2015/dirichletreg-pollsters.png)


Let’s think about the implications of this for a moment. Some institutes published polls in which the one or the other candidate over a period of several months is predicted on average two percents below/above the median of all the polls published in that period; this is really hard to believe given that the polling organizations are all claiming to interview a representative group of the population. Even if we acknowledge that the polls are producing some noisy measurements, there would not be this kind of hex. Unless there is a systematic error in the polls that occurs over and over.


