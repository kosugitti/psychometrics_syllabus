rm(list=ls())
# 母平均40，母SD10
# サンプルサイズ16 標本平均45

diff <- 1.96 * 10* (1/sqrt(16))
45 -diff
45 + diff
1-pnorm(45,40,10)


# サンプルサイズ16　不偏SD9

diff <- qt(0.025,df=15) * 9 * (1/sqrt(16))
45 - diff
45 + diff

tval <- (45-40)/(9/4)
1-pt(q=tval,df=15)

tval <- (0.3*sqrt(49))/(1-0.3^2)
(1-pt(tval,df=47))*2

library(MASS)
X <- mvrnorm(n=20,mu=c(0,0),Sigma=matrix(c(1,0.5,0.5,1),ncol=2),empirical = T)
cor(X)
cor.test(X[,1],X[,2])
