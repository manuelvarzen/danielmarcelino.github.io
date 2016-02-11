#Contents:
# -- The mean model: simulated data, R analysis, WinBUGS / JAGS analysis
# -- the structure of WinBUGS / JAGS models, reexpressing parameters, number of chains, number of iterations, burnin, thinning, the Brooks-Gelman-Rubin (BGR) convergence diagnostic (a.k.a. Rhat), graphical summaries of posterior distributions
# -- binomial proportion inference with WinBUGS / JAGS instead of the Metropolis algorithm we built "by hand" for this purpose
# -- comparison of 3 models for the same binomial proportion data with different uniform priors: posterior estimation with WinBUGS / JAGS and computing the evidence / marginal likelihood for each model based on the WinBUGS / JAGS posterior samples
# -- inference for 2 binomial proportions with WinBUGS / JAGS instead of the Metropolis algorithm we built "by hand" for this purpose



# The MEAN model

### Data generation: generate two samples of reaction times in a lexical decision task (or whatever)

y10 <- rnorm(n=10, mean=600, sd=30) # Sample of 10 subjects
y1000 <- rnorm(n=1000, mean=600, sd=30) # Sample of 1000 subjects

# Plot data
par(mfrow=c(2, 1))
hist(y10, col='lightblue', xlim=c(450, 750), main='RTs of 10 subjects', freq=FALSE)
lines(density(y10), col="blue", lwd=2)
hist(y1000, col = 'lightgreen', xlim=c(450, 750), main = 'RTs of 1000 subjects', freq=FALSE)
lines(density(y1000), col="darkred", lwd=2)
par(mfrow=c(1, 1))

# We analyze only the y1000 data.


# Analysis using R

summary(lm(y1000~1))         


# Analysis using WinBUGS

# Save BUGS description of the model to working directory

cat("model{
    # Priors
    population.mean~dunif(0,5000)
    population.sd~dunif(0,100)
    # Re-expressing parameters for WinBUGS
    population.variance <- population.sd*population.sd
    precision <- 1/population.variance
    # Likelihood
    for (i in 1:n.obs) {
    RT[i] ~ dnorm(population.mean, precision)
    }
    }", fill=TRUE, file="mean_model.txt")

# Bundle data
mean.data <- list(RT=y1000, n.obs=length(y1000))
str(mean.data)

# Function to randomly generate starting values
mean.inits <- function () {
  list(population.mean=rnorm(1, 2500, 500), population.sd=runif(1, 1, 30))
}
mean.inits()

# Parameters to be monitored, i.e., to be estimated
params <- c("population.mean", "population.sd")

# We could also monitor the variance -- or any other function of the parameters we might be interested in:
#params <- c("population.mean", "population.sd", "population.variance")

# MCMC settings
# -- number of chains
nc <- 3

# -- number of iterations, i.e., number of draws from posterior for each chain
ni <- 1100

# -- number of draws / samples to discard as burnin
nb <- 100

# -- thinning rate, i.e., we save only every nth iteration / draw from the posterior
nt <- 1

