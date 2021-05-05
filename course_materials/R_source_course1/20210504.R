rm(list=ls())
library(tidyverse)
library(MASS)
library(scatterplot3d)
old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))
# 3Dプロット ------------------------------------------------------------------

N <- 300
X <- data.frame(mvrnorm(N,c(0,0,0),matrix(c(1,0.7,0.3,
                                            0.7,1,0,
                                            0.3,0,1),nrow=3)))
names(X) <- c("Y","X1","X2")
fit <- lm(Y ~ X1+X2,data=X) 

png("../images/text10/Rplot10_01.png", width = 1200, height = 800)  # 描画デバイスを開く

par(family="HiraKakuProN-W3")
par(mfcol=c(1,2))
plot(X$X1,X$Y,xlab="X1",ylab="Y")
abline(fit)

s3d <- scatterplot3d(X$X1,X$X2,X$Y, pch=16, highlight.3d=T,angle=55,
                     main="",xlab="X1",ylab="X2",zlab="Y")
summary(fit)
s3d$plane3d(fit)

dev.off()                                

# 重回帰分析 -------------------------------------------------------------------

# データを入力
dat <- matrix(c(
    2.13, 460,5.34,
    2.42, 500,7.97,
    2.26, 473,6.30,
    3.87, 620,7.82,
    3.90, 690,8.40,
    2.43, 512,6.60,
    3.44, 582,7.80,
    2.15, 550,7.10,
    2.18, 485,7.30,
    3.00, 650,7.20,
    3.42, 593,7.80,
    2.55, 528,6.50,
    3.19, 585,8.20,
    3.05, 569,7.50,
    2.52, 518,7.60
),
ncol = 3, byrow = T
)
# データフレーム型に変換します
dat.df <- transform(dat)
names(dat.df) <- c("内申点", "入試","評定")

dat.df %>% knitr::kable(format = "latex", caption = "高校と大学の成績例2")

library(GGally)
g <- ggpairs(dat.df)
ggsave(g,filename = "../images/text10/Rplot10_02.png", dpi = 600, width = 8, height = 6)
g
result <- lm(評定~内申点+入試,data=dat.df)
summary(result)

dat.df$Yhat <- result$fitted.values
dat.df$Residuals <- result$residuals
dat.df %>% 
    mutate(ID=LETTERS[1:15]) %>% 
    dplyr::select(ID,内申点,入試,評定,Yhat,Residuals) %>% 
    knitr::kable(format = "latex", caption = "予測値と残差")

g <- ggpairs(dat.df)
ggsave


## 部分相関係数
lm2 <- lm(評定~内申点,data=dat.df)
dat.df$partX1 <- lm2$residuals
cor(dat.df$partX1,dat.df$入試)

## 標準化
dat.z <- scale(dat) %>% as.data.frame %>% 
    dplyr::rename(内申点z=V1,入試z=V2,評定z=V3)
lm3 <- lm(評定z~内申点z+入試z,data=dat.z)
summary(lm3)


library(car)
vif(lm3)


# 重回帰の罠 -------------------------------------------------------------------
library(MASS)
set.seed(46)
N <- 500
mu <- c(50,10,10)
sds <- c(10,10,10)
Sigma <- diag(sds^2)
Sigma[1,2] = sds[1]*sds[2]*-0.6
Sigma[1,3] = sds[1]*sds[3]*0.3
Sigma[2,3] = sds[2]*sds[3]*0.4
Sigma[2,1] = Sigma[1,2]
Sigma[3,1] = Sigma[1,3]
Sigma[3,2] = Sigma[2,3]
X <- mvrnorm(N,mu,Sigma) %>% as.data.frame %>% as_tibble
fit <- lm(V3~V1+V2,data=X)
fit
plot.new()
scatterplot3d(X$V1,X$V2,X$V3, pch=16, highlight.3d=T,angle=55,
                     main="",xlab="X1",ylab="X2",zlab="Y")
s3d$plane3d(fit)
newX <- data.frame(V1=c(30,30,40,40),
                   V2=c(0,10,0,10))
newX
predict(fit,newX)
