# Aldrich-McKelvey analysis on British Candidate Surveys
### Load libraries
library(foreign)
library(basicspace)
library(ggplot2)
library(car)

### Demo

http://voteview.com/AM_and_basicspace_in_R.htm
There are some data available to download

data(LC1980)
result <- aldmck(data=LC1980,
                 polarity=2, respondent=1,
                 missing=c(0,8,9),verbose=TRUE)

with(result$respondents,
     cor(idealpt,selfplace,use="pairwise",method="spearman"))

png(file="issues1980.png")
plot.AM(result)
dev.off()



### Now BRS 2001

brs2001<-read.spss("British Representation Study 2001 Release 1.0.por",
                   to.data.frame=TRUE,use.value.labels=FALSE)

### Recode party
brs2001$party <- recode(brs2001$Q1,
                        "1='Conservative';2='Labour';3='Liberal Democrat';
                        4='SNP';5='Plaid Cymru';6='Green';else=NA")

###
table(brs2001$Q28A)


### Plot some charts for a sanity check
ggplot(brs2001, aes(x = Q28A)) + facet_wrap(~party,ncol = 1) +
  scale_x_continuous("Left-right self. positioning") +
  scale_y_continuous("Number of respondents") +
  geom_bar() +
  theme_bw()

### Do Aldrich-McKelvey

### Subset to Labour respondents
lab.only <- subset(brs2001,party == "Labour")
lab.mat <- as.matrix(lab.only[,
                              c("Q28A","Q28C","Q28D","Q28E")]) ## self, parl. party, leader, voters
colnames(lab.mat) <- c("self","parl.party","leader","voters")

lab.res <- aldmck(data = lab.mat,
                  respondent = 1,
                  polarity = 4, ## assume voters are left leaning
                  ## just for estimation purposes
                  verbose = TRUE)

### Check polarity
with(lab.res$respondents,
     cor(selfplace, idealpt,use="pairwise",method="spearman"))

plot(lab.res)

### Subset to Conservative respondents
con.only <- subset(brs2001,party == "Conservative")
con.mat <- as.matrix(con.only[,
                              c("Q28A","Q28C","Q28D","Q28E")]) ## self, parl. party, leader, voters
colnames(con.mat) <- c("self","parl.party","leader","voters")

con.res <- aldmck(data = con.mat,
                  respondent = 1,
                  polarity = 4, ## assume voters left leaning
                  ## just for estimation purposes
                  verbose = TRUE)

### Check polarity
with(con.res$respondents,
     cor(selfplace, idealpt,use="pairwise",method="spearman"))

plot(con.res)


### Subset to Liberal Democrat
ld.only <- subset(brs2001,party == "Liberal Democrat")
ld.mat <- as.matrix(ld.only[,
                            c("Q28A","Q28C","Q28D","Q28E")]) ## self, parl. party, leader, voters
colnames(ld.mat) <- c("self","parl.party","leader","voters")

ld.res <- aldmck(data = ld.mat,
                 respondent = 1,
                 polarity = 2, ## assume parl party left leaning
                 ## just for estimation purposes
                 verbose = TRUE)

### Check polarity
with(ld.res$respondents,
     cor(selfplace, idealpt,use="pairwise"))

plot(ld.res)



#### And now with 2005

brs2005<-read.spss("brs2005clean.sav",to.data.frame=TRUE,use.value.labels=FALSE)

### Recode party
brs2005$party <- recode(brs2005$q1,
                        "1='Conservative';2='Labour';3='Liberal Democrat';
                        4='SNP';5='Plaid Cymru';6='Green';else=NA")

###
table(brs2005$q26a)

brs2005$q26a <- recode(brs2005$q26a,"c('88','99')= NA")
brs2005$q26a <- round(brs2005$q26a)
brs2005$q26c <- recode(brs2005$q26c,"c('88','99')= NA")
brs2005$q26c <- round(brs2005$q26c)
brs2005$q26d <- recode(brs2005$q26d,"c('88','99')= NA")
brs2005$q26d <- round(brs2005$q26d)
brs2005$q26e <- recode(brs2005$q26e,"c('88','99')= NA")
brs2005$q26e <- round(brs2005$q26e)

### Plot some charts for a sanity check
ggplot(brs2005, aes(x = q26a)) + facet_wrap(~party,ncol = 1) +
  scale_x_continuous("Left-right self. positioning") +
  scale_y_continuous("Number of respondents") +
  geom_bar() +
  theme_bw()

### Do Aldrich-McKelvey

### Subset to Labour respondents
lab.only <- subset(brs2005,party == "Labour")
lab.mat <- as.matrix(lab.only[,
                              c("q26a","q26c","q26d","q26e")]) ## self, parl. party, leader, voters
colnames(lab.mat) <- c("self","parl.party","leader","voters")

lab.res <- aldmck(data = lab.mat,
                  respondent = 1,
                  polarity = 4, ## assume voters are left leaning
                  ## just for estimation purposes
                  ## We could flip if correl. negative
                  verbose = TRUE)

### Check polarity
with(lab.res$respondents,
     cor(selfplace, idealpt,use="pairwise",method="spearman"))

plot(lab.res)

### Subset to Conservative respondents
con.only <- subset(brs2005,party == "Conservative")
con.mat <- as.matrix(con.only[,
                              c("q28a","q28c","q28d","q28e")]) ## self, parl. party, leader, voters
colnames(con.mat) <- c("self","parl.party","leader","voters")

con.res <- aldmck(data = con.mat,
                  respondent = 1,
                  polarity = 3, ## assume leader left leaning
                  ## just for estimation purposes
                  verbose = TRUE)

### Check polarity
with(con.res$respondents,
     cor(selfplace, idealpt,use="pairwise",method="spearman"))

plot(con.res)

### Subset to Liberal Democrat
ld.only <- subset(brs2005,party == "Liberal Democrat")
ld.mat <- as.matrix(ld.only[,
                            c("q28a","q28c","q28d","q28e")]) ## self, parl. party, leader, voters
colnames(ld.mat) <- c("self","parl.party","leader","voters")

ld.res <- aldmck(data = ld.mat,
                 respondent = 1,
                 polarity = 4, ## assume leader left leaning
                 ## just for estimation purposes
                 verbose = TRUE)

### Check polarity
with(ld.res$respondents,
     cor(selfplace, idealpt,use="pairwise",method="spearman"))

plot(ld.res)
