---
layout: post
title: "How to show explained variance in a multilevel model" 
date: 2011-10-03
category: R
tags: [R, multilevel]
---

In this post I will show one way to display explained variance using a line chart. There is no default plot for displaying the effect of each factor on deviance of the model, so this is a tentative proposal for my dissertation. The following values were obtained using multilevel models performed in R (thanks for `nlme` and `lme4` packages). 
Basically, this chart shows the declining variance for each level when each independent parameter is included in the model. You can find the full script below of the chart.


![Explained Variance]({{ site.url }}/images/blog/2011/ResultadoVariancia.png)

### Graph for explained variance

{% highlight r %}
# camera 2002
df1<-data.frame(level3=c(0.5045094,0.1485807, 0.0494265),
level2=c(2.7814555,1.7936947, 1.6300276),
level1=c(3.7370482, 3.4816692, 3.4842407),
t=c(0,1, 2))
par(mfrow = c(2,2), mar = c(2,4, 2, 4))#Matrix
plot(df1$level1 ~ df1$t, type="l", lwd=4, col="red", xlab="", ylab="Variance",
main="Câmara 2002", cex.main = 1,
xlim=c(0,2), xaxt="n", ylim=c(0,4))
axis(1, c(0,1,2))#to remaque axis
lines(df1$level2 ~ df1$t, type="l", lwd=4, col="blue")
lines(df1$level3 ~ df1$t, type="l", lwd=4, col="purple")
text(locator(1), expression(sigma^2)) #need to click
text(locator(1), expression(tau[0][0])) # need to click to add the text
text(locator(1), expression(omega[0][0]))# need to click to add the text
{% endhighlight %}

{% highlight r %}
# camera 2006
df3<-data.frame(level3=c(0.2562132,0.07523431, 0.04434483),
level2=c(1.7604626 ,1.2956322 , 1.08924671),
level1=c(2.2531888, 1.9952469 , 2.00465342),
t=c(0,1, 2))
plot(df3$level1 ~ df3$t, type="l", lwd=4, col="red", xlab="", ylab="Variance",
main="Câmara 2006", cex.main = 1,
xlim=c(0,2), xaxt="n", ylim=c(0,3))
axis(1, c(0,1,2))#to remaque axis
lines(df3$level2 ~ df3$t, type="l", lwd=4, col="blue")
lines(df3$level3 ~ df3$t, type="l", lwd=4, col="purple")
text(locator(1), expression(sigma^2)) # need to click to add the text
text(locator(1), expression(tau[0][0])) # need to click to add the text
text(locator(1), expression(omega[0][0])) # need to click to add the text
{% endhighlight %}

{% highlight r %}
# senado 2002
df2<-data.frame(level2=c(74.1874,50.21794, 39.31336),
level1=c(165.1340, 163.19076, 156.08912),
t=c(0,1, 2))
plot(df2$level1 ~ df2$t, type="l", lwd=4, col="red", xlab="", ylab="Variance",
main="Senado 2002", cex.main = 1,
xlim=c(0,2), xaxt="n", ylim=c(30,170))
axis(1, c(0,1,2))
lines(df2$level2 ~ df2$t, type="l", lwd=4, col="blue")
text(locator(1), expression(sigma^2))# need to click to add the text
text(locator(1), expression(tau[0][0]))# need to click to add the text
{% endhighlight %}

{% highlight r %}
# senado 2006
df4<-data.frame(level2=c(195.8233, 112.2718, 65.28095),
level1=c(292.0457, 270.1955, 250.65042),
t=c(0,1, 2))
plot(df4$level1 ~ df4$t, type="l", lwd=4, col="red", xlab="", ylab="Variance",
main="Senado 2006", cex.main = 1,
xlim=c(0,2), xaxt="n", ylim=c(50,300))
axis(1, c(0,1,2))
lines(df4$level2 ~ df4$t, type="l", lwd=4, col="blue")
text(locator(1), expression(sigma^2)) # need to click to add the text
text(locator(1), expression(tau[0][0])) # need to click to add the text

##End not run
{% endhighlight %}