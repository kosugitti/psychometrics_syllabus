library(tidyverse)
old = theme_set(theme_gray(base_family="HiraKakuProN-W3"))
# サイコロを無限回降る --------------------------------------------------------------
set.seed(12345)
# サイコロを振る回数
N <- 10
# サイコロの目を乱数で発生させる
## runifはrandom + uniformの合成で，「一様分布の乱数を発生させる」関数。
## ここでは1から7までの実数を生成し，それをas.integerで整数にする(小数以下を切り捨てる)
y <- as.integer(runif(N, 1, 7))
hist(y)

## カッコよく描画する
library(ggplot2)
# いろんな回数サイコロを振る
y1 <- as.integer(runif(10, 1, 7))
y2 <- as.integer(runif(100, 1, 7))
y3 <- as.integer(runif(1000, 1, 7))
y4 <- as.integer(runif(10000, 1, 7))
y5 <- as.integer(runif(50000, 1, 7))
y6 <- as.integer(runif(100000, 1, 7))
# データフレームにする
## DICE＝出た目,Trialはどの条件だったか
dat <- data.frame(
  Trial = c(rep(1, 10), rep(2, 100), rep(3, 1000), rep(4, 10000), rep(5, 50000), rep(6, 100000)),
  DICE = c(y1, y2, y3, y4, y5, y6)
)
## それぞれ名義尺度水準
dat$DICE <- as.factor(dat$DICE)
dat$Trial <- factor(dat$Trial, labels = c("N=10", "N=100", "N=1000", "N=10000", "N=50000", "N=100000"))
summary(dat)
## 描画
ggplot(dat, aes(x = DICE, fill = DICE)) +
  geom_bar(stat = "count") +
  facet_wrap(~Trial, scales = "free")

dat %>%
  dplyr::filter(Trial == "N=100") %>%
  ggplot(aes(x = DICE, fill = DICE)) +
  geom_bar()

# 推測する --------------------------------------------------------------------

data.frame(
  key = as.factor(c("降雨", "散水車", "水道管", "通行人")),
  Prob = c(0.25, 0.25, 0.25, 0.25)
) %>%
  ggplot(aes(x = key, y = Prob, fill = key)) +
  geom_bar(stat = "identity") +
  ylim(0, 1) +
  theme_gray(base_family = "HiraKakuPro-W3")

data.frame(
  key = as.factor(c("降雨", "散水車", "水道管", "通行人")),
  Prob = c(0.00, 1 / 3, 1 / 3, 1 / 3)
) %>%
  ggplot(aes(x = key, y = Prob, fill = key)) +
  geom_bar(stat = "identity") +
  ylim(0, 1) +
  theme_gray(base_family = "HiraKakuPro-W3")


data.frame(
  key = as.factor(c("降雨", "散水車", "水道管", "通行人")),
  Prob = c(0.00, 0, 1 / 2, 1 / 2)
) %>%
  ggplot(aes(x = key, y = Prob, fill = key)) +
  geom_bar(stat = "identity") +
  ylim(0, 1) +
  theme_gray(base_family = "HiraKakuPro-W3")


data.frame(
  key = as.factor(c("降雨", "散水車", "水道管", "通行人")),
  Prob = c(0.00, 0, 0, 1)
) %>%
  ggplot(aes(x = key, y = Prob, fill = key)) +
  geom_bar(stat = "identity") +
  ylim(0, 1) +
  theme_gray(base_family = "HiraKakuPro-W3")


# 離散から連続へ -----------------------------------------------------------------

N <- 1000
Y <- rnorm(N, 160, 10)
Y %>%
  as_tibble() %>%
  ggplot(aes(x = value)) +
  geom_histogram(binwidth = 5, fill = "#56B4E9", colour = "#0072B2", boundary = 0, closed = "left") +
  ylim(0, 220) +
  stat_bin(binwidth = 5, boundary = 0, closed = "left", aes(label = ..count..), geom = "text", vjust = -0.5, color = "#993F00")

Y %>%
  as_tibble() %>%
  ggplot(aes(x = value)) +
    geom_histogram(binwidth =2.5, fill = "#56B4E9", colour = "#0072B2", boundary = 0, closed = "left") +
    ylim(0, 120) +
    stat_bin(binwidth = 2.5, boundary = 0, closed = "left", aes(label = ..count..), geom = "text", vjust = -0.5, color = "#993F00")

