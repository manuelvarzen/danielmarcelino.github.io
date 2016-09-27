---
layout: post
title: "Prediction Markets: Will Dilma Stay?" 
date: 2015-04-16
tags: [R]
comments: true
---

 You may probably know that the Brazilian President, Dilma Rousseff, is sinking in a leaking boat, which is circled by power-hungry political sharks, most of them implicated in an outrageous corruption exposition that stretches out to both sides of the political spectrum, including the presidential wanna-be Aecio Neves of the rival party. 
 Today, a parliament with roughly 60% of its members implicated in corruption scandals will decide the fate of Ms Rousseff's leadership. The government did all it could, but have gotten poor results--to say the least, and the President starts to be treated as old history.
 The consensus is that the only chance to block the impeachment is in the House of Representatives. If the government fails to hold 172 votes (1/3 of 513 members) contrary to this call, it becomes virtually impossible to stop it afterwards in the Senate, as the Vice President officially takes office and can articulate a new government.
 It’s fairly common these days to reference prediction markets as part of the political account. Although we often hear about betting odds on who will win the election or be the next president, I haven’t seen many analysts use prediction markets to infer any impeachment outcome.
 With that in mind, I took contract prices trade at [PredictIT](https://www.predictit.org) for the impeachment of the Brazilian president, and used them to calculate the perceived conditional probability of president Dilma staying in office.
 
The time series plot of daily closing price and trading volume of GSPC from December 2015 to April 2016 can be illustrated as below.

![Trading price and volume]({{ site.url }}/images/2016/impeachment.png)

We would like to also observe the distribution of the average price of GSPC stock on regular monthly basis. For most of the past month, the price remains lower than $300 until a break-out occured in 2000. The Q-Q plot also indicates that our sample dataset does not follow normal distribution and is heavily skewed. The last graph is important to analyze the volatility in monthly returns of GSPC stock from Jan 1970 to Sep 2009.

According to the data above, betting markets perceive 

I’m no political analyst, and the data above will continue to update throughout the election season, making anything I write here about it potentially immediately outdated, but according to the data at the time I wrote this on September 15, 2015, betting markets perceive Hillary Clinton as the most electable of the declared candidates, with a 57%–58% chance of winning the presidency if she receives the Democratic nomination. Betting markets also imply that the Democrats are the favorites overall, with about a 57% chance of winning the presidency, which is roughly the same as Clinton’s electability, so it appears that Clinton is considered averagely electable compared to the Democratic party as a whole.
   
The frustration in Brazil over Ms Rousseff's leadership is apparently whenever protesters gather in streets to call for her impeachment and the imprisonment of those involved in the "Petrolão"--oil bribery scandal.  

Electability of 2016 Presidential Candidates as Implied by Betting Markets

It’s fairly commonplace these days for news outlets to reference prediction markets as part of the election cycle. We often hear about betting odds on who will win the primary or be the next president, but I haven’t seen many commentators use prediction markets to infer the electability of each candidate.

With that in mind, I took the betting odds for the 2016 US presidential election from Betfair and used them to calculate the perceived electability of each candidate. Electability is defined as a candidate’s conditional probability of winning the presidency, given that the candidate earns his or her party’s nomination.

Presidential betting market odds and electabilities

Data via Betfair as of 3/19/2016, 10:19:32 AM

“Electability” refers to a candidate’s conditional probability of winning the presidency, given that the candidate wins his or her party’s nomination


I’m no political analyst, and the data above will continue to update throughout the election season, making anything I write here about it potentially immediately outdated, but according to the data at the time I wrote this on September 15, 2015, betting markets perceive Hillary Clinton as the most electable of the declared candidates, with a 57%–58% chance of winning the presidency if she receives the Democratic nomination. Betting markets also imply that the Democrats are the favorites overall, with about a 57% chance of winning the presidency, which is roughly the same as Clinton’s electability, so it appears that Clinton is considered averagely electable compared to the Democratic party as a whole.



Why are the probabilities given as ranges?

Usually when you read something in the news like “according to [bookmaker], candidate A has a 25% chance of winning the primary”, that’s not quite the complete story. The bookmaker might well have posted odds on A to win the primary at 3:1, which means you could bet $1 on A to win the primary, and if you’re correct then you’ll collect $4 from the bookmaker for a profit of $3. Such a bet has positive expected value if and only if you believe the candidate’s probability of winning the primary is greater than 25%. But traditional bookmakers typically don’t let you take the other side of their posted odds. In other words, you probably couldn’t bet $3 on A to lose the nomination, and receive a $1 profit if you’re correct.

Betting markets like Betfair, though, do allow you to bet in either direction, but not at the same odds. Maybe you can bet on candidate A to win the nomination at a 25% risk-neutral probability, but if you want to bet on A to lose the nomination, you might only be able to do so at a 20% risk-neutral probability, which means you could risk $4 for a potential $1 profit if A loses the nomination, or 1:4 odds. The difference between where you can buy and sell is known as the bid-offer spread, and it reflects, among other things, compensation for market-makers.

The probabilities in the earlier table are given as ranges because they reflect this bid-offer spread. If candidate A’s bid-offer is 20%–25%, and you think that A’s true probability is 30%, then betting on A at 25% seems like an attractive option, or if you think that A’s true probability is 15% then betting against A at 20% is also attractive. But if you think A’s true probability falls between 20% and 25%, then you probably don’t have any bets to make, though you might consider becoming a market-maker yourself by placing a bid or offer at an intermediate level and waiting for someone else to come along and take the opposite position.

Generically, most tables focus on market data. There is a three step process. Step 1: construct prices from the back/sell, lay/bid, and last transaction odd/price in the order book. We always take the average of the highest price traders are willing to buy a marginal share and the lowest price people are willing to sell a marginal share, unless the differential is too large or does not exist. Step 2: correct for historical bias and increased uncertainty in constructed prices near $0 or $1. We raise all of the constructed prices to a pre-set value depending on the domain. Step 3: normalized to equal 100% for any mutually exclusive set of outcomes.

Why this site's odds are not from PredictIt.com
PredictIt.com is good for Americans to trade on, but the odds are not efficient: As of this writing, the odds on PredictIt for who will win the Republican nomination add up to 191%.

For example: PredictIt says there's a 38% chance Rubio will win, a 32% chance Bush will win, a 22% chance Trump will win, an 18% chance Cruz will win -- just between those four candidates, PredictIt's odds add up to 110%. So we know the odds are off. The problem is caused by regulations that limit the amount people can bet on any race to $850. Betfair, which this site uses, does not have that problem; their odds add up to about 100%.

When/if PredictIt's odds become more efficient and get close to 100%, this site will include the odds.



Methodology *very technical*
Short answer: This site simply averages the market "bid" and "ask" prices to come up with the implied odds.
Long answer: The odds on Betfair are not expressed as percentages and have to be converted. The conversion formula is 1/x, where x is the Betfair price. For example, on Betfair a candidate will trade at "50" -- that means the candidate has a 1/50 = 2% chance of winning.

ElectionBettingOdds.com converts the Betfair odds to percentages, and then averages them. Specifically, the formula is: ((1/Bid + 1/Ask)/2)

This generally gives intuitive results. For example, on Betfair, Chris Christie may have a "bid" price of "50" and an "ask" price of "25". In other words, the bid is (1/50)=2% and the ask is (1/25)=4%. It seems logical that the implied chance is the average: 3%.

But the sites mentioned above do not do that. Instead of calculating the percentages and then averaging those, they average the Betfair numbers first. Their formula is 1 / ((Back + Lay)/2) which in the Chris Christie example above would yield 2.66% instead of 3%.

This is a particular issue for low odds. For example, if a candidate on Betfair has a spread between "1000" (.1%) and "100" (1%), this site's formula would conclude that the odds are the average: .55%. But the other sites' formulas would compute the odds to be just .18%. In general, their formula skews odds towards 0% probability and 100% probability. Although it is theoretically possible that skewing the odds in that way makes them better at predicting events, there does not seem to be hard evidence for that notion.

So ElectionBettingOdds.com uses the simple averaging method because it most faithfully depicts the odds themselves without alteration.

One tricky thing is the rare occasion when liquidity is very low for a candidate. For example, one could imagine a candidate who has no chance -- so low that almost nobody is bothering to trade on the person's chances. In that case you might see a wide bid-ask spread. In the most extreme possible case, the bid might be 1% and the ask 99%. In that case the average would compute as 50%, which would be pretty clearly misleading for a candidate so obscure that nobody bothers to trade. It would not be good if this site suddenly put that candidate in the lead at 50% just because nobody was trading that person. The solution this site uses is: In cases where the bid-ask spread is greater than 10%, the bid alone is used, because it provides a solid lower-bound. In cases where the bid is greater than 50% and the bid-ask spread is greater than 10%, the ask alone is used. (These cases are extremely rare; the average bid-ask spread is around 1% and nearly all the time all of the candidates' spreads are well under 10%.)