---
layout: post
title: "Venezuelan Parliamentary Election: What do the Polls Say?"
date: 2015-12-06
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, polls]
excerpt: "This entry explores the coming legislative election in Venezuela: Government is about to lose the majority."
published: true
comments: true
header-img: "img/website/spaghetti.png"
---


There is not a huge population of opinion polls covering this parliamentary election in Venezuela, but all I've can be used to gauge the public opinion by the local polling houses. This posting begs an obvious question: how has the mood in Venezuela varied over time with respect to voting intentions for the two political blocs? Next, can we detect any biases among those publishing polls?

<!--more-->

# The data
I've collected some polls available on the internet dating back to January 2014, which I made available [here](https://github.com/danielmarcelino/Polling/raw/master/Venezuela/data/polls.txt) after some [data janitor work](http://www.nytimes.com/2014/08/18/technology/for-big-data-scientists-hurdle-to-insights-is-janitor-work.html?_r=0).

# Polls over time
After a bit filling-in-the-blanks working with missing date values, we can visualize the poll trends over time. Given the sample size, sampling error and other sources of noise, a loess model can pretty much pick out the signals of long-term trends.

![center]({{ site.url }}/img/code-2015-12-06-venezuelan-parliamentary-elections/loess-1.png) 


# Pollster biases
Let's pretend we can trust on all those polls despite the huge variability among them as already mentioned [here](https://danielmarcelino.github.io/r/2015/12/04/venezuelan-parliamentary-election-2015/). In fact, the problem is not the variability as such, but my lack of knowledge about who are the pollsters and their past performance, so I can't judge them at first, let's say it clearly.
Nonetheless, if we accept the above models as a sound estimate of the expected poll response at a given time, we can analyze the residuals of actual poll results and look for systematic biases. In theory, with a decent sample size (all have ~ 1300) and a reasonably stratified sampling method (I'm not even assuming  random samples here), we might expect polls results to be roughly normally distributed around the expected polls result, regardless of who performed or commissioned the poll, right?

The graph below shows the distributions per polling house for those who polled more than a single poll in this dataset.


![center]({{ site.url }}/img/code-2015-12-06-venezuelan-parliamentary-elections/biases-3.png) 


We've to keep in mind that there are important caveats which we're not addressing here, as that different polls have used different question sets, methods etc, so this isn't evidence for anything underhanded per se. It seems reasonable to expect that while parties might have good reasons to publish polls in their favor, pollsters conducting the polls should generally be more or less indifferent.

The results are hampered by a small number of data points per pollster, and that to claim they are polling significantly above or below expectation, save for the *Hercón*, which is significantly more pro opposition (MUD) than expected, given the probability laws, although the p-value is just above the 5% thumb/convention. With a little research, I figure out that *Datanálisis* performed fine in the previous elections, and here it appears just around the center of the distribution leaning toward the Socialists (PSUV).



|**pollster**       |     **p**|
|:------------------|---------:|
|Meganalisis        | 0.1875000|
|Venebarómetro      | 0.2500000|
|IVAD               | 0.4375000|
|ICS                | 0.5000000|
|Delphos            | 1.0000000|
|Datanálisis        | 0.7646484|
|VARIANZAS          | 1.0000000|
|Consultores        | 0.2500000|
|DatinCorp          | 0.5625000|
|Keller y Asociados | 0.2500000|
|Hercón             | 0.0625000|



# Conclusion

What do the polls say? Well, the majority of Venezuelans are favoring opposition candidates and this has been the trend for at least the latter two years, however polls appear to have been more variable in recent months. This election is expected to bring the opposition to control the National Assembly after 16 years loosing the elections in the country. 
The Venezuela's Socialists seem to be at risk, but predicting the final number of seats is a tough task that I'm not considering in this post. 
In fact, it might be really difficult to set forth a range of winning seats as the government recently enacted some redistricting seats in order to weaken an eventual absolute majority by the opposition. Somehow, the polls show this will be a significant symbolic defeat for the government that shows it lost despite all the advantages in state power and control over the media.


## UPDATE (Error)
 I was informed by André Salvati that the code block below was producing an error message of unknown column; the missing part has been included. Thanks for letting me know. The whole code can be found in this [gist](https://gist.github.com/danielmarcelino/904c804b2681ac8a9d08) 

{% highlight r %}

library("dplyr")
library("ggplot2")
library("grid")
library("reshape2")
library("lubridate")
library("scales")
library("knitr")
library("SciencesPo") # to use the themes, you must install the version from github

source = "https://github.com/danielmarcelino/Polling/raw/master/Venezuela/data/polls.txt"

data <- read.csv(source, sep="\t", encoding = "UTF-8")

# Correcting for empty date values
head(data)

data[,2:3]<-lapply(data[,2:3],as.Date, format = "%d-%m-%Y")

times <- function(x)(x*100)

data[,5:8]<-lapply(data[,5:8],times)

days = round(mean(data$end-data$begin, na.rm=TRUE))
mask = is.na(data$end)

data$end[mask] = data$begin[mask]+days

# Find middle time point
DaysInField = round(mean(data$end-data$begin, na.rm=TRUE))
data$date = data$begin+DaysInField
{% endhighlight %}


{% highlight r %}
polls <- melt(data, id.vars=c("house", "date"), 
     measure.var=c("MUD", "PSUV", "Others", "Undecided"))
colnames(polls)[3] <- "response"
levels(polls$response) <- c("MUD", "PSUV", "Others", "Swing")


ggplot(polls, aes(x=date, y=value, col=response, fill=response)) + 
  geom_point() + geom_smooth(method="loess", alpha=I(.2)) +
  theme_538() + 
 theme(legend.position=c(.5,.95), legend.direction="horizontal") +
  scale_color_manual(values = c("blue", "red", "orange", "grey40")) +
  scale_fill_manual(values = c("blue", "red", "orange", "grey40")) +
  scale_x_date(labels = date_format("%b '%y")) +
  scale_y_continuous(breaks=seq(0, 70, 10), limits=c(0,70)) +
  geom_hline(yintercept=0,size=1.2,colour="#535353") +
  ggtitle("Vote Intention Among Venezuelans") +
  labs(x="", y="%", fill="Poll response:", col="Poll response:")
# credits
 geom_foot("danielmarcelino.github.io")
{% endhighlight %}


{% highlight r %}
## Residual analysis per pollster
l.MUD <- loess(value ~ as.numeric(date), data=subset(polls, response=="MUD"))
l.PSUV <- loess(value ~ as.numeric(date), data=subset(polls, response=="PSUV"))
l.Others <- loess(value ~ as.numeric(date), data=subset(polls, response=="Others"))
l.Swing <- loess(value ~ as.numeric(date), data=subset(polls, response=="Swing"))

with(polls, plot(as.numeric(date), value))
lines(as.numeric(polls[polls$response == "MUD",]$date),
      predict(l.MUD, as.numeric(polls[polls$response == "MUD",]$date)))

# Calculate predicted values per row, 
polls$predicted <- NA

loessPrediction <- function(resp, model){
  rows <- polls$response == resp
  curr <- polls[rows,]
  preds <- with(curr, predict(model, as.numeric(date)))
  polls[rows,]$predicted <<- preds
}

loessPrediction("MUD", l.MUD)
loessPrediction("PSUV", l.PSUV)
loessPrediction("Others", l.Others)
loessPrediction("Swing", l.Swing)

polls$residual <- polls$value - polls$predicted
hist(polls$residual)

## Check pollsters' names
polls$house <- gsub(" ?\\(.*", "", polls$house)
polls$house <- gsub("-", " ", polls$house)

houseNames <- do.call(rbind, strsplit(as.character(polls$house), "/"))
colnames(houseNames) <- c("pollster", "commission")

polls <- cbind(polls, houseNames)

## Order pollster by median residual:
ordering <- group_by(polls, pollster) %>%
  filter(response == "MUD") %>%
  summarize(med = median(residual, na.rm=T), count=n()) %>%
  arrange(med) 

polls$pollster <- factor(polls$pollster, levels=ordering$pollster)

## Testing for biases by a given pollster 
ggplot(subset(polls, response == "MUD"), 
       aes(x=pollster, y=residual)) +
  geom_hline(aes(yintercept=0)) +
  geom_violin(scale="width", fill=I("grey50"), col=I("grey50")) + 
  geom_jitter(position=position_jitter(width=.05)) + 
  stat_summary(geom = "crossbar", width=0.75, fatten=2, 
               color="grey20", fun.y=median, fun.ymin=median, fun.ymax=median) +
  coord_flip() + theme_538() + ggtitle("Relative MUD voting intentions") +
  labs(x="Polling house",
       y="Comparison with other polls at the time") +
  ylim(-12,12)
{% endhighlight %}


{% highlight r %}
## Stats significance, is it any?
options(scipen=0)
sigTable <- polls %>% filter(response == "MUD") %>%
  group_by( pollster) %>%
  summarise(p=wilcox.test(residual, mu=0)$p.value) 
kable(sigTable)
{% endhighlight %}
