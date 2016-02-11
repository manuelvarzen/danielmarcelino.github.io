Brazil’s 2018 election polls’ analysis



The Brazilian general elections are yet far from now, but because the `multi-crises` context the country is deep emerged political elites wants this gap to be shortened as quickly as possible. One way of doing this is by starting campaigning early, saying 3 year earlier.

Polls are already coming pavementing the road of potential candidates and party coalitions. Elections in Brazil are a bit more complicated than an average US presidential race. Brazil is a multiparty system and is based on coalition governments. Sometimes it does work, sometimes doesn't. We're still in the process of learning what causes the success and failures.

Although there are plenty of parties, someone said it's the , only three parties are actually viable for the Presidency seat.
PT (center left), PSDB (center right), and PMDB (center).

The main winners though are the medium size parties that recommend to the President who they think has the best chance to construct the next government, so yes there is a good possibility that the general elections winner will not be one constructing the coalition. Making the actual winners the parties that create the biggest coalition which exceeds 60 mandates.

An abundance of polling has been continually published during the run up and the variety of pollsters and publishers is hard to keep track of as a casual voter trying to gauge the temperature of the political landscape. I came across a great realtime database by Project 61 on google docs of past and present polling result information and decided that it was a great opportunity to learn the Shiny library of Studio and create an app that I can check current and past results. 
So after I figured out how to connect google docs to R, I created a self updating app that became a nice place to keep track of polling every day, check trends and distributions using interactive ggplot2 graphs and simulate coalition outcomes.
Please note that as of Friday (March 13th), until election day (March 17th), it is forbidden to perform new polls in Israel, hence the data presented here cannot allow for an up-to-date inference about the expected results of the election. This post is for educational purposes.


### Running the election polls Shiny app on your computer

The github repo is available here.

#changing locale to run on Windows
if (Sys.info()[1] == "Windows") Sys.setlocale("LC_ALL","Hebrew_Israel.1255") 
 
#check to see if libraries need to be installed
libs <- c("shiny","shinyAce","http","XML","strings","ggplot2","scales","ply","reshape2","dplyr")
x <- sapply(libs,function(x)if(!require(x,character.only = T)) install.packages(x))
rm(x,libs)
 
#run App
shiny::runGitHub("Elections","ionic",subdir="shiny")
 
#reset to original locale on Windows
if (Sys.info()[1] == "Windows") Sys.setlocale("LC_ALL")