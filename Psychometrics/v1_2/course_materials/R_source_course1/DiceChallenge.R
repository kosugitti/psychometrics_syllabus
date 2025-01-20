set.seed(12345)
# サイコロを振る回数
N <- 10
# サイコロの目を乱数で発生させる
## runifはrandom + uniformの合成で，「一様分布の乱数を発生させる」関数。
## ここでは1から7までの実数を生成し，それをas.integerで整数にする(小数以下を切り捨てる)
y <- as.integer(runif(N,1,7))
hist(y)

##カッコよく描画する
library(ggplot2)
# いろんな回数サイコロを振る
y1 <- as.integer(runif(10,1,7))
y2 <- as.integer(runif(100,1,7))
y3 <- as.integer(runif(1000,1,7))
y4 <- as.integer(runif(10000,1,7))
y5 <- as.integer(runif(50000,1,7))
y6 <- as.integer(runif(100000,1,7))
# データフレームにする
## DICE＝出た目,Trialはどの条件だったか
dat <- data.frame(Trial = c(rep(1,10),rep(2,100),rep(3,1000),rep(4,10000),rep(5,50000),rep(6,100000)),
    DICE=c(y1,y2,y3,y4,y5,y6))
## それぞれ名義尺度水準
dat$DICE <- as.factor(dat$DICE)
dat$Trial <- factor(dat$Trial,labels = c("N=10","N=100","N=1000","N=10000","N=50000","N=100000"))
summary(dat)
## 描画
ggplot(dat,aes(x=DICE,fill=DICE))+geom_bar(stat="count")+facet_wrap(~Trial, scales = "free")
