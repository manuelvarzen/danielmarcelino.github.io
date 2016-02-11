Understand Bayes Theorem (prior/likelihood/posterior/evidence)


[Bayes Theorem](http://en.wikipedia.org/wiki/Bayes'_theorem) is a very common and fundamental theorem used in Data mining and Machine learning. Its formula is pretty simple:

P(X|Y) = ( P(Y|X) * P(X) ) / P(Y), which is Posterior = ( Likelihood * Prior ) /  Evidence
So I was wondering why they are called correspondingly like that.

Let’s use an example to find out their meanings.


Example

Suppose we have 100 movies and 50 books.
There are 3 different movie types: Action, Sci-fi, Romance,
2 different book types: Sci-fi, Romance


20 of those 100 movies are Action.
30 are Sci-fi
50 are Romance.

15 of those 50 books are Sci-fi
35 are Romance
So given a unclassified object,

The probability that it's a movie is 100/150, 50/150 for book.
The probability that it's a Sci-fi type is 45/150, 20/150 for Action and 85/150 for Romance.
If we already know it's a movie, then the probability that it's an action movie is 20/100, 30/100 for Sci-fi and 50/100 for Romance.
If we already know it's a book, then that probability that it's an Sci-fi book is 15/50, 35/50 for Romance.
Right now, we want to know that given an object which has type Sci-fi, what the probability is if it’s a movie?

Using Bayes theorem, we know that the formula is:

P(movie|Sci-fi) = P(Sci-fi| Movie) * P(Movie) / P(Sci-fi)
Here, P(movie|Sci-fi) is called Posterior,
P(Sci-fi|Movie) is Likelihood,
P(movie) is Prior,
P(Sci-fi) is Evidence.

Now let’s see why they are called like that.

Prior: Before we observe it’s a Sci-fi type, the object is completely unknown to us. Our goal is to find out the possibility that it’s a movie, we actually have the data prior(or before) our observation, which is the possibility that it’s a movie if it’s a completely unknown object: P(movie).

Posterior: After we observed it’s a Sci-fi type, we know something about the object. Because it’s post(or after) the observation, we call it posterior: P(movie|Sci-fi).

Evidence: Because we’ve already known it’s a Sci-fi type, what has happened is happened. We witness it’s appearance, so to us, it’s an evidence, and the chance we get this evidence is P(Sci-fi).

Likelihood: The dictionary meaning of this word is chance or probability that one thing will happen. Here it means when it’s a movie, what the chance will be if it is also a Sci-fi type. This term is very important in Machine Learning.

So why those probabilities are named like that, the observation time is a very important reason.