#' ---
#' title: "Ferguson"
#' author: "Daniel Marcelino"
#' date: "Dec 9 2014"
#' ---
#'

The case of Michael Brown, an unarmed black teenager, who was shot and killed on August 9th, by Darren Wilson, a white police officer, in Ferguson has driven public opinion around the globe to the suburb of St. Louis. After few weeks, on Nov. 24, the St. Louis County prosecutor announced that a grand jury decided not to indict Mr. Wilson. This announcement triggered another ongoing wave of protests.

This trial yields to significant amount of text, which soon became available over the [internet](http://twitter.com/MitchFraas). Thanks for work-horse on the text files, now I can simply [download](https://s3.amazonaws.com/fraasdev/FergusonTextGuide.txt) and analyze them.

I spent some hours learning about LDA--Latent Dirichlet Allocation from a package  called `Mallet'. The Mallet machine learning package  provides an interface to the Java implementation of latent Dirichlet allocation.

`library(devtools)`
`library(repmis)`
`require(dplyr)`
`require(mallet)`

`data_url <- 'https://github.com/danielmarcelino/Tables/raw/master/en.txt'`

`stoplist <- repmis::source_data(data_url, sep = ",", header = TRUE)`

Having dowloaded the documents, let's import them from the folder. Each document is split as 1000 words chunks.

`docs <- mallet.read.dir("originaldocs/chunks")`

Save stoplist file to the path.

`write.table(stoplist, file="stoplist.txt",quote=F, sep=" ", row.names=F)`

`mallet.docs <- mallet.import(docs$id, docs$text, "en.txt", token.regexp = "\\p{L}[\\p{L}\\p{P}]+\\p{L}")`

Let's create a topic trainer object for data
`n.topics <- 50`
`topic.model <- MalletLDA(n.topics)`

And then load the documents:

`topic.model$loadDocuments(mallet.instances)`

Now we can actually get the vocabulary and few statistics about word frequencies.

`vocab <- topic.model$getVocabulary()`

`word.freq <- mallet.word.freqs(topic.model)`

`word.freq %>% arrange(desc(term.freq)) %>% head(10)`

Nice, we have all set. Let's use simulations to
Here, my I'm optimizing the hyperparameters every 10 iterations with a warm-up period of 100 iterations (by default, the hyperparameter optimization is on). After this we can actually train the model. Once again, we can specify the number of iterations, or draws after the burn-in. I'm specifying 200 draws.

`topic.model$setAlphaOptimization(10, 100)`

`topic.model$train(200)`

Now it runs through only few iterations, but picking the 'best' topic for each token rather than sampling from the posterior distribution.

`topic.model$maximize(10)`

Notice that we a structure like: words nested topics, and topics in documents. Thus, it might be a good idea to get the probability of topics in documents and the probability of words in topics.

There is no magic here. The following functions return raw word counts, as I want probabilities, I've to normalize them. I also add smoothing to that so to avoid seen some topics with exactly 0 probability.

`doc.topics <- mallet.doc.topics(topic.model, smoothed=T, normalized=T)`
`topic.words <- mallet.topic.words(topic.model, smoothed=T, normalized=T)`

Now I've two matrixes to transpose and normalize the doc:topics
`topic.docs <- t(doc.topics)`
`topic.docs <- topic.docs / rowSums(topic.docs)`

Write down the output as CSV for further analysis:
  `write.csv(topic.docs, "ferguson-topics.csv" )`

Now we can obtain a vector with short names for the topics:
  `topics.labels <- rep("", n.topics)`
`for(topic in 1:n.topics) topics.labels[topic] <- paste(mallet.top.words(topic.model, topic.words[topic,], num.top.words=5)$words, collapse=" ")`

Check out the keywords for each topic:
  `topics.labels %>% head(50)`
`write.csv(topics.labels, "ferguson-topics-lbs.csv")`

# Correlation matrix
Here,  Correlations with significance levels - each 1000 line chunk correlated against the others. Positive correlation - similar topics.

`cor.matrix <- cor(topic.docs, use="complete.obs", method="pearson")
write.csv(cor.matrix, "corr-matrix.csv")`

From here, a variety of analyses can be conducted. As an instance, one could approach this as a network diagram, showing which pieces of the testimony share similar patterns of discourse, which ones do not.

`library(corrgram)`
`library(ellipse)`

`corrgram(cor.matrix, order=NULL, lower.panel=panel.shade,
          upper.panel=NULL, text.panel=panel.txt,
          main="Correlated chunks of the Ferguson's grand jury testimony")`

How about turn those bits into word clouds of the topics:

`library(RColorBrewer)'

`library(wordcloud)`



`for(i in 1:10){
  topic.top.words <- mallet.top.words(topic.model,
                                      topic.words[i,], 20)
  print(wordcloud(topic.top.words$words,
                  topic.top.words$weights,
                  c(4,.8), rot.per=0,random.order=F,
                  colors=brewer.pal(5, "Dark2") ) )
}`



We can also try some clustering plot based on shared words:
  `library(cluster)`
`hc <- hclust(dist(topic.words))`
`(dens <- as.dendrogram(hc))`
`plot(dens, edgePar=list(col = 1:2, lty = 2:3), dLeaf=1, edge.root = TRUE)`
`plot(hclust(dist(topic.words)), labels=topics.labels)`

It seems to messy, let's create a data.frame and calculate a similarity matrix:
`topic_docs <- data.frame(topic.docs)`
`names(topic_docs) <- docs$id`
`topic_dist <- as.matrix(daisy(t(topic_docs), metric = "euclidean", stand = TRUE))`

The following does the trick to keep only closely related documents and avoid a dense diagram, otherwise it can become difficult to interpret. Change row values to zero if less than row minimum + row standard deviation

`topic_dist[ sweep(topic_dist, 1, (apply(topic_dist,1,min) + apply(topic_dist,1,sd) )) > 0 ] <- 0`

Finally, we can use kmeans to identify groups of similar documents, and further get names for each cluster

`km <- kmeans(topic_dist, n.topics)`

`alldocs <- vector("list", length = n.topics)
for(i in 1:n.topics){
alldocs[[i]] <- names(km$cluster[km$cluster == i]) }`



# find top n topics for a certain author

df1 <- t(topic_docs[,grep("Darren Wilson", names(topic_docs))])
colnames(df1) <- topics.labels
require(reshape2)
topic.proportions.df <- melt(cbind(data.frame(df1),
document=factor(1:nrow(df1))),
variable.name = 'topic',
id.vars = 'docs')

# plot for each doc by that author

require(ggplot2)
ggplot(topic.proportions.df, aes(topic, value, fill=document)) +
geom_bar(stat="identity") +
ylab("proportion") +
theme(axis.text.x = element_text(angle=90, hjust=1)) +
coord_flip() +
facet_wrap(~ document, ncol=5)

## cluster based on shared words
plot(hclust(dist(topic.words)), labels=topics.labels)


## How do topics differ across different years?

topic_docs_t <- data.frame(t(topic_docs))
topic_docs_t$year <- documents$class
# now we have a data frame where each row is a topic and
# each column is a document. The cells contain topic
# proportions. The next line computes the average proportion of
# each topic in all the posts in a given year. Note that in
# topic_docs_t$year there is one FALSE, which dirties the data
# slightly and causes warnings
df3 <- aggregate(topic_docs_t, by=list(topic_docs_t$year), FUN=mean)
# this next line transposes the wide data frame created by the above
# line into a tall data frame where each column is a year. The
# input data frame is subset using the %in% function
# to omit the last row because this
# last row is the result of the anomalous FALSE value that
# is in place of the year for one blog post. This is probably
# a result of a glitch in the blog page format. I also exclude
# the last column because it has NAs in it, a side-effect of the
# aggregate function above. Here's my original line:
  # df3 <- data.frame(t(df3[-3,-length(df3)]), stringsAsFactors = FALSE)
  # And below is an updated version that generalises this in case
  # you have more than two years:
  years <- sort(as.character(na.omit(as.numeric(as.character(unique(topic_docs_t$year))))))
df3 <- data.frame(t(df3[(df3$Group.1 %in% years),-length(df3)]), stringsAsFactors = FALSE)
# now we put on informative column names
# names(df3) <- c("y2012", "y2013")
# Here's a more general version in case you have more than two years
# or different years to what I've got:
names(df3) <- unname(sapply(years, function(i) paste0("y",i)))
# the next line removes the first row, which is just the years
df3 <- df3[-1,]
# the next line converts all the values to numbers so we can
# work on them
df3 <- data.frame(apply(df3, 2, as.numeric, as.character))
df3$topic <- 1:n.topics

# which topics differ the most between the years?

# If you have
# more than two years you will need to do things differently
# by adding in some more pairwise comparisons. Here is one
# pairwise comparison:
df3$diff <- df3[,1] - df3[,2]
df3[with(df3, order(-abs(diff))), ]
# # then if you had three years you might then do
# # a comparison of yrs 1 and 3
# df3$diff2 <- df3[,1] - df3[,3]
# df3[with(df3, order(-abs(diff2))), ]
# # and the other pairwise comparison of yrs 2 and 3
# df3$diff3 <- df3[,2] - df3[,3]
# df3[with(df3, order(-abs(diff3))), ]
## and so on


# plot
library(reshape2)
# we reshape from long to very long! and drop the
# 'diff' column that we computed above by using a negatve
# index, that's the -4 in the line below. You'll need to change
# that value if you have more than two years, you might find
# replacing it with -ncol(df3) will do the trick, if you just
# added one diff column.
df3m <- melt(df3[,-4], id = 3)
ggplot(df3m, aes(fill = as.factor(topic), topic, value)) +
  geom_bar(stat="identity") +
  coord_flip()  +
  facet_wrap(~ variable)


' Visualize people similarity using force-directed network graphs

#### network diagram using Fruchterman & Reingold algorithm
# static
# if you don't have igraph, install it by removing the hash below:
  # install.packages("igraph")
  library(igraph)
g <- as.undirected(graph.adjacency(topic_df_dist))
layout1 <- layout.fruchterman.reingold(g, niter=500)
plot(g, layout=layout1, edge.curved = TRUE, vertex.size = 1, vertex.color= "grey", edge.arrow.size = 0, vertex.label.dist=0.5, vertex.label = NA)


# interactive in a web browser
# if you have a particularly large dataset, you might want to skip this section, and just run the Gephi part.
# if you don't have devtools, install it by removing the hash below:
# install.packages("devtools")

devtools::install_github("d3Network", "christophergandrud")
require(d3Network)
d3SimpleNetwork(get.data.frame(g),width = 1500, height = 800,
                textColour = "orange", linkColour = "red",
                fontsize = 10,
                nodeClickColour = "#E34A33",
                charge = -100, opacity = 0.9, file = "d3net.html")
# find the html file in working directory and open in a web browser

# for Gephi
# this line will export from R and make the file 'g.graphml'
# in the working directory, ready to open with Gephi
write.graph(g, file="g.graphml", format="graphml")