Y %>%
  as_tibble() %>%
  ggplot(aes(x = value)) +
    geom_histogram(binwidth =0.5, fill = "#56B4E9", colour = "#0072B2", boundary = 0, closed = "left") +
    ylim(0, 40) +
    stat_bin(binwidth = 0.5, boundary = 0, closed = "left", aes(label = ..count..), geom = "text", vjust = -0.5, color = "#993F00")




# 二項分布 --------------------------------------------------------------------

data.frame(Ns = seq(0, 50)) %>%
  dplyr::mutate(Prob = dbinom(Ns, 50, 0.2)) %>%
  ggplot(aes(x = Ns, y = Prob)) +
  geom_bar(stat = "identity")


#  正規分布の描画 ----------------------------------------------------------------
library(ggplot2)
limitRange <- function(fun, min, max) {
  function(x) {
    y <- fun(x)
    y[x < min | x > max] <- NA
    return(y)
  }
}
# p(x>2)
p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x))
p + stat_function(fun = dnorm) +
  stat_function(
    fun = limitRange(dnorm, -4, pnorm(1.0)),
    geom = "area", fill = "blue", alpha = 0.2
  ) +
  theme(
    axis.text = element_text(size = 16),
    axis.title = element_text(size = 14, face = "bold")
  ) + ylab("Probability density")



x <- rnorm(1000, mean = 75, sd = 15)
x <- x[x <= 100]
hist(x)


# 例題 ----------------------------------------------------------------------

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
)
# データフレーム型に変換します
dat.df <- transform(dat)
names(dat.df) <- c("高校の成績", "大学の成績")
dat.df %>% ggplot(aes(x = 高校の成績, y = 大学の成績)) +
  geom_point() +
  geom_smooth(method = "lm", se = F) -> m1
plot(m2)

fit1 <- lm(大学の成績 ~ 高校の成績, data = dat.df)
dat.df %>%
  dplyr::mutate(yhat = fit1$fitted.values) %>%
  ggplot(aes(x = yhat, y = 大学の成績)) +
  geom_point() -> g1


# 外れまくる回帰式 ----------------------------------------------------------------
set.seed(12345)
N <- 15
X <- rnorm(N, 300, 10)
Y <- 15 + 0.8 * X + rnorm(N, 0, 100)
fit2 <- lm(Y ~ X)

data.frame(x = X, y = Y) %>%
  ggplot(aes(x = x, y = y)) +
  geom_point() +
  geom_smooth(method = "lm", se = F) -> m2
plot(m1)

data.frame(x = X, y = Y) %>%
  dplyr::mutate(yhat = fit2$fitted.values) %>%
  ggplot(aes(x = yhat, y = y)) +
  geom_point() -> g2
library(gridExtra)
grid.arrange(m1,m2,g1, g2, ncol = 2)


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
library(GGally)
ggpairs(dat.df)

result <- lm(評定~内申点+入試,data=dat.df)
summary(result)

dat.df$Yhat <- result$fitted.values
dat.df$Residuals <- result$residuals
dat.df
ggpairs(dat.df)

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


#  正規分布の描画 ----------------------------------------------------------------
library(ggplot2)
limitRange <- function(fun, min, max) {
  function(x) {
    y <- fun(x)
    y[x < min  |  x > max] <- NA
    return(y)
  }
}
# p(x>2)
p <- ggplot(data.frame(x=c(-4, 4)), aes(x=x))
p + stat_function(fun = dnorm)+
  stat_function(fun = limitRange(dnorm, qnorm(0.2),qnorm(0.8)),
                geom="area", fill="blue", alpha=0.2)+
  stat_function(fun = limitRange(dnorm, qnorm(0.025),qnorm(0.975)),
                geom="area", fill="blue", alpha=0.2)+
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=14,face="bold"))+ylab("Probability density")

pnorm(1)-pnorm(-1)
qnorm(0.80)
qnorm(0.20)

x <- rnorm(1000,mean=75,sd=15)
x <- x[x<=100]
hist(x)

p <- ggplot(data.frame(x=c(0, 150)), aes(x=x))
p + stat_function(fun = dnorm, args = list(mean = 75, sd = 15), 
                  geom="area", fill="blue", alpha=0.2)+
  theme(axis.text=element_text(size=16),
        axis.title=element_text(size=14,face="bold"))+ylab("Probability density")

