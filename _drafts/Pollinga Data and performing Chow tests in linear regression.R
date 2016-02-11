
Polling data and constraining residuals variance. 
Consider the linear regression model:
  y = \beta{0} +\beta{1}x_{1} +\beta{2}x_{2} + u, u \math(N)(0, \sigma^2)

Pretending that we have two groups of data, group 1 and group 2. We could have more groups; but let's keep it simple.

We could estimate the models separetely as:

lm(y ~ x1 + x2 subset=auto(group==1))

lm(y ~ x1 + x2 subset=auto(group==2))

Or we could poll the data and estimate a single model, one way being:
auto$g2 <-dummy(auto$group)
g2x1 = g2*x1
g2x2 = g2*x2

lm(y ~ x1 + x2 g2x1 + g2x2, data=auto)

Of course in R, we can simplify this process by simply adding the whole equation.
lm(y ~ x1 + I(g2*x2) + I(g2*x2), data=auto)

The very difference between these two appraoches is that we are constraining the variance of the residuals to be the same in the two groups when we pool the data. 
Essentially, when we estimate separetely, we estimate
### Group 1

### Group 2

While when we pool the data, we estimate:



auto <- read.delim("~/SciencesPo/auto.txt.gz")

# Attaching it
use(auto)

# Preparing data for the show
auto <- keep(auto, select = c(mpg, weight))

colnames(auto) <- c("x1", "x2")

auto$id <- 1:nrow(auto)

auto$x2= auto$x2/100

# the equation for group 1 will be y = x1 - x2, se(u) = 15
auto1 = auto 
comment(auto1) <- "This reduced version of the `auto` dataset is now group 1."
use(auto)

set.seed(51)
auto1$y = with(auto1, x1 - x2 - 15*invNormal(runif(nrow(auto1))))
auto1$group = 1


* the equation for group 2 will be y = x1 + x2, se(u) = 7
auto2 = auto
set.seed(51)
auto2$y = with(auto2, x1 - x2 - 7*invNormal(runif(nrow(auto2))))
auto1$group = 2

drop id

* next, the groups ?will made slightly unbalanced
drop in -3/l


* BEGINNING OF DEMONSTRATION
regress y x1 x2 if group==1                          /* [1] */
  regress y x1 x2 if group==2                          /* [2] */
  
  gen g2 = (group==2)
gen g2x1 = g2*x1
gen g2x2 = g2*x2
regress y x1 x2 g2 g2x1 g2x2                         /* [3] */
  
  predict r, resid
sum r if group==1
gen w = r(Var)*(r(N)-1)/(r(N)-3) if group==1
sum r if group==2
replace w = r(Var)*(r(N)-1)/(r(N)-3) if group==2

reg y x1 x2 g2 g2x1 g2x2 [aw=1/w]                    /* [4] */
  
  test g2x1 g2x2 g2
quietly regress y x1 x2 g2 g2x1 g2x2                 /* [3] */
  test g2x1 g2x2 g2

xtgls y x1 x2 g2 g2x1 g2x2, panel(het) i(group)      /* [5] */
  log close
exit