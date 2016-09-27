- 27 members of today's Chamber were present at the 1992's impeachment

Data downloaded from Kaggle. It is real world data, hence has the odd missing (in passenger age) and a number of columns with messy data, which might be employed to create additional variables. For the purpose of validation about 90% of the data gets flagged to be training set. test will be the test, set, results of which to be passed back to Kaggle.
  PassengerId Survived Pclass                                                Name
1           1        0      3                             Braund, Mr. Owen Harris
2           2        1      1 Cumings, Mrs. John Bradley (Florence Briggs Thayer)
3           3        1      3                              Heikkinen, Miss. Laina
4           4        1      1        Futrelle, Mrs. Jacques Heath (Lily May Peel)
5           5        0      3                            Allen, Mr. William Henry
6           6        0      3                                    Moran, Mr. James
     Sex Age SibSp Parch           Ticket    Fare Cabin Embarked
1   male  22     1     0        A/5 21171  7.2500              S
2 female  38     1     0         PC 17599 71.2833   C85        C
3 female  26     0     0 STON/O2. 3101282  7.9250              S
4 female  35     1     0           113803 53.1000  C123        S
5   male  35     0     0           373450  8.0500              S
6   male  NA     0     0           330877  8.4583              Q

library(dplyr)
library(randomForest)
library(lattice)
options(width=85)
head(read.csv(‘train.csv’))

titanic <- read.csv(‘train.csv’) %>%
    mutate(.,Pclass=factor(Pclass),
        Survived=factor(Survived),
        age=ifelse(is.na(Age),35,Age),
        age = cut(age,c(0,2,5,9,12,15,21,55,65,100)),
        A=grepl(‘A’,Cabin),
        B=grepl(‘B’,Cabin),
        C=grepl(‘C’,Cabin),
        D=grepl(‘D’,Cabin),
        cn = as.numeric(gsub(‘[[:space:][:alpha:]]’,”,Cabin)),
        oe=factor(ifelse(!is.na(cn),cn%%2,-1)),
        train = sample(c(TRUE,FALSE),
            size=891,
            replace=TRUE, 
            prob=c(.9,.1)   ) )
test <- read.csv(‘test.csv’) %>%
    mutate(.,Pclass=factor(Pclass),
        age=ifelse(is.na(Age),35,Age),
        age = cut(age,c(0,2,5,9,12,15,21,55,65,100)),
        A=grepl(‘A’,Cabin),
        B=grepl(‘B’,Cabin),
        C=grepl(‘C’,Cabin),
        D=grepl(‘D’,Cabin),
        cn = as.numeric(gsub(‘[[:space:][:alpha:]]’,”,Cabin)),
        oe=factor(ifelse(!is.na(cn),cn%%2,-1)),
        Embarked=factor(Embarked,levels=levels(titanic$Embarked))
        )
test$Fare[is.na(test$Fare)]<- median(titanic$Fare)
Age has missing values, hence the first step is to fill those in. In the code above, an age factor has been made, where missings are imputed the largest category. 
Model building

A simple prediction using randomForest.
rf1 <- randomForest(Survived ~ 
        Sex+Pclass + SibSp +
        Parch + Fare + 
        Embarked + age +
        A+B+C+D +oe,
    data=titanic,
    subset=train,
    replace=FALSE,
    ntree=1000)
Call:
 randomForest(formula = Survived ~ Sex + Pclass + SibSp + Parch +      Fare + Embarked + age + A + B + C + D + oe, data = titanic,      replace = FALSE, ntree = 1000, subset = train) 
               Type of random forest: classification
                     Number of trees: 1000
No. of variables tried at each split: 3

        OOB estimate of  error rate: 16.94%
Confusion matrix:
    0   1 class.error
0 454  40  0.08097166
1  95 208  0.31353135
This shows some bias in the predictions. Class one gets predicted as class 0 far too often. Hence I will optimize not only the normal variables nodesize (Minimum size of terminal nodes) and mtry (Number of variables randomly sampled as candidates at each split) but also classwt (Priors of the classes).

titanic$pred <- predict(rf1,titanic)
with(titanic[!titanic$train,],sum(pred!=Survived)/length(pred))

mygrid <- expand.grid(nodesize=c(2,4,6),
    mtry=2:5,
    wt=seq(.5,.7,.05))
sa <- sapply(1:nrow(mygrid), function(i) {
    rfx <- randomForest(Survived ~ 
        Sex+Pclass + SibSp +
        Parch + Fare + 
        Embarked + age +
        A+B+C+D +oe,
    data=titanic,
    subset=train,
    replace=TRUE,
    ntree=4000,
    nodesize=mygrid$nodesize[i],
    mtry=mygrid$mtry[i],
    classwt=c(1-mygrid$wt[i],mygrid$wt[i]))  
    preds <- predict(rfx,titanic[!titanic$train,])
    nwrong <- sum(preds!=titanic$Survived[!titanic$train])
    c(nodesize=mygrid$nodesize[i],mtry=mygrid$mtry[i],wt=mygrid$wt[i],pw=nwrong/length(preds))
    })
tsa <- as.data.frame(t(sa))
xyplot(pw ~ wt | mtry,group=factor(nodesize), data=tsa,auto.key=TRUE,type=’l’)



What is less visible from this plot is the amount of variation I had in the results. One prediction better or worse really makes a difference in the figure. This is the reason I have increased the number of trees in the model.
Final predictions

Using the best settings from above, gets you to the bottom of the ranking. The script makes the model, writes predictions in the format required by kaggle.
rf2 <- randomForest(Survived ~ 
        Sex+Pclass + SibSp +
        Parch + Fare + 
        Embarked + age +
        A+B+C+D +oe,
    data=titanic,
    replace=TRUE,
    ntree=5000,
    nodesize=4,
    mtry=3,
    classwt=c(1-.6,.6))  

pp <- predict(rf2,test)
out <- data.frame(
    PassengerId=test$PassengerId,
    Survived=pp,row.names=NULL)
write.csv(x=out,
    file=’rf1.csv’,
    row.names=FALSE,
    quote=FALSE)