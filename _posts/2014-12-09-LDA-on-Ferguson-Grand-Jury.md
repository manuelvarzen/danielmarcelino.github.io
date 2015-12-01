---
layout: post
title: "LDA on Ferguson Grand Jury I"
date: 2014-12-09
category: R
tags: [R, LDA]
---

The case of Michael Brown, an unarmed black teenager, who was shot and killed on August 9th, by Darren Wilson, a white police officer, in Ferguson has driven public opinion around the globe to the suburb of St. Louis.

<!--more-->


![LDA](/images/blog/2014/ferguson.jpeg)


### Motivation
The case of Michael Brown, an unarmed black teenager, who was shot and killed on August 9th, by Darren Wilson, a white police officer, in Ferguson has driven public opinion around the globe to the suburb of St. Louis. After few weeks, on Nov. 24, the St. Louis County prosecutor announced that a grand jury decided not to indict Mr. Wilson. This announcement triggered another ongoing wave of protests.

This trial yields to significant amount of text, which soon became available over the [internet](http://twitter.com/MitchFraas). Thanks for work-horse on the text files, now I can simply [download](https://s3.amazonaws.com/fraasdev/FergusonTextGuide.txt) and analyze them.

I spent few hours learning about LDA–Latent Dirichlet Allocation from a package called Mallet'. The Mallet machine learning package provides an interface to the Java implementation of latent Dirichlet allocation. To process a text file into mallet` a spot list of words file is required. Typically a file with unimportant words and tag marks that can instruct the algorithm.

#### Important packages
{% highlight r %}
library(devtools)
library(repmis)
require(dplyr)
require(mallet)
require(cluster)
require(wordcloud)
require(corrgram)
require(ellipse)
require(RColorBrewer)
{% endhighlight %}

#### The dictionary
{% highlight r %}
data_url <- 'https://github.com/danielmarcelino/Tables/raw/master/en.txt'

stop list <- repmis::source_data(data_url, sep = ",", header = TRUE)
{% endhighlight %}

Having downloaded the documents, let’s import them from the folder. Each document is split as 1000 words chunks. To proceed, we write the stop list file to the path directory.

{% highlight r %}
docs <- mallet.read.dir("FergusontText/chunks")

write.table(stop list, file="stoplist.txt",quote=F, sep=" ", row.names=F)

mallet.docs <- mallet.import(docs$id, docs$text, "en.txt", token.regexp = "\p{L}[\p{L}\p{P}]+\p{L}")
{% endhighlight %}

Let’s create a topic trainer object for data

{% highlight r %}
n.topics <- 50 topic.model <- MalletLDA(n.topics)
{% endhighlight %}

And then load the documents:

{% highlight r %}
topic.model$loadDocuments(mallet.instances)
{% endhighlight %}


Now we can actually get the vocabulary and few statistics about word frequencies.

{% highlight r %}
vocab <- topic.model$getVocabulary()

word.freq <- mallet.word.freqs(topic.model)

word.freq %>% arrange(desc(term.freq)) %>% head(10)
{% endhighlight %}


#### Almost there
Nice, we have all set. Let’s use simulations to optimize hyper parameters every 25 iterations with a warm-up period of 100 iterations (by default, the hyper parameter optimization is on). After this we can actually train the model. Once again, we can specify the number of iterations, or draws after the burn-in. I’m specifying 200 draws.

{% highlight r %}
topic.model$setAlphaOptimization(25, 100)

topic.model$train(200)
{% endhighlight %}


Now it runs through only few iterations, but picking the ‘best’ topic for each token rather than sampling from the posterior distribution.

{% highlight r %}
topic.model$maximize(20)
{% endhighlight %}


Notice that we a structure like: words nested topics, and topics in documents. Thus, it might be a good idea to get the probability of topics in documents and the probability of words in topics.

There is no magic here. The following functions return raw word counts, as I want probabilities, I’ve to normalize them. I also add smoothing to that so to avoid seen some topics with exactly 0 probability.

{% highlight r %}
doc.topics <- mallet.doc.topics(topic.model, smoothed=T, normalized=T)

topic.words <- mallet.topic.words(topic.model, smoothed=T, normalized=T)
{% endhighlight %}


Now I’ve two matrixes to transpose and normalize the doc:topics

{% highlight r %}
topic.docs <- t(doc.topics)

topic.docs <- topic.docs / rowSums(topic.docs)

Write down the output as CSV for further analysis:

write.csv(topic.docs, "ferguson-topics.csv" )
{% endhighlight %}

Now we can obtain a vector with short names for the topics:

{% highlight r %}
topics.labels <- rep("", n.topics)

for(topic in 1:n.topics) topics.labels[topic] <- paste(mallet.top.words(topic.model, topic.words[topic,], num.top.words=5)$words, collapse=" ")
{% endhighlight %}

Check out the keywords for each topic:

{% highlight r %}
topics.labels %>% head(50)

write.csv(topics.labels, "ferguson-topics-lbs.csv")
{% endhighlight %}


#### Correlation matrix
Here, Correlations with significance levels – each 1000 line chunk correlated against the others. Positive correlation – similar topics.

{% highlight r %}
cor.matrix <- cor(topic.docs, use="complete.obs", method="pearson")
write.csv(cor.matrix, "corr-matrix.csv")
{% endhighlight %}


From here, a variety of analyses can be conducted. As an instance, one could approach this as a network diagram, showing which pieces of the testimony share similar patterns of discourse, which ones do not.

{% highlight r %}
corrgram(cor.matrix, order=NULL, lower.panel=panel.shade,
upper.panel=NULL, text.panel=panel.txt,
main="Correlated chunks of the Ferguson's grand jury testimony")
{% endhighlight %}

#### Gran Finale
How about turn those bits into word clouds of the topics? A word cloud can be tricky as it doesn’t tell us much of anything if obvious words are included. That’s make our stop-list file key for generating good word clouds. Of course the subject names are going to show up a lot, but a word cloud is a lot more fancy and informative if it brings what sorts of emotional or subjective language is being used.

{% highlight r %}
for(i in 1:10){
topic.top.words <- mallet.top.words(topic.model,
topic.words[i,], 20)
print(wordcloud(topic.top.words$words,
topic.top.words$weights,
c(4,.8), rot.per=0,random.order=F,
colors=brewer.pal(5, "Dark2") ) )
}
{% endhighlight %}


We can also try clustering plot based on shared words:

{% highlight r %}
hc <- hclust(dist(topic.words))

(dens <- as.dendrogram(hc))

plot(dens, edgePar=list(col = 1:2, lty = 2:3), dLeaf=1, edge.root = TRUE)

plot(hclust(dist(topic.words)), labels=topics.labels)
{% endhighlight %}


It seems to messy, let’s create a data.frame and calculate a similarity matrix:

{% highlight r %}
topic_docs <- data.frame(topic.docs)

names(topic_docs) <- docs$id

topic_dist <- as.matrix(daisy(t(topic_docs), metric = "euclidean", stand = TRUE))
{% endhighlight %}

The following does the trick to keep only closely related documents and avoid a dense diagram, otherwise it can become difficult to interpret. Change row values to zero if less than row minimum + row standard deviation

{% highlight r %}
topic_dist[ sweep(topic_dist, 1, (apply(topic_dist,1,min) + apply(topic_dist,1,sd) )) > 0 ] <- 0
{% endhighlight %}

#### Gran Finale
Finally, we can use means to identify groups of similar documents, and further get names for each cluster

{% highlight r %}
km <- kmeans(topic_dist, n.topics)

alldocs <- vector("list", length = n.topics)

for(i in 1:n.topics){
alldocs[[i]] <- names(km$cluster[km$cluster == i]) }
{% endhighlight %}
