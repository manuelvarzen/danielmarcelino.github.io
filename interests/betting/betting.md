---
layout: page
title: "Betting Markets"
permalink: "/research/betting"
---


## Overview 
There are many bookmakers that invite people to bet on political events as the outcome of the next election. Political scientists then began to wonder if the aggregated odds could be employed to predict the elections. 
The beauty of the market is that it allows people to be Bayesian. People come in with some prior belief, but they can also follow prices to see what other people believe and may update their beliefs accordingly. Putting some money at stake may motivate people to try harder to find who is going to perform better at the election day not just who you would like to see in the office. 
The expected advantage of using prediction markets data comes from the belief that gamblers are more rational than ordinary people polled by pollsters and that it could yield for more accurate predictions than most polls. However, up to date, studies have been struggling to present bold evidence on this.

In fact, likewise polls, prediction markets accuracy will depend heavily on the diversity of the group. If a crowd of gamblers is similar in many aspects, prediction derived from the group will be less accurate much like the polls. At very best, the odds reflect the collective assessment/wisdom of the gamblers community on the probability of each party--or candidate winning the election. 

### From odds to election winnability
There quite a few ways to interpret bookmakers data. For instance, consider a contract in a market that pays $1 if candidate *A* wins. If in a particular day, the market price for contract *A* is 50 cents, one can interpret as that the market "believes" *A* has 50% chance of winning the election.

It is easy to convert the decimal odds used by online bookmakers to probabilities. All we need do is normalize the odds for the bookmaker's over-round. In terms of Australian election outcomes, I use the following formula (where C is the Coalition's odds and L is Labor's odds).

To calculate the Coalition's win probabilities from these odds, I use the following formula (where C is the Coalition's odds and L is Labor's odds). Of course, this formula simply normalizes the probabilities for the bookmaker's over-round.

p=1C1C+1L

Looking back over the past week, all of the movement has been in Labor's favor (noting that I only ran scrapers for four bookies on 9, 10 and 11 August). On Monday, Sportsbet had reduced its Coalition win probability from 60.2 to 57.7 per cent. On Tuesday, TABtouch reduced from 57.7 to 53.7 and William Hill also reduced from 57.7 to 53.7 per cent. This morning, Luxbet was reduced from 57.7 to 57.0 per cent.

In charts, we can see the probability of a Coalition win at the next election has fallen from somewhere between 57 and 60 per cent to somewhere between 54 and 57 per cent. 

Rather than build an over-round into their odds, betting exchanges charge a winner's commission (typically at 5 per cent of the winnings), before making a payout. To enable a comparison between bookmaker odds and betting exchange odds, I adjust the odds from betting exchanges to convert the winner's commission into an over-round. I do this with the following formula.

$$ \mathsf{adjusted} = \mathsf{((original−1)∗(1−commission))+1} $$

Betting markets have proved to be a good predictor of election outcomes, but they are not infallible. In the 2015 UK election both the polls and the bookmakers got it wrong; both predicted a hung Parliament. The outcome was a conservative majority of 12 seats.