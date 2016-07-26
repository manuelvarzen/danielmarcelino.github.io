---
layout: post
title: "The Star Wars Grossing War"
date: 2016-01-11
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats]
excerpt: "This post shows how to scrap data from 'boxofficemojo.com', then to clean and visualize the data."
published: true
comments: true
header-img: "img/website/spaghetti.png"
---

# Motivation 
I finally made to the movies for watching the new *Star Wars* release this weekend. Although this episode wasn't that spectacular, in my view, it did inspire some data seeking afterwards. I wanted to know how this film compares to others top movies in terms of worldwide grossing as well as within the *Star Wars* series. 

Fortunately, there is a wealth--though incomplete--list of the top grossing films of all time at <boxofficemojo.com>. Although the information is right in the front-page, I'd rather like something more visual teasing. So, I decided to see how it goes with *R* and the new  *ggplot2* package release. Also, because I must scrap the data from the *Box Office* website, I will need a function to handle the HTML structure of those tables. The function `readHTMLTable()` from the *XML* package can certainly be an asset here.

# The setup  
First, let's load the packages we'll need.

{% highlight r %}
library(XML)
library(ggplot2)
{% endhighlight %}

In what follows is my setup for using the `readHTMLTable` function to retrieve, cleaning, and arrange HTML tables in a data.frame format. I'd rather wrap everything in a single function, but keeping the three snippets apart is rather easy to make out. 

The first function will pull out all tables on the webpage as a list of data.frames, and I'll give them similar names.


{% highlight r %}
GetTable <- function(t) {
table <- readHTMLTable(t)[[2]]
names(table) <- c("Rank", "Title", "Studio", "Worldwide", "Domestic", "DomesticPct", "Overseas", "OverseasPct", "Year")
boxdf <- as.data.frame(lapply(table[-1, ], as.character), stringsAsFactors=FALSE)
boxdf <- as.data.frame(boxdf, stringsAsFactors=FALSE)
boxdf <- transform(boxdf, Year = ifelse(Year==0, NA, Year))
return(boxdf)
}
{% endhighlight %}

