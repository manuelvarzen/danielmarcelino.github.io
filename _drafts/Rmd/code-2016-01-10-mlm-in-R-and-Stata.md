MLM in R and Stata 


In R

dfr <- read.table(file="c:/tmp/dataset.csv", sep=",", header=TRUE)
head(dfr)
length(table(dfr$ipnum))
lmer(ene ~ videocond + ifrelevant + videorelevant + choicenum +(1|ipnum), data=dfr)

> lmer(ene ~ videocond + ifrelevant + videorelevant + choicenum +(1|ipnum), data=dfr)
Linear mixed model fit by REML 
Formula: ene ~ videocond + ifrelevant + videorelevant + choicenum + (1 |      ipnum) 
   Data: dfr 
   AIC   BIC logLik deviance REMLdev
 14246 14296  -7116    14201   14232
Random effects:
 Groups   Name        Variance Std.Dev.
 ipnum    (Intercept) 0.057602 0.24000 
 Residual             0.308240 0.55519 
Number of obs: 8388, groups: ipnum, 99

Fixed effects:
               Estimate Std. Error t value
(Intercept)    6.577093   0.034225  192.17
videocond     -0.084752   0.045125   -1.88
ifrelevant     0.058130   0.018008    3.23
videorelevant  0.079140   0.027395    2.89
choicenum     -0.033673   0.003477   -9.69

Correlation of Fixed Effects:
            (Intr) vidcnd ifrlvn vdrlvn
videocond   -0.589                     
ifrelevant  -0.152  0.120              
videorelvnt  0.104 -0.172 -0.657       
choicenum   -0.328 -0.002  0.000 -0.020



In Stata

insheet using c:/tmp/dataset.csv, comma
xtmixed ene videocond ifrelevant videorelevant choicenum || ipnum:

. xtmixed ene videocond ifrelevant videorelevant choicenum || ipnum:

Performing EM optimization: 

Performing gradient-based optimization: 

Iteration 0:   log restricted-likelihood = -7116.1459  
Iteration 1:   log restricted-likelihood = -7116.1459  

Computing standard errors:

Mixed-effects REML regression                   Number of obs      =      8388
Group variable: ipnum                           Number of groups   =        99

                                                Obs per group: min =        27
                                                               avg =      84.7
                                                               max =       405


                                                Wald chi2(4)       =    147.43
Log restricted-likelihood = -7116.1459          Prob > chi2        =    0.0000

------------------------------------------------------------------------------
         ene |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
   videocond |  -.0847629   .0451285    -1.88   0.060     -.173213    .0036873
  ifrelevant |   .0581296   .0180084     3.23   0.001     .0228339    .0934254
videorelev~t |   .0791396   .0273951     2.89   0.004     .0254462    .1328329
   choicenum |   -.033673   .0034768    -9.69   0.000    -.0404873   -.0268587
       _cons |   6.577098    .034227   192.16   0.000     6.510014    6.644182
------------------------------------------------------------------------------

------------------------------------------------------------------------------
  Random-effects Parameters  |   Estimate   Std. Err.     [95% Conf. Interval]
-----------------------------+------------------------------------------------
ipnum: Identity              |
                   sd(_cons) |   .2400042    .018642      .2061118    .2794697
-----------------------------+------------------------------------------------
                sd(Residual) |   .5551934   .0043134      .5468034    .5637122
------------------------------------------------------------------------------
LR test vs. linear regression: chibar2(01) =  1352.50 Prob >= chibar2 = 0.0000

. 
end of do-file

