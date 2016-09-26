Intermediate Programming in R
========================================================
author: Daniel Marcelino
date: 2015-06-21


IF CONDITION
========================================================

```r
x <- 5

if(x > 0){
   print("True")
}
```

```
[1] "True"
```



IF ELSE
========================================================

```r
x <- -5

if(x > 0){
   print("True")
} else {
   print("False")
}
```

```
[1] "False"
```


NESTED IF
========================================================

```r
x <- -2
if (x < 0) {
   print("Negative number")
} else if (x > 0) {
   print("Positive number")
} else
   print("Zero")
```

```
[1] "Negative number"
```


COMBINATION OF IF AND ELSE
========================================================

```r
x <- 700

if(x!=0) {
  print("Party")
  if(x>1000){
    print("Big Hotel")
  } else{
    print("small Hotel")
  }
}else
  print("no party")
```

```
[1] "Party"
[1] "small Hotel"
```



FOR loop
========================================================


```r
for(i in 1:4) {
 for(j in 1:10) {
 print(paste("step",i,j))
 }
}
```

```
[1] "step 1 1"
[1] "step 1 2"
[1] "step 1 3"
[1] "step 1 4"
[1] "step 1 5"
[1] "step 1 6"
[1] "step 1 7"
[1] "step 1 8"
[1] "step 1 9"
[1] "step 1 10"
[1] "step 2 1"
[1] "step 2 2"
[1] "step 2 3"
[1] "step 2 4"
[1] "step 2 5"
[1] "step 2 6"
[1] "step 2 7"
[1] "step 2 8"
[1] "step 2 9"
[1] "step 2 10"
[1] "step 3 1"
[1] "step 3 2"
[1] "step 3 3"
[1] "step 3 4"
[1] "step 3 5"
[1] "step 3 6"
[1] "step 3 7"
[1] "step 3 8"
[1] "step 3 9"
[1] "step 3 10"
[1] "step 4 1"
[1] "step 4 2"
[1] "step 4 3"
[1] "step 4 4"
[1] "step 4 5"
[1] "step 4 6"
[1] "step 4 7"
[1] "step 4 8"
[1] "step 4 9"
[1] "step 4 10"
```



For & IF Logic 
========================================================



```r
d<-data.frame(a=c(1:10),b=c(20,30))

for(i in row(d)){
  if(d[i,"a"]<5){
    a<-1
  }else
    a<-0
  if(d[i,"b"]==20){
    b<-1
  }else
    b<-0
   print(paste(a,b))
}
```

```
[1] "1 1"
[1] "1 0"
[1] "1 1"
[1] "1 0"
[1] "0 1"
[1] "0 0"
[1] "0 1"
[1] "0 0"
[1] "0 1"
[1] "0 0"
[1] "1 1"
[1] "1 0"
[1] "1 1"
[1] "1 0"
[1] "0 1"
[1] "0 0"
[1] "0 1"
[1] "0 0"
[1] "0 1"
[1] "0 0"
```




Alternate 5 & 10
========================================================


```r
for(i in 1:2) {
 for(j in 1:10) {
 if(j<=5){
   print(paste(i,"step",3))
 }else
   print(paste(i,"step",7))
 }
}
```

```
[1] "1 step 3"
[1] "1 step 3"
[1] "1 step 3"
[1] "1 step 3"
[1] "1 step 3"
[1] "1 step 7"
[1] "1 step 7"
[1] "1 step 7"
[1] "1 step 7"
[1] "1 step 7"
[1] "2 step 3"
[1] "2 step 3"
[1] "2 step 3"
[1] "2 step 3"
[1] "2 step 3"
[1] "2 step 7"
[1] "2 step 7"
[1] "2 step 7"
[1] "2 step 7"
[1] "2 step 7"
```

Functions
========================================================



```r
myfun <-function(a,b)
{
m<-a*b
return(m)
}

myfun(a=7,3)
```

```
[1] 21
```


```r
myfun<-function(a,b){
  for(i in 1:a) {
    for(j in 1:b) {
      print(paste(i,"step",j))
    }
  }
}
myfun(b=10,a=4)
```

```
[1] "1 step 1"
[1] "1 step 2"
[1] "1 step 3"
[1] "1 step 4"
[1] "1 step 5"
[1] "1 step 6"
[1] "1 step 7"
[1] "1 step 8"
[1] "1 step 9"
[1] "1 step 10"
[1] "2 step 1"
[1] "2 step 2"
[1] "2 step 3"
[1] "2 step 4"
[1] "2 step 5"
[1] "2 step 6"
[1] "2 step 7"
[1] "2 step 8"
[1] "2 step 9"
[1] "2 step 10"
[1] "3 step 1"
[1] "3 step 2"
[1] "3 step 3"
[1] "3 step 4"
[1] "3 step 5"
[1] "3 step 6"
[1] "3 step 7"
[1] "3 step 8"
[1] "3 step 9"
[1] "3 step 10"
[1] "4 step 1"
[1] "4 step 2"
[1] "4 step 3"
[1] "4 step 4"
[1] "4 step 5"
[1] "4 step 6"
[1] "4 step 7"
[1] "4 step 8"
[1] "4 step 9"
[1] "4 step 10"
```


Find Odd Or Even Number By Passing Values
========================================================


```r
Number<-function(x)
if (x%%2==0){
   print("Even Number")
} else
   print("Odd number")
Number(x=11)
```

```
[1] "Odd number"
```

Array With Exponentials(^)
========================================================


```r
Question<-function(N){
a=0
k=0
for(i in 1:200){
for(j in 1:200){
a=a+1
k[a]=2^i*3^j
}
}
k<-sort(k)
return(k[N])
}

Question(6)
```

```
[1] 48
```


Array with Display Odd Or Even
========================================================

```r
Question<-function(N){
a=0
k=0
for(i in 0:5){
for(j in 0:5){
a=a+1
k[a]=2^i*3^j
}
}
k<-sort(k)
if(k[N]%%2==0){
sprintf("%d is Even Number",k[N])
} else 
sprintf("%d is Odd Number",k[N])
}
```



```
[1] "3 is Odd Number"
```
