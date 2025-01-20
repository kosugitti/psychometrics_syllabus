library(tidyverse)
set.seed(12345)
N <- 5
X <- rnorm(N,10,8) %>% round
X

mean(X)
var(X)
sd(X)
mean((X-mean(X))^2)
# 95%
mean(X) + 1.96 * (8/sqrt(5))
qnorm(0.975,12.2,(8/sqrt(5)))
mean(X) - 1.96 * (8/sqrt(5))
# 間違えてみる。sとnを入れ替え
mean(X) + 1.96 * (5/sqrt(8))
mean(X) - 1.96 * (5/sqrt(8))
#
t.test(X)

library(ggplot2)
limitRange <- function(fun, min, max) {
    function(x) {
        y <- fun(x)
        y[x < min  |  x > max] <- NA
        return(y)
    }
}

limitRange2 <- function(fun, min, max) {
    function(x) {
        y <- fun(x,mean=12.2,sd=8/sqrt(5))
        y[x < min  |  x > max] <- NA
        return(y)
    }
}

ggplot(data.frame(x=c(-4, 4)), aes(x=x)) + stat_function(fun = dnorm) +
    stat_function(fun = limitRange(dnorm, -1.96, 1.96),geom="area", fill="blue", alpha=0.2)
ggplot(data.frame(x=c(0, 25)), aes(x=x)) + 
    stat_function(fun = dnorm,args=list(mean=12.2,sd=8/sqrt(5))) +
    stat_function(fun = limitRange2(dnorm, 5.187691,19.2131),geom="area", fill="blue", alpha=0.2)