The data will come `dirty` with lots of tags and marks, so a little [janitor work](http://www.nytimes.com/2014/08/18/technology/for-big-data-scientists-hurdle-to-insights-is-janitor-work.html?_r=0) will be  necessary. The following code does just that. 


{% highlight r %}
CleanDataFrame <- function(boxdf) {
clean <- function(col) {
col <- gsub("$", "", col, fixed = TRUE)
col <- gsub("%", "", col, fixed = TRUE)
col <- gsub(",", "", col, fixed = TRUE)
col <- gsub("^", "", col, fixed = TRUE)
return(col)
}
boxdf <- sapply(boxdf, clean)
boxdf <- as.data.frame(boxdf, stringsAsFactors=FALSE)
return(boxdf)
}
{% endhighlight %}

The next snippet is the main piece. It will construct the URLs based on the number of pages we feed in and will call the two preceding functions. 

{% highlight r %}
BoxOfficeMojoScraper <- function(npages) {
# This line constructs the URLs
urls <- paste("http://boxofficemojo.com/alltime/world/?pagenum=", 1:npages, "&p=.htm", sep = "")
# The next line scrapes every table in the URLs formed
boxdf <- do.call("rbind", lapply(urls, GetTable))
# This does the janitor work
boxdf <- CleanDataFrame(boxdf)
# The next lines arrange the data to my needs
cols <- c(1, 4:9)
boxdf[, cols] <- sapply(boxdf[, cols], as.numeric)
boxdf$Studio <- as.factor(boxdf$Studio)
return(boxdf)
}
{% endhighlight %}


I'm scrapping the first 7 pages of the target address <http://www.boxofficemojo.com/alltime/world/>. It will bring missing values too, don't worry for the time being.


{% highlight r %}
npages <- 7
box <- BoxOfficeMojoScraper(npages)
{% endhighlight %}



{% highlight text %}
## Warning in lapply(X = X, FUN = FUN, ...): NAs introduced by coercion
{% endhighlight %}

# Results
Our new acquired data is a data.frame with more than 620 rows or films, with the oldest dating back to 1939.


{% highlight r %}
str(box)
{% endhighlight %}



{% highlight text %}
## 'data.frame':	628 obs. of  9 variables:
##  $ Rank       : num  1 2 3 4 5 6 7 8 9 10 ...
##  $ Title      : chr  "Avatar" "Titanic" "Jurassic World" "Star Wars: The Force Awakens" ...
##  $ Studio     : Factor w/ 38 levels "Art.","BV","Col.",..: 7 22 32 2 2 32 2 36 2 2 ...
##  $ Worldwide  : num  2788 2187 1669 1602 1520 ...
##  $ Domestic   : num  760 659 652 781 623 ...
##  $ DomesticPct: num  27.3 30.1 39.1 48.7 41 23.3 32.7 28.4 31.4 33.7 ...
##  $ Overseas   : num  2028 1528 1017 821 896 ...
##  $ OverseasPct: num  72.7 69.9 60.9 51.3 59 76.7 67.3 71.6 68.6 66.3 ...
##  $ Year       : num  2009 1997 2015 2015 2012 ...
{% endhighlight %}



{% highlight r %}
# the oldest:
min(box$Year, na.rm=TRUE)
{% endhighlight %}



{% highlight text %}
## [1] 1939
{% endhighlight %}

The following chart displays the grossing worldwide values for the top 25 ranked movies of all time. As it shines out, the *Star Wars: The Force Awakens_ is doing pretty well worldwide. It's ranked fourth now, but it just began to play in China this week, so it may unseat *Titanic* over the next weeks, and *Avatar* in the long run.

![center]({{ site.url }}/img/code-2016-01-11-star-wars-grossing-war/top25.png) 

If you want to reproduce the very same plot decoration of this post, you'll have to install the development version of **SciencesPo** package, and add `+ theme_538(legend="top")` to the following code. 

{% highlight r %}
box2 <- subset(box, Rank<=25)

ggplot(box2) +
geom_bar(aes(x=reorder(Title, Worldwide), y=Worldwide, fill="Worldwide"), stat = "identity") +
geom_bar(aes(x=Title, y=Domestic, fill="Domestic"),alpha=.5, stat = "identity") +
scale_fill_manual(name="Grossing", values=c(Worldwide="#A6CEE3", Domestic="#386CB0")) +
coord_flip() + 
 labs(x=NULL, y=NULL, title="Top 25 Films by Worldwide Grosses (US$ Millions)") 
{% endhighlight %}


Next, how *The Force Awakens* compares with other episodes of *Star Wars*? 

![center]({{ site.url }}/img/code-2016-01-11-star-wars-grossing-war/starwars.png) 

{% highlight r %}
# will search for Star Wars names within the data.frame:
box3 <- subset(box, grepl("^Star Wars", box$Title)|grepl("^Return of the Jedi", box$Title)|grepl("^The Empire Strikes Back", box$Title))

# will wrap the axis labels
wrap_20 <- function(x)gsub('(.{1,20})(\\s|$)', '\\1\n', x)

ggplot(box3) +
geom_bar(aes(x=reorder(wrap_20(Title), Worldwide), y=Worldwide, fill="Worldwide"), stat = "identity") +
geom_bar(aes(x=wrap_20(Title), y=Domestic, fill="Domestic"), alpha=.5, stat = "identity") +
scale_fill_manual(name="Grossing", values=c(Worldwide="#A6CEE3", Domestic="#386CB0")) +
coord_flip() + 
labs(x=NULL, y=NULL, title="Star Wars Grosses (US$ Millions)")
{% endhighlight %}

The new release by Disney of *Star Wars* is making its way to the top films of all-time. Although the values presented are not in current currency, and old films in the list may have their grosses based on multiple releases, *The Force Awakens* has just began its journey. 
