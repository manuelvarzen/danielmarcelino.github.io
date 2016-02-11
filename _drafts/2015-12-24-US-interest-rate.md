---
layout: post
title: "It Depends on your Perspective of the BRL"
author: "Daniel Marcelino"
date: 2015-12-25
output:
 html_document: 
   keep_md: yes
   toc: yes
category: [R]
tags: [Interest rate]
published: true
status: publish
comments: true
---
 The Federal Reserve-FED decided to raise the interest rate in 0.25 percent, obviously this decision unfolds everywhere, including Brazil, which may lead to short-term capital outflows as some investors want earn big, but avoid excessive risks with a country losing confidence.
 The US kept its interest rate very low over the last 7 years (between 0 and 0.25) as a *brute force* economic incentive policy after the 2008 economic crisis; now the authorities believe it's time to leverage. The graph below show the FED's Federal funds rate behavior over the long run. Briefly, this rate is the interest rate which banks charge one another for 1 day (overnight) lending.
 
How does the US decision of raising the interest rate may affect Brazil?
The SELIC rate can best be compared to the FED's Federal funds target rate 
 In Brazil the central bank is the highest monetary authority and can operate fully autonomously, contrary to what is possible in most other countries. The same applies to the fact that the Banco Central do Brasil is responsible for both the national currency and the national economy.
 
  
 
Whether the Real is undervalued and about to hit bottom or has further downside depends upon how one views the currency, and to what it is compared to.

Spot USD Perspective: Versus the USD, spot BRL probably has further to go on the downside.  The US Federal Reserve is, by all appearances, determined to raise rates.  Barring weak employment numbers, a renewed collapse in commodity prices or a sharp sell-off in the equity market (any of which could happen), the hike could come as soon as September. 

As such, it wouldn’t be surprising if the Real makes a move to test its all-time low from 2002 of 4 BRL per 1 USD (Figure 5). This is less than 15% below the current rate. 
Figure 5: Retesting the 2002 Low and Heading Back to 4 Reals / 1 USD on Spot?

An Interesting Carry Trade versus USD: Investors typically don’t earn the spot return; they earn the spot return + the interest rate differential. While the Federal Reserve has been busy contemplating a fairly notable move from its current range of 0-0.25% rates to, perhaps, 0.25%-0.50%, Banco Central do Brasil has been on a tear, raising rates to 14.15% (Figure 6).  Thus, between the BRL and USD, there is about a 14 percentage point gap in interest rates.  This gives a lot of cushion to long positions in BRL, even if the Real continues its downward course vs. the USD, with carry accumulating at over 1% per month.  Moreover, while real rates in the US are either close to zero (headline inflation) or negative (core inflation), Brazilian real rates are solidly positive.  With the SELIC (Special System for Settlement and Custody) rate at 14.15%, and inflation at 8.89%, real rates in Brazil are five percentage points above inflation – something that the US hasn’t seen since the 1980s.

 Outro efeito da alta de juros americana é dificultar uma queda dos juros no Brasil.

Mas os analistas se dividem sobre se o aperto monetário nos EUA pode levar, no médio prazo, a uma alta da taxa brasileira em função de esta já estar em um patamar relativamente elevado - 14,25%.

"Normalmente os juros brasileiros tendem a acompanhar os americanos, mas a taxa já está alta e subir ainda mais os juros em um momento de economia em recessão seria muito complicado", diz Salvato.

Já na opinião de Nogami, "pode ser que, para atrair capitais e controlar a inflação o Banco Central seja obrigado a aumentar ainda mais a taxa de juros".


![center]({{ site.url }}/img/2015/gender_chairs_n_questions.png)

Here is a template that can be adjusted to your favorite currencies with symbols listed [here](http://research.stlouisfed.org/fred2/categories/94).

{% highlight r %}
# Federal Reserve FRED data

library(dygraphs)
library(quantmod)
 
getSymbols('FEDFUNDS', src='FRED')
 
 
dygraph(FEDFUNDS, main = 'Comportamento dos FED Funds',
 xlab='', ylab='% a.a.') %>%
 dyOptions(stackedGraph = TRUE) %>%
 dyRangeSelector(dateWindow = c("1954-07-01", "2015-11-01")) %>%
 dyShading(from='2008-10-01', to='2015-11-01', color='lightblue')
 
 {% endhighlight %}