# Start Gibbs sampler: run model in WinBUGS and save results in object called out.
#install.packages("R2WinBUGS")
library(R2WinBUGS)
out <- bugs(data=mean.data, inits=mean.inits, parameters.to.save=params, model.file="mean_model.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory = getwd(), clearWD=TRUE)

# Summary of the object:
out	  # Not summary(out)
print(out, dig=3)

# Compare with the frequentist estimates:
summary(lm(y1000~1))
print(out$mean, dig=4)

# More info:
names(out)              
str(out)

# The object out contains all the information that WinBUGS produced plus some processed items such as:
# -- summaries like mean values of all monitored parameters
# -- the Brooks-Gelman-Rubin (BGR) convergence diagnostic called Rhat (to get that, we set DIC=TRUE)
# -- an effective sample size that corrects for the degree of autocorrelation within the chains (more autocorrelation means smaller effective sample size)

# For a quick check whether any of the parameters has a BGR diagnostic greater than 1.1 (i.e., has Markov chains that have not converged), we do this:

which(out$summary[,8]>1.1) 

# -- Rhat values are stored in the eighth column of the summary
# -- none of them is greater than 1.1

# We generate trace plots for the entire chains to see if they converged (if we keep the WinBUGS window open with debug=TRUE we see that WinBUGS does that automatically).


# -- we use the sims.array object for that:      
str(out$sims.array)

# -- dimension 3 -- the estimated parameters (3: population.mean, population.sd and deviance -- the last one is automatically included when we set DIC=TRUE)
# -- dimension 2 -- the chains (3 chains)
# -- dimension 1 -- the actual samples (1000 for each chain of each estimated parameter)

# Samples / draws from the population mean:
head(out$sims.array[ , , 1])
# Samples / draws from the population sd:
head(out$sims.array[ , , 2])


# We plot the chains:
par(mfrow = c(2, 2))
matplot(out$sims.array[ , , 1], type = "l")
matplot(out$sims.array[ , , 2], type = "l")

# or just parts of them:
matplot(out$sims.array[1:30, , 1], type = "l")
matplot(out$sims.array[1:30, , 2], type = "l")
par(mfrow=c(1, 1))

# we can also plot them together to see how the MCMC simulation as a whole evolved:

par(mfrow = c(1, 2))
plot(out$sims.array[1:20, 1, 1], out$sims.array[1:20, 1, 2], type = "b", col="green", pch=20)
text(out$sims.array[1:20, 1, 1], out$sims.array[1:20, 1, 2]+.1, as.character(1:20), cex=.8, col="darkred")

plot(out$sims.array[1:500, 1, 1], out$sims.array[1:500, 1, 2], type = "b", col="green", pch=20)
par(mfrow = c(1, 1))




# We produce graphical summaries, e.g., a histogram of the posterior distributions for the estimated parameters.

# -- we use the sims.list object for this, which pools together all the samples in all the chains

par(mfrow=c(2, 1))
hist(out$sims.list$population.mean, col="lightblue", freq=FALSE)
lines(density(out$sims.list$population.mean), col="blue", lwd=2)
hist(out$sims.list$population.sd, col="lightgreen", freq=FALSE)
lines(density(out$sims.list$population.sd), col="darkred", lwd=2)
par(mfrow=c(1, 1))

# We can obtain numerical summaries for the samples:
summary(out$sims.list$population.mean)
summary(out$sims.list$population.sd)

# We can obtain the standard errors of the point estimates by simply calculating the sd of the posterior distribution:
sd(out$sims.list$population.mean)
sd(out$sims.list$population.sd)

# Compare with the frequentist SE for the mean:
summary(lm(y1000~1))

# Note that the lm function does not gives us the SD for the residual standard error -- it only gives us the point estimate:
summary(lm(y1000~1))$sigma

# Based on our posterior distribution, we can compute the SD for this, i.e., the uncertainty in our estimate of the residual standard error:
sd(out$sims.list$population.sd)

# We can plot the two parameters against each other:
plot(out$sims.list$population.mean, out$sims.list$population.sd, pch=20, cex=.7, col="blue")
text(min(out$sims.list$population.mean)+1, min(out$sims.list$population.sd), paste("cor = ", round(cor(out$sims.list$population.mean, out$sims.list$population.sd), 3), sep=""), col="darkred")

# We can check if the draws are independent from each other (which is what we want) by computing their autocorrelation:
par(mfrow=c(2, 1))
acf(out$sims.list$population.mean)
acf(out$sims.list$population.sd)
par(mfrow=c(1, 1))




# Let's do it with JAGS now:

# -- if we use rjags and R2jags, the output is very similar to the R2WinBUGS output


#install.packages("rjags")
library("rjags")
#install.packages("R2jags")
library("R2jags")

mean.data <- list(RT=y1000, n.obs=length(y1000))
mean.inits <- function () {
  list(population.mean=rnorm(1, 2500, 500), population.sd=runif(1, 1, 30))
}
params <- c("population.mean", "population.sd")
nc <- 3
ni <- 1100
nb <- 100
nt <- 1

outj <- jags(mean.data, inits=mean.inits, parameters.to.save=params, model.file="mean_model.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

nc <- 3
ni <- 11000
nb <- 1000
nt <- 10

outj <- jags(mean.data, inits=mean.inits, parameters.to.save=params, model.file="mean_model.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

# Summary:
print(outj, dig=3)

# Compare with the WinBUGS summary and with the frequentist estimates:
print(outj$BUGSoutput$mean, dig=3)
print(out$mean, dig=3)
data.frame(population.mean=round(as.numeric(coef(lm(y1000~1))), 2), population.sd=round(summary(lm(y1000~1))$sigma, 2), deviance=round(-2*logLik(lm(y1000~1)), 2))

# More info:
names(outj)
names(outj$BUGSoutput)
names(out)

print(outj$BUGSoutput$summary)
outj$BUGSoutput$summary[, 8]
which(outj$BUGSoutput$summary[, 8] > 1.1)

str(outj$BUGSoutput$sims.array)

# Samples / draws from the population mean:
head(outj$BUGSoutput$sims.array[ , , 2])
# Samples / draws from the population sd:
head(outj$BUGSoutput$sims.array[ , , 3])


#Graphical summaries:

par(mfrow=c(2, 1))
hist(outj$BUGSoutput$sims.list$population.mean, col="lightblue", freq=FALSE)
lines(density(outj$BUGSoutput$sims.list$population.mean), col="blue", lwd=2)
hist(outj$BUGSoutput$sims.list$population.sd, col="lightgreen", freq=FALSE)
lines(density(outj$BUGSoutput$sims.list$population.sd), col="darkred", lwd=2)
par(mfrow=c(1, 1))

# Numerical summaries:
summary(outj$BUGSoutput$sims.list$population.mean)
summary(outj$BUGSoutput$sims.list$population.sd)

# Standard errors of the point estimates:
sd(outj$BUGSoutput$sims.list$population.mean)
sd(outj$BUGSoutput$sims.list$population.sd)

# Compare with the frequentist SE for the mean:
summary(lm(y1000~1))

# We can plot the two parameters against each other:
plot(outj$BUGSoutput$sims.list$population.mean, outj$BUGSoutput$sims.list$population.sd, pch=20, cex=.7, col="blue")
text(min(outj$BUGSoutput$sims.list$population.mean)+1, min(outj$BUGSoutput$sims.list$population.sd), paste("cor = ", round(cor(outj$BUGSoutput$sims.list$population.mean, outj$BUGSoutput$sims.list$population.sd), 3), sep=""), col="darkred")

# We can check if the draws are independent from each other:
par(mfrow=c(2, 1))
acf(outj$BUGSoutput$sims.list$population.mean)
acf(outj$BUGSoutput$sims.list$population.sd)
par(mfrow=c(1, 1))


# Finally, we can plot the chains themselves:
par(mfrow = c(2, 1))
matplot(outj$BUGSoutput$sims.array[ , , 2], type = "l")
matplot(outj$BUGSoutput$sims.array[ , , 3], type = "l")
par(mfrow=c(1, 1))

# Or more simply:

traceplot(outj)

# -- this also works for the WinBUGS output

traceplot(out)



# OR we can do it in JAGS only w/ rjags (no R2jags used):

#install.packages("rjags")
library("rjags")

mean.data <- list(RT=y1000, n.obs=length(y1000))
mean.inits <- function () {
  list(population.mean=rnorm(1, 2500, 500), population.sd=runif(1, 1, 30))
}
inits.list <- list(mean.inits(), mean.inits(), mean.inits())
inits.list

params <- c("population.mean", "population.sd", "deviance")

nc <- 3
ni <- 11000
nb <- 1000
nt <- 10

na <- 5000 # adapting iterations (before burnin and retained samples), used by JAGS to choose optimal sampler and optimize mixing of the chains

# 1. We initialize the jags model:

load.module("dic")
jm <- jags.model(file="mean_model.txt", data=mean.data, inits=mean.inits, n.chains=nc, n.adapt=na, quiet=FALSE)

# 2. We go through the burnin:
update(jm, n.iter=nb)

# 3. We generate posterior samples in a format suitable for analysis with the CODA package

samples <- coda.samples(jm, variable.names=params, n.iter=ni, thin=nt)

str(samples)
head(samples)

summary(samples)

str(summary(samples))

summary(samples)$stat
summary(samples)$quant

# -- 95% CIs (CRIs, to be more precise)
summary(samples)$quant[, c(1, 5)]


#Rhat:
gelman.diag(samples)


# Or we can generate posterior samples in a different format easier for plotting the chains

samples2 <- jags.samples(jm, variable.names=params, n.iter=ni, thin=nt)

str(samples2)

# Plot the chains
par(mfrow = c(2, 1))
matplot(samples2$population.mean[1, , ], type = "l")
matplot(samples2$population.sd[1, , ], type = "l")
par(mfrow=c(1, 1))


#Graphical summaries:

# -- we use as.vector to flatten matrices by column
(a <- cbind(c(1, 2), c(10, 20)))
as.vector(a)

str(as.vector(samples2$population.mean[1, , ]))
str(as.vector(samples2$population.sd[1, , ]))

par(mfrow=c(2, 1))
hist(as.vector(samples2$population.mean[1, , ]), col="lightblue", freq=FALSE)
lines(density(as.vector(samples2$population.mean[1, , ])), col="blue", lwd=2)
hist(as.vector(samples2$population.sd[1, , ]), col="lightgreen", freq=FALSE)
lines(density(as.vector(samples2$population.sd[1, , ])), col="darkred", lwd=2)
par(mfrow=c(1, 1))





# Let's use WinBUGS and JAGS now for binomial proportion inference, i.e., to replace the Metropolis algorithm we wrote by hand for this purpose

cat("model{
    for (i in 1:nFlips) {
    y[i] ~ dbern(theta)
    }
    theta ~ dbeta(priorA, priorB)
    priorA <- 1
    priorB <- 1
    }", fill=TRUE, file="Bern_model.txt")

nFlips <- 14
y <- c(rep(1, 11), rep(0, 3))
BUGSdata <- list(nFlips=nFlips, y=y)

inits <- function() {
  list(theta=runif(1))
}
params <- c("theta")
nc <- 3; ni <- 22000; nb <- 2000; nt <- 10

library(R2WinBUGS)
out <- bugs(data=BUGSdata, inits=inits, parameters.to.save=params, model.file="Bern_model.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory = getwd(), clearWD=TRUE)

print(out, dig=3)
print(out$mean, dig=4)


library("R2jags")
outj <- jags(BUGSdata, inits=inits, parameters.to.save=params, model.file="Bern_model.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)

print(outj, dig=3)
print(outj$BUGSoutput$mean, dig=3)


par(mfrow=c(1, 2))

hist(out$sims.list$theta, freq=FALSE, col="lightblue", breaks=30, xlim=range(0, 1))
lines(density(out$sims.list$theta), lwd=2, col="blue")
# theoretical distribution: Beta(1+11, 1+3)
lines(seq(0, 1, length.out=100), dbeta(seq(0, 1, length.out=100), 12, 4), col="red", lwd=2, lty=2)


hist(outj$BUGSoutput$sims.list$theta, freq=FALSE, col="lightblue", breaks=30, xlim=range(0, 1))
lines(density(outj$BUGSoutput$sims.list$theta), lwd=2, col="blue")
# theoretical distribution: Beta(1+11, 1+3)
lines(seq(0, 1, length.out=100), dbeta(seq(0, 1, length.out=100), 12, 4), col="red", lwd=2, lty=2)

par(mfrow=c(1, 1))



# Comparing 3 models with 3 different priors


#Model 1 with prior dunif(0, 0.4)

cat("model{
    for (i in 1:nFlips) {
    y[i] ~ dbern(theta)
    }
    theta ~ dunif(0, 0.4)
    }", fill=TRUE, file="Bern_model1.txt")

nFlips <- 14
y <- c(rep(1, 11), rep(0, 3))
BUGSdata <- list(nFlips=nFlips, y=y)

inits <- function() {
  list(theta=runif(1, 0, 0.4))
}
params <- c("theta")
nc <- 3; ni <- 22000; nb <- 2000; nt <- 10

library(R2WinBUGS)
out1 <- bugs(data=BUGSdata, inits=inits, parameters.to.save=params, model.file="Bern_model1.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory = getwd(), clearWD=TRUE)
print(out1, dig=3)


library("R2jags")
outj1 <- jags(BUGSdata, inits=inits, parameters.to.save=params, model.file="Bern_model1.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)
traceplot(outj1)
print(outj1, dig=3)


par(mfrow=c(1, 2))

hist(out1$sims.list$theta, freq=FALSE, col="lightblue", breaks=30, xlim=range(0, 1))
lines(density(out1$sims.list$theta), lwd=2, col="blue")

hist(outj1$BUGSoutput$sims.list$theta, freq=FALSE, col="lightblue", breaks=30, xlim=range(0, 1))
lines(density(outj1$BUGSoutput$sims.list$theta), lwd=2, col="blue")

par(mfrow=c(1, 1))


# Computing the evidence for model 1

acceptedTraj <- out1$sims.list$theta
myData <- y

likelihood <- function(theta, data){
  z <- sum(data==1)
  N <- length(data)
  pDataGivenTheta <- theta^z * (1-theta)^(N-z)
  pDataGivenTheta[theta>1 | theta<0] <- 0
  return(pDataGivenTheta)
}
prior <- function(theta){
  prior <- dunif(theta, min=0, max=0.4)
  prior[theta>1 | theta<0] <- 0
  return(prior)    
}

(meanTraj <- mean(acceptedTraj))
(sdTraj <- sd(acceptedTraj))
(a <- meanTraj * ((meanTraj*(1-meanTraj)/sdTraj^2)-1))
(b <- (1-meanTraj) * ((meanTraj*(1-meanTraj)/sdTraj^2)-1))
wtdEvid <- dbeta(acceptedTraj, a, b) / (likelihood(acceptedTraj, myData) * prior(acceptedTraj))
pData1 <- 1/mean(wtdEvid)
round(pData1, 6)


#Model 2 with prior dunif(0.4, 0.6)

cat("model{
    for (i in 1:nFlips) {
    y[i] ~ dbern(theta)
    }
    theta ~ dunif(0.4, 0.6)
    }", fill=TRUE, file="Bern_model2.txt")

inits <- function() {
  list(theta=runif(1, 0.4, 0.6))
}

library(R2WinBUGS)
out2 <- bugs(data=BUGSdata, inits=inits, parameters.to.save=params, model.file="Bern_model2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory = getwd(), clearWD=TRUE)
print(out2, dig=3)


library("R2jags")
outj2 <- jags(BUGSdata, inits=inits, parameters.to.save=params, model.file="Bern_model2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)
traceplot(outj2)
print(outj2, dig=3)


par(mfrow=c(1, 2))

hist(out2$sims.list$theta, freq=FALSE, col="lightblue", breaks=30, xlim=range(0, 1))
lines(density(out2$sims.list$theta), lwd=2, col="blue")

hist(outj2$BUGSoutput$sims.list$theta, freq=FALSE, col="lightblue", breaks=30, xlim=range(0, 1))
lines(density(outj2$BUGSoutput$sims.list$theta), lwd=2, col="blue")

par(mfrow=c(1, 1))


# Computing the evidence for model 2

acceptedTraj <- outj2$BUGSoutput$sims.list$theta
myData <- y

prior <- function(theta){
  prior <- dunif(theta, min=0.4, max=0.6)
  prior[theta>1 | theta<0] <- 0
  return(prior)    
}

(meanTraj <- mean(acceptedTraj))
(sdTraj <- sd(acceptedTraj))
(a <- meanTraj * ((meanTraj*(1-meanTraj)/sdTraj^2)-1))
(b <- (1-meanTraj) * ((meanTraj*(1-meanTraj)/sdTraj^2)-1))
wtdEvid <- dbeta(acceptedTraj, a, b) / (likelihood(acceptedTraj, myData) * prior(acceptedTraj))
pData2 <- 1/mean(wtdEvid)
round(pData2, 6)


#Model 3 with prior dunif(0.6, 1)

cat("model{
    for (i in 1:nFlips) {
    y[i] ~ dbern(theta)
    }
    theta ~ dunif(0.6, 1)
    }", fill=TRUE, file="Bern_model3.txt")

inits <- function() {
  list(theta=runif(1, 0.6, 1))
}

library(R2WinBUGS)
out3 <- bugs(data=BUGSdata, inits=inits, parameters.to.save=params, model.file="Bern_model3.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory = getwd(), clearWD=TRUE)
print(out3, dig=3)


library("R2jags")
outj3 <- jags(BUGSdata, inits=inits, parameters.to.save=params, model.file="Bern_model3.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)
traceplot(outj3)
print(outj3, dig=3)


par(mfrow=c(1, 2))

hist(out3$sims.list$theta, freq=FALSE, col="lightblue", breaks=30, xlim=range(0, 1))
lines(density(out3$sims.list$theta), lwd=2, col="blue")

hist(outj3$BUGSoutput$sims.list$theta, freq=FALSE, col="lightblue", breaks=30, xlim=range(0, 1))
lines(density(outj3$BUGSoutput$sims.list$theta), lwd=2, col="blue")

par(mfrow=c(1, 1))


# Computing the evidence for model 3

acceptedTraj <- out3$sims.list$theta
myData <- y

prior <- function(theta){
  prior <- dunif(theta, min=0.6, max=1)
  prior[theta>1 | theta<0] <- 0
  return(prior)    
}

(meanTraj <- mean(acceptedTraj))
(sdTraj <- sd(acceptedTraj))
(a <- meanTraj * ((meanTraj*(1-meanTraj)/sdTraj^2)-1))
(b <- (1-meanTraj) * ((meanTraj*(1-meanTraj)/sdTraj^2)-1))
wtdEvid <- dbeta(acceptedTraj, a, b) / (likelihood(acceptedTraj, myData) * prior(acceptedTraj))
pData3 <- 1/mean(wtdEvid)
round(pData3, 6)



# Comparison of the three models:

pData <- c(pData1=pData1, pData2=pData2, pData3=pData3)
print(pData, dig=3)

# -- best model
pData[pData==max(pData)]
# -- worst model
pData[pData==min(pData)]

# Bayes factors (assuming the 3 models are equally likely a priori):
# -- recall that BF = p(Data|M1) / p(Data|M2)

# The Jeffreys scale for the interpretation of the BF:
# -- < 1:1          Negative (supports M2)
# -- 1:1 to 3:1     Barely worth mentioning
# -- 3:1 to 10:1    Substantial
# -- 10:1 to 30:1   Strong
# -- 30:1 to 100:1  Very strong
# -- > 100:1        Decisive

round(pData3/pData2, 2)
round(pData2/pData1, 2)
round(pData3/pData1, 2)




#WinBUGS / JAGS version of the 2-coin model we estimated with a  "custom-made" Metropolis before


cat("model{
    for (i in 1:nparams) {
    for (j in 1:N[i]) {
    y[i, j] ~ dbern(theta[i])
    }
    theta[i] ~ dbeta(priorA, priorB)
    }
    priorA <- 3
    priorB <- 3
    }", fill=TRUE, file="model_2_coins.txt")

nparams <- 2
nobs <- 7
y <- array(0, dim=c(nparams, nobs))
y[1, ] <- c(rep(1, 5), rep(0, 2))
y[2, ] <- c(rep(1, 2), rep(0, 5))
N <- apply(y, 1, length)
BUGSdata <- list(nparams=nparams, N=N, y=y)
BUGSdata

inits <- function() {
  list(theta=runif(2))
}
inits()
params <- c("theta")
nc <- 3; ni <- 22000; nb <- 2000; nt <- 10

library(R2WinBUGS)
out <- bugs(data=BUGSdata, inits=inits, parameters.to.save=params, model.file="model_2_coins.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory = getwd(), clearWD=TRUE)
print(out, dig=3)


library("R2jags")
outj <- jags(BUGSdata, inits=inits, parameters.to.save=params, model.file="model_2_coins.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)
traceplot(outj)
print(outj, dig=3)

str(outj$BUGSoutput$sims.array[, , "theta[1]"])
str(outj$BUGSoutput$sims.array[, , "theta[2]"])

(chainLength <- dim(outj$BUGSoutput$sims.array[, , "theta[1]"])[1])

thetaSample <- array(0, dim=c(chainLength, nparams))
thetaSample[, 1] <- outj$BUGSoutput$sims.array[, 1, "theta[1]"]
thetaSample[, 2] <- outj$BUGSoutput$sims.array[, 1, "theta[2]"]

par(pty="s", mfrow=c(2, 2))

plot(thetaSample[1:50, 1], thetaSample[1:50, 2], type="o", xlim=range(0, 1), ylim=range(0, 1), xlab=bquote(theta[1]), ylab=bquote(theta[2]), main="50 steps", col="blue")

plot(thetaSample[1:100, 1], thetaSample[1:100, 2], type="o", xlim=range(0, 1), ylim=range(0, 1), xlab=bquote(theta[1]), ylab=bquote(theta[2]), main="100 steps", col="blue")

plot(thetaSample[1:300, 1], thetaSample[1:300, 2], type="o", xlim=range(0, 1), ylim=range(0, 1), xlab=bquote(theta[1]), ylab=bquote(theta[2]), main="300 steps", col="blue")

plot(thetaSample[, 1], thetaSample[, 2], type="o", xlim=range(0, 1), ylim=range(0, 1), xlab=bquote(theta[1]), ylab=bquote(theta[2]), main="all steps", col="blue")

par(mfrow=c(1, 1))


# sampling the prior -- we remove the data, e.g., BUGSdata <- list(nparams=nparams, N=N), and rerun the model, or we add a couple more lines to the model and run it

cat("model{
    for (i in 1:nparams) {
    for (j in 1:N[i]) {
    y[i, j] ~ dbern(theta[i])
    }
    theta[i] ~ dbeta(priorA, priorB)
    }
    for (i in 1:nparams) {
    for (j in 1:N[i]) {
    y.prior[i, j] ~ dbern(theta.prior[i])
    }
    theta.prior[i] ~ dbeta(priorA, priorB)
    }
    priorA <- 3
    priorB <- 3
    }", fill=TRUE, file="model_2_coins2.txt")

nparams <- 2
nobs <- 7
y <- array(0, dim=c(nparams, nobs))
y[1, ] <- c(rep(1, 5), rep(0, 2))
y[2, ] <- c(rep(1, 2), rep(0, 5))
N <- apply(y, 1, length)
BUGSdata <- list(nparams=nparams, N=N, y=y)

inits <- function() {
  list(theta=as.numeric(runif(2)), theta.prior=as.numeric(runif(2)), y.prior=array(rbinom(nparams*nobs, 1, .5), dim=c(nparams, nobs)))
}
params <- c("theta", "theta.prior", "y.prior")
nc <- 3; ni <- 42000; nb <- 2000; nt <- 10

library(R2WinBUGS)
out <- bugs(data=BUGSdata, inits=inits, parameters.to.save=params, model.file="model_2_coins2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory = getwd(), clearWD=TRUE)
print(out, dig=3)

library("R2jags")
outj <- jags(BUGSdata, inits=inits, parameters.to.save=params, model.file="model_2_coins2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)
traceplot(outj)
print(outj, dig=3)


par(pty="s", mfrow=c(2, 2))

library("MASS")
theta.kde <- kde2d(outj$BUGSoutput$sims.list$theta[, 1], outj$BUGSoutput$sims.list$theta[, 2], n=50)
theta.prior.kde <- kde2d(outj$BUGSoutput$sims.list$theta.prior[, 1], outj$BUGSoutput$sims.list$theta.prior[, 2], n=50)

image(theta.kde); contour(theta.kde, add=T)
persp(theta.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", xlab="", ylab="", zlab="", zlim=range(0, 9))

image(theta.prior.kde); contour(theta.prior.kde, add=T)
persp(theta.prior.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", xlab="", ylab="", zlab="", zlim=range(0, 9))

par(mfrow=c(1, 1))



# -- we test the difference in bias between the two coins

thetaDiff <- outj$BUGSoutput$sims.list$theta[, 1]-outj$BUGSoutput$sims.list$theta[, 2]
source("plotPost.r")
plotPost(thetaDiff, compVal=0.0, xlab=expression(theta[1]-theta[2]), breaks=30, col="lightblue")


# acf


par(mfrow=c(2, 3))

for (i in 1:3) {
  acf(outj$BUGSoutput$sims.array[, i, "theta[1]"])
}

for (i in 1:3) {
  acf(outj$BUGSoutput$sims.array[, i, "theta[2]"])
}

par(mfrow=c(1, 1))


# Evidence for model p(D)

likelihood <- function(theta, z, N) {
  like <- 1
  for (i in 1:length(theta)){
    like <- like * (theta[i]^z[i] * (1-theta[i])^(N[i]-z[i]))
  }
  return(like)
}
prior <- function(theta){
  a <- b <- rep(3, length(theta))
  pri <- 1
  for (i in 1:length(theta)){
    pri <- pri * dbeta(theta[i], a[i], b[i])
  }
  return(pri)    
}
targetRelProb <- function(theta, z, N){
  if (all(theta >= 0.0) & all(theta <= 1.0)){
    target <- likelihood(theta, z, N) * prior(theta)   
  } else {
    target <- 0.0    
  }
  return(target)
}

(z = apply(y, 1, sum))
(N = apply(y, 1, length))
nDim = nparams

(meanTraj <- apply(outj$BUGSoutput$sims.list$theta, 2, mean))
(sdTraj <- apply(outj$BUGSoutput$sims.list$theta, 2, sd))
print(outj)

(a <- meanTraj * ((meanTraj*(1-meanTraj)/sdTraj^2)-rep(1, nDim)))
(b <- (1-meanTraj) * ((meanTraj*(1-meanTraj)/sdTraj^2)-rep(1, nDim)))

(nSim <- dim(outj$BUGSoutput$sims.list$theta)[1])

wtdEvid <- rep(0, nSim)
for (i in 1:nSim) {
  wtdEvid[i] <- dbeta(outj$BUGSoutput$sims.list$theta[i, 1], a[1], b[1])*dbeta(outj$BUGSoutput$sims.list$theta[i, 2], a[2], b[2]) / (likelihood(outj$BUGSoutput$sims.list$theta[i, ], z, N) * prior(outj$BUGSoutput$sims.list$theta[i, ]))
}
pData <- 1/mean(wtdEvid)
round(pData, 7)



# Suppose we have a uniform prior instead -- let's compare the posterior and prior distributions of the parameters

cat("model{
    for (i in 1:nparams) {
    for (j in 1:N[i]) {
    y[i, j] ~ dbern(theta[i])
    }
    theta[i] ~ dbeta(priorA, priorB)
    }
    for (i in 1:nparams) {
    for (j in 1:N[i]) {
    y.prior[i, j] ~ dbern(theta.prior[i])
    }
    theta.prior[i] ~ dbeta(priorA, priorB)
    }
    priorA <- 1
    priorB <- 1
    }", fill=TRUE, file="model_2_coins3.txt")

nparams <- 2
nobs <- 7
y <- array(0, dim=c(nparams, nobs))
y[1, ] <- c(rep(1, 5), rep(0, 2))
y[2, ] <- c(rep(1, 2), rep(0, 5))
N <- apply(y, 1, length)
BUGSdata <- list(nparams=nparams, N=N, y=y)

inits <- function() {
  list(theta=as.numeric(runif(2)), theta.prior=as.numeric(runif(2)), y.prior=array(rbinom(nparams*nobs, 1, .5), dim=c(nparams, nobs)))
}
params <- c("theta", "theta.prior", "y.prior")
nc <- 3; ni <- 42000; nb <- 2000; nt <- 10

library(R2WinBUGS)
out <- bugs(data=BUGSdata, inits=inits, parameters.to.save=params, model.file="model_2_coins3.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory = getwd(), clearWD=TRUE)
print(out, dig=3)

library("R2jags")
outj <- jags(BUGSdata, inits=inits, parameters.to.save=params, model.file="model_2_coins3.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)
traceplot(outj)
print(outj, dig=3)



par(pty="s", mfrow=c(2, 2))

library("MASS")
theta.kde <- kde2d(outj$BUGSoutput$sims.list$theta[, 1], outj$BUGSoutput$sims.list$theta[, 2], n=50)
theta.prior.kde <- kde2d(outj$BUGSoutput$sims.list$theta.prior[, 1], outj$BUGSoutput$sims.list$theta.prior[, 2], n=50)

image(theta.kde); contour(theta.kde, add=T)
persp(theta.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", xlab="", ylab="", zlab="", zlim=range(0, 6.5))

image(theta.prior.kde); contour(theta.prior.kde, add=T)
persp(theta.prior.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", xlab="", ylab="", zlab="", zlim=range(0, 6.5))

par(mfrow=c(1, 1))






#Contents:
# -- essentials of linear models (focus on design matrices)
# -- t-tests with equal and unequal variances (simulated data, R analysis, WinBUGS / JAGS analysis)


### Essentials of linear models

# Linear models have a stochastic / random part and a deterministic part.
# -- e.g., for OLS regression, the deterministic part is the equation Y = Beta*X and the stochastic part is the distribution of normal error, assumed to be normal with mean 0 and variance sigma^2
# -- i.e., an OLS regression model is parametrized by the coefficients Beta together with the error variance sigma^2


# Stochastic part of linear models: statistical distributions


# -- Normal distribution
n.obs <- 100000
mu <- 600
st.dev <- 30

sample.1 <- rnorm(n=n.obs, mean=mu, sd=st.dev)
head(sample.1)
hist(sample.1, col="lightblue", freq=FALSE, ylim=c(0, .015), breaks=30)
lines(density(sample.1), col="blue", lwd=2)


# -- Continuous uniform distribution
n.obs <- 100000
a <- lower.limit <- 0
b <- upper.limit <- 10

sample.2 <- runif(n=n.obs, min=a, max=b)
head(sample.2)
hist(sample.2, col="lightblue", freq=FALSE, breaks=30)
lines(density(sample.2), col="blue", lwd=2)


# -- Binomial distribution: The "coin-flip distribution"
n.obs <- 100000
N <- 16 #Number of individuals that flip the coin / decide whether the indefinite or the universal has wide scope
p <- 0.8 #Probability of heads / scoping out the indefinite

sample.3 <- rbinom(n=n.obs, size=N, prob=p)
head(sample.3)
par(mfrow=c(2, 1))
hist(sample.3, col="lightblue", freq=FALSE)
plot(prop.table(table(sample.3)), lwd = 3, ylab = "Relative Frequency", col="blue")
par(mfrow=c(1, 1))

table(sample.3)
prop.table(table(sample.3))
sum(prop.table(table(sample.3)))

# -- Poisson distribution
n.obs <- 100000
l <- 5 #Average no. of quantifiers (including modals, adverbs etc.) per sentence

sample.4 <- rpois(n=n.obs, lambda=l)
head(sample.4)
par(mfrow=c(2, 1))
hist(sample.4, col="lightblue", freq=FALSE)
plot(prop.table(table(sample.4)), lwd = 3, ylab = "Relative Frequency", col="blue")
par(mfrow=c(1, 1))


# Deterministic part of linear models: linear predictors and design matrices

# -- to fit a linear model in WinBUGS, we must know exactly what the model descriptions are and how they can be adapted to match our hypotheses
# -- we introduce the so-called design matrix of linear / generalized linear models (GLM)
# -- we will see how the same linear model can be described in different ways
# -- the different forms of the associated design matrices are called parameterizations of a model

# This material may not be necessary when fitting linear models with canned routines, but it is needed in order to use WinBUGS.
# -- only in this way we will be able to specify the customized models that we need for a particular linguistic problem


# This is part of the process of learning to let the data guide the analysis.

# -- it's the same situation as with first order logic and semantic analyses of natural language phenomena: if you know only first order logic (the canned routine), you will try to shoehorn your phenomena into that logic although the formal account might require a generalization of that logic (modal logic, partial logic, dynamic logic, higher-order logic, any mixture thereof etc.)
# -- if you know only t-tests and ANOVAs, you will try to apply them to categorical data (yes/no responses to truth-value judgment tasks, narrow vs wide scoping etc.), although they are inappropriate for this
# -- as in any other serious linguistic endeavor, the price of modeling freedom and being able to listen to what the data has to say is: acquire a higher level of formal, mathematical sophistication
# -- it is always worth it


# We learn about design matrices with a toy data set consisting of 6 observations.

y <- response <- c(6, 8, 5, 7, 9, 11)
f1 <- categorical.predictor.1 <- factor(c(1,1,2,2,3,3))
f2 <- categorical.predictor.2 <- factor(c(1,1,1,1,2,2))
f3 <- categorical.predictor.3 <- factor(c(1,2,3,1,2,3))
x <- continuous.covariate <- c(40, 45, 39, 50, 52, 57)

(toy.data.set <- data.frame(y, f1, f2, f3, x))
str(toy.data.set)


# The design matrix has:
#-- as many columns as the fitted model has parameters
#-- as many rows as there are observations, i.e., as many rows as there are responses in the response vector


# When the design matrix is matrix-multiplied with the parameter vector Beta, it yields the linear predictor X %*% Beta, another vector:
# -- the linear predictor contains the expected value of the response given the values of all explanatory variables in the model
# -- expected value means the response that would be observed when all random variation is averaged out; to get actual responses, we add the random variation, a.k.a. the error.


# We examine a progression of typical linear models: t-tests, simple linear regression, one-way ANOVA and analysis of covariance (ANCOVA).

# Goal: find out how R represents these models internally to estimate their parameters, so that we can instruct WinBUGS to build this kind of representations (only customized for our specific modeling needs).
# -- we will see different ways of writing what is essentially the same model, i.e., different parameterizations of a model, and how these affect the interpretation of the model parameters.


# The model of the mean / Null model
y
lm(y~1)
model.matrix(lm(y~1))


# t-test
cbind(y, f2)
lm(y~f2)
model.matrix(lm(y~f2))

lm(y~-1+f2)
model.matrix(lm(y~-1+f2))


# Simple linear regression
cbind(y, x)
lm(y~x) 
model.matrix(lm(y~x))

lm(y~-1+x)
model.matrix(lm(y~-1+x))


# Q: should you drop the intercept for the above linear regression?



# One-way ANOVA

# -- effects parameterization (R default)
cbind(y, f1)
lm(y~f1)
model.matrix(lm(y~f1))
# -- means parameterization
lm(y~-1+f1)
model.matrix(lm(y~-1+f1))


# Two-way ANOVA
cbind(y, f2, f3)
lm(y~f2+f3)
model.matrix(lm(y~f2+f3))

lm(y~f2*f3)
model.matrix(lm(y~f2*f3))

lm(y~-1+f2*f3-f2-f3)
model.matrix(lm(y~-1+f2*f3-f2-f3))


# ANCOVA

lm(y~f1+x)			# main effects model
lm(y~f1*x)			# main effects + interactions
lm(y~f1+x+f1:x) 	# Same, R's way of specifying the interaction term separately

model.matrix(lm(y~f1+x))
model.matrix(lm(y~f1*x))

model.matrix(lm(y~f1+x-1))
model.matrix(lm(y~(f1*x-1-x)))


# -- visualize the model w/o interactions

(fm <- lm(y~f1+x))
plot(x, y, col = c(rep("red", 2), rep("blue", 2), rep("green", 2)))
abline(fm$coef[1], fm$coef[4], col = "red")
abline(fm$coef[1]+ fm$coef[2], fm$coef[4], col = "blue")
abline(fm$coef[1]+ fm$coef[3], fm$coef[4], col = "green")


# -- visualize the model w/ interactions

(fm <- lm(y~f1*x))
plot(x, y, col = c(rep("red", 2), rep("blue", 2), rep("green", 2)))
abline(fm$coef[1], fm$coef[4], col = "red")
abline(fm$coef[1]+fm$coef[2], fm$coef[4]+fm$coef[5], col = "blue")
abline(fm$coef[1]+fm$coef[3], fm$coef[4]+fm$coef[6], col = "green")



# t-tests with WinBUGS


#t-test with equal variances

# Data generation

n1 <- 60 # observations in group / treatment 1
n2 <- 40 # observations in group / treatment 2
mu1 <- 105 # mean for group 1
mu2 <- 77.5 # mean for group 2
sigma <- 2.75 # average population SD for both groups / treatments

(n <- n1+n2) # total sample size
(x <- rep(c(0, 1), c(n1, n2))) # indicator / dummy variable for group 2

(beta.0 <- mu1) # mean for group 1 serves as the intercept
(beta.1 <- mu2-mu1) # beta.1 is the difference group2-group1

(E.y <- beta.0 + beta.1*x) # Expectation (deterministic part of the model)
y.obs <- rnorm(n=n, mean=E.y, sd=sigma) # Add random variation (stochastic part of the model)

cbind(round(y.obs, 2), E.y, x)
plot(as.factor(x), y.obs, col="lightblue", xlab="Groups", ylab = "RTs")


# Analysis using R
fit1 <- lm(y.obs~x)
summary(fit1)
model.matrix(fit1)


# Analysis using WinBUGS

# Define BUGS model
cat("model{
    # Likelihood
    for (i in 1:n) {
    mu[i] <- mu1 + delta*x[i]    # Deterministic part
    y.obs[i]~dnorm(mu[i], tau)      # Stochastic part
    residual[i] <- y.obs[i]-mu[i]     # We define residuals so that we can monitor them
    }
    
    # Priors
    mu1~dnorm(0, 0.0001) # Mean for group 1 (recall: precision=1/variance; this is a pretty vague prior)
    delta~dnorm(0, 0.0001) # Difference between group 1 and group 2
    sigma~dunif(0, 10) # The SD of the error
    tau <- 1/(sigma*sigma) # We reparametrize this -- WinBUGS uses precision, not SD / variance for normal distributions
    
    # Derived quantities: one of the greatest things about a Bayesian analysis
    mu2 <- mu1 + delta      # Mean for the second group
    }", fill=TRUE, file="t_test.txt")


# Bundle data
win.data <- list(x=x, y.obs=y.obs, n=n)
win.data

# Inits function
inits <- function() {
  list(mu1=rnorm(1), delta=rnorm(1), sigma=rlnorm(1))
}

# We initialize the SD sigma with a random draw from the log normal distribution:
x.lnorm <- rlnorm(10000)
par(mfrow=c(2, 1))
plot(density(x.lnorm), col="blue", lwd=2)
plot(density(log(x.lnorm)), col="blue", lwd=2)
par(mfrow=c(1, 1))


# Parameters to estimate
params <- c("mu1", "mu2", "delta", "sigma", "residual")

# MCMC settings
nc <- 3		# Number of chains
ni <- 1000	# Number of draws from posterior for each chain
nb <- 1		# Number of draws to discard as burn-in
nt <- 1		# Thinning rate

# Start Gibbs sampler
library(R2WinBUGS)
out <- bugs(data=win.data, inits=inits, parameters=params, model="t_test.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory=getwd(), clearWD=TRUE)

print(out, dig=2)

# Examine the point estimates:
print(out$mean, dig=5)
# Compare with the frequentist / maximum likelihood ones
coef(fit1)
print(-2*logLik(fit1))


# Run quick regression diagnostics to check for homoscedasticity:

plot(out$mean$residual, pch=20, col="blue")
abline(h=0)

boxplot(out$mean$residual~x, col="lightblue", xlab="Groups", ylab="Residual RTs", las=1)
abline(h=0)


# Doing it with JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="t_test.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)

nb <- 1000
ni <- 2000

outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="t_test.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)


# Summary:
print(outj, dig=3)

# Compare with the frequentist estimates:
print(outj$BUGSoutput$mean, dig=5)
coef(fit1)
print(-2*logLik(fit1))


plot(outj$BUGSoutput$mean$residual, pch=20, col="blue")
abline(h=0)

boxplot(outj$BUGSoutput$mean$residual~x, col="lightblue", xlab="Groups", ylab="Residual RTs", las=1)
abline(h=0)




# t-test with unequal variances

# Data generation
n1 <- 60 # Number of observations in group 1
n2 <- 40 # Number of observations in group 1
mu1 <- 105 # Population mean for group 1
mu2 <- 77.5 # Population mean for group 2
sigma1 <- 3 # Population SD for group 1
sigma2 <- 2.5 # Population SD for group 2

n <- n1+n2 # Total sample size
y1 <- rnorm(n1, mu1, sigma1) # Data for group 1
y2 <- rnorm(n2, mu2, sigma2) # Data for group 2
y <- c(y1, y2) # Aggregate both data sets
x <- rep(c(0, 1), c(n1, n2)) # Indicator for group 2

cbind(round(y, 2), x)
plot(as.factor(x), y, col="lightblue", xlab="Groups", ylab="RTs")


# Analysis using R
t.test(y~x)


# Analysis using WinBUGS

# Define BUGS model
cat("model{
    # Priors
    mu1~dnorm(0,0.001)
    mu2~dnorm(0,0.001)
    sigma1~dunif(0, 1000)
    sigma2~dunif(0, 1000)
    tau1 <- 1/(sigma1*sigma1)
    tau2 <- 1/(sigma2*sigma2) 
    # Likelihood
    for (i in 1:n1) {
    y1[i]~dnorm(mu1, tau1)
    }
    for (i in 1:n2) {
    y2[i]~dnorm(mu2, tau2)
    }
    # Derived quantities
    delta <- mu2-mu1
    }",fill=TRUE, file="t_test2.txt")


# Bundle data
win.data <- list(y1=y1, y2=y2, n1=n1, n2=n2)
win.data

# Inits function
inits <- function() {
  list(mu1=rnorm(1), mu2=rnorm(1), sigma1=rlnorm(1), sigma2=rlnorm(1))
}

# Parameters to estimate
params <- c("mu1","mu2", "delta", "sigma1", "sigma2")

# MCMC settings
nc <- 3
ni <- 2000
nb <- 500
nt <- 1

# Start Gibbs sampler
library("R2WinBUGS")
out <- bugs(data=win.data, inits=inits, parameters=params, model="t_test2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

print(out, dig=3)

# Examine the point estimates:
print(out$mean, dig=3)
# Compare with the frequentist ones:
t.test(y~x)



# Doing it with JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="t_test2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)


# Summary:
print(outj, dig=3)

# Compare with the frequentist estimates:
print(outj$BUGSoutput$mean, dig=5)
t.test(y~x)




# If we re-run the model and monitor the residuals (as we did for the homosced. t-test), we can confirm heteroscedasticity:

cat("model{
    # Priors
    mu1~dnorm(0, 0.001)
    mu2~dnorm(0, 0.001)
    sigma1~dunif(0, 1000)
    sigma2~dunif(0, 1000)
    tau1 <- 1/(sigma1*sigma1)
    tau2 <- 1/(sigma2*sigma2) 
    # Likelihood
    for (i in 1:n1) {
    y1[i]~dnorm(mu1, tau1)
    residual1[i] <- y1[i]-mu1
    }
    for (i in 1:n2) {
    y2[i]~dnorm(mu2, tau2)
    residual2[i] <- y2[i]-mu2
    }
    # Derived quantities
    delta <- mu2-mu1
    }", fill=TRUE, file="t_test3.txt")

# data -- same as before
win.data <- list(y1=y1, y2=y2, n1=n1, n2=n2)

# inits -- same as before
inits <- function() {
  list(mu1=rnorm(1), mu2=rnorm(1), sigma1=rlnorm(1), sigma2=rlnorm(1))
}

params <- c("mu1", "mu2", "delta", "sigma1", "sigma2", "residual1", "residual2")

# MCMC settings -- same as before
nc <- 3
ni <- 2000
nb <- 500
nt <- 1

# Run BUGS:
library("R2WinBUGS")
out <- bugs(data=win.data, inits=inits, parameters=params, model="t_test3.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

# Confirm heteroscedasticity:
par(mfrow=c(1, 2))
plot(c(out$mean$residual1, out$mean$residual2), col=c("black", "blue"), pch=c(1, 19), ylab="Residual RTs")
abline(h=0)                
plot(c(out$mean$residual1, out$mean$residual2)~as.factor(x), col="lightblue", xlab="Groups", ylab="Residual RTs")
par(mfrow=c(1, 1))



# Doing it with JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="t_test3.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)

# Confirm heteroscedasticity:
par(mfrow=c(1, 2))
plot(c(outj$BUGSoutput$mean$residual1, outj$BUGSoutput$mean$residual2), col=c("black", "blue"), pch=c(1, 19), ylab="Residual RTs")
abline(h=0)                
plot(c(outj$BUGSoutput$mean$residual1, outj$BUGSoutput$mean$residual2)~as.factor(x), col="lightblue", xlab="Groups", ylab="Residual RTs")
par(mfrow=c(1, 1))




# Contents:
# -- Simple linear regression (simulated data, R analysis, WinBUGS / JAGS analysis)
# -- goodness-of-fit assessment in Bayesian analyses (posterior predictive distributions and Bayesian p-values)
# -- interpretation of confidence vs. credible intervals, fixed-effects 1-way ANOVA (simulated data, R analysis, WinBUGS / JAGS analysis)
# -- random-effects 1-way ANOVA (simulated data, R analysis, WinBUGS / JAGS analysis)
# -- inferring binomial proportions with hierarchical priors (random-effects for "coins", i.e., basically, random-effect "binomial" ANOVA)




# Simple linear regression


# Data generation

n <- 16 # Number of observations
a <- 40 # Intercept
b <- -1.5 # Slope
sigma2 <- 25 # Residual variance
x <- 1:16 # Values of covariate

# Assemble data set:
normal.error <- rnorm(n, mean=0, sd=sqrt(sigma2))
(y <- a + b*x + normal.error)
#	Alternatively:
(y <- rnorm(n, a+b*x, sd=sqrt(sigma2)))

plot(x, y, xlab = "Covariate (continuous)", las=1, ylab="Continuous response", cex=1, pch=20, col="blue")


# Analysis using R
summary(lm(y~x))
cbind(estimates=round(coef(lm(y~x)), 2), true.values=c(a, b))

abline(lm(y~x), col="darkred", lwd=2)



# Analysis using WinBUGS


# Fitting the model

# Write model
cat("model {
    # Priors
    alpha~dnorm(0, 0.0001)
    beta~dnorm(0, 0.0001)
    sigma~dunif(0, 100)
    tau <- 1/(sigma*sigma)
    
    # Likelihood
    for (i in 1:n) {
    y[i] ~ dnorm(mu[i], tau)
    mu[i] <- alpha + beta*x[i]
    }
    
    # Derived quantities
    p.decrease <- 1-step(beta) # Probability that the slope is negative, i.e., that the response decreases as the predictor increases
    
    # Assess model fit using a sum-of-squares-type discrepancy
    for (i in 1:n) {
    predicted[i] <- mu[i]             # Predicted values
    residual[i] <- y[i]-predicted[i]  # Residuals for observed data                                     
    sq[i] <- pow(residual[i], 2)      # Squared residuals
    
    # Generate replicate data and compute fit statistics for them
    y.new[i]~dnorm(mu[i], tau)        # One new data set at each MCMC iteration
    sq.new[i] <- pow(y.new[i]-predicted[i], 2)  # Squared residuals for new data
    }
    
    fit <- sum(sq[])              # Sum of squared residuals for actual data set
    fit.new <- sum(sq.new[])      # Sum of squared residuals for new data set
    test <- step(fit.new-fit) 		# Test whether new data set more extreme
    bpvalue <- mean(test) 		  	# Bayesian p-value
    }
    ", fill=TRUE, file="linreg.txt")


# There are two components included in the code to assess the goodness-of-fit of our model:
# --  there are two lines that compute residuals and predicted values under the model
# -- there is code to compute a Bayesian p-value, i.e., a posterior predictive check (Gelman and Hill 2007 and references therein)

# As an instructive example, we will assess the adequacy of the model:
# -- first, using the traditional residual check
# -- then, using posterior predictive distributions, including a Bayesian p-value


# Bundle data
win.data <- list(x=x, y=y, n=n)

# Inits function
inits <- function() {
  list(alpha=rnorm(1), beta=rnorm(1), sigma = rlnorm(1))
}

# Parameters to estimate
params <- c("alpha","beta", "p.decrease", "sigma", "fit", "fit.new", "bpvalue", "residual", "predicted")

# MCMC settings
nc=3; ni=1200; nb=200; nt=1

# Start Gibbs sampler
library("R2WinBUGS")
out <- bugs(data=win.data, inits=inits, parameters=params, model="linreg.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

print(out, dig=3)

# Compare with the MLEs
print(out$mean, dig=5)
coef(lm(y~x))
print(-2*logLik(lm(y~x)))


# Goodness-of-Fit assessment in Bayesian analyses

par(mfrow=c(1, 2))
plot(out$mean$predicted, out$mean$residual, main="Residuals vs. predicted values", las=1, xlab="Predicted values", ylab="Residuals", pch=20, col="blue")
abline(h=0)

plot(x, out$mean$residual, main="Residuals vs. predictor values", las=1, xlab="Predictor values", ylab="Residuals", pch=20, col="blue")
abline(h=0)
par(mfrow=c(1, 1))



# Doing it with JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="linreg.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)

print(outj, dig=3)

# Compare with the MLEs
print(outj$BUGSoutput$mean, dig=5)
coef(lm(y~x))
print(-2*logLik(lm(y~x)))




# Posterior Predictive Distributions and Bayesian p-Values

# Posterior predictive distributions -- a very general way of assessing the fit of a model when using MCMC model fitting techniques (Gelman and Hill 2007 and references therein).

# The idea of a posterior predictive check:
# -- compare the lack of fit of the model for the actual data set with the lack of fit of the model when fitted to replicated, �ideal� data sets

# Ideal data set:
# -- it conforms exactly to the assumptions made by the model
# -- it is generated under the parameter estimates obtained from the analysis of the actual data set

# Bayesian analyses estimate a distribution -- in contrast to frequentist analyses, where the solution of a modeling problem consists of a single value for each parameter.
# Hence any lack-of-fit statistic will also have a distribution.

# We assembled one perfect / replicate data set at each MCMC iteration:
# --  under the same model that we fit to the actual data set
# --  using the values of all parameters from the current MCMC iteration

# A discrepancy measure chosen to embody a certain kind of lack of fit is computed for both that perfect data set and for the actual data set.
# -- at the end of an MCMC run for n chains of length m, we have n*m draws from the posterior predictive distribution of the discrepancy measure applied to the actual data set as well as for the discrepancy measure applied to a perfect data set

# The discrepancy measure can be chosen to assess particular features of the model.
# -- often, some global measure of lack of fit is elected, e.g., a sum-of-squares type of discrepancy, as we do here (or a Chi-squared type discrepancy)

# However, entirely different measures may also be chosen.
# -- e.g., a discrepancy measure that quantifies the incidence or magnitude of extreme values to assess the adequacy of the model for outliers

# Assessment of model adequacy based on posterior predictive distributions:
# 1. graphically, in a plot of the lack of fit for the ideal data vs. the lack of fit for the actual data 
## -- if the model fits the data, then about half of the points should lie above and half of them below a 1:1 line

lim <- c(0, max(c(out$sims.list$fit, out$sims.list$fit.new)))
plot(out$sims.list$fit, out$sims.list$fit.new, main="Graphical posterior predictive check", las=1, xlab="SSQ for actual data set", ylab="SSQ for ideal (new) data sets", xlim=lim, ylim=lim, col="blue")
abline(0, 1)

# 2. by means of a numerical summary called a Bayesian p-value
## -- this quantifies the proportion of times when the discrepancy measure for the perfect data sets is greater than the discrepancy measure computed for the actual data set
## -- a fitting model has a Bayesian p-value near 0.5 and values close to 0 or close to 1 suggest doubtful fit of the model

mean(out$sims.list$fit.new>out$sims.list$fit)



# Forming predictions

plot(x, y, xlab = "Covariate (continuous)", las=1, ylab="Continuous response", pch=20, col="blue")
abline(lm(y~x), col="darkred", lwd=2)

pred.y <- out$mean$alpha+out$mean$beta*x
points(pred.y, type="l", col="green", lwd=2)
text(c(3, 3), c(20, 18), labels=c("dark red: ML reg", "green: MCMC reg"), col=c("darkred", "green"), cex=1.2)

# Add CRIs for the expected values:

predictions <- array(dim=c(length(x), length(out$sims.list$alpha)))
for (i in 1:length(x)) {
  predictions[i, ] <- out$sims.list$alpha + out$sims.list$beta*i
}
str(predictions)
predictions[, 1:6]

# Lower bound
(LPB <- apply(predictions, 1, quantile, probs=0.025))
#?apply
#?quantile
# Upper bound
(UPB <- apply(predictions, 1, quantile, probs = 0.975))

points(LPB, type="l", col="red", lwd=2)
points(UPB, type="l", col="red", lwd=2)
text(3, 16, labels="red: CRIs", col="red", cex=1.2)


# Interpretation of confidence vs. credible intervals

# Consider the frequentist inference about the slope parameter:
print(summary(lm(y~x))$coef, dig=3)

# -- a quick and dirty frequentist 95% CI:
coefs <- summary(lm(y~x))$coef
print(c(coefs[2, 1]-2*coefs[2, 2], coefs[2, 1]+2*coefs[2, 2]), dig=3)

# This means that if we took 100 sample 16 observations from the same population and estimated a 95% CI for the slope of the linear regression, then we would expect 95 of the 100 CIs to contain the true value of the population slope / trend.

# Remember: in frequentist statistics, parameters are unknown, but FIXED; only the data is random and varies-- and the variation can be quantified in terms of probabilities.
# -- we cannot make any direct probability statement about the trend itself
# -- the true value of the trend is either in or out of any given CI, there is no probability associated with this

# In particular: it is wrong to say that the population trend / slope lies between [insert whatever interval you just got] with a probability of 95%.

# The probability statement in the 95% CI refers to the reliability of the tool, i.e., computation of the confidence interval, and not to the parameter for which a CI is constructed.

# In contrast, the posterior probability in a Bayesian analysis measures our degree of belief about the likely magnitude of a parameter, given:
# -- the model
# -- the observed data
# -- our priors

# We can make direct probability statements about a parameter using its posterior distribution.

hist(out$sims.list$beta, main="", col="lightblue", xlab = "Slope estimate", xlim = c(-4, 0), freq=FALSE, breaks=30)
lines(density(out$sims.list$beta), col="blue", lwd=2)
abline(v=0, col="red", lwd = 2)

# We see clearly that values representing no decline or an increase, i.e., values of the slope of 0 and larger have no mass at all under this posterior distribution.

# We can say:
# -- the probability of a stable or increasing trend in the population is essentially non-existent

# This is the kind of statement that most users of statistics would like to have rather than the somewhat convoluted frequentist statement about a population trend as based on the hypothetical repeated sampling and CI estimation.





# NORMAL ONE-WAY ANOVA


# Fixed-effects ANOVA

# Data generation

ngroups <- 5 # Number of groups / treatments
nsample <- 10 # Number of observations in each group
(n <- ngroups*nsample) # Total number of data points

pop.means <- c(50, 40, 45, 55, 60) # Population means for each of the groups
sigma <- 3 # Residual sd (note: assumption of homoscedasticity)
normal.error <- rnorm(n, 0, sigma) # Residuals 
sort(round(normal.error, 2))

(x <- rep(1:5, rep(nsample, ngroups))) # Indicator for population
rep(nsample, ngroups)

(means <- rep(pop.means, rep(nsample, ngroups)))

(X <- as.matrix(model.matrix(~as.factor(x)-1))) # Create design matrix

# Assemble responses

# -- deterministic part
X %*% as.matrix(pop.means) # %*% denotes matrix multiplication
as.numeric(X %*% as.matrix(pop.means))


# -- deterministic & stochastic part
y <- as.numeric(X %*% as.matrix(pop.means) + normal.error) # as.numeric is ESSENTIAL for WinBUGS
round(y, 2)

boxplot(y~x, col="lightgreen", xlab="Groups / Treatments", ylab="Continuous Response", main="", las = 1)


# Maximum likelihood analysis using R
print(summary(lm(y~as.factor(x))), dig=3)
print(anova(lm(y~as.factor(x))), dig=3)

print(summary(lm(y~as.factor(x)))$coef, dig=3)
print(summary(lm(y~as.factor(x)))$sigma, dig=3)


# Bayesian analysis using WinBUGS

# Write model
cat("model {
    # Priors
    # Implicitly define alpha as a vector
    for (i in 1:5) {
    alpha[i]~dnorm(0, 0.001)
    }
    sigma~dunif(0, 100)
    tau <- 1/(sigma*sigma)
    # Likelihood
    for (i in 1:50) {
    mean[i] <- alpha[x[i]]
    y[i]~dnorm(mean[i], tau)
    }
    # Derived quantities
    effe2 <- alpha[2]-alpha[1]
    effe3 <- alpha[3]-alpha[1]
    effe4 <- alpha[4]-alpha[1]
    effe5 <- alpha[5]-alpha[1]
    # Custom hypothesis test / Define your own contrasts
    test1 <- (effe2+effe3)-(effe4+effe5) # Equals zero when 2+3=4+5
    test2 <- effe5-2*effe4 		# Equals zero when effe5=2*effe4
    }",fill=TRUE, file="anova.txt")


# Bundle data
win.data <- list(y=y, x=x)

# Inits function
inits <- function() {
  list(alpha=rnorm(5, mean=mean(y)), sigma=rlnorm(1))
}

# Parameters to estimate
params <- c("alpha", "sigma", "effe2", "effe3", "effe4", "effe5", "test1", "test2")

# MCMC settings
ni <- 1200; nb <- 200; nt <- 2; nc <- 3

# Start Gibbs sampling
library("R2WinBUGS")
out <- bugs(win.data, inits, params, "anova.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

# We should check for convergence; we skip over this step (just examine Rhat -- all seems fine)

# Inspect estimates:
print(out, dig=3)
print(out$mean, dig=3)

# Compare with MLEs:
print(lm(y~as.factor(x))$coef, dig=3)
print(summary(lm(y~as.factor(x)))$sigma, dig=3)
print(-2*logLik(lm(y~as.factor(x))))



# JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="anova.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)

print(outj, dig=3)

# Compare with the MLEs
print(outj$BUGSoutput$mean, dig=4)
print(lm(y~as.factor(x))$coef, dig=3)
print(summary(lm(y~as.factor(x)))$sigma, dig=3)
print(-2*logLik(lm(y~as.factor(x))))



# Random-effects ANOVA

# Data generation
npop <- 10 # Number of groups / treatments: now 10 rather than 5
nsample <- 12 # Number of observations in each group
(n <- npop*nsample)	# Total number of data points

# Random effects: the means for the different groups are correlated and they come from a probability distribution

# -- in contrast to fixed-effects ANOVA, where they are taken to be independent AND fixed / not variable, e.g., the treatments are the entire population, i.e., they exhaust the space of all treatments

pop.grand.mean <- 50 # Grand mean
pop.sd <- 5 # sd of population effects about mean
pop.means <- rnorm(n=npop, mean=pop.grand.mean, sd=pop.sd)
round(pop.means, 2)

sigma <- 3 # Residual sd
normal.error <- rnorm(n, 0, sigma) # Draw residuals
sort(round(normal.error, 2))

# Note that the stochastic part of the model consists of TWO stochastic processes:
# -- the usual one involving the probability distribution for individual observations (normal.error above)
# -- the one involving the probability distribution for the group means (the random effects)

# We generate the predictor:
(x <- rep(1:npop, rep(nsample, npop)))
rep(nsample, npop)
(X <- as.matrix(model.matrix(~as.factor(x)-1)))

# We generate the response
# -- the deterministic and random-effects stochastic parts:
round(pop.means, 2)
round(as.numeric(X %*% as.matrix(pop.means)), 2)

# -- and we add the individual-level stochastic part
y <- as.numeric(X %*% as.matrix(pop.means) + normal.error) # recall that as.numeric is essential

boxplot(y~x, col="lightgreen", xlab="Groups/Treatments", ylab="Continuous Response", main="", las=1)
abline(h=pop.grand.mean, col="red", lwd=2)


# Restricted maximum likelihood (REML) analysis using R
library("lme4")
pop <- as.factor(x) # Define x as a factor and call it pop
lme.fit <- lmer(y~1+1|pop)

# Inspect results:
print(lme.fit, cor=FALSE)

# Compare with the true values:
pop.sd
sigma
pop.grand.mean


# Estimated random effects:
ranef(lme.fit)

# Compare with the true values
round(data.frame(true.values=pop.means-pop.grand.mean, RMLEs=ranef(lme.fit)$pop[, 1]), 2)


# MLEs (as opposed to RMLEs)
lme.fit2 <- lmer(y~1+1|pop, REML=FALSE)
print(lme.fit2, cor=FALSE)
round(data.frame(true.values=pop.means-pop.grand.mean, RMLEs=ranef(lme.fit)$pop[, 1], MLEs=ranef(lme.fit2)$pop[, 1]), 3)


# Bayesian analysis using WinBUGS

cat("model {
    # Priors
    mu~dnorm(0,0.001) # Hyperprior for grand mean x
    sigma.group~dunif(0, 10) # Hyperprior for sd of group effects
    tau.group <- 1/(sigma.group*sigma.group)
    for (i in 1:npop) {
    pop.mean[i]~dnorm(mu, tau.group) # Prior for group means
    effe[i] <- pop.mean[i]-mu # Group effects as derived quantities
    }
    sigma.res~dunif(0, 10) # Prior for residual sd
    tau.res <- 1/(sigma.res*sigma.res)
    # Likelihood
    for (i in 1:n) {
    y[i]~dnorm(mean[i], tau.res)
    mean[i] <- pop.mean[x[i]]
    }
    }", fill=TRUE, file="re.anova.txt")

# Bundle data
win.data <- list(y=y, x=x, npop=npop, n=n)

# Inits function
inits <- function() {
  list(mu=runif(1, 0, 100), sigma.group=rlnorm(1), sigma.res=rlnorm(1))
}

# Params to estimate
params <- c("mu", "pop.mean", "effe", "sigma.group", "sigma.res")

# MCMC settings
ni <- 1200; nb <- 200; nt <- 2; nc <- 3

# Start WinBUGS
library("R2WinBUGS")
out <- bugs(win.data, inits, params, "re.anova.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

# Inspect estimates:
print(out, dig=3)
print(out$mean, dig=3)

# Compare with MLEs:
round(fixef(lme.fit), 2)
round(ranef(lme.fit)$pop[, 1], 2)
round(coef(lme.fit)$pop[, 1], 2)
round(deviance(lme.fit), 2)
print(-2*logLik(lme.fit), dig=4)
summary(lme.fit, cor=FALSE)


# Compare with the true values:
pop.sd
sigma
pop.grand.mean
round(pop.means, 2)
round(pop.means-pop.grand.mean, 2)





# JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="re.anova.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)

print(outj, dig=3)

# Compare with the MLEs
print(outj$BUGSoutput$mean, dig=4)

round(ranef(lme.fit)$pop[, 1], 2)
round(coef(lme.fit)$pop[, 1], 2)
round(deviance(lme.fit), 2)
print(-2*logLik(lme.fit), dig=4)
summary(lme.fit, cor=FALSE)



# Inferring binomial proportions with hierarchical priors


# 1. One coin from one mint: low certainty about the bias of the mint (Amu=Bmu=2), high certainty about the dependency of the coin bias on the mint bias (K=100)

cat("model{
    for (i in 1:nobs) {
    y[i] ~ dbern(theta)
    }
    theta ~ dbeta(A, B)
    A <- mu*K
    B <- (1-mu)*K
    mu ~ dbeta(Amu, Bmu)
    
    for (i in 1:nobs) {
    y.prior[i] ~ dbern(theta.prior)
    }
    theta.prior ~ dbeta(A.prior, B.prior)
    A.prior <- mu.prior*K
    B.prior <- (1-mu.prior)*K
    mu.prior ~ dbeta(Amu, Bmu)
    
    K <- 100
    Amu <- 2
    Bmu <- 2
    }", fill=TRUE, file="1_coin_1_mint.txt")

(y <- c(rep(1, 9), rep(0, 3)))
(nobs <- length(y))
BUGSdata <- list(nobs=nobs, y=as.numeric(y))

inits <- function() {
  list(theta=runif(1), mu=runif(1), theta.prior=runif(1), mu.prior=runif(1), y.prior=rbinom(nobs, 1, .5))
}
params <- c("theta", "mu", "theta.prior",  "mu.prior", "y.prior")
nc <- 3; ni <- 42000; nb <- 2000; nt <- 10

library(R2WinBUGS)
out <- bugs(data=BUGSdata, inits=inits, parameters.to.save=params, model.file="1_coin_1_mint.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory = getwd(), clearWD=TRUE)
print(out, dig=3)

library("R2jags")
outj <- jags(BUGSdata, inits=inits, parameters.to.save=params, model.file="1_coin_1_mint.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)
traceplot(outj)
print(outj, dig=3)



par(pty="s", mfrow=c(2, 2))

library("MASS")
theta.mu.prior.kde <- kde2d(outj$BUGSoutput$sims.list$theta.prior, outj$BUGSoutput$sims.list$mu.prior, n=35)
theta.mu.kde <- kde2d(outj$BUGSoutput$sims.list$theta, outj$BUGSoutput$sims.list$mu, n=35)

image(theta.mu.prior.kde); contour(theta.mu.prior.kde, add=T)
persp(theta.mu.prior.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", xlab="", ylab="", zlab="", zlim=range(0, 26))

image(theta.mu.kde); contour(theta.mu.kde, add=T)
persp(theta.mu.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", xlab="", ylab="", zlab="", zlim=range(0, 26))

par(mfrow=c(1, 1))


par(mfrow=c(1, 2))

hist(outj$BUGSoutput$sims.list$theta, main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30)
lines(density(outj$BUGSoutput$sims.list$theta), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$theta.prior), col="darkgreen", lwd=2)

hist(outj$BUGSoutput$sims.list$mu, main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30)
lines(density(outj$BUGSoutput$sims.list$mu), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$mu.prior), col="darkgreen", lwd=2)

par(mfrow=c(1, 1))



# 2. One coin from one mint: high certainty about the bias of the mint (Amu=Bmu=20), low certainty about the dependency of the coin bias on the mint bias (K=6)

cat("model{
    for (i in 1:nobs) {
    y[i] ~ dbern(theta)
    }
    theta ~ dbeta(A, B)
    A <- mu*K
    B <- (1-mu)*K
    mu ~ dbeta(Amu, Bmu)
    
    for (i in 1:nobs) {
    y.prior[i] ~ dbern(theta.prior)
    }
    theta.prior ~ dbeta(A.prior, B.prior)
    A.prior <- mu.prior*K
    B.prior <- (1-mu.prior)*K
    mu.prior ~ dbeta(Amu, Bmu)
    
    K <- 6
    Amu <- 20
    Bmu <- 20
    }", fill=TRUE, file="1_coin_1_mint2.txt")

(y <- c(rep(1, 9), rep(0, 3)))
(nobs <- length(y))
BUGSdata <- list(nobs=nobs, y=as.numeric(y))

inits <- function() {
  list(theta=runif(1), mu=runif(1), theta.prior=runif(1), mu.prior=runif(1), y.prior=rbinom(nobs, 1, .5))
}
params <- c("theta", "mu", "theta.prior",  "mu.prior", "y.prior")
nc <- 3; ni <- 42000; nb <- 2000; nt <- 10

library(R2WinBUGS)
out <- bugs(data=BUGSdata, inits=inits, parameters.to.save=params, model.file="1_coin_1_mint2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory = getwd(), clearWD=TRUE)
print(out, dig=3)

library("R2jags")
outj <- jags(BUGSdata, inits=inits, parameters.to.save=params, model.file="1_coin_1_mint2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)
traceplot(outj)
print(outj, dig=3)



par(pty="s", mfrow=c(2, 2))

library("MASS")
theta.mu.prior.kde <- kde2d(outj$BUGSoutput$sims.list$theta.prior, outj$BUGSoutput$sims.list$mu.prior, n=35)
theta.mu.kde <- kde2d(outj$BUGSoutput$sims.list$theta, outj$BUGSoutput$sims.list$mu, n=35)

image(theta.mu.prior.kde); contour(theta.mu.prior.kde, add=T)
persp(theta.mu.prior.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", xlab="", ylab="", zlab="", zlim=range(0, 20))

image(theta.mu.kde); contour(theta.mu.kde, add=T)
persp(theta.mu.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", xlab="", ylab="", zlab="", zlim=range(0, 20))

par(mfrow=c(1, 1))


par(mfrow=c(1, 2))

hist(outj$BUGSoutput$sims.list$theta, main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30)
lines(density(outj$BUGSoutput$sims.list$theta), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$theta.prior), col="darkgreen", lwd=2)

hist(outj$BUGSoutput$sims.list$mu, main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30)
lines(density(outj$BUGSoutput$sims.list$mu), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$mu.prior), col="darkgreen", lwd=2)

par(mfrow=c(1, 1))


# 3. Multiple (two) coins from one mint: low certainty about the bias of the mint (Amu=Bmu=2), low certainty about the dependency of the coin bias on the mint bias (K=5)

cat("model{
    for (i in 1:nobs1) {
    y1[i] ~ dbern(theta1)
    }
    for (i in 1:nobs2) {
    y2[i] ~ dbern(theta2)
    }
    theta1 ~ dbeta(A, B)
    theta2 ~ dbeta(A, B)
    A <- mu*K
    B <- (1-mu)*K
    mu ~ dbeta(Amu, Bmu)
    
    for (i in 1:nobs1) {
    y1.prior[i] ~ dbern(theta1.prior)
    }
    for (i in 1:nobs2) {
    y2.prior[i] ~ dbern(theta2.prior)
    }
    theta1.prior ~ dbeta(A.prior, B.prior)
    theta2.prior ~ dbeta(A.prior, B.prior)
    A.prior <- mu.prior*K
    B.prior <- (1-mu.prior)*K
    mu.prior ~ dbeta(Amu, Bmu)
    
    K <- 5
    Amu <- 2
    Bmu <- 2
    }", fill=TRUE, file="2_coins_1_mint.txt")

(y1 <- c(rep(1, 3), rep(0, 12)))
(y2 <- c(rep(1, 4), rep(0, 1)))
(nobs1 <- length(y1))
(nobs2 <- length(y2))
BUGSdata <- list(nobs1=nobs1, nobs2=nobs2, y1=as.numeric(y1), y2=as.numeric(y2))

inits <- function() {
  list(theta1=runif(1), theta2=runif(1), mu=runif(1), theta1.prior=runif(1), theta2.prior=runif(1), mu.prior=runif(1), y1.prior=rbinom(nobs1, 1, .5), y2.prior=rbinom(nobs2, 1, .5))
}
params <- c("theta1", "theta2", "mu", "theta1.prior", "theta2.prior", "mu.prior")
nc <- 3; ni <- 42000; nb <- 2000; nt <- 10

library(R2WinBUGS)
out <- bugs(data=BUGSdata, inits=inits, parameters.to.save=params, model.file="2_coins_1_mint.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory = getwd(), clearWD=TRUE)
print(out, dig=3)

library("R2jags")
outj <- jags(BUGSdata, inits=inits, parameters.to.save=params, model.file="2_coins_1_mint.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)
traceplot(outj)
print(outj, dig=3)



par(pty="s", mfrow=c(2, 4))

library("MASS")
theta1.mu.prior.kde <- kde2d(outj$BUGSoutput$sims.list$theta1.prior, outj$BUGSoutput$sims.list$mu.prior, n=35)
theta2.mu.prior.kde <- kde2d(outj$BUGSoutput$sims.list$theta2.prior, outj$BUGSoutput$sims.list$mu.prior, n=35)
theta1.mu.kde <- kde2d(outj$BUGSoutput$sims.list$theta1, outj$BUGSoutput$sims.list$mu, n=35)
theta2.mu.kde <- kde2d(outj$BUGSoutput$sims.list$theta2, outj$BUGSoutput$sims.list$mu, n=35)

image(theta1.mu.prior.kde); contour(theta1.mu.prior.kde, add=T)
persp(theta1.mu.prior.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", zlab="", zlim=range(0, 26))
image(theta1.mu.kde); contour(theta1.mu.kde, add=T)
persp(theta1.mu.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", zlab="", zlim=range(0, 26))

image(theta2.mu.prior.kde); contour(theta2.mu.prior.kde, add=T)
persp(theta2.mu.prior.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", zlab="", zlim=range(0, 26))
image(theta2.mu.kde); contour(theta2.mu.kde, add=T)
persp(theta2.mu.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", zlab="", zlim=range(0, 26))

par(mfrow=c(1, 1))


par(mfrow=c(1, 3))

hist(outj$BUGSoutput$sims.list$theta1, main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 4))
lines(density(outj$BUGSoutput$sims.list$theta1), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$theta1.prior), col="darkgreen", lwd=2)

hist(outj$BUGSoutput$sims.list$theta2, main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 4))
lines(density(outj$BUGSoutput$sims.list$theta2), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$theta2.prior), col="darkgreen", lwd=2)

hist(outj$BUGSoutput$sims.list$mu, main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 4))
lines(density(outj$BUGSoutput$sims.list$mu), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$mu.prior), col="darkgreen", lwd=2)

par(mfrow=c(1, 1))


# 4. Multiple (two) coins from one mint: low certainty about the bias of the mint (Amu=Bmu=2), high certainty about the dependency of the coin bias on the mint bias (K=75)

cat("model{
    for (i in 1:nobs1) {
    y1[i] ~ dbern(theta1)
    }
    for (i in 1:nobs2) {
    y2[i] ~ dbern(theta2)
    }
    theta1 ~ dbeta(A, B)
    theta2 ~ dbeta(A, B)
    A <- mu*K
    B <- (1-mu)*K
    mu ~ dbeta(Amu, Bmu)
    
    for (i in 1:nobs1) {
    y1.prior[i] ~ dbern(theta1.prior)
    }
    for (i in 1:nobs2) {
    y2.prior[i] ~ dbern(theta2.prior)
    }
    theta1.prior ~ dbeta(A.prior, B.prior)
    theta2.prior ~ dbeta(A.prior, B.prior)
    A.prior <- mu.prior*K
    B.prior <- (1-mu.prior)*K
    mu.prior ~ dbeta(Amu, Bmu)
    
    K <- 75
    Amu <- 2
    Bmu <- 2
    }", fill=TRUE, file="2_coins_1_mint2.txt")

(y1 <- c(rep(1, 3), rep(0, 12)))
(y2 <- c(rep(1, 4), rep(0, 1)))
(nobs1 <- length(y1))
(nobs2 <- length(y2))
BUGSdata <- list(nobs1=nobs1, nobs2=nobs2, y1=as.numeric(y1), y2=as.numeric(y2))

inits <- function() {
  list(theta1=runif(1), theta2=runif(1), mu=runif(1), theta1.prior=runif(1), theta2.prior=runif(1), mu.prior=runif(1), y1.prior=rbinom(nobs1, 1, .5), y2.prior=rbinom(nobs2, 1, .5))
}
params <- c("theta1", "theta2", "mu", "theta1.prior", "theta2.prior", "mu.prior")
nc <- 3; ni <- 42000; nb <- 2000; nt <- 10

library(R2WinBUGS)
out <- bugs(data=BUGSdata, inits=inits, parameters.to.save=params, model.file="2_coins_1_mint2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory = getwd(), clearWD=TRUE)
print(out, dig=3)

library("R2jags")
outj <- jags(BUGSdata, inits=inits, parameters.to.save=params, model.file="2_coins_1_mint2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)
traceplot(outj)
print(outj, dig=3)



par(pty="s", mfrow=c(2, 4))

library("MASS")
theta1.mu.prior.kde <- kde2d(outj$BUGSoutput$sims.list$theta1.prior, outj$BUGSoutput$sims.list$mu.prior, n=35)
theta2.mu.prior.kde <- kde2d(outj$BUGSoutput$sims.list$theta2.prior, outj$BUGSoutput$sims.list$mu.prior, n=35)
theta1.mu.kde <- kde2d(outj$BUGSoutput$sims.list$theta1, outj$BUGSoutput$sims.list$mu, n=35)
theta2.mu.kde <- kde2d(outj$BUGSoutput$sims.list$theta2, outj$BUGSoutput$sims.list$mu, n=35)

image(theta1.mu.prior.kde); contour(theta1.mu.prior.kde, add=T)
persp(theta1.mu.prior.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", zlab="", zlim=range(0, 26))
image(theta1.mu.kde); contour(theta1.mu.kde, add=T)
persp(theta1.mu.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", zlab="", zlim=range(0, 26))

image(theta2.mu.prior.kde); contour(theta2.mu.prior.kde, add=T)
persp(theta2.mu.prior.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", zlab="", zlim=range(0, 26))
image(theta2.mu.kde); contour(theta2.mu.kde, add=T)
persp(theta2.mu.kde, phi=50, border=NULL, col="lightblue", ticktype="detailed", zlab="", zlim=range(0, 26))

par(mfrow=c(1, 1))


par(mfrow=c(1, 3))

hist(outj$BUGSoutput$sims.list$theta1, main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 4))
lines(density(outj$BUGSoutput$sims.list$theta1), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$theta1.prior), col="darkgreen", lwd=2)

hist(outj$BUGSoutput$sims.list$theta2, main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 4))
lines(density(outj$BUGSoutput$sims.list$theta2), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$theta2.prior), col="darkgreen", lwd=2)

hist(outj$BUGSoutput$sims.list$mu, main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 4))
lines(density(outj$BUGSoutput$sims.list$mu), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$mu.prior), col="darkgreen", lwd=2)

par(mfrow=c(1, 1))


# 5. Multiple coins from one mint: low certainty about the bias of the mint (Amu=Bmu=2), estimating the dependency of the coin bias on the mint bias (with a Gamma hyperprior)


# Examples of Gamma distributions

meanVector <- c(114, 10, 1, 50, 50, 50)
sdVector <- c(161, 10, 1, 70, 45, 20)
x <- seq(0, 150, length.out=10000)

par(mfcol=c(length(meanVector)/2, 2))

for (i in 1:length(meanVector)) {
  shape <- (meanVector[i]^2)/(sdVector[i]^2)
  rate <- meanVector[i]/(sdVector[i]^2)
  plot(x, dgamma(x, shape, rate), type="l", col="blue", xlab=expression(kappa), ylab=expression(p(kappa)), main=paste("Gamma(", round(shape, 3), ", ", round(rate, 3), "),", " mean=", meanVector[i], ", sd=", sdVector[i], sep=""), xlim=range(0, 150), ylim=range(0, 0.03))        
}

par(mfcol=c(1, 1))


# The model with multiple coins and a Gamma hyperprior for the dependency of coin bias on mint bias

cat("model{
    for (i in 1:nobs) {
    y[i] ~ dbern(theta[coin[i]])
    }
    for (i in 1:ncoins) {
    theta[i] ~ dbeta(A, B)
    }
    A <- mu*K
    B <- (1-mu)*K
    mu ~ dbeta(Amu, Bmu)
    K ~ dgamma(shapeK, rateK)
    
    for (i in 1:nobs) {
    y.prior[i] ~ dbern(theta.prior[coin[i]])
    }
    for (i in 1:ncoins) {
    theta.prior[i] ~ dbeta(A.prior, B.prior)
    }
    A.prior <- mu.prior*K.prior
    B.prior <- (1-mu.prior)*K.prior
    mu.prior ~ dbeta(Amu, Bmu)
    K.prior ~ dgamma(shapeK, rateK)
    
    Amu <- 2
    Bmu <- 2
    meanK <- 10
    sdK <- 10
    shapeK <- pow(meanK, 2)/pow(sdK, 2)
    rateK <- meanK/pow(sdK, 2)
    }", fill=TRUE, file="mult_coins_1_mint.txt")


# data 1: 3 coins, each with 5 heads out of 10 flips; posterior meanK is greater than prior meanK since all coins have similar biases, so we infer that the dependency on the common mint is strong
ncoins <- 3
y <- rep(c(rep(1, 5), rep(0, 5)), ncoins)
coin <- rep(1:ncoins, each=10)
data.frame(y=y, coin=coin)
(nobs <- length(y))
BUGSdata <- list(nobs=nobs, ncoins=ncoins, coin=coin, y=y)

inits <- function() {
  list(theta=runif(3), mu=runif(1), K=rgamma(1, 2, 0.5), theta.prior=runif(3), mu.prior=runif(1), K.prior=rgamma(1, 2, 0.5), y.prior=rbinom(nobs, 1, .5))
}
params <- c("theta", "mu", "K", "theta.prior", "mu.prior", "K.prior")
nc <- 3; ni <- 42000; nb <- 2000; nt <- 10

library(R2WinBUGS)
out <- bugs(data=BUGSdata, inits=inits, parameters.to.save=params, model.file="mult_coins_1_mint.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory = getwd(), clearWD=TRUE)
print(out, dig=3)

library("R2jags")
outj <- jags(BUGSdata, inits=inits, parameters.to.save=params, model.file="mult_coins_1_mint.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)
traceplot(outj)
print(outj, dig=3)


par(mfrow=c(2, 3))

for (i in 1:ncoins) {
  hist(outj$BUGSoutput$sims.list$theta[, i], main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 4))
  lines(density(outj$BUGSoutput$sims.list$theta[, i]), col="blue", lwd=2)
  lines(density(outj$BUGSoutput$sims.list$theta.prior[, i]), col="darkgreen", lwd=2)
}

hist(outj$BUGSoutput$sims.list$mu, main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 4))
lines(density(outj$BUGSoutput$sims.list$mu), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$mu.prior), col="darkgreen", lwd=2)

hist(outj$BUGSoutput$sims.list$K, main="", xlim=range(0, 50), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 0.09))
lines(density(outj$BUGSoutput$sims.list$K), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$K.prior), col="darkgreen", lwd=2)

par(mfrow=c(1, 1))


# data 2: 3 coins, one with 1 head out of 10 flips, one with 5 heads out of 10 flips, one with 9 heads out of 10 flips; posterior meanK is less than prior meanK since the coins have different biases, so we infer that the dependency on the common mint is weak
ncoins <- 3
y <- c(c(rep(1, 1), rep(0, 9)), c(rep(1, 5), rep(0, 5)), c(rep(1, 9), rep(0, 1)))
coin <- rep(1:ncoins, each=10)
data.frame(y=y, coin=coin)
(nobs <- length(y))
BUGSdata <- list(nobs=nobs, ncoins=ncoins, coin=coin, y=y)

library("R2jags")
outj <- jags(BUGSdata, inits=inits, parameters.to.save=params, model.file="mult_coins_1_mint.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)
traceplot(outj)
print(outj, dig=3)


par(mfrow=c(2, 3))

for (i in 1:ncoins) {
  hist(outj$BUGSoutput$sims.list$theta[, i], main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 3.5))
  lines(density(outj$BUGSoutput$sims.list$theta[, i]), col="blue", lwd=2)
  lines(density(outj$BUGSoutput$sims.list$theta.prior[, i]), col="darkgreen", lwd=2)
}

hist(outj$BUGSoutput$sims.list$mu, main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 3.5))
lines(density(outj$BUGSoutput$sims.list$mu), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$mu.prior), col="darkgreen", lwd=2)

hist(outj$BUGSoutput$sims.list$K, main="", xlim=range(0, 50), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 0.2))
lines(density(outj$BUGSoutput$sims.list$K), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$K.prior), col="darkgreen", lwd=2)

par(mfrow=c(1, 1))


# 6. Shrinkage of individual estimates, a.k.a. borrowing strength -- a model with 5 coins, 4 of which with low bias for heads and 1 with high bias


cat("model{
    for (i in 1:nobs) {
    y[i] ~ dbern(theta.b[coin[i]])
    }
    for (i in 1:ncoins) {
    theta[i] ~ dbeta(A, B)
    theta.b[i] <- max(0.0001, min(0.9999, theta[i]))
    }
    A <- mu*K
    B <- (1-mu)*K
    mu ~ dbeta(Amu, Bmu)
    K ~ dgamma(shapeK, rateK)
    
    for (i in 1:nobs) {
    y.prior[i] ~ dbern(theta.prior.b[coin[i]])
    }
    for (i in 1:ncoins) {
    theta.prior[i] ~ dbeta(A.prior, B.prior)
    theta.prior.b[i] <- max(0.0001, min(0.9999, theta.prior[i]))
    }
    A.prior <- mu.prior*K.prior
    B.prior <- (1-mu.prior)*K.prior
    mu.prior ~ dbeta(Amu, Bmu)
    K.prior ~ dgamma(shapeK, rateK)
    
    Amu <- 2
    Bmu <- 2
    meanK <- 10
    sdK <- 10
    shapeK <- pow(meanK, 2)/pow(sdK, 2)
    rateK <- meanK/pow(sdK, 2)
    }", fill=TRUE, file="mult_coins_1_mint2.txt")


ncoins <- 5
y <- c(rep(c(rep(1, 1), rep(0, 4)), 4), rep(1, 5))
coin <- rep(1:ncoins, each=5)
data.frame(y=y, coin=coin)
(nobs <- length(y))
BUGSdata <- list(nobs=nobs, ncoins=ncoins, coin=coin, y=y)

inits <- function() {
  list(theta=runif(5), mu=runif(1), K=rgamma(1, 2, 0.5), theta.prior=runif(5), mu.prior=runif(1), K.prior=rgamma(1, 2, 0.5), y.prior=rbinom(nobs, 1, .5))
}
params <- c("theta", "mu", "K", "theta.prior", "mu.prior", "K.prior")
nc <- 3; ni <- 42000; nb <- 2000; nt <- 10

library(R2WinBUGS)
out <- bugs(data=BUGSdata, inits=inits, parameters.to.save=params, model.file="mult_coins_1_mint2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, working.directory = getwd(), clearWD=TRUE)
print(out, dig=3)

library("R2jags")
outj <- jags(BUGSdata, inits=inits, parameters.to.save=params, model.file="mult_coins_1_mint2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)
traceplot(outj)
print(outj, dig=3)


par(mfrow=c(2, 4))

for (i in 1:ncoins) {
  hist(outj$BUGSoutput$sims.list$theta[, i], main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 3))
  lines(density(outj$BUGSoutput$sims.list$theta[, i]), col="blue", lwd=2)
  lines(density(outj$BUGSoutput$sims.list$theta.prior[, i]), col="darkgreen", lwd=2)
}

hist(outj$BUGSoutput$sims.list$mu, main="", xlim=range(0, 1), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 4))
lines(density(outj$BUGSoutput$sims.list$mu), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$mu.prior), col="darkgreen", lwd=2)

hist(outj$BUGSoutput$sims.list$K, main="", xlim=range(0, 50), col="lightblue", freq=FALSE, breaks=30, ylim=range(0, 0.15))
lines(density(outj$BUGSoutput$sims.list$K), col="blue", lwd=2)
lines(density(outj$BUGSoutput$sims.list$K.prior), col="darkgreen", lwd=2)

par(mfrow=c(1, 1))





# Contents:
# -- 2-way ANOVA w/o and w/ interactions (simulated data, R analysis, WinBUGS / JAGS analysis)
# -- [skim / skip] ANCOVA and the importance of covariate standardization (simulated data, R analysis, WinBUGS / JAGS analysis)
# -- linear mixed-effects models---random intercepts only, independent random intercepts and slopes, correlated random intercepts and slopes (simulated data, R analysis, WinBUGS / JAGS analysis)



# Normal two-way ANOVA

# Data generation

# Choose sample size
n.groups.1 <- 5
n.groups.2 <- 3
nsample <- 12
(n <- n.groups.1*nsample)

# Create factor levels
(groups.1 <- gl(n=n.groups.1, k=nsample, length=n, labels=paste("level.", c(1:n.groups.1), sep="")))

# groups.2 is replicated for each level of groups.1
(groups.2 <- gl(n=n.groups.2, k=nsample/n.groups.2, length=n, labels=paste("level.", c(1:n.groups.2), sep="")))

cbind(groups.1, groups.2)

contrasts(groups.1)
contrasts(groups.2)

# Choose effects
baseline <- 40 # Intercept

# Main effects:
(groups.1.effects <- c(-10, -5, 5, 10)) # groups.1 effects
(groups.2.effects <- c(5, 10)) # groups.2 effects

# Interaction effects -- 8 of them, i.e., (5-1)*(3-1):
(interaction.effects <- c(-2, 3, 0, 4, 4, 0, 3, -2))

(all.effects <- c(baseline, groups.1.effects, groups.2.effects, interaction.effects))
length(all.effects)

# Residuals
sigma <- 3
normal.error <- rnorm(n, 0, sigma)

round(normal.error, 2)

# Create design matrix
X <- as.matrix(model.matrix(~groups.1*groups.2))
dim(X)
head(X)


# Create response by putting together the deterministic and stochastic parts of the model
# -- deterministic part
data.frame(groups.1, groups.2, E.y=as.numeric(as.matrix(X) %*% as.matrix(all.effects)), error=round(normal.error, 2))

# -- all together
y <- as.numeric(as.matrix(X) %*% as.matrix(all.effects) + normal.error) # recall that as.numeric is ESSENTIAL for WinBUGS later
data.frame(groups.1, groups.2, E.y=as.vector(as.matrix(X) %*% as.matrix(all.effects)), error=round(normal.error, 2), y=round(y, 2))

# Plot of generated data
par(mar=c(8, 6, 4, 2))
boxplot(y~groups.1*groups.2, col="lightgreen", xlab="", ylab="Continuous Response", main="Simulated data set (groups.2*groups.1)", las=2, ylim=c(20, 70))	
abline(h=40, col="red", lwd=2)
par(mar=c(5, 4, 4, 2))

library("lattice")
xyplot(y~groups.1|groups.2, main = "Relationship between y and groups.1 (by groups.2)")
xyplot(y~groups.2|groups.1, main="Relationship between y and groups.2 (by groups.1)")


## Aside: Using simulation to assess bias and precision of an estimator
print(lm(y~groups.1*groups.2), dig=3)

# Let's compare the "true" values with the estimated values:
data.frame(true=all.effects, estimates=round(lm(y~groups.1*groups.2)$coef, 2), row.names=names(lm(y~groups.1*groups.2)$coef))

# We generate 1000 datasets to assess the estimators:
n.iter <- 1000 # Desired number of iterations
estimates <- array(dim=c(n.iter, length(all.effects))) # Data structure to hold results

for (i in 1:n.iter) { # Run simulation n.iter times
  #print(i) # Print iteration number so that we know how far we are (optional)
  normal.error <- rnorm(n, 0, sigma) # residuals
  y <- as.numeric(as.matrix(X) %*% as.matrix(all.effects) + normal.error) # assemble data
  fit.model <- lm(y~groups.1*groups.2) # fit the model
  estimates[i,] <- fit.model$coefficients # keep values of coefs
}

# Compare the true values and the mean estimates taken over the 1000 iterations:
data.frame(true=all.effects, estimates=round(apply(estimates, 2, mean), 2), row.names=names(lm(y~groups.1*groups.2)$coef))


# Analysis using R
# Main effects only:
mainfit <- lm(y~groups.1+groups.2)
summary(mainfit)

# The means parameterization of the interaction model:
intfit <- lm(y~groups.1*groups.2-1-groups.1-groups.2)
summary(intfit)



# Analysis using WinBUGS

# Main-effects ANOVA using WinBUGS

# Define model
cat("model {
    # Priors
    alpha~dnorm(0, 0.0001) # intercept
    beta.groups.1[1] <- 0 # set effect of 1st level to zero
    beta.groups.1[2]~dnorm(0, 0.0001)
    beta.groups.1[3]~dnorm(0, 0.0001)
    beta.groups.1[4]~dnorm(0, 0.0001)
    beta.groups.1[5]~dnorm(0, 0.0001)
    beta.groups.2[1] <- 0 # ditto
    beta.groups.2[2]~dnorm(0, 0.0001)
    beta.groups.2[3]~dnorm(0, 0.0001)
    sigma~dunif(0, 100)
    tau <- 1/(sigma*sigma)
    # Likelihood
    for (i in 1:n) {
    y[i]~dnorm(mean[i], tau)
    mean[i] <- alpha + beta.groups.1[groups.1[i]] + beta.groups.2[groups.2[i]]
    }
    }", fill=TRUE, file="2w.anova.txt")


# Bundle data
win.data <- list(y=y, groups.1 = as.numeric(groups.1), groups.2=as.numeric(groups.2), n=length(y))

# Inits function
inits <- function() {
  list(alpha=rnorm(1), beta.groups.1=c(NA, rnorm(4)), beta.groups.2=c(NA, rnorm(2)), sigma = rlnorm(1))
}

# Parameters to estimate
params <- c("alpha", "beta.groups.1", "beta.groups.2", "sigma")

# MCMC settings
ni <- 5500; nb <- 500; nt <- 10; nc <- 3

# Start Gibbs sampling
library("R2WinBUGS")
out <- bugs(win.data, inits, params, "2w.anova.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

# Print estimates
print(out, dig=3)

# Compare with the MLEs:
print(out$mean, dig=3)

print(mainfit$coef, dig=3)
print(summary(mainfit)$sigma, dig=3)
print(-2*logLik(mainfit))



# JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="2w.anova.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)

print(outj, dig=3)

# Compare with the MLEs
print(outj$BUGSoutput$mean, dig=4)

print(mainfit$coef, dig=3)
print(summary(mainfit)$sigma, dig=3)
print(-2*logLik(mainfit))




# Interaction-effects ANOVA using WinBUGS

# Write model
cat("model {
    # Priors
    for (i in 1:n.groups.1) {
    for (j in 1:n.groups.2) {
    group.mean[i,j]~dnorm(0, 0.0001)
    }
    }
    sigma~dunif(0, 100)
    tau <- 1/(sigma*sigma)
    # Likelihood
    for (i in 1:n) {
    mean[i] <- group.mean[groups.1[i], groups.2[i]]
    y[i]~dnorm(mean[i], tau)
    }
    }", fill=TRUE, file="2w.anova2.txt")

# Bundle data
win.data <- list(y=y, groups.1=as.numeric(groups.1), groups.2=as.numeric(groups.2), n=length(y), n.groups.1=length(unique(groups.1)), n.groups.2=length(unique(groups.2)))

# Inits function
inits <- function() {
  list(sigma=rlnorm(1))
}

# Parameters to estimate
params <- c("group.mean", "sigma")

# MCMC settings
ni <- 5500; nb <- 500; nt <- 10; nc <- 3

# Start Gibbs sampling
library("R2WinBUGS")
out <- bugs(win.data, inits, params, "2w.anova2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

# Print estimates
print(out, dig=3)

# Compare with the MLEs:
(new.data <- data.frame(groups.1=gl(n=n.groups.1, k=3, length=15, labels=paste("level.", c(1:n.groups.1), sep="")), groups.2=gl(n=n.groups.2, k=1, length=15, labels=paste("level.", c(1:n.groups.2), sep=""))))

data.frame(new.data, predicts=round(predict(intfit, newdata=new.data), 2))
print(out$mean, dig=3)



# JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="2w.anova2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)

print(outj, dig=3)

# Compare with the MLEs
data.frame(new.data, predicts=round(predict(intfit, newdata=new.data), 2))
print(outj$BUGSoutput$mean, dig=4)




# Forming predictions

# -- we present the Bayesian inference for the interaction-effects model in a graph showing the predicted response for each combination of groups.1 and groups.2 levels

# -- this is analogous to the boxplot we had above 


par(mfrow=c(1, 2), mar=c(8, 6, 4, 2))
boxplot(y~groups.2*groups.1, col="lightgreen", xlab="", ylab="y", main="Data", las=2, ylim=c(20, 70))	
abline(h=40, col="red", lwd=2)

# -- we select the order of the predictions to match that of the boxplot

ordering <- c(1, 4, 7, 10, 13, 2, 5, 8, 11, 14, 3, 6, 9, 12, 15)
plot(ordering, out$mean$group.mean, xlab="", las=1, ylab="y", cex=1.2, ylim=c(20, 70), col="blue", lab=c(6, 15, 3), main="Bayesian predictions: means +/- 2 std.dev.s")
segments(ordering, out$mean$group.mean-(2*out$sd$group.mean), ordering, out$mean$group.mean+(2*out$sd$group.mean), col="black", lwd=1)
abline(h=40, col="red", lwd=2)
par(mfrow=c(1, 1), mar=c(5, 4, 4, 2))




# General linear model (ANCOVA) -- skim / skip


# Data generation
n.groups <- 3
n.sample <- 10	
(n <- n.groups*n.sample) # Total number of data points

# Generate the factor
rep(n.sample, n.groups)
(f1 <- rep(1:n.groups, rep(n.sample, n.groups))) # Indicator for groups
(groups <- factor(f1, labels = c("A", "B", "C")))

# Generate the continuous covariate
x <- runif(n, 45, 70)
round(x, 2)


# Generate the linear predictor (i.e., the deterministic part of the model)
Xmat <- model.matrix(~groups*x)
print(Xmat, dig=2) 
beta.vec <- c(-250, 150, 200, 6, -3, -4)

lin.pred <- Xmat %*% beta.vec # lin.predictor
data.frame(f1=f1, x=round(x, 2), E.y=round(lin.pred, 2))

# Add the stochastic part
sigma <- 10
normal.error <- rnorm(n=n, mean=0, sd=sigma) # residuals 
y <- lin.pred+normal.error # response=lin.pred+residual

data.frame(f1=f1, x=round(x, 2), E.y=round(lin.pred, 2), y=round(y, 2))

# Plot the data:
par(mfrow=(c(1, 2)))
hist(y, col="lightgreen", freq=FALSE)
lines(density(y), col="darkred", lwd=2)

matplot(cbind(x[1:10], x[11:20], x[21:30]), cbind(y[1:10], y[11:20], y[21:30]), ylim=c(0, max(y)), ylab="y", xlab="x", col=c("red", "green", "blue"), pch=c("A", "B", "C"), las=1, cex=1.2)
par(mfrow=(c(1, 1)))


# Analysis using R
summary(lm(y~groups*x))

# Compare with the true values:
beta.vec
sigma


# Analysis using WinBUGS (and a cautionary tale about the importance of covariate standardization)

# Define model
cat("model {
    # Priors
    for (i in 1:n.group) {
    alpha[i]~dnorm(0, 0.001) # Intercepts
    beta[i]~dnorm(0, 0.001) # Slopes
    }
    sigma~dunif(0, 100)			# Residual standard deviation
    tau <- 1/(sigma*sigma)
    # Likelihood
    for (i in 1:n) {
    mu[i] <- alpha[groups[i]]+beta[groups[i]]*x[i]
    y[i]~dnorm(mu[i], tau)
    }
    # Derived quantities
    # Define effects relative to baseline level
    a.effe2 <- alpha[2]-alpha[1] # Intercept B vs. A
    a.effe3 <- alpha[3]-alpha[1] # Intercept C vs. A
    b.effe2 <- beta[2]-beta[1] # Slope B vs. A
    b.effe3 <- beta[3]-beta[1] # Slope C vs. A
    # Custom tests
    test1 <- beta[3]-beta[2] # Slope C vs. B
    }", fill=TRUE, file="lm.txt")

# Bundle data
win.data <- list(y=as.numeric(y), groups=as.numeric(groups), x=x, n.group=max(as.numeric(groups)), n=n)

# Inits function
inits <- function() {
  list(alpha=rnorm(n.groups, 0, 2), beta=rnorm(n.groups, 1, 1), sigma=rlnorm(1))
}

# Parameters to estimate
params <- c("alpha", "beta", "sigma", "a.effe2", "a.effe3", "b.effe2", "b.effe3", "test1")

# MCMC settings
ni <- 5500; nb <- 500; nt <- 10; nc <- 3

# Start Markov chains
library("R2WinBUGS")
out <- bugs(win.data, inits, params, "lm.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

print(out, dig=3)			# Bayesian analysis

# Compare Bayesian estimates, ML estimates and the true values
print(out$mean, dig=3)
summary(lm(y~groups*x))	  # The ML solution
beta.vec; sigma           # Truth

# WHAT? The Bayesian estimates are really off -- although the chains seem to have converged (see Rhat values)! And this is a fairly simple model ...

# This is the reason for the following warning in the WinBUGS User Manual:
# Beware: MCMC sampling can be dangerous!

# Imagine you have to decide whether to approve a drug (that could be widely used) based on the above MCMC simulation.
# But we're lucky -- we're only playing with linguistic corpora and experiments here.

# This example illustrates how useful it is to check the consistency of one�s inference from WinBUGS with other sources:
# -- estimates from a simpler, but similar model run in WinBUGS
# -- maximum likelihood estimates from another software
# -- plots of the estimated regression lines into the observed data to check whether something is wrong

matplot(cbind(x[1:10], x[11:20], x[21:30]), cbind(y[1:10], y[11:20], y[21:30]), ylim=c(0, max(y)), ylab="y", xlab="x", col = c("red", "green", "blue"), pch = c("A", "B", "C"), las=1, cex=1.2)

(alphas <- out$mean$alpha)
(betas <- out$mean$beta)
abline(alphas[1], betas[1], col="red", lty=3, lwd=2)
abline(alphas[2], betas[2], col="green", lty=3, lwd=2)
abline(alphas[3], betas[3], col="blue", lty=3, lwd=2)

(lm.coefs <- lm(y~groups*x)$coef)
abline(lm.coefs[1], lm.coefs[4], col="red", lty=1, lwd=1)
abline(lm.coefs[1]+lm.coefs[2], lm.coefs[4]+lm.coefs[5], col="green", lty=1, lwd=1)
abline(lm.coefs[1]+lm.coefs[3], lm.coefs[4]+lm.coefs[6], col="blue", lty=1, lwd=1)


# The problem: lack of standardization of the covariate length.
# -- in WinBUGS, it is always advantageous to scale covariates so that their extremes are not too far away from zero
# -- otherwise, there may be nonconvergence


# JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="lm.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)

print(outj, dig=3)

# Compare with the MLEs and true values
print(outj$BUGSoutput$mean, dig=4)
summary(lm(y~groups*x))	  # The ML solution
beta.vec; sigma           # Truth


# Let's keep the data the same, but increase the burnin significantly
# MCMC settings
ni <- 100000; nb <- 90000; nt <- 5; nc <- 3

# Start Markov chains
library("R2WinBUGS")
out.bis <- bugs(win.data, inits, params, "lm.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

print(out.bis, dig=3)			# Bayesian analysis

# Compare Bayesian estimates, ML estimates and the true values
print(out.bis$mean, dig=3)
summary(lm(y~groups*x))	  # The ML solution
beta.vec; sigma           # Truth


library("R2jags")
outj.bis <- jags(win.data, inits=inits, parameters.to.save=params, model.file="lm.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj.bis)
print(outj.bis, dig=3)

# Compare with the MLEs and true values
print(outj.bis$BUGSoutput$mean, dig=4)
summary(lm(y~groups*x))	  # The ML solution
beta.vec; sigma           # Truth

# No significant change!


# New data for WinBUGS with standardized covariate x:
win.data2 <- list(y=as.numeric(y), groups=as.numeric(groups), x=as.numeric(scale(x)), n.group=max(as.numeric(groups)), n=n)

ni <- 1200; nb <- 200; nt <- 2; nc <- 3

# Start Markov chains
library("R2WinBUGS")
out2 <- bugs(win.data2, inits, params, "lm.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

# Inspect results and compare with MLEs (much better)
print(out2$mean, dig=3)
print(lm(y~groups*as.numeric(scale(x)))$coef, dig=4)


library("R2jags")
outj2 <- jags(win.data2, inits=inits, parameters.to.save=params, model.file="lm.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj2)

# Compare with the MLEs and true values
print(outj2$BUGSoutput$mean, dig=4)
print(lm(y~groups*as.numeric(scale(x)))$coef, dig=4)


# We should always consider transforming all covariates for WinBUGS even if that slightly complicates presentation of results afterwards (for instance, in graphics).

# Transforming:
# 1. centering, i.e., subtracting the mean, which changes the intercept only (not the slope)
scale(x, scale=FALSE)

# 2. normalizing / standardizing, i.e., subtracting the mean and dividing the result by the standard deviation of the original covariate values
scale(x)


# Simply centering the data also works for the above ANCOVA example:

# -- new data for WinBUGS with centered covariate x
win.data3 <- list(y=as.numeric(y), groups=as.numeric(groups), x=as.numeric(scale(x, scale=FALSE)), n.group=max(as.numeric(groups)), n=n)

# -- start Markov chains
library("R2WinBUGS")
out3 <- bugs(win.data3, inits, params, "lm.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

# -- inspect results and compare with MLEs
print(out3$mean, dig=3)
print(lm(y~groups*as.numeric(scale(x, scale=FALSE)))$coef, dig=3)


library("R2jags")
outj3 <- jags(win.data3, inits=inits, parameters.to.save=params, model.file="lm.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj3)

print(outj3$BUGSoutput$mean, dig=3)
print(lm(y~groups*as.numeric(scale(x, scale=FALSE)))$coef, dig=3)




# Linear mixed-effects models

# Mixed-effects or mixed models contain factors, or more generally covariates, with both fixed and random effects.

# The dataset and model we consider are a generalization of the ANCOVA model we just discussed:
# -- we now constrain the values for at least one set of effects (intercepts and/or slopes) to come from a normal distribution
# -- this is what the random-effects assumption means (usually; in general, the random effects can come from any distribution)

# There are at least three sets of assumptions that one may make about the random effects for the intercept and/or the slope of regression lines that are fitted to grouped data:

## 1. only intercepts are random, but slopes are identical for all groups

## 2. both intercepts and slopes are random, but they are independent

## 3. both intercepts and slopes are random and there is a correlation between them

## (an additional case, where slopes are random and intercepts are fixed, is not a sensible model in most circumstances)


# Model No. 1 is often called a random-intercepts model.
# Both models No. 2 and 3 are called random-coefficients models.
# Model No. 3 is the default in R�s function lmer() in package lme4 when fitting a random-coefficients model.


# The plan:
# -- first, we generate a random-coefficients dataset under model No. 2, where both intercepts and slopes are uncorrelated random effects; we then fit both a random-intercepts (No. 1) and a random-coefficients model without correlation (No. 2) to this dataset

# -- next, we generate a second data set that includes a correlation between random intercepts and random slopes and adopt the random-coefficients model with correlation between intercepts and slopes (No. 3) to analyze it


# A close examination of how such a dataset can be assembled (i.e., simulated) will help us better understand how analogous datasets are broken down (i.e., analyzed) using mixed models.
# -- as Kery (2010) puts it: very few strategies can be more effective to understand this type of mixed model than the combination of simulating data sets and describing the models fitted in WinBUGS syntax 



# Data generation

# The factor for groups:
n.groups <- 56				# Number of groups
n.sample <- 10				# Number of observations in each group
(n <- n.groups*n.sample) 		# Total number of data points
(groups <- gl(n=n.groups, k=n.sample)) 	# Indicator for population


# Continuous predictor x
original.x <- runif(n, 45, 70)
summary(original.x)

# We standardize it
x <- scale(original.x)
round(x, 2)

(mn <- mean(original.x))
(st.dev <- sd(original.x))
x <- (original.x - mn)/st.dev
round(x, 2)

hist(x, col="lightgreen", freq=FALSE)
lines(density(x), col="darkred", lwd=2)


# This is the model matrix for the means parametrization of the interaction model between the groups and the continuous covariate x:

Xmat <- model.matrix(~groups*x-1-x)
dim(Xmat) 

# Q: where do these dimensions come from?

head(Xmat)

# -- there are 560 observations (rows) and 112 regression terms / variables (columns)
dimnames(Xmat)[[1]]
dimnames(Xmat)[[2]]

# -- there are 56 terms for groups, the coefficients of which will provide the group-specific intercepts (i.e., the intercept random effects, or intercept effects for short)
# -- there are 56 terms for interactions between each group and the continuous covariate x, the coefficients of which will provide the group-specific slopes (i.e., the slope random effects, or slope effects for short)

round(Xmat[1, ], 2) 		# Print the top row for each column
Xmat[, 1]               # Print all rows for column 1 (group 1)
round(Xmat[, 57], 2)    # Print all rows for column 57 (group 1:x)


# Parameters for the distributions of the random coefficients / random effects (note that the intercepts and slopes comes from two independent Gaussian distributions):

intercept.mean <- 230 # mu_alpha
intercept.sd <- 20 # sigma_alpha

slope.mean <- 60 # mu_beta
slope.sd <- 30 # sigma_beta


# Generate the random coefficients:

intercept.effects <- rnorm(n=n.groups, mean=intercept.mean, sd=intercept.sd)

par(mfrow=c(1, 2))
hist(intercept.effects, col="lightgreen", freq=FALSE)
lines(density(intercept.effects), col="darkred", lwd=2)

slope.effects <- rnorm(n=n.groups, mean=slope.mean, sd=slope.sd)

hist(slope.effects, col="lightgreen", freq=FALSE)
lines(density(slope.effects), col="darkred", lwd=2)
par(mfrow=c(1, 1))

all.effects <- c(intercept.effects, slope.effects) # Put them all together
round(all.effects, 2)

# -- thus, we have two stochastic components in our model IN ADDITION TO the usual stochastic component for the individual-level responses, to which we now turn


# Generating the continuous response variable:

# -- the deterministic part
lin.pred <- Xmat %*% all.effects # Value of lin.predictor
str(lin.pred)

# -- the stochastic part
sigma <- 30
normal.error <- rnorm(n=n, mean=0, sd=sigma) # residuals 
str(normal.error)

# -- put the two together
y <- lin.pred+normal.error
str(y)
# or, alternatively
y <- rnorm(n=n, mean=lin.pred, sd=sigma)
str(y)

# We take a look at the response variable
hist(y, col="lightgreen", freq=FALSE)
lines(density(y), col="darkred", lwd=2)
summary(y)

library("lattice")
xyplot(y~x|groups)



# Analysis under a random-intercepts model

# REML analysis using R

library("lme4")

lme.fit1 <- lmer(y~x+(1|groups))

print(lme.fit1, cor=FALSE)

fixef(lme.fit1)
ranef(lme.fit1)
coef(lme.fit1)

# Compare with true values:
data.frame(intercept.mean=intercept.mean, slope.mean=slope.mean, intercept.sd=intercept.sd, slope.sd=slope.sd, sigma=sigma)
print(lme.fit1, cor=FALSE)

# Bayesian analysis using WinBUGS

# Write model
cat("model {
    # Priors
    mu.int~dnorm(0, 0.0001) # Mean hyperparameter for random intercepts
    sigma.int~dunif(0, 100) # SD hyperparameter for random intercepts
    tau.int <- 1/(sigma.int*sigma.int)
    for (i in 1:ngroups) {
    alpha[i]~dnorm(mu.int, tau.int) # Random intercepts
    }
    beta~dnorm(0, 0.0001) # Common slope
    sigma~dunif(0, 100) # Residual standard deviation
    tau <- 1/(sigma*sigma)
    # Likelihood
    for (i in 1:n) {
    mu[i] <- alpha[groups[i]]+beta*x[i] # Expectation
    y[i]~dnorm(mu[i], tau) # The actual (random) responses
    }
    }", fill=TRUE, file="lme.model1.txt")

# Bundle data
win.data <- list(y=as.numeric(y), groups=as.numeric(groups), x=as.numeric(x), ngroups=max(as.numeric(groups)), n=as.numeric(n))
# use as.numeric across the board for the data passed to WinBUGS; omitting this can yield an "expected collection operator c" error ...

# Inits function
inits <- function() {
  list(alpha=rnorm(n.groups, 0, 2), beta=rnorm(1, 1, 1), mu.int=rnorm(1, 0, 1), sigma.int=rlnorm(1), sigma=rlnorm(1))
}

# Parameters to estimate
params <- c("alpha", "beta", "mu.int", "sigma.int", "sigma")

# MCMC settings
ni <- 11000; nb <- 1000; nt <- 20; nc <- 3

# Start Gibbs sampling
library("R2WinBUGS")
out <- bugs(win.data, inits, params, "lme.model1.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

# Inspect results
print(out, dig=3)

# Compare with true values and MLEs:
data.frame(intercept.mean=intercept.mean, slope.mean=slope.mean, intercept.sd=intercept.sd, slope.sd=slope.sd, sigma=sigma)
print(out$mean, dig=3)
print(lme.fit1, cor=FALSE)


# JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="lme.model1.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)
print(outj, dig=3)

# Compare with MLEs and true values
print(outj$BUGSoutput$mean, dig=4)
print(lme.fit1, cor=FALSE)
data.frame(intercept.mean=intercept.mean, slope.mean=slope.mean, intercept.sd=intercept.sd, slope.sd=slope.sd, sigma=sigma)




# Analysis under a random-coefficients model without correlation between intercept and slope

# REML analysis using R
library("lme4")
(lme.fit2 <- lmer(y~x+(1|groups)+(0+x|groups)))
fixef(lme.fit2)
ranef(lme.fit2)
coef(lme.fit2)


# Compare with true values:
data.frame(intercept.mean=intercept.mean, slope.mean=slope.mean, intercept.sd=intercept.sd, slope.sd=slope.sd, sigma=sigma)
print(lme.fit2, cor=FALSE)


# Bayesian analysis using WinBUGS
# Define model
cat("model {
    # Priors
    mu.int~dnorm(0, 0.001) # Mean hyperparameter for random intercepts
    sigma.int~dunif(0, 100) # SD hyperparameter for random intercepts
    tau.int <- 1/(sigma.int*sigma.int)
    mu.slope~dnorm(0, 0.001) # Mean hyperparameter for random slopes
    sigma.slope~dunif(0, 100) # SD hyperparameter for slopes
    tau.slope <- 1/(sigma.slope*sigma.slope)
    for (i in 1:ngroups) {
    alpha[i]~dnorm(mu.int, tau.int) # Random intercepts
    beta[i]~dnorm(mu.slope, tau.slope) # Random slopes
    }
    sigma~dunif(0, 100) # Residual standard deviation
    tau <- 1/(sigma*sigma) # Residual precision
    # Likelihood
    for (i in 1:n) {
    mu[i] <- alpha[groups[i]]+beta[groups[i]]*x[i]
    y[i]~dnorm(mu[i], tau)    
    }
    }", fill=TRUE, file="lme.model2.txt")

# Bundle data
win.data <- list(y=as.numeric(y), groups=as.numeric(groups), x=as.numeric(x), ngroups=max(as.numeric(groups)), n=as.numeric(n))

# Inits function
inits <- function() {
  list(alpha=rnorm(n.groups, 0, 2), beta=rnorm(n.groups, 10, 2), mu.int=rnorm(1, 0, 1), sigma.int=rlnorm(1), mu.slope=rnorm(1, 0, 1), sigma.slope=rlnorm(1), sigma=rlnorm(1))
}

# Parameters to estimate
params <- c("alpha", "beta", "mu.int", "sigma.int", "mu.slope", "sigma.slope", "sigma")

# MCMC settings
ni <- 11000; nb <- 1000; nt <- 10; nc <- 3

# Start Gibbs sampling
library("R2WinBUGS")
out <- bugs(win.data, inits, params, "lme.model2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

print(out, dig=2)

# Compare with true values and MLEs:
data.frame(intercept.mean=intercept.mean, slope.mean=slope.mean, intercept.sd=intercept.sd, slope.sd=slope.sd, sigma=sigma)
print(out$mean, dig=2)
print(lme.fit2, cor=FALSE)

# Using simulated data and successfully recovering the input values makes us fairly confident that the WinBUGS analysis has been correctly specified.

# This is very helpful for more complex models b/c it's easy to make mistakes:
# -- a good way to check the WinBUGS analysis for a custom model that is needed for a particular phenomenon is to simulate the data and run the WinBUGS model on that data


# JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="lme.model2.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)
print(outj, dig=3)

# Compare with MLEs and true values
print(outj$BUGSoutput$mean, dig=4)
print(lme.fit2, cor=FALSE)
data.frame(intercept.mean=intercept.mean, slope.mean=slope.mean, intercept.sd=intercept.sd, slope.sd=slope.sd, sigma=sigma)



# The random-coefficients model with correlation between intercept and slope

# Data generation

# Group factor:
n.groups <- 56
n.sample <- 10
(n <- n.groups*n.sample)
(groups <- gl(n=n.groups, k=n.sample))

# Standardized continuous covariate:
original.x <- runif(n, 45, 70)
x <- scale(original.x)

hist(x, col="lightgreen", freq=FALSE)
lines(density(x), col="darkred", lwd=2)

# Design matrix:
Xmat <- model.matrix(~groups*x-1-x)

# -- there are 560 observations (rows) and 112 regression terms / variables (columns), just as before
dimnames(Xmat)[[1]]
dimnames(Xmat)[[2]]

round(Xmat[1, ], 2) # Print the top row for each column

# Generate the correlated random effects for intercept and slope:

library("MASS") # Load MASS
?mvrnorm

# Assembling the parameters for the multivariate normal distribution

intercept.mean <- 230 # Values for five hyperparameters
intercept.sd <- 20
slope.mean <- 60
slope.sd <- 30
intercept.slope.covariance <- 10

(mu.vector <- c(intercept.mean, slope.mean))
(var.covar.matrix <- matrix(c(intercept.sd^2, intercept.slope.covariance, intercept.slope.covariance, slope.sd^2), 2, 2))

# Generating the correlated random effects for intercepts and slopes:

effects <- mvrnorm(n=n.groups, mu=mu.vector, Sigma=var.covar.matrix)
round(effects, 2)

par(mfrow=c(1, 2))
hist(effects[, 1], col="lightgreen", freq=FALSE)
lines(density(effects[, 1]), col="darkred", lwd=2)

hist(effects[, 2], col="lightgreen", freq=FALSE)
lines(density(effects[, 2]), col="darkred", lwd=2)
par(mfrow=c(1, 1))

# Plotting the bivariate distribution:
effects.kde <- kde2d(effects[, 1], effects[, 2], n=50) # kernel density estimate
par(mfrow=c(1, 3))
contour(effects.kde)
image(effects.kde)
persp(effects.kde, phi=45, theta=30)

# even better:
par(mfrow=c(1, 2))
image(effects.kde); contour(effects.kde, add=T)
persp(effects.kde, phi=45, theta=-30, shade=.1, border=NULL, col="lightblue", ticktype="detailed", xlab="", ylab="", zlab="")
par(mfrow=c(1, 1))

apply(effects, 2, mean)
apply(effects, 2, sd)
apply(effects, 2, var)
cov(effects[, 1], effects[, 2])
var(effects)


# Sampling error for intercept-slope covariance (200 samples of 50, 500, 5000 and 50000 group/random effects each)

par(mfrow=c(1, 4))
cov.temp1 <- numeric()
for (i in 1:200) {
  temp1 <- mvrnorm(50, mu=mu.vector, Sigma=var.covar.matrix)
  cov.temp1[i] <- var(temp1)[1, 2]    
}
hist(cov.temp1, col="lightgreen", freq=FALSE, main="n=50")
lines(density(cov.temp1), col="darkred", lwd=2)

cov.temp2 <- numeric()
for (i in 1:200) {
  temp2 <- mvrnorm(500, mu=mu.vector, Sigma=var.covar.matrix)
  cov.temp2[i] <- var(temp2)[1, 2]    
}
hist(cov.temp2, col="lightgreen", freq=FALSE, main="n=500")
lines(density(cov.temp2), col="darkred", lwd=2)

cov.temp3 <- numeric()
for (i in 1:200) {
  temp3 <- mvrnorm(5000, mu=mu.vector, Sigma=var.covar.matrix)
  cov.temp3[i] <- var(temp3)[1, 2]    
}
hist(cov.temp3, col="lightgreen", freq=FALSE, main="n=5000")
lines(density(cov.temp3), col="darkred", lwd=2)

cov.temp4 <- numeric()
for (i in 1:200) {
  temp4 <- mvrnorm(50000, mu=mu.vector, Sigma=var.covar.matrix)
  cov.temp4[i] <- var(temp4)[1, 2]    
}
hist(cov.temp4, col="lightgreen", freq=FALSE, main="n=50000")
lines(density(cov.temp4), col="darkred", lwd=2)
par(mfrow=c(1, 1))


intercept.effects <- effects[, 1]
round(intercept.effects, 2)
slope.effects <- effects[, 2]
round(slope.effects, 2)
all.effects <- c(intercept.effects, slope.effects) # Put them all together
round(all.effects, 2)


# Generate the response variable:
# -- the deterministic part
lin.pred <- Xmat %*% all.effects
round(as.vector(lin.pred), 2)

# -- the stochastic part
sigma <- 30
(normal.error <- rnorm(n=n, mean=0, sd=sigma))	# residuals

# -- add them together
y <- lin.pred+normal.error
# or, in one go:
y <- rnorm(n=n, mean=lin.pred, sd=sigma)

hist(y, col="lightgreen", freq=FALSE, breaks=15)
lines(density(y), col="darkred", lwd=2)

library("lattice")
xyplot(y~x|groups, pch=20)


# REML analysis using R
library("lme4")
lme.fit3 <- lmer(y~x+(x|groups))
print(lme.fit3, cor=FALSE)

# Compare with the true values:
data.frame(intercept.mean=intercept.mean, slope.mean=slope.mean, intercept.sd=intercept.sd, slope.sd=slope.sd, intercept.slope.correlation=intercept.slope.covariance/(intercept.sd*slope.sd) , sigma=sigma)  



# Bayesian analysis using WinBUGS

# This is one way in which we can specify a Bayesian analysis of the random-coefficients model with correlation.
# For a different and more general way to allow for correlation among two or more sets of random effects in a model, see Gelman and Hill (2007: 376-377).

# Define model
cat("model {
    # Priors
    mu.int~dnorm(0, 0.0001) # mean for random intercepts
    mu.slope~dnorm(0, 0.0001) # mean for random slopes
    sigma.int~dunif(0, 100) # SD of intercepts
    sigma.slope~dunif(0, 100) # SD of slopes
    rho~dunif(-1, 1) # correlation between intercepts and slopes
    Sigma.B[1, 1] <- pow(sigma.int, 2) # We start assembling the var-covar matrix for the random effects
    Sigma.B[2, 2] <- pow(sigma.slope, 2)
    Sigma.B[1, 2] <- rho*sigma.int*sigma.slope
    Sigma.B[2, 1] <- Sigma.B[1, 2]
    covariance <- Sigma.B[1, 2]
    Tau.B[1:2, 1:2] <- inverse(Sigma.B[,])
    for (i in 1:ngroups) {
    B.hat[i, 1] <- mu.int
    B.hat[i, 2] <- mu.slope
    B[i, 1:2]~dmnorm(B.hat[i, ], Tau.B[,]) # the pairs of correlated random effects
    alpha[i] <- B[i, 1] # random intercept
    beta[i] <- B[i, 2] # random slope
    }
    sigma~dunif(0, 100) # Residual standard deviation
    tau <- 1/(sigma*sigma)
    # Likelihood
    for (i in 1:n) {
    mu[i] <- alpha[groups[i]]+beta[groups[i]]*x[i]
    y[i]~dnorm(mu[i], tau)
    }
    }", fill=TRUE, file="lme.model3.txt")

# Bundle data
win.data <- list(y=as.numeric(y), groups=as.numeric(groups), x=as.numeric(x), ngroups=max(as.numeric(groups)), n=as.numeric(n))

# Inits function
inits <- function() {
  list(mu.int=rnorm(1, 0, 1), sigma.int=rlnorm(1), mu.slope=rnorm(1, 0, 1), sigma.slope=rlnorm(1), rho=runif(1, -1, 1), sigma=rlnorm(1))
}

# Parameters to estimate
params <- c("alpha", "beta", "mu.int", "sigma.int", "mu.slope", "sigma.slope", "rho", "covariance", "sigma")

# MCMC settings
ni <- 3200; nb <- 200; nt <- 6; nc <- 3 # more than this needed for a good approx. of the posterior distribution, but takes too long for a demo

# Start Gibbs sampler
library("R2WinBUGS")
out <- bugs(win.data, inits, params, "lme.model3.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

print(out, dig=2)

# Compare with the MLEs and the true values:
print(out$mean, dig=2)
print(lme.fit3, cor=FALSE)
data.frame(intercept.mean=intercept.mean, slope.mean=slope.mean, intercept.sd=intercept.sd, slope.sd=slope.sd, intercept.slope.correlation=intercept.slope.covariance/(intercept.sd*slope.sd) , sigma=sigma)

# Note the very large SD for the posterior distribution of the covariance (relative to the mean):
print(out$mean$covariance, dig=2)
print(out$sd$covariance, dig=2)

print(out$mean$rho, dig=2)
print(out$sd$rho, dig=2)


# -- R does not even provide an SE for the covariance estimator (equivalently, for the correlation of random effects)
# -- covariances are even harder to reliably estimate than variances, which are harder than mean estimators (it's easy to estimate measures of center / location, harder to estimate measures of dispersion and even harder to estimate measures of association)



# JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="lme.model3.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)

ni <- 25000; nb <- 5000; nt <- 40; nc <- 3

outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="lme.model3.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)

print(outj, dig=3)

# Compare with MLEs and true values
print(outj$BUGSoutput$mean, dig=4)
print(lme.fit3, cor=FALSE)
data.frame(intercept.mean=intercept.mean, slope.mean=slope.mean, intercept.sd=intercept.sd, slope.sd=slope.sd, intercept.slope.correlation=intercept.slope.covariance/(intercept.sd*slope.sd) , sigma=sigma)






#Contents:
# -- Generalized linear models
# -- Poisson "t-test" (simulated data, R analysis, WinBUGS / JAGS analysis)
# -- Binomial "t-test" (simulated data, R analysis, WinBUGS / JAGS analysis)
# -- Binomial ANCOVA (simulated data, R analysis, WinBUGS / JAGS analysis)
# -- Binomial GLMM (simulated data, R analysis, WinBUGS / JAGS analysis)



# GLM INTRO: Poisson "t-test"

# A GLM is described by the following three components:

# 1. a statistical distribution, used to describe the random variation in the response y; this is the stochastic part of the system description
# 2. a link function g, that is applied to the expectation of the response E(y); result: g(E(y))
# 3. a linear predictor, which is a linear combination of covariate effects that are thought to make up g(E(y)); this is the systematic or deterministic part of the model


# -- g is a link function b/c it links the random and deterministic parts of the model


# Binomial, Poisson and normal are probably the three most widely used statistical distributions in a GLM.
# The three most widely used link functions are the identity, logit=log(odds)=log(x/(1-x)) and the log.


# The plan from now on: go through a progression from simple to more complex models for Poisson and binomial responses (mostly binomial).


# Just as we did for normal linear models, we begin again with what might be called a "Poisson t-test", in the sense that it consists of a comparison of two groups.

# The inferential situation considered: counts (C) of wide-scope indefinites in a sample of (parts of) 10 short stories (written fiction) and 10 short dialogues (spoken text transcriptions).

# The length of the written and spoken chunks (as measured by word counts) is more or less the same.
# Goal: determine whether the usage of wide scope indefinites depends on register (written fiction vs. spoken dialogue).

# The typical distribution assumed for such counts is a Poisson, which applies when counted things are distributed independently and randomly (and the sampled intervals / texts are of equal size).
# -- then, the number C of wide scope indefinites per corpus sample will be described by a Poisson
# -- the Poisson has a single parameter, the expected count lambda, often called the intensity or rate, which represents the mean density of wide scope indefinites per text sample
# -- in contrast to the normal, the Poisson variance is not a free parameter but is equal to the mean lambda
# -- for a Poisson-distributed random variable C, we write C~Poisson(lambda)


# Detectability: whenever we interpret lambda as the mean density of wide scope indefinites, we make the implicit assumption that every single wide scope indefinite has indeed been identified, i.e., that detection probability p is equal to 1 -- or that the proportion of indefinites overlooked per sampling unit is, on average, the same for both registers.

# This is fairly uncontroversial in this case -- but imagine that you are counting certain types of rhetorical relations or aspectual coercion or type shifting or anaphora (or some kind of syntactic boundary, e.g., "small clause" boundaries). These are much harder to unambiguously identify and the assumption of perfect detectability is called into question.

# The distinction between the imperfectly observed true state and the observed data (as reflected by inter-annotator disagreements) can be explicitly modeled.
# -- we will introduce one type of model for this later on
# -- the use of WinBUGS will be crucial since it is much harder to find a canned routine / software package that implements the relevant frequentist estimation procedures


# Data generation
n.texts <- 10
(f1 <- gl(n=2, k=n.texts, labels=c("written", "spoken")))
as.numeric(f1) # f1 has levels 1 and 2, not 0 and 1
(n <- 2*n.texts)

# The deterministic part of the model together with the link function:
lambda <- exp(0.69+0.92*(as.numeric(f1)-1))

#Q: what does the formula above do exactly?

round(lambda, 2)

# Add the stochastic part (i.e., add Poisson noise):
(C <- rpois(n=n, lambda=lambda))

# The observed means:
aggregate(C, by=list(f1), FUN=mean)
boxplot(C~f1, col="lightgreen", xlab="Register (written vs spoken)", ylab="Wide-scope indefinite count", las = 1)


# Analysis using R

poisson.t.test <- glm(C~f1, family=poisson)
print(summary(poisson.t.test), dig=2)

# Compare with true values:
data.frame(alpha=0.69, beta=0.92)

# Likelihood ratio test (LRT):
anova(poisson.t.test, test="Chi")


# Analysis using WinBUGS

# Define model
cat("model {                            
    # Priors
    alpha~dnorm(0,0.0001)
    beta~dnorm(0,0.0001)
    # Likelihood
    for (i in 1:n) {
    log(lambda[i]) <- alpha+beta*f1[i]
    C[i]~dpois(lambda[i])
    # Fit assessments
    P.res[i] <- (C[i]-lambda[i])/sqrt(lambda[i]) # Pearson residuals
    C.new[i]~dpois(lambda[i]) # Replicate data set
    P.res.new[i] <- (C.new[i]-lambda[i])/sqrt(lambda[i]) # Pearson res. for replicated data set
    D[i] <- pow(P.res[i], 2)
    D.new[i] <- pow(P.res.new[i], 2)
    }
    # Add up discrepancy measures
    fit <- sum(D[])
    fit.new <- sum(D.new[])
    }", fill=TRUE, file="Poisson.t.test.txt")


# Bundle data
win.data <- list(C=as.numeric(C), f1=as.numeric(f1)-1, n=length(f1))

# Inits function
inits <- function() {
  list(alpha=rlnorm(1), beta=rlnorm(1))
}

# Parameters to estimate
params <- c("lambda","alpha", "beta", "P.res", "fit", "fit.new")

# MCMC settings
nc <- 3; ni <- 3000; nb <- 1000; nt <- 2

# Start Gibbs sampler
library("R2WinBUGS")
out <- bugs(data=win.data, inits=inits, parameters.to.save=params, model.file="Poisson.t.test.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, DIC=TRUE, clearWD=TRUE)

print(out, dig=3)

# Compare estimates with true values and MLEs (all close enough given the small sample size -- n=20):
print(out$mean, dig=3)
data.frame(alpha=0.69, beta=0.92)
summary(poisson.t.test)



# JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="Poisson.t.test.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)

print(outj, dig=3)

# Compare with MLEs and true values
print(outj$BUGSoutput$mean, dig=4)
data.frame(alpha=0.69, beta=0.92)
summary(poisson.t.test)



# The first two things to do before even looking at the estimates of a model fitted using MCMC should really be to check:
# -- that the Markov chains have converged 
# -- that the fitted model is adequate for the data set

# We'll do both here as an example and usually dispense with it later on.

# Check MCMC convergence:

# The Brooks-Gelman-Rubin statistic, which R2WinBUGS calls Rhat, is about 1 at convergence, with 1.1 often taken an acceptable threshold.

print(out, dig=3)
which(out$summary[, 8]>1.1)		# which value in the 8th column is > 1.1 ?                                  
hist(out$summary[, 8], col="lightgreen", main="Rhat values")

# Check model adequacy

# Residuals

# -- for GLMs other than the normal linear model, the variability of the response depends on the mean response
# -- to get residuals with approximately constant variance, Pearson residuals are often computed (obtained by dividing the raw residuals by the standard deviation)

plot(out$mean$P.res, las=1, col="blue", pch=20)
abline(h=0)

# Posterior predictive check

plot(out$sims.list$fit, out$sims.list$fit.new, main="Posterior predictive check \nfor sum of squared Pearson residuals", xlab="Discrepancy measure for actual data set", ylab="Discrepancy measure for perfect data sets", col="blue")
abline(0, 1, lwd=2, col = "black")
# -- if the model fits the data, then about half of the points should lie above and half below a 1:1 line

mean(out$sims.list$fit.new>out$sims.list$fit)
# -- a fitting model has a Bayesian p-value near 0.5 and values close to 0 or close to 1 suggest doubtful fit of the model


# Inference under the model

# Is there a difference in wide-scope indefinite density according to register?

# -- we look at the mean and SD of the posterior distribution of the coefficient for "spoken" (i.e., beta)

print(out$mean$beta)
print(out$sd$beta)
# -- compare with the MLEs:
summary(poisson.t.test)$coef[2, ]

# -- we can also look at the entire posterior distribution of the coefficient for "spoken" (i.e., beta)

hist(out$sims.list$beta, col="lightgreen", las=1, xlab="Coefficient for spoken", main="", freq=FALSE, breaks=20)
lines(density(out$sims.list$beta), col="darkred", lwd=2)
abline(v=out$mean$beta, col="red", lwd=2)

# -- the posterior distribution does not overlap zero (it actually could, depending on the particular simulated data we have), so spoken texts really seem to have a different density of wide-scope indefinites than written texts

# -- the same conclusion is arrived at when looking at the 95% credible interval of beta (or not: depending on the simulated data, 0 might be in this interval)
print(out$summary, dig=3)
out$summary[22, c(3, 7)]
abline(v=out$summary[22, 3], col="darkred", lwd=2, lty=2)
abline(v=out$summary[22, 7], col="darkred", lwd=2, lty=2)

# -- compare with the quick and dirty interval obtained by +/- 2*SD:                  
abline(v=out$mean$beta-2*out$sd$beta, col="blue", lwd=2, lty=2)
abline(v=out$mean$beta+2*out$sd$beta, col="blue", lwd=2, lty=2)


# Finally, we form predictions for presentation.
# -- predictions are the expected values of the response under certain conditions, such as for particular covariate values
# -- in a Bayesian analysis, forming predictions is easy: predictions are just another form of unobservables, such as parameters or missing values -- and we can base inference about predictions on their posterior distributions


# Thus, to summarize what we have learned about the differences between spoken and written texts with respect to wide-scope indefinites, we plot the posterior distributions of the expected counts for both registers:
# -- we obtain the expected counts by exponentiating alpha and alpha+beta, respectively

par(mfrow = c(2,1))
hist(exp(out$sims.list$alpha), main="Written texts", col="lightgreen", xlab="Expected wide-scope indefinite count", xlim = c(0,10), breaks=20, freq=FALSE)
lines(density(exp(out$sims.list$alpha)), col="darkred", lwd=2)
hist(exp(out$sims.list$alpha+out$sims.list$beta), main="Spoken texts", col="lightgreen", xlab="Expected wide-scope indefinite count", xlim=c(0,10), breaks=20, freq=FALSE)
lines(density(exp(out$sims.list$alpha+out$sims.list$beta)), col="darkred", lwd=2)
par(mfrow = c(1,1))



# Binomial "t-test"


# We now turn to another common kind of count data, where we want to estimate a binomial proportion.
# -- associated models: logistic regressions

# The crucial difference between binomial and Poisson random variables is the presence of a ceiling in the former: binomial counts cannot be greater than some upper limit.
# -- we model bounded counts, where the bound is provided by trial size N
# -- we express a count relative to that bound -- i.e., a proportion
# -- in contrast, Poisson counts lack an upper limit, at least in principle

# Modeling a binomial random variable in essence means modeling a series of coin flips:
# -- we count the number of heads among the total number of coin flips (N)
# -- from this want to estimate the general tendency of the coin to show heads, i.e., P(heads)

# Data coming from coin flip-like processes are very common in  linguistics -- e.g., the proportion of wide-scope readings in a sample of 30 indefinites, the proportion of deontic readings in a sample of 50 modals etc.                   


# Suppose we are interested in the probability that "should" and "must" have a deontic (as opposed to non-deontic, i.e., epistemic or circumstantial) reading.

# We randomly select 50 occurrences of each from a particular register of COCA and record whether they have a deontic reading or not.
# -- suppose we find 13 occurrences of deontic "should" among those 50 and 29 occurrences of deontic "must"

# We wonder whether this is enough evidence, given the variation inherent in binomial sampling, to claim that deontic "should" is less frequent / has a more restricted distribution than deontic "must" (in the particular COCA register we selected)



# Data generation

N <- 50					      # Binomial total (Number of coin flips)

# Our modeled response simply consists of two numbers:
p.should <- 13/50			# Success probability deontic "should"
p.must <- 29/50				# Success probability deontic "must"

(C.should <- rbinom(1, 50, prob=p.should))    # Add Binomial noise
(C.must <- rbinom(1, 50, prob=p.must))    # Add Binomial noise
(C <- c(C.should, C.must))

(modals <- factor(c(0,1), labels=c("should","must")))


# Analysis using R
summary(glm(cbind(C, N-C)~modals, family=binomial))

# Compare true values and MLEs:
data.frame(p.should=p.should, p.must=p.must)
predict(glm(cbind(C, N-C)~modals, family=binomial), type="response")

(coefs <- coef(glm(cbind(C, N-C)~modals, family=binomial)))

(p.should.predicted <- exp(coefs[1])/(1+exp(coefs[1])))
(p.must.predicted <- exp(coefs[1]+coefs[2])/(1+exp(coefs[1]+coefs[2])))

(p.should.predicted <- 1/(1+exp(-coefs[1])))
(p.must.predicted <- 1/(1+exp(-(coefs[1]+coefs[2]))))




# Analysis using WinBUGS

# Define model
cat("model {
    # Priors
    alpha~dnorm(0, 0.0001)
    beta~dnorm(0, 0.0001)
    # Likelihood
    for (i in 1:n) {
    logit(p[i]) <- alpha+beta*modals[i]
    C[i]~dbin(p[i], N)    # Note p before N
    }
    # Derived quantities
    p.deontic.should <- exp(alpha) / (1 + exp(alpha))
    p.deontic.must <- exp(alpha + beta) / (1 + exp(alpha + beta))
    p.deontic.diff <- p.deontic.should-p.deontic.must
    }", fill=TRUE, file="Binomial.t.test.txt")

# Bundle data
win.data <- list(C=as.numeric(C), N=50, modals=c(0,1), n=length(C))

# Inits function
inits <- function() {
  list(alpha=rlnorm(1), beta=rlnorm(1))
}

# Parameters to estimate
params <- c("alpha", "beta", "p.deontic.should", "p.deontic.must", "p.deontic.diff")

# MCMC settings
nc <- 3; ni <- 4500; nb <- 500; nt <- 8

# Start Gibbs sampling
library("R2WinBUGS")
out <- bugs(data=win.data, inits=inits, parameters.to.save=params, model.file="Binomial.t.test.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, clearWD=TRUE)

print(out, dig=3)

# Compare with true values and MLEs:
print(out$mean, dig=3)
data.frame(p.should=p.should, p.must=p.must)
predict(glm(cbind(C, N-C)~modals, family=binomial), type="response")


# JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="Binomial.t.test.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)

print(outj, dig=3)

# Compare with MLEs and true values
print(outj$BUGSoutput$mean, dig=4)
data.frame(p.should=p.should, p.must=p.must)
predict(glm(cbind(C, N-C)~modals, family=binomial), type="response")



# We plot the posterior distribution of the distributions of deontic readings for the two modals -- and their difference.

par(mfrow=c(3, 1))
hist(out$sims.list$p.deontic.should, col="lightgreen", xlim=c(0,1), main="", xlab = "p(deontic|should)", breaks = 30, freq=FALSE)
lines(density(out$sims.list$p.deontic.should), col="darkred", lwd=2)
abline(v=out$mean$p.deontic.should, lwd=3, col="red")

hist(out$sims.list$p.deontic.must, col="lightgreen", xlim=c(0,1), main="", xlab="p(deontic|must)", breaks=30, freq=FALSE)
lines(density(out$sims.list$p.deontic.must), col="darkred", lwd=2)
abline(v=out$mean$p.deontic.must, lwd=3, col="red")

hist(out$sims.list$p.deontic.diff, col="lightgreen", xlim=c(-1,1), main="", xlab="difference in probability", breaks=30, freq=FALSE)
lines(density(out$sims.list$p.deontic.diff), col="darkred", lwd=2)                                       
abline(v=0, lwd=3, col="blue")
abline(v=out$summary[5, 3], lwd=2, col="blue", lty=3)
abline(v=out$summary[5, 7], lwd=2, col="blue", lty=3)
par(mfrow=c(1, 1))



# Binomial ANCOVA

# Suppose we want to determine the proportion of wide-scope indefinites:
# -- in 3 types of text registers A, B, C
# -- based on 10 samples of text from each of the 3 registers A, B and C
# -- as a function of the distance between the indefinite and the beginning of the sentece; the distance is measured in words


# Data generation
n.groups <- 3
n.sample <- 10
(n <- n.groups*n.sample)
(f1 <- rep(1:n.groups, rep(n.sample, n.groups)))
(groups <- factor(f1, labels=c("A", "B", "C")))

# Get discrete uniform values for the number of indefinites in each sample:
(N <- round(runif(n, 5, 20)))

# For each sample i, we have N[i] indefinites:
# -- for each of these indefinites, we should generate the position in the sentence: discrete uniform values between 0 and 20, for example
# -- we should store it in a vector for each of the registers A, B and C

# This will add up to as many measurements as there are indefinites:
sum(N)


# For simplicity, we assume that all the indefinites in a sample have the same position, so we generate only 10 measurements per register -- i.e., 30 measurements total

(indef.pos.A <- round(runif(n.sample, 0, 20)))
(indef.pos.B <- round(runif(n.sample, 0, 20)))
(indef.pos.C <- round(runif(n.sample, 0, 20)))
(indef.pos <- c(indef.pos.A, indef.pos.B, indef.pos.C))
(indef.pos <- scale(indef.pos))


Xmat <- model.matrix(~groups*indef.pos)
print(Xmat[1, ], dig=2)
str(Xmat) 
Xmat

beta.vec <- c(.3, 0.5, 0.6, -1, -.5, -.75)


lin.pred <- Xmat %*% beta.vec	# Value of lin.predictor
exp.p <- exp(lin.pred)/(1+exp(lin.pred)) # Expected proportion
C <- rbinom(n=n, size=N, prob = exp.p) # Add binomial noise

# Inspect what we've created:
C
hist(C, col="lightgreen", freq=FALSE)					
plot(prop.table(table(C)), col="blue", lwd=3)

par(mfrow=c(2, 1))
matplot(cbind(indef.pos[1:10], indef.pos[11:20], indef.pos[21:30]), cbind(exp.p[1:10], exp.p[11:20], exp.p[21:30]), ylab="Expected proportion", xlab="Indef position", col=c("red","green","blue"), pch = c("A","B","C"), las=1, cex=1.2, main="")
matplot(cbind(indef.pos[1:10], indef.pos[11:20], indef.pos[21:30]), cbind(C[1:10]/N[1:10], C[11:20]/N[11:20], C[21:30]/N[21:30]), ylab = "Observed proportion", xlab = "Indef position", col=c("red","green","blue"), pch = c("A","B","C"), las=1, cex = 1.2, main = "")
par(mfrow = c(1,1))


# Analysis using R
summary(glm(cbind(C, N-C)~groups*indef.pos, family=binomial))

# Given the small sample size, we observe only a moderate correspondence with the true values:
beta.vec
round(coef(glm(cbind(C, N-C)~groups*indef.pos, family=binomial)), 2)

# Analysis using WinBUGS

# Define model
cat("model {
    # Priors
    for (i in 1:n.groups) {
    alpha[i]~dnorm(0, 0.0001)		# Intercepts
    beta[i]~dnorm(0, 0.0001)		# Slopes
    }
    # Likelihood
    for (i in 1:n) {
    logit(p[i]) <- alpha[groups[i]]+beta[groups[i]]*indef.pos[i]
    C[i]~dbin(p[i], N[i])
    # Fit assessments: Pearson residuals and posterior predictive check
    P.res[i] <- (C[i]-(N[i]*p[i]))/sqrt(N[i]*p[i]*(1-p[i]))	# Pearson residual
    C.new[i]~dbin(p[i], N[i])		# Create replicate data set
    P.res.new[i] <- (C.new[i]-(N[i]*p[i]))/sqrt(N[i]*p[i]*(1-p[i]))
    D[i] <- pow(P.res[i], 2)
    D.new[i] <- pow(P.res.new[i], 2)
    }
    # Derived quantities
    # Recover the effects relative to baseline level
    a.effe2 <- alpha[2]-alpha[1]		# Intercept B vs. A
    a.effe3 <- alpha[3]-alpha[1]		# Intercept C vs. A
    b.effe2 <- beta[2]-beta[1]		  # Slope B vs. A
    b.effe3 <- beta[3]-beta[1]		  # Slope C vs. A
    # Custom tests
    test1 <- beta[3]-beta[2]		  # Difference slope C vs. B
    # Add up discrepancy measures
    fit <- sum(D[])
    fit.new <- sum(D.new[])
    }", fill=TRUE, file="glm.txt")

# Bundle data
win.data <- list(C=as.numeric(C), N=as.numeric(N), groups=as.numeric(groups), n.groups=as.numeric(n.groups), indef.pos=as.numeric(indef.pos), n=as.numeric(n))

# Inits function
inits <- function() {
  list(alpha=runif(n.groups, 0, 1), beta=runif(n.groups, -1, 1))
}

# Parameters to estimate
params <- c("alpha", "beta", "a.effe2", "a.effe3", "b.effe2", "b.effe3", "test1", "P.res", "fit", "fit.new")

# MCMC settings
ni <- 5500; nb <- 500; nt <- 5; nc <- 3

# Start Gibbs sampler
library("R2WinBUGS")
out <- bugs(data=win.data, inits=inits, parameters.to.save=params, model.file="glm.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, clearWD=TRUE)

# JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="glm.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)


# We practice good statistical behavior and first assess MCMC  convergence and then model fit before rushing on to inspect the parameter estimates or indulge in some activity related to significance testing.
# -- we should believe the parameter estimates only for chains that we are confident have converged and a model that adequately reproduces the salient features in the dataset

# We first check convergence
par(mfrow=c(1, 2))
plot(out$summary[, "Rhat"], col="blue", pch=19, ylim=c(1, 2))
abline(h=1.1, col="red", lwd=2)
plot(outj$BUGSoutput$summary[, "Rhat"], col="blue", pch=19, ylim=c(1, 2))
abline(h=1.1, col="red", lwd=2)
par(mfrow=c(1, 1))

# Then we plot the Pearson residuals:
par(mfrow = c(1, 2))
plot(out$mean$P.res, ylab="Residual", las=1, col="blue", pch=20)
abline(h = 0)
plot(indef.pos, out$mean$P.res, xlab="Indef position", ylab="Residual", las=1, col="blue", pch=20)
abline(h = 0)
par(mfrow = c(1, 1))

# Finally, we conduct a posterior predictive check for overall goodness of fit of the model:
# -- our discrepancy measure is the sum of squared Pearson residuals
plot(out$sims.list$fit, out$sims.list$fit.new, main="Posterior predictive check", xlab="Discrepancy actual data", ylab="Discrepancy ideal data", col="blue")
abline(0, 1, lwd=2, col="black")

# Bayesian p-value:
mean(out$sims.list$fit.new>out$sims.list$fit)



# We can now look at the parameter estimates -- compare Bayesian estimates with true values and MLEs:
print(out$mean, dig=3)

beta.vec
round(glm(cbind(C, N-C)~groups*indef.pos, family=binomial)$coef, 2)

print(outj$BUGSoutput$mean, dig=3)




# Binomial GLMM


# Suppose we want to determine the proportion of wide-scope indefinites:
# -- in 16 novels
# -- based on 10 samples of text from each of the 16 novels
# -- as a function of the distance between the indefinite and the beginning of the sentece; the distance is measured in words

# The proportions of wide-scope indefinites are taken to vary from novel to novel as a function of the style of the author, the content of the novel etc. 
# -- we therefore have random coefficients for the novels

# Data generation
n.novels <- 16
n.samples <- 10
(n <- n.novels*n.samples)
(novel <- gl(n=n.novels, k=n.samples))

# Get discrete uniform values for the number of indefinites in each sample:
(N <- round(runif(n, 3, 15)))

# For each sample i, we have N[i] indefinites:
# -- for each of these indefinites, we should generate the position in the sentence: discrete uniform values between 0 and 20, for example
# -- we should store it in a vector for each of the 16 novels

# This will add up to as many measurements as there are indefinites:
sum(N)


# For simplicity, we assume that all the indefinites in a sample have the same position, so we generate only 10 measurements per novel -- i.e., 160 measurements total.
# -- we also assume that the vector of indef.positions is scaled, so 160 draws from a uniform dist from -2 to 2 should do                                    
indef.pos <- runif(n, -2, 2)
round(indef.pos, 2)


Xmat <- model.matrix(~novel*indef.pos-1-indef.pos)
print(Xmat[1, ], dig=2) # Print top row
str(Xmat)


# Select hyperparams:
intercept.mean <- 1
intercept.sd <- 1
slope.mean <- -2
slope.sd <- 1
(intercept.effects <- rnorm(n=n.novels, mean=intercept.mean, sd=intercept.sd))
(slope.effects <- rnorm(n=n.novels, mean=slope.mean, sd=slope.sd))
all.effects <- c(intercept.effects, slope.effects) # Put them all together


lin.pred <- Xmat %*% all.effects	# Value of lin.predictor
exp.p <- exp(lin.pred)/(1 + exp(lin.pred)) # Expected proportion
hist(exp.p, col="lightblue", breaks=30, freq=FALSE, main="Expected proportions of wide-scope indefinites")
library("lattice")
xyplot(exp.p~indef.pos|novel, ylab="Expected proportions of wide-scope indefinites", xlab="Position in the sentence (scaled)", main="Expected wide-scope indefinites")


C <- rbinom(n=n, size=N, prob=exp.p) # Add binomial variation
hist(C/N, col="lightblue", breaks=30, freq=FALSE, main="Observed proportions of wide-scope indefinites")
xyplot(C/N ~ indef.pos|novel, ylab="Observed proportions of wide-scope indefinites", xlab="Position in the sentence (scaled)", main = "Observed wide-scope indefinites")




# Analysis under a random-coefficients model

# Analysis using R
library("lme4")
glmm.fit <- glmer(cbind(C, N-C)~indef.pos+(1|novel)+(0+indef.pos|novel), family=binomial)
print(glmm.fit, cor=FALSE)

# Compare with true values:
print(glmm.fit, dig=2)
data.frame(intercept.mean=intercept.mean, intercept.sd=intercept.sd, slope.mean=slope.mean, slope.sd=slope.sd)


# Analysis using WinBUGS
# Define model
cat("model {
    # Priors
    mu.int~dnorm(0, 0.0001)		# Hyperparams for random intercepts
    sigma.int~dunif(0, 10)
    tau.int <- 1/(sigma.int*sigma.int)
    mu.beta~dnorm(0, 0.0001)		# Hyperparams for random slopes
    sigma.beta~dunif(0, 10)
    tau.beta <- 1/(sigma.beta*sigma.beta)
    for (i in 1:n.novels) {		
    alpha[i]~dnorm(mu.int, tau.int)	# Intercepts
    beta[i]~dnorm(mu.beta, tau.beta)	# Slopes
    }
    # Binomial likelihood
    for (i in 1:n) {
    C[i]~dbin(p[i], N[i])
    logit(p[i]) <- alpha[novel[i]]+beta[novel[i]]*indef.pos[i]
    }
    }", fill=TRUE, file="glmm.txt")



# Estimation of extreme probabilities (very close to 0 or 1) can be numerically unstable in WinBUGS, in which case we would need to make sure the estimated probability stays within the [0, 1] bounds. So we add a p.bound variable that truncates the estimated probabilities to the correct range:

# logit(p[i]) <- alpha[novel[i]]+beta[novel[i]]*indef.pos[i]
# p.bound[i] <- max(0.0001, min(0.9999, p[i]))
# C[i]~dbin(p.bound[i], N[i])

# We can also add a posterior predictive check based on Pearson residuals, just as before:

# P.res[i] <- (C[i]-(N[i]*p.bound[i]))/sqrt(N[i]*p.bound[i]*(1-p.bound[i]))
# C.new[i]~dbin(p.bound[i], N[i])
# P.res.new[i] <- (C.new[i]-(N[i]*p.bound[i]))/sqrt(N[i]*p.bound[i]*(1-p.bound[i]))
# D[i] <- pow(P.res[i], 2)
# D.new[i] <- pow(P.res.new[i], 2)
# fit <- sum(D[])
# fit.new <- sum(D.new[])


# Bundle data
win.data <- list(C=as.numeric(C), N=as.numeric(N), novel=as.numeric(novel), indef.pos=as.numeric(indef.pos), n.novels=as.numeric(n.novels), n=as.numeric(n))

# Inits function
inits <- function() {
  list(alpha=rnorm(n.novels, 0, 2), beta=rnorm(n.novels, 1, 1), mu.int=rnorm(1, 0, 1), mu.beta=rnorm(1, 0, 1))
}

# Parameters to estimate
params <- c("alpha", "beta", "mu.int", "sigma.int", "mu.beta", "sigma.beta")

# MCMC settings
ni <- 4500; nb <- 500; nt <- 8; nc <- 3

# Start Gibbs sampling
library("R2WinBUGS")
out <- bugs(win.data, inits, params, "glmm.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, debug=TRUE, clearWD=TRUE)

print(out, dig=2)

# Compare with true values and MLEs:
print(out$mean, dig=2)
data.frame(intercept.mean=intercept.mean, intercept.sd=intercept.sd, slope.mean=slope.mean, slope.sd=slope.sd)
print(glmm.fit, dig=2)


# JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="glmm.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj)  

print(outj, dig=2)

print(outj$BUGSoutput$mean, dig=2)
data.frame(intercept.mean=intercept.mean, intercept.sd=intercept.sd, slope.mean=slope.mean, slope.sd=slope.sd)
print(glmm.fit, dig=2)


# As is typical, the estimates of random-effects variances are greater in the Bayesian approach, presumably since inference is exact and incorporates all uncertainty in the modeled system.
# -- the approach in lmer() or glmer() is approximate and may underestimate these variances (Gelman and Hill 2007)




#Contents:
# -- GLMMs that take into account inter-annotator disagreement (simulated data, R analysis, WinBUGS / JAGS analysis)
# -- Ordinal probit "t-test" (based on joint work with Jakub Dotlacil): simulated data for an ordinal probit "t-test", i.e., an ordinal probit regression with only one predictor (a factor with 2 levels); frequentist analysis in R using the "ordinal" package; Bayesian analysis using WinBUGS / JAGS



# GLMMs that take into account inter-annotator disagreement


# We have now seen a pretty wide range of random-effects models (a.k.a. mixed-effects or hierarchical models).

# -- "random-effects" means that some parameters are themselves represented as realizations from a random process
# -- we have used a normal (or a multivariate normal) distribution as our sole description of this additional random component
# -- however, nothing constrains us to use the normal distribution only and sometimes, other distributions will be appropriate for some parameters

# We will now illustrate this with a model with discrete random effects assumed to be drawn from a Bernoulli distribution. 

# This kind of effects help us model inter-annotator (dis)agreement with respect to binomial outcomes, which model the presence / absence of certain abstract linguistic representations (e.g., discourse relations, aspectual coercion, type shifting etc.) that are imperfectly identified / tagged by the annotators.

# There (probably) is no canned routine for the frequentist estimation of the parameters in such models -- but MCMC-based Bayesian modeling can deal with such models just as it did with the previous ones.


# A GLMM that couples two logistic regressions

# Consider an investigation of whether wide-scope readings for indefinites are available in 150 sentences that contain at least one other quantifier besides the indefinite. 

# Data generation
n.sent <- 150 # 150 sentences to be examined

# Position of the indefinite in the sentence:
(indef.pos.initial <- sort(round(runif(n=n.sent, min=0, max=20))))
(mean.initial <- mean(indef.pos.initial))
(sd.initial <- sd(indef.pos.initial))
(indef.pos <- (indef.pos.initial-mean.initial)/sd.initial)

# The position of the indefinite affects the probability with which the indefinite takes Wide Scope (WS):
alpha.WS <- 0 # Logit-linear intercept for indef.pos with respect to WS availability
beta.WS <- -2.5	# Logit-linear slope for indef.pos with respect to WS availability
WS.prob <- exp(alpha.WS+beta.WS*indef.pos)/(1+exp(alpha.WS+beta.WS*indef.pos))

# The further away from the beginning of a sentence the indefinite is, the less likely it is to have WS:
plot(indef.pos, WS.prob, ylim=c(0,1), xlab="Indef position", ylab="Wide scope probability", main="", las=1, col="blue", pch=20)

# Add Bern / Binom noise to obtain true data:
(true.WS.presence <- rbinom(n=n.sent, size=1, prob=WS.prob)) # Look at the true WS presence for each indefinite / sentence
sum(true.WS.presence) # Among the 150 sentences

# But we do not have access to the true data, we only have access to what different annotators report about the true data; it is very plausible that annotation is imperfect / has errors.

alpha.annotation <- -1 # Logit-linear intercept for indef.pos with respect to annotation / identification as such
beta.annotation <- -4 # Logit-linear slope for indef.pos with respect to annotation / identification as such
annotation.prob <- exp(alpha.annotation+beta.annotation*indef.pos)/(1+exp(alpha.annotation+beta.annotation*indef.pos))

# The further away from the beginning of a sentence the indefinite is, the less likely it is to be correctly annotated as WS (the annotator gets increasingly more distracted):
plot(indef.pos, annotation.prob, ylim=c(0,1), main="", xlab="Indef position", ylab="Wide scope annotation probability", las=1, col="blue", pch=20)

# The effective annotation probability is the product of true presence of WS and the annotation probability:
eff.annotation.prob <- true.WS.presence*annotation.prob

round(data.frame(true.WS.presence=true.WS.presence, annotation.prob=annotation.prob, eff.annotation.prob=eff.annotation.prob), 3)

# -- we idealize and do not allow for the possibility that annotators can identify an indefinite as WS without the indefinite actually being WS; i.e., we assume asymmetric errors for simplicity

plot(indef.pos, eff.annotation.prob, ylim=c(0,1), main="", xlab="Indef position", ylab="Effective wide scope annotation probability", las=1, col="blue", pch=20)

# Plot all 3 components:

par(mfrow=c(1, 3))
plot(indef.pos, true.WS.presence, ylim=c(0,1), xlab="Indef position", ylab="Wide scope probability", main="", las=1, col="blue", pch=20, cex=2)
lines(indef.pos, WS.prob, ylim=c(0,1), col="red", lwd=1)

plot(indef.pos, annotation.prob, ylim=c(0,1), main="", xlab="Indef position", ylab="Wide scope annotation probability", las=1, col="blue", pch=20, cex=2)

plot(indef.pos, eff.annotation.prob, ylim=c(0,1), main="", xlab="Indef position", ylab="Effective wide scope annotation probability", las=1, col="blue", pch=20, cex=2)
par(mfrow=c(1, 1))



# Simulate results of three annotators:
R <- n.sent
T <- 3
(y <- array(dim=c(R, T)))

for(i in 1:T) {
  y[, i] <- rbinom(n=n.sent, size=1, prob=eff.annotation.prob)
}

# Look at the data:
y
apply(y, 2, sum)

# Apparent availability of WS among the 150 indefinites / sentences:
sum(apply(y, 1, sum)>0)

# A naive analysis would just pool together all these observations and estimate a binomial GLM:

(obs <- as.numeric(apply(y, 1, sum)>0))
naive.analysis <- glm(obs~indef.pos, family=binomial)
summary(naive.analysis)

lin.pred <- naive.analysis$coef[1]+naive.analysis$coef[2]*indef.pos

# Compare the estimates of the naive analysis to the true WS probabilities:
plot(indef.pos, exp(lin.pred)/(1+exp(lin.pred)), ylim=c(0,1), xlab="Indef position", ylab="WS Probability", main="WS Probability: Naive estimates (red) vs. True values (blue)", las=1, col="red", pch=20, type="b")
points(indef.pos, WS.prob, ylim=c(0,1), col="blue", pch=20, type="b")




# Analysis using WinBUGS

# Define model
cat("model {
    # Priors
    alpha.WS~dunif(-20, 20)		# Set A of priors
    beta.WS~dunif(-20, 20)
    alpha.annotation~dunif(-20, 20)
    beta.annotation~dunif(-20, 20)
    # alpha.WS~dnorm(0, 0.001) 		# Set B of priors
    # beta.WS~dnorm(0, 0.001)
    # alpha.annotation~dnorm(0, 0.001)
    # beta.annotation~dnorm(0, 0.001)
    
    # Likelihood
    for (i in 1:R) { #start initial loop over the sentences R
    # True state model for the partially observed true state
    logit(psi[i])<-alpha.WS+beta.WS*indef.pos[i]    # True WS probability in sentence i
    z[i]~dbern(psi[i])		# True WS presence / absence in sentence i
    for (j in 1:T) { # start a second loop over the annotators T
    # Observation model for the actual observations
    logit(p[i, j]) <- alpha.annotation+beta.annotation*indef.pos[i]
    eff.p[i, j] <- z[i]*p[i, j]
    y[i, j]~dbern(eff.p[i, j])	# Annotation-nonannotation at i and j
    # Computation of fit statistic (for Bayesian p-value)
    P.res[i, j] <- abs(y[i, j]-p[i, j])	 # Absolute residual
    y.new[i, j]~dbern(eff.p[i, j])
    P.res.new[i, j] <- abs(y.new[i, j]-p[i, j])
    }
    }
    fit <- sum(P.res[,])            # Discrepancy for actual data set
    fit.new <- sum(P.res.new[,]) 		# Discrepancy for replicate data set
    # Derived quantities
    WS.fs <- sum(z[])			# Number of actual WS among 150
    }", fill=TRUE, file="annotator_WS_model.txt")

# Bundle data
win.data <- list(y=y, indef.pos=as.numeric(indef.pos), R=as.numeric(dim(y)[1]), T=as.numeric(dim(y)[2]))

# Inits function
zst <- apply(y, 1, max)			# Good starting values for latent states are essential!
inits <- function() {
  list(z=as.numeric(zst), alpha.WS=runif(1, -5, 5), beta.WS=runif(1, -5, 5), alpha.annotation=runif(1, -5, 5), beta.annotation=runif(1, -5, 5))
}

# Parameters to estimate
params <- c("alpha.WS", "beta.WS", "alpha.annotation", "beta.annotation", "WS.fs", "fit", "fit.new")

# MCMC settings
nc <- 3; nb <- 2000; ni <- 12000; nt <- 20

# Start Gibbs sampler
library("R2WinBUGS")
out <- bugs(win.data, inits, params, "annotator_WS_model.txt", n.chains=nc, n.iter=ni, n.burn = nb, n.thin=nt, debug=TRUE, clearWD=TRUE)


# JAGS

library("R2jags")
outj <- jags(win.data, inits=inits, parameters.to.save=params, model.file="annotator_WS_model.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)
traceplot(outj) 


# Check convergence:
par(mfrow=c(1, 2))
plot(out$summary[, "Rhat"], col="blue", pch=19, ylim=c(1, 2))
abline(h=1.1, col="red", lwd=2)
plot(outj$BUGSoutput$summary[, "Rhat"], col="blue", pch=19, ylim=c(1, 2))
abline(h=1.1, col="red", lwd=2)
par(mfrow=c(1, 1))



# Check model fit:
plot(out$sims.list$fit, out$sims.list$fit.new, main="", xlab="Discrepancy for actual data set", ylab="Discrepancy for perfect data sets", las=1, col="blue")
abline(0,1, lwd = 2)

# Bayesian p-value:
mean(out$sims.list$fit.new>out$sims.list$fit)

# The model seems to fit well, so we compare the known true values from the data-generating process with what the analysis has recovered.

# True values:
data.frame(alpha.WS=alpha.WS, beta.WS=beta.WS, alpha.annotation=alpha.annotation, beta.annotation=beta.annotation)
# Bayesian estimates:
round(data.frame(alpha.WS=out$mean$alpha.WS, beta.WS=out$mean$beta.WS, alpha.annotation=out$mean$alpha.annotation, beta.annotation=out$mean$beta.annotation), 2)

sum(true.WS.presence) #True number of WS indefs
sum(apply(y, 1, sum)>0) # Apparent number of WS indefs
out$mean$WS.fs # Bayesian estimate

# The true WS probability vs. Bayesian analysis vs. Naive analysis 
plot(indef.pos, exp(lin.pred)/(1+exp(lin.pred)), ylim=c(0,1), xlab="Indef position", ylab="WS Probability", main="True (blue) vs. Bayes (black) vs. Naive (red)", las=1, col="red", pch=1, type="b", lwd=1.5)
points(indef.pos, WS.prob, ylim=c(0,1), col="blue", pch=19, type="b", lwd=1.5)
lin.pred2 <- out$mean$alpha.WS+out$mean$beta.WS*indef.pos
points(indef.pos, exp(lin.pred2)/(1+exp(lin.pred2)), ylim=c(0,1), col="black", pch=1, type="b", lwd=1.5)


# The WinBUGS model is sometimes inferior and sometimes superior to the ML one because of the small effective sample -- the number of distinct positions that an indefinite can occupy in a sentence is pretty limited.

# The model will also not be adequate if there are important unmeasured covariates.

# On the application side, WinBUGS can be painful when fitting these slightly more complex models.
# -- it is essential to provide adequate starting values, in particular, for the latent state (the code bit z = zst)
# -- it is essential to scale all the covariates
# -- there may also be prior sensitivity -- e.g., altering the set B prior precision from 0.01 to 0.001 may cause WinBUGS to issue one of its trap messages; sometimes, they are produced even with uniform or normal(0, 0.01) priors

# Many other seemingly innocent modeling choices may influence success or failure when fitting a particular model to a given data set.

# Sometimes you must be prepared for an extensive amount of frustrating trial and error until the code works.
# -- but then this applies quite generally to more complex models, not just to models fitted using WinBUGS




# Ordinal probit "t-test"

# Data generation

# Suppose we want to determine the acceptability of the sentence-internal reading of singular "different" with an "every NP-sg" vs. a "the NP-pl" licensor, e.g.:

# 1. Every student read a different paper.
# 2. The students read a different paper.

# We evaluate the acceptability of EVERY vs. THE on a 1-5 ordinal scale, where 1=very bad, 2=fairly bad, 3=neither good nor bad, 4=fairly good, 5=very good

# We obtain 30 independent acceptability judgments for each of the two conditions (EVERY and THE).

N <- 30

# We assume that acceptability is underlyingly continuous, but we do not have access to the latent continuous data.
# -- this assumption might not be very realistic for the linguistic example we are considering, in which case we should simply think of it as a technical way of aggregating the acceptability data and extracting generalizations from it
# -- this is very much like the infinite set of types postulated type logic: we only use a finite subset to formalize natural language meaning and that's fine; or the denumerably infinite set of variables postulated in type logic: we only use a finite subset in our formal semantics analyses
# -- the assumption is more realistic for grades, for example, where it's likely that the underlying ability of the student is continuous, but we evaluate that ability by discretizing it into a finite number of ordered grades

# Furthermore, we will assume that the latent variable has a normal distribution -- hence the word "probit". If the latent variable has a logistic distribution, we would have an ordinal logistic "t-test".

# We will assume that the latent normal variable has a variance of 1^2 for both conditions, a mean of 0 for THE and a mean of 1.2 for EVERY.

# We fix four thresholds at:

t1 <- -2.1
t2 <- -0.9
t3 <- 0.2
t4 <- 1.5

# We now generate 30 random values from the latent N(0, 1^2) for condition THE:

THE.latent <- rnorm(N, 0, 1)
str(THE.latent)
summary(THE.latent)
print(sort(THE.latent), dig=1)

hist(THE.latent, col="lightblue", freq=FALSE)
lines(density(THE.latent), col="blue", lwd=2)


# For every one of the 30 values, if the value is:
# -- less than t1=-2.1, then the acceptability judgment is 1=very bad
# -- between t1=-2.1 and t2=-0.9, then the acceptability judgment is 2=fairly bad
# -- between t2=-0.9 and t3=0.2, then the acceptability judgment is 3=neither good nor bad
# -- between t3=0.2 and t4=1.5, then the acceptability judgment is 4=fairly good
# -- greater than t4=1.5, then the acceptability judgment is 5=very good

THE.acc <- numeric(length=N)
str(THE.acc)

for (i in 1:N) {
  if (THE.latent[i]<t1) {THE.acc[i] <- 1}
  if (THE.latent[i]>=t1 & THE.latent[i]<t2) {THE.acc[i] <- 2}
  if (THE.latent[i]>=t2 & THE.latent[i]<t3) {THE.acc[i] <- 3}
  if (THE.latent[i]>=t3 & THE.latent[i]<t4) {THE.acc[i] <- 4}
  if (THE.latent[i]>=t4) {THE.acc[i] <- 5}    
}

print(data.frame(THE.latent=THE.latent, THE.acc=THE.acc), dig=1)

str(THE.acc)
plot(as.factor(THE.acc), col="lightblue")

# THE.acc represents the result of our acceptability judgment experiment for condition THE.

# We now do the same thing for condition EVERY. We generate 30 random values from the latent N(1.2, 1^2):

EVERY.latent <- rnorm(N, 1.2, 1)
str(EVERY.latent)
summary(EVERY.latent)
print(sort(EVERY.latent), dig=1)

hist(EVERY.latent, col="lightblue", freq=FALSE)
lines(density(EVERY.latent), col="blue", lwd=2)

# For every one of the 30 values, if the value is:
# -- less than t1=-2.1, then the acceptability judgment is 1=very bad
# -- between t1=-2.1 and t2=-0.9, then the acceptability judgment is 2=fairly bad
# -- between t2=-0.9 and t3=0.2, then the acceptability judgment is 3=neither good nor bad
# -- between t3=0.2 and t4=1.5, then the acceptability judgment is 4=fairly good
# -- greater than t4=1.5, then the acceptability judgment is 5=very good

EVERY.acc <- numeric(length=N)
str(EVERY.acc)

for (i in 1:N) {
  if (EVERY.latent[i]<t1) {EVERY.acc[i] <- 1}
  if (EVERY.latent[i]>=t1 & EVERY.latent[i]<t2) {EVERY.acc[i] <- 2}
  if (EVERY.latent[i]>=t2 & EVERY.latent[i]<t3) {EVERY.acc[i] <- 3}
  if (EVERY.latent[i]>=t3 & EVERY.latent[i]<t4) {EVERY.acc[i] <- 4}
  if (EVERY.latent[i]>=t4) {EVERY.acc[i] <- 5}    
}

print(data.frame(EVERY.latent=EVERY.latent, EVERY.acc=EVERY.acc), dig=1)

str(EVERY.acc)
plot(as.factor(EVERY.acc), col="lightblue")

# EVERY.acc represents the result of our acceptability judgment experiment for condition EVERY.

# THE.acc and EVERY.acc together are the response variable for our acceptability judgment experiment.

acc <- c(THE.acc, EVERY.acc)
str(acc)
acc

par(mfrow=c(1, 2))
plot(as.factor(acc[1:30]), col="lightblue", main="THE")
plot(as.factor(acc[31:60]), col="lightblue", main="EVERY")
par(mfrow=c(1, 1))


# Generate the data a couple of times to develop an intuition about the kind of data variability we expect to see (and can account for) given this model.


# We now assemble the data for analysis:
groups <- as.factor(c(rep("THE", N), rep("EVERY", N)))
groups
str(groups)



datafinal <- data.frame(groups=groups, acc=acc)
datafinal

contrasts(datafinal$groups)
datafinal$groups <- relevel(datafinal$groups, ref="THE")
contrasts(datafinal$groups)

par(mfrow=c(1, 2))
plot(acc~groups, col="lightblue", data=datafinal)
plot(as.factor(acc)~groups, col=c("black", "azure4", "azure3", "azure2", "white"), data=datafinal)
par(mfrow=c(1, 1))



# Analysis using R

#install.packages("ordinal")
library("ordinal")

m0 <- clm(as.factor(acc)~groups, data=datafinal, link="probit")
print(summary(m0), dig=2)

# Compare with true values
print(m0$coef, dig=2)
data.frame(t1=t1, t2=t2, t3=t3, t4=t4, "EVERY.minus.THE"=1.2)

# Plot the parameter estimates (based on code by Matt Wagers)
xrange<-seq(-5,5,0.01)
plot(xrange, dnorm(xrange), type='l', lwd=3, xlim=c(-5, 5), main="THE (green), EVERY (red), Thresholds (blue)", xlab="", ylab="", col="green")
abline(v=m0$coef[1:4], col="blue", lwd=2)
lines(xrange, dnorm(xrange, mean=m0$coef[5]), type='l', lwd=3, xlim=c(-5, 5), col="red" )



# Analysis using WinBUGS / JAGS

cat("model {
    # Prior for the predictor: we set gr[1] to 0 for identifiability; gr[2] is the difference in mean acceptability between EVERY and THE
    # Recall that precision is the reciprocal of the variance and WinBUGS / JAGS parametrizes normal distributions in terms of precision
    grPrecision <- 0.01
    gr[1] <- 0
    gr[2]~dnorm(0, grPrecision)
    
    # Priors for the 4 thresholds:
    threshPriorPrec <- 0.01
    threshPriorMean[1] <- 0
    thresh[1]~dnorm(threshPriorMean[1], threshPriorPrec)
    threshPriorMean[2] <- 0
    thresh[2]~dnorm(threshPriorMean[2], threshPriorPrec)
    threshPriorMean[3] <- 0
    thresh[3]~dnorm(threshPriorMean[3], threshPriorPrec)
    threshPriorMean[4] <- 0
    thresh[4]~dnorm(threshPriorMean[4], threshPriorPrec)
    
    # Likelihood: nobs is the number of observations (=60); the two groups THE and EVERY are associated with 2 different means gr[1] and gr[2] for the two latent normal variables that underlie the acceptability judgments for the two groups; in particular, for i=1:30, mu[i]=gr[1]=0 and for i=31:60, mu[i]=gr[2] and gr[2] is greater than 0 because EVERY is overall more acceptable than THE.
    
    # For example:
    
    # -- consider observation 1, i.e., i=1
    # -- observation 1 is the first one for condition THE, i.e., groups[i] = groups[1] = 1
    # -- therefore, mu[i] = mu[1] = gr[groups[1]] = gr[1] = 0
    # -- thus, mu[1] = gr[1] = 0, i.e., the latent variable for THE is centered at 0
    # -- the probability of getting rating 1=very bad is encoded by pr[i, 1] = pr[1, 1], which is phi((thresh[1]-mu[1])) = phi((thresh[1]-gr[1])) = phi((thresh[1]-0)) = phi(thresh[1]) [recall that phi is the cdf of the standard normal N(0, 1^2)]
    # -- this is exactly how we generated the data: a random draw from the latent variable for THE was categorized as 1=very bad iff it was less than threshold t1
    
    # -- consider now observation 31, i.e., i=31
    # -- this is the first observation for condition EVERY, i.e., groups[i] = groups[31] = 2 
    # -- therefore, mu[i] = mu[31] = gr[groups[31]] = gr[2]
    # -- thus, mu[31] = gr[2] is the mean of the latent variable for EVERY, which will be higher than gr[1] = 0, which is the mean for the latent variable for THE
    # -- so, the probability pr[i, 1] = pr[31, 1] of getting a rating of 1=very bad for EVERY will be correspondingly smaller
    # -- this probability pr[31, 1] is phi((thresh[1]-mu[31])) = phi((thresh[1]-gr[2]))
    # -- and phi((thresh[1]-gr[2])) is less than phi(thresh[1]) if gr[2] is greater than 0 (which it is), i.e., we correctly capture the fact that the probability of getting a rating of 1=very bad for EVERY (group 2) is less than the probability of getting a rating of 1=very bad for THE (group 1)
    
    # -- etc. 
    
    # The max(0, ...) part in the definition of pr[i,2], pr[i,3] and pr[i,4] is needed to enforce the relative ordering of the 4 thresholds:
    # -- consider for example the probability of getting rating 2=fairly bad, encoded by pr[i, 2]
    # -- in the aberrant case in which the first threshold thresh[1] is greater than the second threhold thresh[2], the difference phi((thresh[2]-mu[i])) - phi((thresh[1]-mu[i])) is negative, so we will select 0 as the value for pr[i, 2]
    # -- note that we would actually obtain pr[i, 2]=0 if the two thresholds would be the same, i.e., thresh[1]=thresh[2]
    # -- that is, we effectively constrain thresh[1] to be less than thresh[2] or at most equal to thresh[2], which is exactly what we want to properly encode our ordinal response variable
    
    for (i in 1:nobs) {
    mu[i] <- gr[groups[i]]
    pr[i,1] <- phi((thresh[1]-mu[i]))
    pr[i,2] <- max(0, phi((thresh[2]-mu[i])) - phi((thresh[1]-mu[i])))
    pr[i,3] <- max(0, phi((thresh[3]-mu[i])) - phi((thresh[2]-mu[i])))
    pr[i,4] <- max(0, phi((thresh[4]-mu[i])) - phi((thresh[3]-mu[i])))
    pr[i,5] <- 1 - (pr[i,1] + pr[i,2] + pr[i,3] + pr[i,4])
    acc[i]~dcat(pr[i,1:5])
    }
    }", fill=TRUE, file="ord_prob_ttest.txt")


# Assembling the data
win.data <- list(acc=as.numeric(datafinal$acc), groups=as.numeric(datafinal$groups), nobs=as.numeric(length(datafinal$acc)))


#as.numeric(datafinal$acc)
#as.numeric(datafinal$groups)
#as.numeric(length(datafinal$acc))

# Initializing the chains
inits <- function() {list(gr=c(NA, 0), thresh=rnorm(4, mean=as.numeric(m0$coef[1:4]), sd=0.1))}

#rnorm(4, mean=as.numeric(m0$coef[1:4]), sd=0.1)

# Parameters to monitor
params <- c("thresh", "gr")

# MCMC settings
nc <- 3; ni <- 12500; nb <- 2500; nt <- 5

# Run WinBUGS
library("R2WinBUGS")
out.m0 <- bugs(data=win.data, inits=inits, parameters.to.save=params, model.file="ord_prob_ttest.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni, working.directory=getwd(), debug=TRUE, clearWD=TRUE)

# JAGS:

library("R2jags")
outj.m0 <- jags(data=win.data, inits=inits, parameters.to.save=params, model.file="ord_prob_ttest.txt", n.thin=nt, n.chains=nc, n.burnin=nb, n.iter=ni)

traceplot(outj.m0)


# WinBUGS usually does not converge, while JAGS usually converges with this kind of models.

par(mfrow=c(1, 2))
plot(out.m0$summary[, "Rhat"], col="blue", pch=19, ylim=c(1, 2), main="WinBUGS")
abline(h=1.1, col="red", lwd=2)
plot(outj.m0$BUGSoutput$summary[, "Rhat"], col="blue", pch=19, ylim=c(1, 2), main="JAGS")
abline(h=1.1, col="red", lwd=2)
par(mfrow=c(1, 1))

print(out.m0, dig=3)
print(outj.m0, dig=3)

# We compare the results with the MLEs and the true values:


print(out.m0$mean, dig=2)

print(m0$coef, dig=2)
data.frame(deviance=-2*logLik(m0))

data.frame(t1=t1, t2=t2, t3=t3, t4=t4, "EVERY.minus.THE"=1.2)

print(outj.m0$BUGSoutput$mean, dig=2)




# Plot Highest Posterior Density Intervals (code by John Kruschke)

# We define two functions first, HDIofMCMC and plotPost

HDIofMCMC <- function(sampleVec, credMass=0.95) {
  sortedPts = sort(sampleVec)
  ciIdxInc = floor(credMass*length(sortedPts))
  nCIs = length(sortedPts)-ciIdxInc
  ciWidth = rep(0, nCIs)
  for (i in 1:nCIs) {
    ciWidth[i] = sortedPts[i+ciIdxInc]-sortedPts[i]
  }
  HDImin = sortedPts[which.min(ciWidth)]
  HDImax = sortedPts[which.min(ciWidth)+ciIdxInc]
  HDIlim = c(HDImin, HDImax)
  return(HDIlim)
}

plotPost <- function(paramSampleVec, credMass=0.95, compVal=NULL, HDItextPlace=0.7, yaxt=NULL, ylab=NULL, xlab=NULL, cex.lab=NULL, cex=NULL, xlim=NULL, main=NULL, showMode=F, ... ) {
  # Override defaults of hist function, if not specified by user (additional arguments "..." are passed to the hist function)
  if (is.null(xlab)) xlab="Parameter"
  if (is.null(cex.lab)) cex.lab=1.5
  if (is.null(cex)) cex=1.4
  if (is.null(xlim)) xlim=range(c(compVal, paramSampleVec))
  if (is.null(main)) main=""
  if (is.null(yaxt)) yaxt="n"
  if (is.null(ylab)) ylab=""
  # Plot histogram.
  par(xpd=NA)
  histinfo = hist(paramSampleVec, xlab=xlab , yaxt=yaxt, ylab=ylab, freq=F , border="white", xlim=xlim, main=main, cex=cex, cex.lab=cex.lab, ...)
  # Display mean or mode:
  if (showMode==F) {
    meanParam = mean(paramSampleVec)
    text(meanParam, .9*max(histinfo$density),
         bquote(mean==.(signif(meanParam,3))), adj=c(.5,0), cex=cex)
  } else {
    dres = density(paramSampleVec)
    modeParam = dres$x[which.max(dres$y)]
    text(modeParam, .9*max(histinfo$density) ,
         bquote(mode==.(signif(modeParam,3))) , adj=c(.5,0) , cex=cex )
  }
  # Display the comparison value.
  if (!is.null(compVal)) {
    pcgtCompVal = round(100 * sum(paramSampleVec > compVal) / length(paramSampleVec), 1)
    pcltCompVal = 100-pcgtCompVal
    lines(c(compVal,compVal), c(.5*max(histinfo$density),0) , lty="dashed" , lwd=2)
    text(compVal, .5*max(histinfo$density), bquote(.(pcltCompVal)*"% <= " * .(signif(compVal,3)) * " < "*.(pcgtCompVal)*"%" ), adj=c(pcltCompVal/100,-0.2), cex=cex)
  }
  # Display the HDI.
  HDI = HDIofMCMC(paramSampleVec, credMass)
  lines(HDI, c(0,0), lwd=4)
  text(mean(HDI), 0, bquote(.(100*credMass) * "% HDI"), adj=c(.5,-1.9) , cex=cex)
  text(HDI[1], 0, bquote(.(signif(HDI[1],3))), adj=c(HDItextPlace,-0.5) , cex=cex)
  text(HDI[2], 0, bquote(.(signif(HDI[2],3))), adj=c(1.0-HDItextPlace,-0.5), cex=cex )
  par(xpd=F)
  return(histinfo)
}

# Now we can plot the HDIs for both the WinBUGS and the JAGS samples.

par(mfrow=c(1, 2))
histInfo = plotPost(out.m0$sims.list$gr, main="", compVal=0.0, col="lightblue", breaks=30, xlab="EVERY.minus.THE (WinBUGS)", cex.main=1.67, cex.lab=1.33)
histInfo = plotPost(outj.m0$BUGSoutput$sims.list$gr[, 2], main="", compVal=0.0, col="lightblue", breaks=30, xlab="EVERY.minus.THE (JAGS)", cex.main=1.67, cex.lab=1.33)
par(mfrow=c(1, 1))

