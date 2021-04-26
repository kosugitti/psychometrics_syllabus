rm(list=ls())
library(tidyverse)
old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))
# データを入力
dat <- matrix(c(
    2.13, 460,
    2.42, 500,
    2.26, 473,
    3.87, 620,
    3.90, 690,
    2.43, 512,
    3.44, 582,
    2.15, 550,
    2.18, 485,
    3.00, 650,
    3.42, 593,
    2.55, 528,
    3.19, 585,
    3.05, 569,
    2.52, 518
),
ncol = 2, byrow = T
) %>% transform

g <- dat %>% 
    rename(X=X1,Y=X2) %>% 
    mutate(ID = LETTERS[1:NROW(dat)]) %>% 
    ggplot(aes(x=X,y=Y))+geom_point()+
    xlab("高校の内申点")+ylab("大学の成績") 
g
ggsave(g,filename = "../images/text09/Rplot09_01.png", dpi = 600, width = 8, height = 6)


g2 <- g+geom_line()
g3 <- g2+geom_smooth(se=F)
g4 <- g+geom_smooth(method="lm",se=F)

g <- gridExtra::grid.arrange(g2,g4)
ggsave(g,filename = "../images/text09/Rplot09_02.png", dpi = 600, width = 8, height = 6)

g4


rxy <- cor(dat)
bx <- mean(dat$X1)
by <- mean(dat$X2)
sx <- sd(dat$X1)
sy <- sd(dat$X2)

fit1 <- lm(X2 ~ X1, data = dat)
fit1$coefficients
b1 <- rxy[1,2]*sy/sx
b2 = by - b1*bx
b1
b2
fit2 <- lm(X1 ~ X2,data=dat)
fit2

regFunc1 <- function(x1){
    93.71779*x1+288.73711
}

regFunc2 <- function(x2){
    0.008046*x2-1.626110
}

(x2 <- regFunc1(3.42))
(x1 <- regFunc2(x2))
for(i in 1:100){
    (x2 <- regFunc1(x1))
    (x1 <- regFunc2(x2))
}
x1
x2
summary(dat)

dat.df %>% ggplot(aes(x = 高校の成績, y = 大学の成績)) +
    geom_point() +
    geom_smooth(method = "lm", se = F) -> m1
plot(m2)

fit1 <- lm(大学の成績 ~ 高校の成績, data = dat.df)
dat.df %>%
    dplyr::mutate(yhat = fit1$fitted.values) %>%
    ggplot(aes(x = yhat, y = 大学の成績)) +
    geom_point() -> g1