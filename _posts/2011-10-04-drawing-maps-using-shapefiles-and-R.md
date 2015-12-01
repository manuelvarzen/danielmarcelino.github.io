---
layout: post
title: "Drawing maps using shape files and R" 
date: 2011-10-04
category: R
tags: [R, maps]
---


Sometimes, the only thing we want is a chart that speaks for itself rather than boring regression tables in our research paper. Graphs are efficient at showing the broad picture of an issue. In fact, graphs in research papers seem to be gaining a momentum in political science. If you want a more in-depth discussion about this, you may want reading [Kastellec and Leoni (2007)](http://eduardoleoni.com/published/graphs.pdf), for instance.

<!--more-->

![The campaign finance impact]({{ site.url }}/img/2011/senado06.png)


I do prefer to draw maps to present many thing like electoral results or to show simple bivariate associations. In this post, I will use regression coefficients to plot a cartogram using R--a free statistical package.

To plot a chart with OLS coefficients, we need to get the OLS results first. There are many possible approach to this, but I'll make it very simple. As I want to plot the relationship for each of the Brazilian state, I'll repeat the following command for each of those 27 units. In next posts I may show how to automate a bit more this tedious process.


### Graph for explained variance

{% highlight r %}
AC <- lm(PVOTOS~PGASTOS+I(PGASTOSc^2),

subset(dados, p==5 & t==2006 & j=='AC'),

na.action=na.omit)

ac <- as.data.frame(summary(AC)$coef)

ac <- ac[-c(1,3),]

# repeat for all states

SP <- lm(PVOTOS~PGASTOS+I(PGASTOSc^2),

subset(dados, p==5 & t==2006 & j==”SP”),

na.action=na.omit)

sp <- as.data.frame(summary(SP)$coef)

sp <- sp[-c(1,3),]

TO <- lm(PVOTOS~PGASTOS+I(PGASTOSc^2),

subset(dados, p==5 & t==2006 & j==”TO”),

na.action=na.omit)

to <- as.data.frame(summary(TO)$coef)

to <- to[-c(1,3),]


# Then I merge the results into a matrix:

sen6<- rbind(ac, al, am, ap, ba, ce, df, es, go, ma, mg, ms, mt, pa, pb, pe, pi, pr, rj, rn, ro, rr, rs, sc, se, sp, to)

sen6$Estimate <- format(round(sen6$Estimate, 2))

colnames(sen6) <-c("sen06", "Std.Error”, "tvalue”, "Pr(>|t|)”)

###

coefmap <- as.data.frame (cbind(UF, sen6$sen06, sen6$Std.Error))

colnames (coefmap) <- c("UF”,”sen02", "Erro02",”sen06", "Erro06")

Calling the shape file

## ======> Maps <=======

# loads sp library for maps and for nice color schemes

require(map tools)

gpclibPermit()

require(classInt)

require(RColorBrewer)

# ===> Shapefile Ivocation <==

brasil <- readShapeSpatial(file.choose(),

proj4string=CRS("+proj=longlat"))

summary(brasil)

coefmap <- read.csv("/Users/Daniel/D1/coefmap.csv", sep = ",", header=TRUE)

data <- subset(coefmap, T, select = c(

"UF", "sen02", "sen06"))

data.br <- attr(brasil, "data”)#getting names from shape

data.br $indice <- 1:dim(data.br)[1]

data$UF <- as.character(data$UF)

data.br$UF <- as.character(data.br$UF)

data$cam02 <- as.numeric(as.character(data$cam02))

data.br <- merge(data.br, data)

data.br <- data.br[order(data.br$indice),]

attr(brasil, "data") <- data.br #attributing data to shape

# Finally, I have the map of money effects across states for the senatorial elections in Brazil

## Variables

var2plot <- as.numeric(brasil@data$sen06)

nclr <- 12

clr2plot <- palette(c("#FFFF99", "#FFFF66","#FFEB5C",

"#FFD652", "#FFC247", "#FFAD3D”,”#FF9933", "#FF8529",

"#FF701F”, "#FF5C14", "#FF470A”, "#FF3300"))

class <- classIntervals(var2plot, nclr, style=”fisher”,

dataPrecision = 2)

colors <- findColours(class, clr2plot)

#Plot Map <===========

plot(brasil, xlim=c(-73.83943,-34.85810),

ylim=c(-33.77086,5.38289))

plot(brasil, border = gray (.9), col=colors, add=T)

title(paste("Senado Federal, 2006"))

legend("bottom left”, border=”white”,

xjust = 0, yjust = 0, x.intersp = 1, y.intersp = .8,

legend=names(attr(colors, "table”)),

fill=attr(colors, "palette”), cex=0.8, bty=”n”,

title=”%Gastos sobre %Votos”)

##======> Labels <========

br.polgns <- attr(brasil, "polygons”)

br.cntrd <- lapply(br.polgns, slot, "labpt”)

text(as.character(data$UF), cex = 0.6)

br.x <- sapply(br.cntrd, function(x) x[1])

br.y <- sapply(br.cntrd, function(x) x[2])

text(br.x, br.y, as.character(

brasil$sen06), cex = 0.6)#=====> Senado 2006 <===========

#Variables

var2plot <- as.numeric(brasil@data$sen06)

nclr <- 12

clr2plot <- palette(c("#FFFF99", "#FFFF66",”#FFEB5C”,

"#FFD652", "#FFC247", "#FFAD3D”,”#FF9933", "#FF8529",

"#FF701F”, "#FF5C14", "#FF470A”, "#FF3300"))

class <- classIntervals(var2plot, nclr, style=”fisher”,

dataPrecision = 2)

colors <- findColours(class, clr2plot)

#Plot Map <===========

plot(brasil, xlim=c(-73.83943,-34.85810),

ylim=c(-33.77086,5.38289))

plot(brasil, border = gray (.9), col=colors, add=T)

title(paste("Senado Federal, 2006"))

legend("bottom left”, border=”white”,

xjust = 0, yjust = 0, x.intersp = 1, y.intersp = .8,

legend=names(attr(colors, "table”)),

fill=attr(colors, "palette”), cex=0.8, bty=”n”,

title=”%Gastos sobre %Votos”)

##======> Labels <========

br.polgns <- attr(brasil, "polygons”)

br.cntrd <- lapply(br.polgns, slot, "labpt”)

text(as.character(data$UF), cex = 0.6)

br.x <- sapply(br.cntrd, function(x) x[1])

br.y <- sapply(br.cntrd, function(x) x[2])

text(br.x, br.y, as.character(

brasil$sen06), cex = 0.6)
##End not run
{% endhighlight %}