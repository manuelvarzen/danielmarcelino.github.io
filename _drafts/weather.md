---
layout: page
subheadline: "Tutorial"
title: "The Dry Weather Drives me Crazy"
teaser: "When we study elections with this geometric figure, each point of the triangle intuitively represents 3 coordinates."
date:  2015-08-04 00:10:00
categories:
   - R
tags:
  - R
comments: true
show_meta: true
header: no
---

NASA reported that 2014 was the hottest year since 1880. The long weather time series also provides indication that since the last quarter of 1900s, the global temperature has kept above the average.
 
In Brasilia, these days appear to be even hotter than last year, but I'm not sure whether the last year was the hottest year of the serie. 

I found all the information required to downloads data and  a very informative [script](https://rpubs.com/bradleyboehmke/weather_graphic) for plotting the graph below with ggplot, written by *Brad Boehmke* and inspired by the data visualization guru [Edward Tufte](http://www.edwardtufte.com/tufte/index). See, for example, Tufte's [New York City weather charts](http://www.edwardtufte.com/bboard/q-and-a-fetch-msg?msg_id=00014g), which implements much of his ideas of "beautiful evidence", data integrity, and aesthetic minimalism.


I managed to find weather temperatures data for Brazilian cities using a [custom google search engine](https://www.google.com/cse/publicurl?cx=002720237717066476899%3Av2wv26idk7m) dedicated for searching data bases that I came across to a while ago. I found  _The Average Daily Temperature Archive_,  a repository that contains files from the National Climatic Data Center (NCDC) for 157 U.S. cities plus 167 cities around the globe.  [Help yourself](http://academic.udayton.edu/kissock/http/Weather/citylistWorld.htm), maybe your city is there! 


http://academic.udayton.edu/kissock/http/Weather/gsod95-current/BZBRSLIA.txt

I got daily temperature averages, or  in climatology terms,  T24 and Tminmax  ( "24 hour"  and (min + max) / 2) for three important Brazilian cities: Brasilia, Sao Paulo and Rio de Janeiro. This data set  covers daily temperatures from 1995 to 2014, there are some missing points, which is identified with the "-99" value. 

  To reproduce this chart, I used ggplot and few other helper packages. The script can be found in the [gist](https://gist.github.com/e4c299c697261c7a3ece.git) or below this post.

The data used for producing these graphs were converted from Fahrenheit to Celsius. 



40 degrees Celsius (104 degrees Fahrenheit) 
In the world's hottest cities, temperatures get above 40 degrees Celsius (104 degrees Fahrenheit) nearly every day for months at a time. Dozens of cities in the Middle East and Africa have extended periods of 40-degree weather.
Only Kuwait City and Ahwaz report having months with daily maximum temperatures averaging above 46 °C (115 °F).

Edmonton
http://academic.udayton.edu/kissock/http/Weather/gsod95-current/CNEDMNTN.txt

Winnipeg
http://academic.udayton.edu/kissock/http/Weather/gsod95-current/CNWINNPG.txt

Yerevan
http://academic.udayton.edu/kissock/http/Weather/gsod95-current/RSYERVAN.txt

Kuwait 
http://academic.udayton.edu/kissock/http/Weather/gsod95-current/KWKUWAIT.txt

https://stackoverflow.com/questions/19593881/replace-na-values-in-dataframe-variable-with-values-from-other-dataframe-by-id?rq=1

http://adv-r.had.co.nz/Subsetting.html

https://stackoverflow.com/questions/23524013/combine-different-rowcells-from-a-data-table-or-data-frame-based-on-simple-condi?rq=1


<script src="https://gist.github.com/danielmarcelino/e4c299c697261c7a3ece.js"></script>