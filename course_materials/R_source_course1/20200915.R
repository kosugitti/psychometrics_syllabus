library(tidyverse)


# ベルヌーイ分布 -----------------------------------------------------------------

library(extraDistr)
rbern(100,prob=0.5)
rbern(100,prob=0.9)

rbern(10,prob=0.1)



# ベルヌーイ尤度関数 ---------------------------------------------------------------


b_lik <- function(x,theta){
  n <- length(x)
  k <- sum(x)
  temp <- theta^k * (1-theta)^(n-k)
  return(temp)
}

b_log_lik <- function(x,theta){
  n <- length(x)
  k <- sum(x)
  temp <- theta^k * (1-theta)^(n-k)
  return(log(temp))
}

b_lik(c(1,1,1),theta = 0.5)

b_lik(c(1,1,1,0,0),theta=0.59)
b_lik(c(1,1,1,0,0),theta=0.6)
b_lik(c(1,1,1,0,0),theta=0.61)
f <- expression( x^3*(1-x)^2 )
D(f, "x")
foo <- function(x){x^3*(1-x)^2}
x <- seq(0,1,0.001)
y <- foo(x)
plot(x,y)
optimize(foo,c(0,1),maximum = T)
# 尤度関数の描画 -----------------------------------------------------------------


ggplot(data=data.frame(X=c(0,1)),aes(x=X))+
  stat_function(fun=b_lik,args = list(x=c(1,1,0,0,1)))+
  xlab("theta")+ylab("likelihood")
ggsave(filename = "Rplot24_01.png", dpi = 600, width = 4, height = 2)


ggplot(data=data.frame(X=c(0,1)),aes(x=X))+
  stat_function(fun=b_log_lik,args = list(x=c(1,1,0,0,1)))+
  xlab("theta")+ylab("log-likelihood")
ggsave(filename = "Rplot24_02.png", dpi = 600, width = 4, height = 2)


# 正規分布の例 ------------------------------------------------------------------

n_log_lik <- function(x){
  tmp <- log(dnorm(165,x,10))+log(dnorm(173,x,10))+log(dnorm(182,x,10))
  return(tmp)
}
ggplot(data=data.frame(X=c(150,200)),aes(x=X))+
  stat_function(fun=n_log_lik)+
  xlab("mu")+ylab("log-likelihood")
ggsave(filename = "Rplot24_03.png", dpi = 600, width = 4, height = 2)

N <- 50
mu <- seq(150,190,length.out = N)
sig <- seq(5,11,length.out = N)
n2lik <- data.frame(mu=rep(mu,N),sig=rep(sig,each=N),LL=NA)
n2_log_lik <- function(mu,sig){
  tmp <- log(dnorm(165,mu,sig))+log(dnorm(173,mu,sig))+log(dnorm(182,mu,sig))
  return(tmp)
}

n2lik$LL = purrr::map2(.x=n2lik$mu,.y=n2lik$sig,~n2_log_lik(.x,.y))
library(animation)
library(scatterplot3d)
scatterplot3d(n2lik$mu,n2lik$sig,n2lik$LL,col.axis="blue",angle = 150,
               col.grid="lightblue", pch=20,xlab="mu",ylab="sigma",zlab="log-likelihood")


plot3d360 <- function() {
  for (i in 1:360)  {
    scatterplot3d(n2lik, angle=i, pch =20, main=i)
  }
}
saveGIF(plot3d360(), interval=0.05,movietype="gif", outdir=getwd(),width=640, height=480)

## 推定値
n2_log_lik_v <- function(V){
  mu <- V[1]
  sig <- V[2]
  tmp <- log(dnorm(165,mu,sig))+log(dnorm(173,mu,sig))+log(dnorm(182,mu,sig))
  return(-tmp)
}
optim(par=c(150,5),n2_log_lik_v)      


library(gridExtra)
ts <- Sys.time()
# 正規乱数のはなし
X1 <- rnorm(100)
X2 <- rnorm(1000)
X3 <- rnorm(10000)
X4 <- rnorm(1e+05)

p1 <- ggplot(as.data.frame(X1), aes(x = X1)) + geom_histogram(binwidth = 0.1) + 
  xlim(-4, 4) + xlab("N=100")
p2 <- ggplot(as.data.frame(X2), aes(x = X2)) + geom_histogram(binwidth = 0.1) + 
  xlim(-4, 4) + xlab("N=1000")
p3 <- ggplot(as.data.frame(X3), aes(x = X3)) + geom_histogram(binwidth = 0.1) + 
  xlim(-4, 4) + xlab("N=10000")
p4 <- ggplot(as.data.frame(X4), aes(x = X4)) + geom_histogram(binwidth = 0.1) + 
  xlim(-4, 4) + xlab("N=100000")

grid.arrange(p1, p2, p3, p4, ncol = 2) -> g5
ggsave(g5,filename = "Rplot25_01.png", dpi = 600, width = 8, height = 6)
ts - Sys.time()

X <- rnorm(100000,mean=0,sd=1)
length(X[X>1])/100000

1-pnorm(1,mean=0,sd=1)
