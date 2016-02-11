Like many concepts in mathematics, linearity has multiple interpretations and meanings. What do we mean when we say something is linear? Well, it depends on what follows. A linear relationship is different from a linear system. Let’s see why.

### Linear Relationships

Suppose I’m Mark Zuckerberg, and I have a theory that mathematicians are motivated by money1. My hypothesis is that there is a linear relationship between the percentage of people majoring in mathematics, y and the starting salaries of mathematicians x. In other words, y = mx + b. Here is our data2:

enrollment <- c(rep(.7,3), rep(.6,2), rep(.7,5), rep(.8,4), rep(.9,2))
names(enrollment) <- 1:length(enrollment) + 1994
 
salary <- c(rep(94,3), rep(82,2), rep(94,5), rep(106,4), rep(118,2))
names(salary) <- 1:length(salary) + 1994
Plotting out this contrived example, we see that the relationship does seem to take the shape of a line.

How might we find the slope and y-intercept? Recall that in algebra, we first solve for m and then b. Of course m = \frac{y_2 - y_1}{x_2 - x_1} = 8.3e-3. Therefore, b = y - mx = -0.08333333. Note that we can accomplish the same thing with a linear regression.

lm(enrollment ~ salary, data.frame(enrollment, salary))


We call these linear models precisely because the relationship between the response and the predictors can be described by a line. Note that it doesn’t matter if we have one or more than one predictor, since the equation is simply a line in multiple dimensions.

If the data provided is messy, then the exact equation for a line might not work out. We would see slight variations in the slope and intercept depending on which data points we chose to solve the slope. Obviously a linear regression gets us closer to a true value in this circumstance. Keep this in the back of your head as we go forward.

Linear Systems

Moving on to a linear system, otherwise known as a system of linear equations, you might think that this is simply a bunch of equations for lines thrown together. While almost right, you’d be slightly off the Mark. For convenience let’s look at a system of two variables, such as the one in Example 1.6 of Cherney, Denton, and Waldron.

\begin{array}{rrr}2x &+ 6y &= 20 \\ 4x &+ 8y &= 28 \end{array}

How is this different from the structure of the equation in the first section? You might have to squint to see it, as it’s subtle. One thing is that we can solve x,y directly, which yields x = 10 - 3y \Rightarrow 40 - 12y + 8y = 28 \Rightarrow y=3, x=1. Note that here we’re not allowed to do a linear regression, since there isn’t enough data. Indeed, if we were pig-headed and tried anyway, here’s what we’d get:

lm(z ~ x + y, data.frame(x=c(2,4), y=c(6,8), z=c(20,28)))

This is clearly wrong. Before the regression worked out perfectly and gave us the slope and intercept. So what’s going on? In the first example we had one line, but now we have two. Let’s rearrange the equations to see.

\begin{array}{rll}y &= -1/3x &+ 10/3 \\ y &= -1/2x &+ 7/2 \end{array}

Plotting these two equations illustrates the difference nicely.

f1 <- function(x) -1/3 * x + 10/3
f2 <- function(x) -1/2 * x + 7/2
xs <- seq(-2,2, by=.1)
plot(xs, f1(xs), type='l', col='brown')
lines(xs, f2(xs), col='orange')
points(1,3)


The lesson here is that a linear relationship is a single relationship between a dependent variable (response) and a set of independent variables (predictors). Ultimately you are looking for the coefficients that describe a line. On the other hand, a system of linear equations describes multiple linear relationships. What’s important is that here you are solving for the variables that solve all the equations simultaneously.

Linearity

Finally, let’s think about linearity. As we know, a function is linear if it satisfies two properties: additivity and homogeneity. In equation form, these look like

Additivity: L(u + v) = L(u) + L(v)
Homogeneity: L(cu) = c L(u)

So what types of functions are linear? It’s natural to ask whether the equation for a line satisfies linearity. Let’s see what additivity looks like for f(x) = mx + b.

\begin{array}{rl}f(u + v) &= m(u + v) + b \\ &= mu + mv + b \\  f(u) + f(v) &= mu + b + mv + b \\  &= mu + mv + 2b \end{array}

Surprise! So lines do not exhibit linearity unless b = 0. This peculiarity has a neat connection to our system of linear equations. Notice that by re-writing the equations in standard form, two things happen. First, the intercept term “disappears”. Second, we can now interpret the system as two independent variables and one dependent variable! That’s precisely what I did during my pig-headed episode with lm.

The bigger punchline is of course that re-writing the system once more into matrix form yields another insight. Now our system can be described simply by Ax = b, or

\left(\begin{array}{cc}2 & 6 \\ 4 & 8 \end{array}\right)     \left(\begin{array}{c}r \\ s \end{array}\right)  = \left(\begin{array}{c}20 \\ 28 \end{array}\right)

This brings us back to the textbook, where our matrix A is considered a linear operator. Let’s verify that this is true. For additivity, we get

\begin{array}{rl}A(u + v)   &= (u_x + v_x) \left(\begin{array}{c} 2 \\ 4 \end{array}\right)    + (u_y + v_y) \left(\begin{array}{c} 6 \\ 8 \end{array}\right) \\  &= u_x \left(\begin{array}{c} 2 \\ 4 \end{array}\right)    + u_y \left(\begin{array}{c} 6 \\ 8 \end{array}\right)   + v_x \left(\begin{array}{c} 2 \\ 4 \end{array}\right)    + v_y \left(\begin{array}{c} 6 \\ 8 \end{array}\right) \\  &= Au + Av \end{array}

Proving homogeneity is easier, so I leave that up to you.

One last question before we close this chapter is why are matrices also called linear transformations? To answer this, let’s look at our original problem that we posed as Mark Z. Let’s create a more complete line based on our enrollment ~ salary relationship.

A = matrix(c(2,4,6,8), nrow=2)
old <- rbind(salary, enrollment)
new <- A %*% old
xlim <- range(c(old[1,],new[1,]))
ylim <- range(c(old[2,],new[2,]))
plot(old[1,], old[2,], type='l', col='brown', xlim=xlim, ylim=ylim)
lines(new[1,], new[2,], col='orange')


What we see is that the original line (brown) has been transformed into a new line (orange). This transformation will behave the same for any collection of points. So this time we’re creating a whole new set of x,y pairs based on another set.

Conclusion

We’ve covered three different aspects of linearity. Notice that even though each section begins with a linear equation, by changing the representation and problem we accomplish a different task. This is probably the most important result and one that you won’t find in textbooks.

