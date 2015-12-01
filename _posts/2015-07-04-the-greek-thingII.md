---
layout: post
title: "The Greek thing II" 
date: 2015-07-04
category: R
tags: [R, elections, public opinion]
---

Just few hours before Greeks head to the polls to decide on the bailout agreement, and ultimately, whether the country will stay in the euro, there is no overwhelming advantage of either side. Actually, the margin became blurred over the last three days, with the "Yes" position rehearsing a last-minute recovery. Despite this last-minute trend, the aggregate preference for the “NO” is not too far behind. To frame this in terms of probabilities, when the \\( \theta_{YES} \\) exceeds \\( \theta_{NO} \\), I adapted a short [function](https://gist.github.com/danielmarcelino/9522c58c1dbbd3acc805#file-greek-thing-r) written a while [ago](http://danielmarcelino.com/bayes-says-dont-worry-about-scotlands-referendum/) to simulate from a Dirichlet distribution and to compute posterior probabilities shown in the chart below. It’s really nothing, but the *YES* outperformed the *NO* in *57%* of the times.

![Loess](/images/blog/2015/probs_greece.png)

The polls were aggregated and the "Don’t Know" respondents were distributed accordingly to proportion of the Yes/No reported by the polls.

**UPDATE:**
With polls yesterday showing both sides in a dead heat, today’s overwhelmingly majority of voters saying *NO* is a big surprise, isn’t? Plenty of theories will appear to explain why Greeks have chosen to reject the terms of the deal as proposed by EU officials, meanwhile, it’s time for the parties to set up the plan B.

