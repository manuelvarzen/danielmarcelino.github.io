---
layout: post
title: "UK General Election 2017: May vs June"
author: "Daniel Marcelino (@dmarcelinobr)"
date: "June 09, 2017"
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, Viz, Elections]
excerpt: "Pundits have been asking themselves over the last days how did Theresa May's gamble fail? I would say it could have been even worse."
published: true
status: published
comments: true
---

<img src="/img/2017/electionresults.png" title="center" alt="center" style="display: block; margin: auto;" />

Pundits have been asking themselves over the last days how did Theresa  May’s gamble fail? Although the Conservative party received 42% of the vote, Labour received 40%, and all the other parties received 18% between them. The Tories lost their parliamentary majority in an election they purposively called when they were 20 points ahead in the polls. 

Two year ago, in the previous general election, Conservative beat Labour by 37%-30%. And the time before, the Conservatives beat Labour by 36%-29% of the vote.

The [polls were certainly off](https://yougov.co.uk/news/2017/06/07/final-call-poll-tories-seven-points-and-set-increa/), and the higher turnout seems to have favored the Labour party this time. But the inconvenient conclusion from my preliminary analysis is that the Conservatives would have received at least 20 fewer seats, so taking them well below the required majority, if Labour, Lib Dem, and SNP voters had coordinated.

This is not voters' fault, however. It is very difficult to communicate with all voters supporting several different parties to get them to adopt a strategy. In fact, this is a known failure of [First-past-the-post](https://en.wikipedia.org/wiki/First-past-the-post_voting) voting systems. [Other voting systems](https://en.wikipedia.org/wiki/Instant-runoff_voting) would accomplish the strategic outcome automatically, but perhaps would impose new concerns as well.

## The data
The data were collected from *The Economist’s Infographics* following the steps put forward by [Thiemo Fetzer](http://freigeist.devmag.net/r/1002-uk-2017-general-election-results-data.html), and further stored as a CSV file. I didn’t upload it anywhere, but I’d be happy to share it with you if really needed, just send me an e-mail. 
 

##### Load the data:
{% highlight r %}	
library(dplyr)

data <- read.csv("UK2017.csv", skip = 1, header=T, stringsAsFactors = F)

data[,7:15] <- lapply(data[,7:15],function(x){as.numeric(gsub(",", "", x))})

data[is.na(data)] <- 0

Con <- data %>% filter(X2017 == "Con")

Lab <- data %>% filter(X2017 == "Lab")

nrow(Con); 
[1] 317
nrow(Lab)
[1] 260
{% endhighlight %}


## Labour's weakest seats

So, among seats won by Labour, how many might Con + UKIP have won if their voters had coordinated? Just 13 more seats.

{% highlight r %}
Lab.margin <- with(Lab, Con + UKIP - Lab)

sum(Lab.margin > 0)
[1] 13
{% endhighlight %}

How many seats would have been won by a margin of 1000 or more votes?

{% highlight r %}
sum(Lab.margin > 1000)
[1] 9
{% endhighlight %}


Which seats are these?

{% highlight r %}
print(Lab[which(Lab.margin > 1000),
	c("Constituency", "Con", "UKIP", "Lab")], 
		row.names = FALSE)

             Constituency   Con UKIP   Lab
           Leicester East 35116    0 12668
         Crewe & Nantwich 25880 1885 25928
                   Exeter 34336    0 18219
             Dudley North 18068 2144 18090
            Walsall South 25286 1805 16394
 Wolverhampton North East 12623 1675 12623
                 Keighley 23817 1291 24066
 Penistone & Stocksbridge 21485 3453 22807
        Sheffield, Heeley 26524 1977 12696
{% endhighlight %}

## Conservatives weakest seats

So, among seats won by Conservatives, how many might Lab + Lib Dem + SNP have won if their voters had coordinated? The number of 52 seats is surprisingly high. 

{% highlight r %}
Con.margin <- with(Con, Lab + Lib + SNP - Con)

sum(Con.margin > 0)
[1] 52
{% endhighlight %}


Similarly, how many seats would have been won by a margin of 1000 or more votes?

{% highlight r %}
sum(Con.margin > 1000)
[1] 33
{% endhighlight %}


Which seats are these?

{% highlight r %}
print(Con[which(Con.margin > 1000), 
	c("Constituency", "Lab", "Lib", "SNP", "Con")],
		row.names = FALSE)

                    Constituency   Lab  Lib   SNP   Con
                        Broxtowe 25120  2247     0 25983
                      Colchester 18888  9087     0 24565
                       St Albans 13137 18462     0 24571
                         Watford 24639  5335     0 26731
                 Chipping Barnet 25326  3012     0 25679
  Cities of London & Westminster 14857  4270     0 18005
        Finchley & Golders Green 22942  3463     0 24599
                          Putney 19125  5448     0 20679
                   Richmond Park  5773 26543     0 28588
                       Wimbledon 18324  7427     0 23946
                         Cheadle 10417 19824     0 24331
                     Hazel Grove  9036 14533     0 20047
                       Southport 15627 12661     0 18541
                  Aberdeen South  9143  2600 13994 18746
                           Angus  5233  1308 15504 18148
          Ayr, Carrick & Cumnock 11024   872 15776 18550
                  Banff & Buchan  3936  1448 16283 19976
             Dumfries & Galloway 10775  1241 16701 22344
               East Renfrewshire 14346  1112 16784 21496
                          Gordon  6340  6230 19254 21861
                           Moray  5208  1078 18478 22637
        Ochil & South Perthshire 10847  1742 19110 22469
                        Stirling 10902  1683 18143 18291
 West Aberdeenshire & Kincardine  5706  4461 16754 24704
                  Hastings & Rye 25322  1885     0 25668
             Southampton, Itchen 21742  1421     0 21773
              Camborne & Redruth 21424  2979     0 23001
                      Cheltenham  5408 24046     0 26615
                     North Devon  7063 21185     0 25517
                         St Ives  7298 21808     0 22120
                Truro & Falmouth 21331  8465     0 25123
                   Calder Valley 26181  1952     0 26790
                          Pudsey 25219  1761     0 25550
{% endhighlight %}


