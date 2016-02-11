# Data Science Specialization
## R Programming

0. Prelim Notes
Week 1: Overview of R, R data types and objects, reading and writing data
Week 2: Control structures, functions, scoping rules, dates and times
Week 3: Loop functions, debugging tools
Week 4: Simulation, code profiling

0. Prelim Notes
SETUP, INSTALLING PACKAGES ETC.
In R, to find working directory:
  getwd()
dir() # to list files
ls() # to list available functions
rm(list=ls()) # clears out all your variables and functions
search() # shows your packages, in order, note it is the library() command that causes them to list here
read.csv("file.csv") # reads this file from working directory
control-l to clear console
install.packages("RMySQL") # you need the quotes!
library("RMySQL")
library() # to list packages (that you have installed, may or may not be loaded)
.packages(all = TRUE) # for names of all available packages, supposedly (does not list anything for me!), or
installed.packages # too much info! shows names of all available packages
HAD PROBLEM INSTALLING RMySQL: (but will apply whenever there are no binaries):
  package 'RMySQL' is available as a source package but not as a binary
- this is because I installed OS X Mavericks, and the cran page fro RMySQL says
OS X Mavericks binaries:	r-release: not available
StackExchange Solution: So you'll have to build it from source. Your first step should probably be to download the source, read the INSTALL instructions, maybe do some Googling and then give it try.
and/or see: http://stackoverflow.com/questions/23784919/install-rmysql-for-mac
Class discussion Solution: First, you have to install the package DBI, which the RMySQL package requires. Next you have to install MySQL on your Mac. This step will be really simple if you have Homebrew installed on your Mac. Just run the following command in the terminal:
brew install mysql
Then MySQL will be installed. Make sure that the internet connection is available for downloading. After these preparations, you can run
install.packages("RMySQL", type = "source")
to install the package. the type option is set for there is no binary package available.
install.packages("DBI")
Homebrew: I did not have, found it at url: brew.sh; you enter at command line:
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
then entered in terminal:
$ brew install mysql
then tried in RStudio: (would try R standalone if this didn't work)
install.packages("RMySQL", type = "source")
This appeared to work...
packageVersion("dplyr")
CRAN is a network of ftp and web servers ... RStudio maintains a CRAN mirror and it is publicly available
- sessionInfo() # versions, packages, etc.
R CMD INSTALL RMySQL_0.9-3.tar.gz
READING DATA IN, OR CREATING DATA CONSTRUCTS
reading data in, trick, read in first few rows then set colClasses (from week 1):
  trick: read in some rows, have it run that:
  initial <- read.table("datatable.txt", nrows = 100)
classes <- sapply(initial, class)
tabAll <- read.table("datatable.txt", colClasses = classes)
if you have spaces in your column names:
  names(pm0) <- make.names(cnames[[1]]) # replaces a space with .
Create an empty dataframe and add to it: note, will overwrite col names if you use rbind... (alternative, could track and reassign after first assignment)
n_personalize <- data.frame(title=character(), titletext=character(), stringsAsFactors = FALSE)
n_personalize[nrow(n_personalize)+1, ] <- c("TITLE_01_n3542693", "Sheer Feminine Fancy with Elegant Embellishments")
n_personalize[nrow(n_personalize)+1, ] <- c("TITLE_02_n3882004", "Soft and Sultry with Beaded Lace")
data = read.csv(bzfile('repdata-data-StormData.csv.bz2'), as.is=TRUE)
Say you have data where you want to convert a column with A,B,C to 1,2,3 or something like that:
  str <- c('A', 'B', 'C')
num <- c(1, 2, 3)
revalue(str, c('A' = 'one', 'C' = 'three'))
mapvalues(str, from=c('A','C'), to=c('one', 'three'))
or, if want char to numeric for example:
  training$classe_num <- 0
training$classe_num[training$classe=='A'] <- 1
training$classe_num[training$classe=='B'] <- 2
training$classe_num[training$classe=='C'] <- 3
training$classe_num[training$classe=='D'] <- 4
training$classe_num[training$classe=='E'] <- 5
SUMMARIZING DATA
Distinct values:
  levels(stormData$PROPDMGEXP)
head(unique(stormData$EVTYPE), 10)
Group by and adding up
table(restData$zipCode, useNA = "ifany") # like a proc freq?
table(restData$councilDistrict,restData$zipCode) # crosstab proc freq?
tapply(ucb$Freq,ucb$Gender,sum) # sum a quantitative by a qualitative - like proc freq with tables
economySummary <- ddply(economyData, .(EVENT), summarize, totProp=sum(PROPCOST), totCrop=sum(CROPCOST))
damages <- aggregate(cbind(FATALITIES, INJURIES) ~ EVTYPE , stormdata, sum)
Mapping data values to another (like merge)
healthData['EVENT'] <- 'Other'
for (i in 1:length(patterns)){
  match = grep(patterns[i], healthData$EVTYPE, ignore.case=T, perl=T)
  if (length(match) > 0){
    healthData[match, c('EVENT')] = events[i]
  }
}
dat$evtype <- gsub(".*(BLIZZARD|SNOW).*", "snow", dat$evtype)
stormdata$CROPDMG <- stormdata$CROPDMG*as.numeric(Recode(stormdata$CROPDMGEXP, "'0'=1;'2'=100;'B'=1000000000;'k'=1000;'K'=1000;'m'=1000000;'M'=1000000;''=0; '?'=0",as.factor.result=FALSE))
corrgram.data$Embarked <- revalue(corrgram.data$Embarked, c("C" = 1, "Q" = 2, "S" = 3))
note revalue is part of plyr package
PLOTTING
par(new=T) # use between plot() calls if you want to show plots on same plot
Example from Millenium dataset:
  lmM <- lm(hunger$Numeric[hunger$Sex=="Male"] ~ hunger$Year[hunger$Sex=="Male"])
lmF <- lm(hunger$Numeric[hunger$Sex=="Female"] ~ hunger$Year[hunger$Sex=="Female"])
plot(hunger$Year,hunger$Numeric,pch=19)
points(hunger$Year,hunger$Numeric,pch=19,col=((hunger$Sex=="Male")*1+1))
lines(hunger$Year[hunger$Sex=="Male"],lmM$fitted,col="black",lwd=3)
lines(hunger$Year[hunger$Sex=="Female"],lmF$fitted,col="red",lwd=3)
lines(x, lm1$fitted) is similar to abline(lm1)
abline() args: a,b are intercept and slope, v,h are vertical horizontal. reg, coef, untf are others
STATISTICS...
x <- runif(3) # produces 3 random uniform variables
y <- rnorm(1000)
z <- sample(y,10) #samples 10 from y
sd(x, na.rm = TRUE) to remove missing values
gl(nfac,nrep,len) # generate nfac factors, repeat each nrep times, len total length
interaction(f1, f2) # if 2 and 5 levels, will create 10 levels
cor(mtcars$mpg, mtcars) # will show all correlations
fit <- lm() # output has structure, eg fit$coeff[1]
coefficients, residuals, fitted.values, rank, weights, df.residual, call, terms, contrasts, xlevels, offset, y, x, model, na.action
PRESENTATION
R markdown: so that you get a .md and a .html that you can put on github (because .Rmd does not have results, and .html does not render the html when you open in github): example:
  ---
  title: "Evaluating Correctness of Biceps Curls from Sensor Data"
output:
  html_document:
  keep_md: true
---
  MISC COMMANDS
say you create a function myfunction(x) and save to a text file using R's text editor, file named test.r. To read and apply it, 2 ways:
1. if it's just a bit of code, copy and paste into r console and hit enter.
2. if file in your working directory, source it by command
source("test.r")
then you can run it by entering
myfunction(3)
myfunction # this will display the function code
subsetting tricks:
  o31t90 <- subset(hw1, Ozone > 31 & Temp > 90)
repeat 10 4 times:
  rep(10,4)
rep(c(0,1,2),times=10) # repeats the 0,1,2 10 times so length 30 (0 1 2 0 1 2 etc)
rep(c(0,1,2),each=4) # repeats each of the 0,1,2 4 times so length 12 (0 0 0 0 1 1 1 1 2 2 2 2)
full syntax is rep(x, ...) where ... options are times, length.out, each
related, more specific ones:
  rep.int(10,4) # repeat 10 4 times, rep.int(x, times)
rep_len(c(0,1,2),10) # vector length 10, ie 0 1 2 0 1 2 0 1 2 0, is rep_len(x, length.out)
to look at elements of a list, you unclass it eg names(unclass(p))
helpful functions: sqrt(), abs()
predefined variables: pi is a constant, LETTERS is vector of all capital letters
logical operators: not equal is !=, equal is == ... A or B is A | B, A and B is A & B ... control is left to right if mixed ors and ands
paste(c("hi","there"), collapse = " ")
paste("hi","there",sep = " ") # does same thing
paste(1:3,c("X","Y","Z"),sep="")
[1] "1X" "2Y" "3Z"
note is.na(my_data) is not the same as my_data == NA; the latter will give you a vector of all NAs, because NA is not really a value, it is a placeholder for a quantity that is not available
to sum up the NAs:
  sum(my_na) where my_na <- is.na(my_data)
to generate NaN:
  0/0, or > Inf - Inf
vector x has some NAs in it, here is how to put all the not-NAs in a vector y:
  y <- x[!is.na(x)]
or get more fancy, 2 steps at once:
  y <- x[!is.na(x) & x > 0] # returns where both is not NA and is gt 0
how to get all but the 2nd thru 10th elements of a vector x?
x[c(-2,-10)] # or x[-c(2,10)]
to check if 2 things are identical:
  identical(a,b)
say you want to add a column of names to a matrix of numbers... could cbind(pnames,matrix) but the numbers will turn to characters. do instead:
  my_data <- data.frame(patients, my_matrix)
say then you want to name the columns...
cnames <- c("patient","age","claims")
colnames(my_data) <- cnames
may want to check out the 'parallel' package (for what?)
restData$zipWrong = ifelse(restData$zipCode < 0, T, F) # If/then/else!
SWIRL
install.packages("swirl")
when you want to use it:
  library(swirl)
swirl()
ls() # lists variables in your workspace...
rm(list=ls()) # to clear them all
to exit swirl: esc key, or type bye() to exit and save if you are at prompt.
skip(), play() (on your own), nxt() to come back to swirl, main() to main menu, info() shows these options
help.start() # for menu with more info
Top | Bottom (other notes)

Week 1: Overview of R, R data types and objects, reading and writing data
Introduction
this course: basics (data types), writing R scripts (control structures, functions, operations), profiling and debugging
Use R version 3.1.1
videos are v3.0.3, but use 3.1.1
Overview and History of R (16:07)
What is R? it is a dialect of S... by John Chambers at Bell Labs, 1976, was Fortran libraries. 1988 rewritten in C, started looking like today's version. The white book.. version 4 of S, 1998 is like todays, though there has been buying and selling by corporations. the green book Programming with Data by John Chambers
Chambers: (S) interactive environment where you don't think you are programming, but you slide into it as you get more complexity
R: 1991, NZ by Ihaka and Gentleman, 1996 paper, 1993 announced to the public, 1995 GNU public license so free software, 1996 R-help and R-devel public mailing lists. 1997 R Core Group, this group controls the source code
Features: similar to S, though semantics underneath are different. Runs on any standard OS even PS3. Frequent releases (annual major, intermittent bug fixes). Quite lean, with modular packages. Sophisticated graphics, useful for interactive work with powerful programming language for new tool development. Great user community with R-help R-devel and Stackoverflow
Free software: free + freedom of speech
Free software foundation: Freedom 0: to run for any purpose. Freedom 1: access to source code to study how it works and adapt it. Freedom 2: free to redistribute. Freedom 3: to improve program and release to public.
Drawbacks of R: 40 year old technology essentially. Little support for dynamic or 3-D graphics. Functionality based on consumer demand and user contributions. Objects must be stored in physical memory of computer... there have been advancements though... Lastly, but like all languages, it is not ideal for all possible situations.
Design of R system, two parts: base and everything else
  download base pkg from CRAN (Comprehensive R Archive Network)
base has base package, but also some other packages that are pretty fundamental (utils, stats, datasets, graphics, grDevices, grid, methods, tools, parallel, compiler, splines, tcltk, stats4).
'Recommend' packages, commonly used: boot, class, cluster, codetools, foreign, KernSmooth, lattice, mgc, nlme, rpart, survival, MASS, spatial, nnet, Matrix
more on CRAN, about 4000 packages, user contributed, uploaded every day. There are restrictions and standards though: documentation, other tests
Bioconductor project (bioconductor.org), for genomic data analysis
people put packages on their own websites also
R resources on CRAN (cran.r-project.org): intro, writing extensions, import/export, installation and aadmin, internals for really technical low-level info
book resources: including Chambers book, there is a list on r-project.org
Getting Help (13:53)
discussion boards
email, limitations and context
on your own: search forum archives, search web, rtfm, read FAQ, inspection/experimentation with your problem, skilled friend, programmers can read source code
if you do ask, let people know you did all that stuff on your own
error messages can be googled
if you do ask, consider: what steps will reproduce problem, what is expected, actual outputs, R or R packages versions and your OS, other things you tried
good example for subject header: R 2.15.0 lm() function on Mac OS X 10.6.3 -- seg fault on large data frame
Do: describe goal, not step. Be explicit about question. Provide min amount of info necessary. Be nice. Follow up with solution if you find it.
Don't: say you found a bug, grovel, post homework questions, email multiple lists at once, ask others to debug without saying what problem is
getting help on a function: ?abs . or if a symbol: ?`:` (that is the backtick)
Data Types Part 1 (9:26)
5 atomic classes of objects: (CLINC): character, numeric (real numbers), integer, complex, logical (t/f)
most basic object is a vector, can contain objects of same class
exception is a list: a vector that can contain objects of different classes (so, there are 2 different flavors of vectors: atomic vectors and lists)
x <- c(1,TRUE, "a") # vector of character class, they get converted to char
x <- list(1,TRUE, "a") # a list of 3 1-element vectors, no conversion
empty vectors can be created with
vector() # 2 args, class and length
numbers: generally treated as numeric (double precision real numbers)
to explicitly specify integer, but L sufix after it:
1L
Inf represents infinity, eg 1 / Inf = 0
NaN, not a number, can be thought of as missing value... 0/0=NaN
R objects can have attributes: names, dimnames; dimensions (matrices, arrays), class, length, other user-defined attributes/metadata.
attributes() # use to set or modify them
note vectors do not have dimensions, they have length though. (matrices and data frames have dimensions) If you give dimensions to a vector, it becomes a matrix.
entering input... <- is assignment operator, assigns value to a symbol (like = gets)
x <- 1 # really it is recorded as a numeric vector with one element
print(x) # explicit printing. you see: [1] 1
x # does same thing, this is called auto-printing
hitting enter triggers R engine to evaluate what you entered
x <- 1:20 # sequence of 1 to 20, creates a 20 element integer vector.
note pi:3 would be 3.14... 4.14... 5.14..., ie it increments by 1 but doesn't have to be integer
15:1 will count down not up, though again incrementing by 1
seq() is like :, but more control and options, 1:20 is same as seq(1,20), but can do seq(1,20,by=0.5), my_seq <- seq(5,10,length=30)
1:length(my_seq) is same as seq(along=my_seq) is same as seq_along(my_seq) # the last is probably the most efficient and optimized
Data Types Part 2 (9:45)
create vectors of objects with c() function
x <- c(0.5,0.6)
x <- c(T,FALSE)
x <- vector("numeric", length=10) # initializes it with default 0. I think you can omit the length=
mixing objects: R will coerce it to least common denominator
numeric and character: you get character
logical and numeric: you get numeric (true=1, false=0)
logical and character: you get character (logicals give you text, 'true' and 'false')
explicit coercion, use as.numeric(x), as.logical(x), as.character(x) # you must assign those to change the class of x
class(x) # tells you which kind
with as.logical(x), anything not 0 is true
nonsensical coercion results in NA values, and you get a warning
matrices are vectors (items must have same class) with a dimension attribute, which is an integer vector of length 2 (nrow, ncol)
note 'array' is a more general term for matrix, or really, a matrix is an array with two subscripts
M <- matrix(nrow = 2, ncol = 3)
dim(m) # [1] 2 3
attributes(m) # $dim | [1] 2 3
matrixes are constructed column-wise, ie start upper left then go down, then to next column
1 3 5
2 4 6
can create directly from vectors by adding dimension attribute to vector
m <- 1:10
dim(m) <- c(2,5)
cbind-ing and rbind-ing:
  x <- 1:3
y <- 10:12
cbind(x,y)
1 10
2 11
3 12
Lists: remember, like vector but can contain different classes. pretty handy, common...
x <- list(1, "a", TRUE, 1+4i)
prints differently, using double brackets
[[1]]
[1] 1
[[2]]
[1] "a"
etc.
so it is like treating each element of a list as a vector on its own
when you see double brackets [[ ]] this tells you it's a list
to look at elements of a list, you unclass it eg names(unclass(p))
Data Types Part 3 (11:51)
Factors: special vectors used to represent categorical data. (their class is factor.) They are unordered or ordered. Think of a factor as an integer vector where each integer has a label
treated specially by modelling functions like lm() and glm()
using factors with labels is better than using integers, because factors are self-describing; eg Male and Female vs 1 and 2
use factor function, with inputs being characters (character vector)
x < factor(c("yes", "yes", "no", "yes", "no"))
x
[1] yes yes no yes no
Levels: no yes
# see how the result of printing puts them in levels, alphabetically
table(x)
no yes
2 3
unclass(x)
[1] 2 2 1 2 1
attr(, "levels")
[1] "no" "yes"
to set order, say you want yes no not no yes:
x < factor(c("yes", "yes", "no", "yes", "no")), levels = c("yes", "no")
missing values: NA or NaN
is.na(), or is.nan()
nan = undefined math ops, na is everything else
NA values ahve a class also, so there are integer NA, character NA, etc.
a NaN is also NA, but an NA is not necessarily an NaN
x <- c(1,2,NaN,NA,3)
is.na(x)
[1] F F T T F
is.nan(x)
[1] F F T F F
Data frames: used to store tabular data
special type of list where every element has to have the same length
each element of list is like a column, and the length is the number of rows
you can coerce a list to a data frame, it will have max rows as of list, with blanks filled in by last row, not nulls
matrices store elements of same class only; data frames have columns of different classes
data frames have a special attribute called row.names (sounds like an index?)
create a data frame by calling read.table() or read.csv()
can convert to a matrix by calling data.matrix(), may have coercion
mydf <- data.frame(id=as.integer(),nobs=as.integer()) # to initialize a df with cols specified but no rows
x <- data.frame(foo = 1:4, bar = c(T,T,F,F))
x
foo bar
1 1 TRUE
2 2 TRUE
3 3 FALSE
4 4 FALSE
# notice how row names at far left are just numbers
nrow(x) # [1] 4
ncol(x) # [1] 2
you can assign names to R objects (all objects can have names) (note the way to do it differs quite a bit depending on what object you are naming: vector, list, matrix)
Vectors:
x <- 1:3
names(x)
NULL
names(x) <- c("foo", "bar", "norf")
x
foo bar norf
1 2 3
names(x)
[1] "foo" "bar" &norf"
Lists:
x <- list(a=1, b=2, c=3)
x
$a
[1] 1
$b
[1] 2
$c
[1] 3
# notice how you no longer see the [[ ]]...
Matrices too, they are called dimnames, you list row names first, then column names:
m <- matrix(1:4, nrow=2, ncol=2)
dimnames(m) <- list(c("a", "b"), c("c", "d"))
m
c d
a 1 3
b 2 4
Summary: Data types: (DAMNFLV): atomic classes (CLINC), vectors and lists, factors, matrices, data frames, names
Subsetting Part 1 (7:01)
operators to extract: [, [[, $
[: you get an object of the same class as original, back
[[: for lists or data frames, only extract a single element, may not be a list or data frame
$: for lists or data frames, by name; otherwise similar to [[
x <- c("a", "b", "c", "c", "d", "a")
x[1]
[1] "a" # note how numbering starts with 1 not 0 !!!
x[2:3]
[1] "b" "c"
x[4:2]
[1] "c" "c" "b" # so it prints elements 4, 3, 2
x[x > "a"]
[1] "b" "c" "c" "d"
u <- x > "a"
u
[1] F T T T T F
x[u]
[1] "b" "c" "c" "d"
what you are doing here: you are subsetting vector x with numeric or logical index
subsetting matrices: with (i,j) as (row,column), so [1,2] is row 1, column 2, [1, ] is full row 1
x <- matrix(1:6, 2,3)
x[1,2]
[1] 3
x[1, ]
[1] 1 3 5
by default, if single element retrieved, it returns a vector of length 1, not a 1x1 matrix... to turn off this behavior, use drop=FALSE
x[1,2,drop=FALSE]
subset a single column or row, similarly you get a vector not a matrix.. use same drop=FALSE here too
x[1, ,drop=FALSE]
Subsetting Part 2 (10:18)
subsetting lists: use [[ or $
x <- list(foo = 1:4, bar = 0.6) # two elements
x[1] # returns a list
$foo
[1] 1 2 3 4
x[[1]] # returns an integer vector, not a list
[1] 1 2 3 4
x$foo # returns same integer vector, identical to x[[1]]
x$bar # returns single number vector
[1] 0.6
x[["bar"]] # same as above, notice the quotes !
[1] 0.6
x["bar"] # this returns a list
$bar
[1] 0.6
remember: single bracket always returns a list
with bar above, you don't need to remember where it was
multiple elements: pass it a vector
x <- list(foo = 1:4, bar = 0.6, baz = "hello")
x[c(1,3)]
$foo
[1] 1 2 3 4
$baz
[1] "hello"
[[ vs $: $ limited in that you can only use it with literal names, whereas [[ can be used with computed indices
                                                                              name <- "foo" # note use of quotes
                                                                              x[[name]] # [[, this works!
                                                                              [1] 1 2 3 4
                                                                              x$name # $, this does not work!
                                                                              NULL
                                                                              x$foo
                                                                              [1] 1 2 3 4
                                                                              note [[ can take an integer sequence, it kind of recurses into the list
                                                                                      x[[c(1,3)]]
                                                                                      [1] 3
                                                                                      x[[1]][[3]] # returns the same result
                                                                                      partial matching is allowed with [[ and $
                                                                                                                            x$f
                                                                                                                          [1] 1 2 3 4
                                                                                                                          x[["f"]] # this does not work by default !
                                                                                                                          NULL
                                                                                                                          x[["f", exact = FALSE]] # this does work !
                                                                                                                          [1] 1 2 3 4
                                                                                                                          to remove missing values (NAs) from an object: create logical vector that says where they are, then use subsetting
                                                                                                                          x <- c(1,2,NA,4,NA,5)
                                                                                                                          bad <- is.na(x)
                                                                                                                          x[!bad] # ! is 'bang' or not operator
                                                                                                                          [1] 1 2 4 5
                                                                                                                          multiple things, and you want the subset with no missing values
                                                                                                                          x <- c(1,2,NA,4)
                                                                                                                          y <- c("a",NA,NA,"d")
                                                                                                                          good <- complete.cases(x,y)
                                                                                                                          good
                                                                                                                          [1] TRUE FALSE FALSE TRUE
                                                                                                                          x[good]
                                                                                                                          [1] 1 4
                                                                                                                          y[good]
                                                                                                                          [1] "a" "d"
                                                                                                                          if you use complete.cases() on a dataframe, you eliminate rows that have any NA in any column of that row
                                                                                                                          good <- complete.cases(airquality) # logical vector, index of complete rows
                                                                                                                          airquality[good, ][1:6, ]
                                                                                                                          Reading and Writing Data Part 1 (12:55)
                                                                                                                          Reading:
                                                                                                                            - read.table, read.csv: to read tabular data, returns data frame
                                                                                                                          - readLines: read lines of a text file, returns character vectors
                                                                                                                          - source: for reading in R code files (inverse of dump)
                                                                                                                          - dget: for R code files that have been de-parsed (inverse of dput)
                                                                                                                          - load: for reading in saved workspaces
                                                                                                                          - unserialize: for reading single R objects in binary form
                                                                                                                          Writing:
                                                                                                                            - write.table
                                                                                                                          - writeLines
                                                                                                                          - dump
                                                                                                                          - dput
                                                                                                                          - save
                                                                                                                          - serialize
                                                                                                                          read.table: most commonly used. arguments:
                                                                                                                            file: name of file or connection
                                                                                                                          header: logical, indicates if file has header line
                                                                                                                          sep: separator of columns
                                                                                                                          colClasses: character vector indicating class of each column
                                                                                                                          nrows: number of rows
                                                                                                                          comment.char: char string indicating the comment character
                                                                                                                          skip: number of lines to skip from the beginning
                                                                                                                          stringsAsFactors: should character variables be coded as factors?
                                                                                                                          small/moderate datasets, you can read table simply
                                                                                                                          data <- read.table("foo.txt")
                                                                                                                          R automatically will:
                                                                                                                            skip lines beginning with #
                                                                                                                          figure out how many rows there are and how much memory it needs to allocate
                                                                                                                          figure out what type of variable is in each column of the table
                                                                                                                          (note though that R will run faster and more efficiently if you do tell it!)
                                                                                                                          read.csv is same as read.table except the default sep is comma (space is expected for read.table), also header=true
                                                                                                                          with larger datasets:
                                                                                                                            read the help page for read.table! many hints here
                                                                                                                          roughly calculate memory required for storage. if more than your RAM, stop there...
                                                                                                                          set comment.char = "" if there are no commented lines in your file
                                                                                                                          colClasses, setting this can have huge impact
                                                                                                                          trick: read in some rows, have it run that:
                                                                                                                            initial <- read.table("datatable.txt", nrows = 100)
                                                                                                                          classes <- sapply(initial, class)
                                                                                                                          tabAll <- read.table("datatable.txt", colClasses = classes)
                                                                                                                          set nrows can help with memory usage, but won't run faster. use unix wc to calculate number of lines in a file. mildly overestimating is ok.
                                                                                                                          good to know things about your system:
                                                                                                                          how much memory (physical RAM)? what other apps in use? other users? what OS? 32 or 64bit? (64bit, can access more memory usually)
                                                                                                                          rough calc of memory requirements:
                                                                                                                          1.5M rows, 120 columns, all numeric
                                                                                                                          1.5M x 120 x 8 bytes/numeric
                                                                                                                          = 1.44 x 10^9 bytes
                                                                                                                          = 1.44 x 10^9 / 2^20 bytes/MB
                                                                                                                          = 1373 MB or 1.34GB
                                                                                                                          but you need a little more, for overhead in reading it in, do 2x this, so 2.8GB
                                                                                                                          Reading and Writing Data Part 2 (9:30)
                                                                                                                          beyond table, csv, text file, you can save by dumping and dputing
                                                                                                                          useful because resulting textual format is editable and potentially recoverable
                                                                                                                          it preserves metadata (while sacrificing some readability)
                                                                                                                          can be useful with version control programs like git or subversion
                                                                                                                          can be longer lived; if corruption, easier to fix problem
                                                                                                                          adhere to 'Unix philosophy'
                                                                                                                          downside: format is not very space-efficient
                                                                                                                          dput and dget: puts structure around it - writes R code about structure that you retrieve again on dget
                                                                                                                          dput(y)
                                                                                                                          structure(
                                                                                                                          list(...),
                                                                                                                          .Names = ...,
                                                                                                                          class = ...)
                                                                                                                          dput(y, file = "y.R")
                                                                                                                          new.y <- dget("y.R")
                                                                                                                          new.y #shows you the dataframe or whatever it was when you dput it in
                                                                                                                          dumping R objects: deparses multiple objects. read them back in using source.
                                                                                                                          x <- "foo"
                                                                                                                          y <- data.frame(a=1, b="a")
                                                                                                                          dump(c("x", "y"), file = "data.R") # notice you have to put in quotes in the concatenated vector
                                                                                                                          rm(x, y) # removes these
                                                                                                                          source("data.R")
                                                                                                                          x
                                                                                                                          [1] "foo"
                                                                                                                          interfaces to the outside world:
                                                                                                                          data read in using connection interfaces. can be made to files or to more exotic things.
                                                                                                                          file: open connection to a file
                                                                                                                          gzfile: to a file compressed with gzip
                                                                                                                          bzfile: bzip2 compressed
                                                                                                                          url: opens a connection to a webpage
                                                                                                                          str(file) # shows you the function parameters... description is name of file. open is r, w, a (appending), rb, wb, ab (b = in binary mode, Windows only?)
                                                                                                                          connections are power tools that let you navigate, for example to read only parts of a file
                                                                                                                          con <- gzfile("words.gz")
                                                                                                                          x <- readLines(con,10)
                                                                                                                          x
                                                                                                                          or, (put first lines in program?)
                                                                                                                          con <- url("http://www.jhsph.edu", "r") # this may take a while
                                                                                                                          x <- readLines(con)
                                                                                                                          head(x)
                                                                                                                          Introduction to swirl
                                                                                                                          experimental feature, swirl system modules, helps you learn R at your own pace
                                                                                                                          Statistics With Interactive R Learning
                                                                                                                          optional, but you get extra credit
                                                                                                                          QUIZ WEEK 1
                                                                                                                          11, 12: to read first few lines only:
                                                                                                                          hw1 <- read.csv("hw1_data.csv", nrows = 5) # to read sample to see column names and first few rows
                                                                                                                          13: number of rows, change to read whole file, then:
                                                                                                                          dim(hw1)
                                                                                                                          you could also then do head(hw1) to see the first few lines only
                                                                                                                          14, 15: last two rows:
                                                                                                                          tail(hw1, 2) # or, hw1[152:153, ]
                                                                                                                          16: missing values in ozone column:
                                                                                                                          badOzone <- is.na(hw1$Ozone)
                                                                                                                          length(hw1$Ozone[badOzone])
                                                                                                                          17: mean of ozone column, excluding missing values:
                                                                                                                          mean(hw1$Ozone[!badOzone])
                                                                                                                          18: subset of rows where Ozone > 31 and Temp > 90, what is mean of Solar.R?
                                                                                                                          o31t90 <- subset(hw1, Ozone > 31 & Temp > 90)
                                                                                                                          mean(o31t90$Solar.R)
                                                                                                                          19: what is mean of Temp when Month is 6?
                                                                                                                          m6 <- subset(hw1, Month == 6)
                                                                                                                          mean(m6$Temp)
                                                                                                                          20: max ozone value in May?
                                                                                                                          m5 <- subset(hw1[!badOzone,], Month == 5)
                                                                                                                          max(m5$Ozone)
                                                                                                                          Top | Bottom (other notes)

                                                                                                                          Week 2: Control structures, functions, scoping rules, dates and times
                                                                                                                          Control Structures Part 1 (7:10)
                                                                                                                          Control Structures Part 2 (8:11)
                                                                                                                          if() {} else {} # note you can assign this whole thing to a value using eg y <- if...
                                                                                                                          check out ifelse(test,yes,no) also! returns object of same shape as test.
                                                                                                                          for(i in __) {}
                                                                                                                          some variations on for loop: for (i in seq_along(x))... for (letter in x) {print(letter)}... can omit {} if only one item
                                                                                                                          seq_along takes a vector and presents as integer vector of 1 to length
                                                                                                                          can nest for loop, eg matrix: for (i in seq_len(nrow(x)))...
                                                                                                                          while(i __) {} # multiple conditions are evaluated L to R
                                                                                                                          repeat {..... break ....} # infinite loop until break is called. limited and tricky use of this construct, it is useful for convergence, though for loop probably better.
                                                                                                                          next: next to skip an iteration of the loop, example:
                                                                                                                          for(i in 1:100) {if (i==1) {next} .... }
                                                                                                                          return: break out of a function (or a loop in the function), it also returns a value
                                                                                                                          these above good in programs; the command-line *apply functions are more useful for interactive work
                                                                                                                          Functions Part 1 (9:17)
                                                                                                                          Functions Part 2 (7:13)
                                                                                                                          functions represent transition from user of R to programmer of R
                                                                                                                          f <- function(<arguments>) { ... }
                                                                                                                          functions are 'first class objects', which means you treat them like any other object (pass to other functions, nesting, return value of a function is the last expression to be evaluated in the function)
                                                                                                                          formal arguments (use formals() to list) are included in function definition. can also have missing or defaulted args.
                                                                                                                          args can match either positionally or by name, best to use position at least... but if long list and you want defaults for all but last, for example, then name is handy. also if position hard to remember, eg plotting
                                                                                                                          can also partially match... order is:
                                                                                                                          1. exact match of name
                                                                                                                          2. partial match
                                                                                                                          3. positional match
                                                                                                                          f <- function (a, b = 1, c = 2, d = NULL) {...} # illustrating defaults, or not
                                                                                                                          lazy evaluation: only evaluate if needed, i.e ok to not use an arg, but if you use an arg that you didn't send, get an error
                                                                                                                          the '...' arg: when extending another function and you don't want to copy whole arg list of original function
                                                                                                                          myplot <- function(x,y,type="1",...) { plot(x,y,type=type, ...) }
                                                                                                                          or, so that exra args can be passed to methods (example: mean)
                                                                                                                          or when nbr args not known in advance (examples: paste, which concatenates variable number of args, and cat, similar, can print to file though too)
                                                                                                                          any args after the '...' must be named explicitly and fully
                                                                                                                          Your First R Function (10:29)
                                                                                                                          put in text file usually.
                                                                                                                          later, you will want to put into a package
                                                                                                                          RStudio: create clean script
                                                                                                                          or in R: remember, working directory, and use source() to bring in the file's functions
                                                                                                                          example: get column means:
                                                                                                                            columnmean <- function(x, removeNA = TRUE) {
                                                                                                                              nc <- ncol(y)
                                                                                                                              means <- numeric(1:nc)
                                                                                                                              for (i in 1:nc) {
                                                                                                                                means[i] <- mean(x[,i], na.rm = removeNA)
                                                                                                                              }
                                                                                                                              means # remember functions just return last variable
                                                                                                                            }
                                                                                                                          Coding Standards (8:59)
                                                                                                                          1. use text files/editor
                                                                                                                          2. indent code (at least 4 spaces)
                                                                                                                          3. limit width to eg 80 col
                                                                                                                          4. limit length of individual functions, limit to one basic activity (don't read data, process it, print out in model; also good to have on single page of code; and can be useful in debugging)
                                                                                                                                                                                                rationale: helps you write sensible code: 8 spaces with 80 width kind of keeps you from doing more than 2 nested for loops
                                                                                                                                                                                                Scoping Rules Part 1 (10:32)
                                                                                                                                                                                                Scoping Rules Part 2 (8:34)
                                                                                                                                                                                                eg if you create a function called lm, it does your function not the one in stats package
                                                                                                                                                                                                R needs to bind a value (a function) to a symbol (lm in this case)... it searches through a series of environments
                                                                                                                                                                                                order is roughly: global environment (user's workspace), then namespaces of each of the packages on search list ie
                                                                                                                          search() # all pkgs loaded into R, in order, ends with base
                                                                                                                          new package loaded with library() goes into slot 2 and everything else gets pushed down a level
                                                                                                                          R has separate namespaces for functions and non-functions, so can have an object and a function named c
                                                                                                                          scoping in R is different than in S
                                                                                                                          R uses lexical scoping or static scoping
                                                                                                                          free variables are not assigned in formal variables of a function. R will search for the value in the function's environment. think of environment as collection of symbol,value pairs. they have a parent, and could have many children. empty environment has no parent.
                                                                                                                          a function + an environment = a closure or function closure
                                                                                                                          in function env?... if not, go to parent... then more parents until top-level, which is usually the global env workspace or namespace of a pkg.. then goes down the search list, until empty environment, it will throw an error there if still not found
                                                                                                                          more simply: function first, then global env
                                                                                                                          a function can return another function, it was defined there, here is where scoping rules more at play...
                                                                                                                          'constructor functions'
                                                                                                                          make.power <- function(n) {
                                                                                                                          pow <- function(x) { x^n }
                                                                                                                          pow
                                                                                                                          }
                                                                                                                          to see what is in a function's env? (the function closure)
                                                                                                                          ls(environment(cube)) # for cube function
                                                                                                                          [1] "n" "pow"
                                                                                                                          get("n", environment(cube))
                                                                                                                          [1] 3 # would be 2 for square
                                                                                                                          flexible vs dynamic: if a function called within a function, but defined outside of the function, and both inner and outer functions refer to variable y, with y defined as 2 inside and as 10 globally
                                                                                                                          lexical would use env where function defined so would be 10, dynamic would use env where function was called so would use 2, for the inner function. In R the calling env is aka the 'parent frame'
                                                                                                                          so remember: lexical: defined, dynamic: called
                                                                                                                          Scheme, Perl, Python and common Lisp all support lexical scoping ('all languages converge to Lisp')
                                                                                                                          consequences: all objects must be stored in memory; functions must carry a pointer to their defining env
                                                                                                                          Vectorized Operations (3:46)
                                                                                                                          operations making code more efficient, concise, easier to read (good for command line use feature)
                                                                                                                          eg 2 4 length vectors, if you add them you get eg 1,2,3,4 + 5,6,7,8 = 6,,8,10,12
                                                                                                                          and say x+2 returns 4 length vector
                                                                                                                          effectively, the 2 is a one-length vector and it gets recycled...
                                                                                                                          so what would 1,2,3,4 + 5,6 be? it would recycle the 5,6, so 6,8,8,10
                                                                                                                          BUT: if not divisible with no remainder, it does recycle and does give an answer but also a warning
                                                                                                                          matrices too, this is confusing though:
                                                                                                                            regular * makes element-wise multiplication, to get true matrix multiplication use x %*% y
                                                                                                                          x <- matrix(1:4,2,2); y <- matrix(rep(10,4),2,2)
                                                                                                                          x*y
                                                                                                                          10 30
                                                                                                                          20 40
                                                                                                                          x %*% y
                                                                                                                          40 40 60 60
                                                                                                                          Dates and Times (10:29)
                                                                                                                          dates represented with the Date class
                                                                                                                          times by the POSIXct and POSIXlt classes
                                                                                                                          dates and times are since 1970-01-01
                                                                                                                          x <- as.Date("1970-01-01")
                                                                                                                          x
                                                                                                                          ## [1] "1970-01-01"
                                                                                                                          prints like char string, but it's a print feature
                                                                                                                          unclass(x)
                                                                                                                          ## [1] 0
                                                                                                                          POSIX is family of standards.
                                                                                                                          POSIXct is just a very large integer, useful for storing in data frames
                                                                                                                          POSIXlt is a list, stores other useful info like day of the week, day of year, month, day of month
                                                                                                                          generic functions on both date and time (as.POSIXlt()):
                                                                                                                          weekdays: gives day of week
                                                                                                                          months: month name
                                                                                                                          quarters: Q1-Q4
                                                                                                                          x <- Sys.time()
                                                                                                                          x
                                                                                                                          [1] "2014-08-15 09:01:24 MDT"
                                                                                                                          x+3
                                                                                                                          [1] "2014-08-15 09:01:27 MDT" # i.e adds seconds!
                                                                                                                          p <- as.POSIXlt(x)
                                                                                                                          names(unclass(p))
                                                                                                                          ## [1] 'sec' 'min' 'hour' 'mday' 'mon' 'year' 'wday' 'yday' 'isdst' 'zone' 'gmtoff
                                                                                                                          p$wday
                                                                                                                          [1] 5 # starts monday = 1
                                                                                                                          most are numeric, except zone. 1 for isdst is yes for dst
                                                                                                                          say you have a text field with a date and want to convert it to an R-recognized date: use strptime:
                                                                                                                            datestring <- c("January 10, 2012 14:40", ...)
                                                                                                                          x <- strptime(datestring, "%B %d, %Y %H:%M")
                                                                                                                          this converts it to POSIXlt
                                                                                                                          use ?strptime for formatting help
                                                                                                                          now to operate on them:
                                                                                                                            you can't mix different classes (eg Date and POSIXlt)
                                                                                                                          otherwise just eg x-y, will say something like 'Time difference of 3 days'. there is not consistency here, it chooses what seems relevant, even if you do eg as.numeric(x-y). probably use the POSIXlt elements or something to get consistency
                                                                                                                          Top | Bottom (other notes)

                                                                                                                          Week 3: Loop functions, debugging tools
                                                                                                                          lapply (9:23)
                                                                                                                          these functions are powerful, they implement looping, good to use on command line, instead of for or while loops. lapply is 'workhorse' function...
                                                                                                                          1. lapply: apply a function over a list, evaluate it on each element, returns a list
                                                                                                                          2. sapply: like lapply but try to simplify the result (may not result in list)
                                                                                                                          3. apply: apply a function over the margins of an array
                                                                                                                          4. tapply: apply a function over subsets of a vector
                                                                                                                          5. mapply: multivariate version of lapply
                                                                                                                          6. split also useful, esp with lapply
                                                                                                                          lapply (and sapply) syntax: function (X, FUN, ...)
                                                                                                                          apply syntax: function (X, MARGIN, FUN, ...)
                                                                                                                          tapply syntax: function(X, INDEX, FUN = NULL, ..., simplify = TRUE)
                                                                                                                          split syntax: function(x, f, drop=FALSE, ...)
                                                                                                                          mapply syntax: function(FUN, ..., MoreArgs = NULL, SIMPLIFY = TRUE, USE.NAMES = TRUE)
                                                                                                                          1. lapply: apply a function over a list, evaluate it on each element, returns a list
                                                                                                                          lapply (and sapply) syntax: function (X, FUN, ...)
                                                                                                                          X is a list (will coerce if not), FUN is a function, other args via ...
                                                                                                                          lapply(x, mean) # returns list with same nbr cols, one row = mean of rows for each column (because mean is a summary function)
                                                                                                                          note runif(3) produces 3 random uniform variables
                                                                                                                          lapply(x, runif) # list has however many elements it started out with
                                                                                                                          want to specify parameters to the function? put in the lapply function (inheritance?)
                                                                                                                          lapply(x, runif, min=0, max=100)
                                                                                                                          heavy use of anonymous functions with these, i.e where function does not have a name, commonly is defined within the lapply
                                                                                                                          lapply(x, function(elt) elt[,1]) # elt is an arg not a name; here, say x is list of 2 matrices, elt is extracting first column of each matrix
                                                                                                                          2. sapply: like lapply but try to simplify the result (may not result in list)
                                                                                                                          sapply(x,mean) # lapply would return a list of elements with length 1, so sapply will return a vector, removing the list stacking. If all rows were equal sapply would return a matrix.
                                                                                                                          apply (7:21)
                                                                                                                          3. apply: apply a function over the margins of an array
                                                                                                                          most often applies function to rows and cols of a matrix (a 2-d array)
                                                                                                                          can be used with general arrays, taking the avg of an array of matrices for example
                                                                                                                          not faster, but fast to code
                                                                                                                          apply syntax: function (X, MARGIN, FUN, ...)
                                                                                                                          X is an array (matrix or...), MARGIN is an integer vector indicating which margins should be 'retained'
                                                                                                                          x <- matrix(rnorm(200), 20,10) # 20 rows, 10 col
                                                                                                                          apply(x,2,mean) # dimension 2 is 10 col, so you get 10 element vector back from this, a mean for each column... NOT the same as sapply(x,mean), but is essentially the same as sapply(data.frame(x),mean) (data frame may have column names, is the diference)
                                                                                                                          apply(x,1,sum) # dimension 1 is 20 rows, so you get 20 element vector back from this, a mean for each row
                                                                                                                          this gives some shortcuts for sums and means of matrix dimensions:
                                                                                                                          rowSums(x) # same as: apply(x,1,sum)
                                                                                                                          colMeans(x) # same as: apply(x,2,mean)
                                                                                                                          also rowMeans(), colSums()
                                                                                                                          they are faster as well as fast to code
                                                                                                                          apply(x, 1, quantile, probs = c(0.25, 0.75)) # the probs are needed from quantile function, these are passes as part of the ... . returns matrix with 2 rows and 20 columns.
                                                                                                                          a <- array(rnorm(2 * 2 * 10), c(2,2,10))
                                                                                                                          apply(a, c(1,2), mean) # keep rows/cols (2 and 2), and collapse the 3rd dimension (10)
                                                                                                                          rowMeans(a, dims=2) # same answer
                                                                                                                          tapply (3:17)
                                                                                                                          4. tapply: apply a function over subsets of a numeric vector; you subset it with factors
                                                                                                                          tapply syntax: function(X, INDEX, FUN = NULL, ..., simplify = TRUE)
                                                                                                                          X is a vector, INDEX is a factor or list of factors of same length as X
                                                                                                                          x <- c(rnorm(10), runif(10), rnorm(10,1))
                                                                                                                          f <- gl(3,10) # factors 1,2,3, each repeated 10 times
                                                                                                                          tapply(x, f, mean) # 3 means, for each distribution, result is an array that prints on 2 lines... if you add 'simplify = FALSE', result is a list (? says array...)
                                                                                                                          tapply(x, f, range) # list of 3 where each of the 3 has length 2
                                                                                                                          split (9:09)
                                                                                                                          6. split also useful, esp with lapply
                                                                                                                          tapply does a split really but that is not all; split does first part of it but without the summary part at the end
                                                                                                                          takes a vector or other objects and splits it into groups determined by a factor or list of factors
                                                                                                                          split syntax: function(x, f, drop=FALSE, ...)
                                                                                                                          x is a vector, list or dataframe
                                                                                                                          f is a factor or list of them
                                                                                                                          drop indicates whether empty factors levels should be dropped
                                                                                                                          (prior example)
                                                                                                                          split(x,f) # result is a list, with 2 levels, first has 3 entries and 10 each in each of those
                                                                                                                          commonly:
                                                                                                                          lapply(split(x,f), mean) # SAME AS tapply, no diff in efficiency it sounds like... splits x into the 3 factors, and gets mean of each of the 3
                                                                                                                          data frames:
                                                                                                                          s <- split(airquality, airquality$Month) # note, month was not a factor, but becomes one basically
                                                                                                                          sapply(s, function(x) colMeans(x[, c("Ozone", "Solar.R", "Wind")]), na.rm = TRUE)
                                                                                                                          splitting on more than one level, using interactions:
                                                                                                                          interaction(f1, f2) # if 2 and 5 levels, will create 10 levels i.e all combinations
                                                                                                                          you may get empty levels, use drop=TRUE to delete them
                                                                                                                          str(split(x, list(f1, f2), drop=TRUE)) # returns list of <=10 (drops empty ones) different interaction factors, with 0 to 2 elements in each. This is kind of handy to show all values, not summarize like you would get with tapply
                                                                                                                          mapply (4:46)
                                                                                                                          5. mapply: multivariate version of lapply
                                                                                                                          applies a function in parallel over a set of args
                                                                                                                          the others only apply function over elements of a list... what if you have 2 lists? could use a for loop... or mapply: takes multiple lists, and works in parallel
                                                                                                                          mapply syntax: function(FUN, ..., MoreArgs = NULL, SIMPLIFY = TRUE, USE.NAMES = TRUE)
                                                                                                                          to replace
                                                                                                                          list(rep(1,4), rep(2,3), rep(3,2), rep(4,1))
                                                                                                                          do instead:
                                                                                                                          mapply(rep, 1:4, 4:1)
                                                                                                                          vectorizing a function:
                                                                                                                          noise <- function(n, mean, sd) { rnorm(n, mean, sd) }
                                                                                                                          noise(1:5, 1:5, 2) # get result too summarized, not what you wanted...
                                                                                                                          instant vectorization of a function:
                                                                                                                          mapply(noise, 1:5, 1:5, 2) # list of 5, with 1,2,3,4,5 items in each list item
                                                                                                                          this is same as:
                                                                                                                          list(noise(1,1,2), noise(2,2,2), noise(3,3,2), noise(4,4,2), noise(5,5,2))
                                                                                                                          Debugging Tools Part 1 (12:33)
                                                                                                                          Debugging Tools Part 2 (6:25)
                                                                                                                          Debugging Tools Part 3 (8:21)
                                                                                                                          4 indicators: message, warning, error, condition... only an error is fatal.
                                                                                                                          1. message: diagnostic message, execution continues
                                                                                                                          2. warning: wrong but not fatal, exec continues. from 'warning' function. eg. 'NaNs produced'
                                                                                                                          3, error: fatal problem, exec stops, from 'stop' function
                                                                                                                          4. condition: indicates that something unexpected can occur; you can create your own condition
                                                                                                                          consider: what was input? how did you call funciton? expected __? got __? correct expectations? can you reproduce the problem (exactly)?
                                                                                                                          Debugging tools:
                                                                                                                          traceback, debug, browser, trace, recover
                                                                                                                          1. traceback: prints out function call stack after an error occurs (nothing if no error). you can enter traceback() in interactive mode
                                                                                                                          2. debug: flags a function for 'debug' mode, allowing you to step through execution one line at a time. enter in interactive, before running what you want to debug, eg: debug(lm). it will give you a 'Browse' prompt, enter 'n' for next to get through each line
                                                                                                                          3. browser: suspends exec when called and puts function in debug mode
                                                                                                                          4. trace: lets you insert debugging code into a function at specific places
                                                                                                                          5. recover: lets you modify the error behavior so that you can browse the function call stack. do at prompt: options(error = recover)
                                                                                                                          you can also insert print/cat statements of course
                                                                                                                          Top | Bottom (other notes)

                                                                                                                          Week 4: Simulation, code profiling
                                                                                                                          The str Function (6:08)
                                                                                                                          'the most important function in all of R'
                                                                                                                          - str for structure: compactly displays the internal structure of an R object
                                                                                                                          - diagnostic, alternative to summary() (or to head(), sort of transposed but also tells data type
                                                                                                                          - especially useful to show nested lists
                                                                                                                          - roughly one line per basic object
                                                                                                                          - generally, is to answer question: what's in this object?
                                                                                                                          Simulation Part 1 (7:47)
                                                                                                                          Simulation Part 2 (7:02)
                                                                                                                          Generating random numbers (r___): functions for probability distributions:
                                                                                                                            rnorm, dnorm, pnorm, rpois, rbinom... exp, gamma, more
                                                                                                                          rnorm: random Normal with given mean and sd
                                                                                                                          dnorm: rnorm density at a point or vector of points
                                                                                                                          pnorm: cumulative distribution
                                                                                                                          rbinom: eg rbinom(100, 1, 0.5)
                                                                                                                          rpois: random Poisson with a given rate
                                                                                                                          more generally, most prob dist functions have 4 functions, prefixed with:
                                                                                                                            r for random number generation
                                                                                                                          d for density
                                                                                                                          p for cumulative
                                                                                                                          q for quantile
                                                                                                                          So, for Normal dist, function syntax and defaults:
                                                                                                                            rnorm(n, mean=0, sd=1)
                                                                                                                          dnorm(x, mean=0, sd=1, log=FALSE) # most times you do want to do log?
                                                                                                                          pnorm(q, mean=0, sd=1, lower.tail=TRUE, log.p=FALSE) # lower.tail = FALSE evaluates upper tail instead
                                                                                                                          qnorm(p, mean=0, sd=1, lower.tail=TRUE, log.p=FALSE)
                                                                                                                          if psi is the cumulative dist function for a std Normal dist, then pnorm(q) = psi(q) and qnorm(p) = psy-1(p)
                                                                                                                          Generating random numbers: setting seed, to ensure reproducibility
                                                                                                                          set.seed(1)
                                                                                                                          rnorm(5)...
                                                                                                                          ALWAYS SET SEED WHEN DOING SIMULATION!
                                                                                                                            Poisson:
                                                                                                                            rpois(10,2) # generate 10, lambda = 2
                                                                                                                          ppois(4,2) # Pr(x <= 4)
                                                                                                                          Random nbrs from a linear model (y = B0 + B1x + error, with errors ~ N(0,22, x ~ N(0,1), B0 = 0.5, B1 = 2...)
                                                                                                                                                           set.seed(20)
                                                                                                                                                           x <- rnorm(100)
                                                                                                                                                           x <- rnorm(100,0,2)
                                                                                                                                                           y <- 0.5 + 2 * x + e
                                                                                                                                                           can do summary(y), plot(x,y) to inspect
                                                                                                                                                           GLM simulation from a Poisson model, mean ju, log u = B0 + B1x and B0=0.5 and B1=0.3
                                                                                                                                                           set.seed(1)
                                                                                                                                                           x <- rnorm(100)
                                                                                                                                                           log.mu <- 0.5 + 0.3 * x
                                                                                                                                                           y <- rpois(100, exp(log.mu))
                                                                                                                                                           Random sampling:
                                                                                                                                                             set.seed(1)
                                                                                                                                                           sample(1:10, 4) # vector of 4 between 1 and 10
                                                                                                                                                           sample(letters, 5) # vector of 5 letters, withOUT replacement
                                                                                                                                                           sample(1:10) # all 10 permutation
                                                                                                                                                           sample(1:10, replace = TRUE) # with replacement
                                                                                                                                                           R Profiler Part 1 (10:39)
                                                                                                                                                           R Profiler Part 2 (10:26)
                                                                                                                                                           R Profiler is a handy tool for debugging slow code
                                                                                                                                                           Profiling: systematic way to examine how much time is spent in different parts of a pgm, useful in optimizing code... profiling is better than guessing
                                                                                                                                                           find out where your code spends most of its time
                                                                                                                                                           'premature optimization is the root of all evil' - Donald Knuty
                                                                                                                                                           General Principles of Optimization:
                                                                                                                                                             1. Design first, then optimize
                                                                                                                                                           2. Remember: Premature optimization is the root of all evil
                                                                                                                                                           3. Measure, don't guess
                                                                                                                                                           4. If you're going to be a scientist, apply the same principles here!
                                                                                                                                                             use system.time(): input an R expression, it gives time to execute or until error, user time and elapsed time (elapsed time can be < user time if multiple processors ... R itself is not parallel, but packages can be, eg. multi-threaded BLAS libaries, parallel processing via the 'parallel' package)
                                                                                                                                                           user time, the user is the cpu
                                                                                                                                                           elapsed time > user time when reading stuff from the web... elapsed < user time, for instance, svd function for linear algebra (singular value d__), uses accelerate framework which is multi-threaded
                                                                                                                                                           But if you don't know where to start in measuring time?
                                                                                                                                                           use R Profiler, Rprof: (note usually it is already compiled but in some special instances you will need to compile R with proiler support)
                                                                                                                                                           Rprof() starts it; summaryRprof() summarizes output from Rprof()
                                                                                                                                                           DO NOT USE system.time() and Rprof() together!! Not meant to be used together.
                                                                                                                                                           Rprof() keeps track of function call stack regularly, default 0.02 sec
                                                                                                                                                           not useful if your code runs quicker than that, but then wouldn't be useful anyway
                                                                                                                                                           sample.interval=10000 # prints where it is at each interval
                                                                                                                                                           read result right to left, how functions call each other, rightmost calls next left calls next left calls.... calls leftmost. Not so easy to read this, so instead may want to use:
                                                                                                                                                             summaryRprof(), 2 methods for normalizing the data:
                                                                                                                                                             - by.total, time spent in each function / total run time
                                                                                                                                                           - by.self, time spent less spent in functions above in call stack, / total run time
                                                                                                                                                           by.total, tells how many times function appears, usually you don't spend a lot in the top level function, but more in some helper function called by the top... so by.self can be particularly more useful, more accurate picture
                                                                                                                                                           $by.total # 100% spent in top level function
                                                                                                                                                           $by.self # lm.fit spent more time than top-level lm function, for instance
                                                                                                                                                           $sample.interval # time to print it?
                                                                                                                                                           $sampling.time # like elapsed time
                                                                                                                                                           Summary... good to break your code into functions so profiled can give useful info
                                                                                                                                                           Note, C or Fortran code, if called, is not profiled
                                                                                                                                                           Scoping Rules (9:21)
                                                                                                                                                           Optimization is a combination of scoping and functions
                                                                                                                                                           several routines: optim, nlm, optimize, you pass a function whose arg is a vector of parameters, eg log-likelihood. Depends on data too... maybe let the user hold certain parameters fixed
                                                                                                                                                           create a 'constructor' function, which creates the 'objective' function that has all the data etc.
                                                                                                                                                           see code from website
                                                                                                                                                           when you define a function inside another, and print it, you get an 'environment' tag, where defining env is located in memory
                                                                                                                                                           optim will optimize multiple variables at once,
                                                                                                                                                           optimize only works on one variable
                                                                                                                                                           summary: objective functions can be 'built' with all data needed into closing env, you don't need to specify the data/arg lists each time, due to lexical scoping
                                                                                                                                                           Order on command line: global env, then namespaces of each package
                                                                                                                                                           search() # shows your packages, in order; global always first, base always last, new ones go in position 2 and rest move down
                                                                                                                                                           note object c and function c are separate namespaces
                                                                                                                                                           remember, for free variables, values searched for in the env in which function DEFINED. Env is collection of symbol, value pairs. every env has a parent, and can have one or more children. Function + env = a 'closure' or 'function closure'
                                                                                                                                                           Search order: where defined... parent... on down sequence of parents until top level (global env) or pkg namespace... on down the search list until we hit empty env, after that an error is thrown
                                                                                                                                                           ... more that is repeated from earlier lecture ...
                                                                                                                                                           Application: optimization - why is thi useful?
                                                                                                                                                           things like optim, nlm, optimize
                                                                                                                                                           Top | Bottom (other notes)

                                                                                                                                                           Other Notes
