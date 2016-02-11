# Visualizations speak better than numbers

 ![Titanic](.jpg)
 
library(ggplot2) #Loading ggplot2 library</pre>
library(gam) #Loading gam library
titanic<-read.csv(file="D:/Kaggle/Titanic/train.csv",sep=",",header=TRUE) #Loading the inputfile
titanic<-na.gam.replace(titanic[,c("Survived","Age","Sex","Fare","Pclass")])#Replacing the NA values with gam library
#considering only few features which play a major role in identifyng the outcome
titanic$Survived<-as.factor(titanic$Survived)#changing the output variable to categorical.


#Age_Survived
qplot(Age,data=titanic,colour=Survived,geom="freqpoly")

#Sex_Survived
qplot(Sex,data=titanic,fill=Survived,geom="bar")
 
