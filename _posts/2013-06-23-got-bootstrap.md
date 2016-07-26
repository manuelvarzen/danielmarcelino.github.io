---
layout: post
title: "Got Bootstrap?" 
date: 2013-06-23
output:
 html_document: 
   keep_md: yes
   toc: yes
share: true
category: blog
tags: [R, rstats, Bootstrap]
excerpt: "This post discuss some of the techniques of bootstrapping in R, presented in the new book by Michael Chernick and Robert LaBudde."
published: true
status: published
comments: true
header-img: "img/website/spaghetti.png"
---

I read a book by Michael Chernick and Robert LaBudde, [An Introduction to Bootstrap Methods with Applications to R](http://www.amazon.com/gp/product/0470467045/ref=as_li_ss_tl?ie=UTF8&camp=1789&%23038;creative=390957&%23038;creativeASIN=0470467045&%23038;linkCode=as2&%23038;tag=danielmarceli-20). It's an interesting *oeuvre* for useRs of all stripes. The book brings lots of examples of bootstrapping applications, such as standard errors, confidence intervals, hypothesis testing, and bootstrap applied for time-series analysis. The showcases in the book draw upon libraries like the **boot** by Angelo Canty and Brian Ripley, which is a great package. However, I’d love to find in the book more examples on "how to do my own bootstrap program" instead, so I decided to write down these lines. Before starting any code, it might be a good idea to refresh what exactly bootstrap is, and why it is so relevant for data analysis nowadays.

The objective of bootstrapping is to provide an estimation of a parameter based on the data, such as standard deviation, mean, or median. The technique itself was introduced by Brad Efron in 1979. Third years before, however, Quenouille had introduced the jackknife method, and permutation tests were already described by Fisher in the early1930s. Hence, Efron’s resampling procedure build upon these pioneering methods and propose a simplification of them. Although, his original idea was a simple approximation of the jackknife method, depending on the context, computing a statistic from an estimator using bootstrap is as good as or even superior to jackknife method. Nonetheless, because the complexity to deal with big numbers $n^n$, for instance, a sample of size n=10 demands a huge computation: 10 billion, the bootstrapping—in practice—relies on Monte Carlo approximation rather than analytically computation.

Indeed, bootstrapping is all about sampling randomly with replacement from the original data. Here is an example, suppose we have a sample of size n=4 and the observations are $X_1 = 7, X_2 = 5, X_3 = 4, X_4 = 8$ and that we want to estimate the mean. Then, the sample estimate of the population parameter is the sample mean: $(7+5+4+8)/4 = **6.0**$. The bootstrap sample is denoted by $X_1^*,X_2^*,X_3^*,X_4^*$. The sampling distribution with replacement from $F_n$ is called the bootstrap distribution, which—to be consistent—we denote the bootstrap estimate by $T(F_n^*)$. So, a bootstrap sample might be $X_1^* = 5,X_2^* = 8,X_3^* = 7,X_4^* = 7$, with estimate of $(5+8+7+7)/4 = **6.75**$.

Note that, although it is possible to get the original sample back, typically, some values get repeated one or more times and consequently others get omitted. In this simple bootstrap sample instance, the bootstrap estimate of the mean is given by $(5+8+7+7)/4 = **6.75**$, which differs slightly from the original sample mean estimate of 6.0. If we take another bootstrap sample, we may get yet another estimate that may differ from the previous one and the original sample, like in the next bootstrap sample: $X_1^* = 4,X_2^* = 8,X_4^* = 7,X_5^* = 4$. We get, in the case, two repeated observations at once, and the bootstrap estimate for the mean **5.75**.

Despite the bootstrapping sounds complicated, the basic intuition is not. The bootstrap refers to a method that assigns values of accuracy of sample estimates by using resampling parcels of the original data. Therefore, it allows for inference about a population from a sample data [sample -> population], which can be modeled by resampling the sample data and performing inference on [resample -> sample]. In other words, all the bootstrap does is resample from a sampling distribution, and then estimate the desired statistic for the data parameter. The puzzle, nonetheless, is that as the population is unknown, the true error for a sample against its population is unknowable. Fortunately, by resampling with bootstrap, the ‘population’ becomes in fact the sample, and this is known. By following this logic: resampling the sample [resample -> sample], the ‘true’ parameter is measurable.

To apply the bootstrap, in the following example I’m going to use data (NLS-Y) from Griliches (1976) about the impact of years of schooling on individual revenues. These data are used in many econometric books, including one by Hayashi (2000), and are replicated in the SciencePo package, for educational reason, so you can easily get them by using the following commands:


{% highlight r %}
if(!require('SciencePo')) install.packages('SciencePo')
data(griliches76, package="SciencePo")
detail(griliches76)
summary(lm(lw~s+age, data=griliches76))
{% endhighlight %}


To apply the bootstrap on the estimates, I used years of schooling “s” and IQ score “iq” to estimate the individual log wage rate “lw”—the dependent variable; therefore, the OLS equation is simply “lw = s + iq”. Which yield for the following statistics:

{% highlight r %}
Call:
lm(formula = lw ~ s + iq, data = griliches76)

Residuals:
    Min      1Q  Median      3Q     Max 
-1.2817 -0.2436  0.0009  0.2424  1.1050 

Coefficients:
            Estimate Std. Error t value Pr(>|t|)
(Intercept)  4.15573    0.10810   38.44  < 2e-16
s            0.08470    0.00699   12.11  < 2e-16
iq           0.00381    0.00115    3.32  0.00093

Residual standard error: 0.369 on 755 degrees of freedom
Multiple R-squared:  0.264,    Adjusted R-squared:  0.262 
F-statistic:  135 on 2 and 755 DF,  p-value: <2e-16
{% endhighlight %}


Based on these estimates, we can see that "s" has a standard error six times greater that of "iq" parameter. Now, for the sake of the doubt, let’s say you want to bootstrap the estimates and calculate the standard deviation of 10 thousands resamples on the fly. Because the standard deviation shows how much variation or dispersion exists from the average. A low standard deviation for the estimates (intercept, "s", and "iq") indicates that the data points tend to be very close to the mean.

As you will learn, building such an exercise in R is incredible straightforward. First, you want to draw a function that takes data and the estimators for generating standard deviations for each variable. Second, you want to draw a function to bootstrap the standard deviation, as in the following.

{% highlight r %}
myboot<-function(data, stat, nreps, hist = TRUE) {
estimates<-get(stat)(data)
len<-length(estimates) 
container<-matrix(NA, ncol = len , nrow = nreps) 
nobs<-nrow(data)
for(i in 1:nreps) { 
posdraws<-ceiling(runif(nobs)*nobs)
resample<-data[posdraws,] 
container[i,]<-get(stat)(resample)
}
  ads<-apply(container,2,sd)
  if(hist==T) {
    mfrow=c(1,1)
    frame()
    if(len<= 3) par(mfrow=c(len,1))
    if((len> 3)&(len<= 6)) par(mfrow=c(3,2))
    for(j in 1:len) hist(container[,j], 
    main=paste("Estimates for ", names(estimates)[j]), xlab="")
  }  
  print(rbind(estimates,ads))
  return(list(estimation=container, sds=sds))
}

### 2 ###
mod<-function(griliches76)lm(lw~s+iq, data=griliches76)[[1]]

mod1.res<-myboot(griliches76, "mod", 10000, hist=T)

{% endhighlight %}



An annotated version of the program above can be found [here](http://gist.github.com/danielmarcelino/5800912).
Having completed the bootstrap algorithm and the function to generate the standard deviation, you can finally perform the routine to get the results.

{% highlight r %}
mod1 <- function(griliches76)lm(lw~s+iq, data=griliches76)[[1]]

mod1.sds <- myboot(griliches76, "mod1", 10000, hist=TRUE)

         (Intercept)      s       iq
estimates      4.1557 0.084696 0.003810
sds            0.1123 0.007351 0.001159

{% endhighlight %}

Not only the values displayed in the prompt are informative, but the histogram of the distribution. The above histogram tells us about the distribution of the bootstrap estimates. By comparing these estimates with those obtained from the naïve OLS, we can guarantee that the OLS estimates are rather robust, since they are contained in the distribution of standard deviations produced by 10 thousands sampling simulations.

![Histograms]({{ site.url }}/img/2013/boot_histograms.jpeg)