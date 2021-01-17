rm(list = ls())
source("http://riseki.php.xdomain.jp/index.php?plugin=attach&refer=ANOVA君&openfile=anovakun_485.txt")


# Between -----------------------------------------------------------------
# データフレームを組み上げる
Example1 <- data.frame(
  id = rep(1:4, 3),
  condition = rep(1:3, each = 4),
  value = c(6, 6, 5, 5, 7, 4, 7, 6, 4, 3, 4, 6)
)
# Factor型にする
Example1$condition <- factor(Example1$condition,
  labels = c("control", "exp1", "exp2")
)

result.lm1 <- lm(value ~ condition, data = Example1)
summary(result.lm1)
ggplot(Example1) +
  aes(x = condition, y = value, fill = condition) +
  stat_summary(geom = "bar", fun = "mean")
anova(result.lm1)


anovakun(Example1[, 2:3], "As", 3, eps = T)


# 二要因 ---------------------------------------------------------------------
Example2 <- data.frame(
  id = 1:12,
  num = rep(1:3, 4),
  temp = rep(1:2, each = 6),
  maker = rep(rep(1:2, each = 3), 2),
  value = c(13, 15, 12, 1, 6, 8, 9, 9, 9, 13, 11, 9)
)
Example2$temp <- factor(Example2$temp,
  labels = c("Hot", "Cold")
)
Example2$maker <- factor(Example2$maker,
  label = c("A", "B")
)

result.lm2 <- lm(value ~ temp * maker, data = Example2)
summary(result.lm2)
anova(result.lm2)
anovakun(Example2[, 3:5], "ABs", 2, 2, eps = T)

# Within ------------------------------------------------------------------

Example3 <- data.frame(
  ID = 1:4,
  Time1 = c(10, 9, 4, 7),
  Time2 = c(5, 4, 3, 3),
  Time3 = c(9, 1, 3, 5)
)
anovakun(Example3[, 2:4], "sA", 3, eps = T)


# R実践課題ようのデータを作る ----------------------------------------------------------
set.seed(8931)
## 線形モデル
N <- 10
mu <- 50
sig <- 3
X1 <- rnorm(N, mu + 5, sig) %>% round
X2 <- rnorm(N, mu+1,sig) %>% round
X3 <- rnorm(N, mu-6,sig) %>% round
X4 <- rnorm(N, mu+0,sig) %>% round
EXE1 <- data.frame(
  id = rep(1:N,4),
  condition = factor(c(rep(1,N),rep(2,N),rep(3,N),rep(4,N)),
                     label=c("textA","textB","textC","textD")),
           value = c(X1,X2,X3,X4)) 
# 模範解答
summary(lm(value~condition,EXE1))
anovakun(EXE1[,-1],"As",4,eps=T)
# 印刷用データフレーム
EXE1 %>%
  tidyr::pivot_wider(id_cols=id,names_from=condition,values_from=value) %>% 
  dplyr::select(-id) %>% knitr::kable(.,format = "latex")
# 保存用データフレーム
write_csv(EXE1,file = "Lesson8exe1.csv")

## Betweenモデル
N <- 12
mu <- 30
beta1a <- 3
beta1b <- 3
beta1c <- 0 - (beta1a+beta1b)
beta2 <- 1
beta3a <- 0
beta3b <- 1
beta3c <- 0 - (beta3a+beta3b)
sig <- 5
mu11 <- mu + beta1a  + beta2  + beta3a
mu12 <- mu + beta1b  + beta2  + beta3b
mu13 <- mu + beta1c  + beta2  + beta3c
mu21 <- mu - beta1a  - beta2  - beta3a
mu22 <- mu - beta1b  - beta2  - beta3b
mu23 <- mu - beta1c  - beta2  - beta3c

X11 <- rnorm(N, mu11, sig) %>% round
X12 <- rnorm(N, mu12, sig) %>% round
X13 <- rnorm(N, mu13, sig) %>% round
X21 <- rnorm(N, mu21, sig) %>% round
X22 <- rnorm(N, mu22, sig) %>% round
X23 <- rnorm(N, mu23, sig) %>% round

EXE2 <- data.frame(
  id = rep(1:N,6),
  cond1 = factor(rep(rep(1:3,each=N),2),label=c("textA","textB","textC")),
  cond2 = factor(rep(rep(1:2,each=3*N)),label=c("teacherA","teacherB")),
  value = c(X11,X12,X13,X21,X22,X23)
)

anovakun(EXE2[,-1],"ABs",3,2,eps=T)
# 印刷用データフレーム
EXE2 %>%
  tidyr::pivot_wider(id_cols=id,names_from=c(cond1,cond2),
                     names_sep="-",values_from=value) %>% 
  dplyr::select(-id) %>% knitr::kable(.,format = "latex")
# 保存用データフレーム
write_csv(EXE2,file = "Lesson8exe2.csv")

## Withinモデル
N <- 20
gm <- 50
b1 <- -2
b2 <- -2
b3 <- 2
b4 <- 2
tau <- 10
sig <- 5
muN <- rnorm(N,gm,tau)
mu1 <- (muN + b1 + rnorm(N,0,sig)) %>% round
mu2 <- (muN + b2 + rnorm(N,0,sig)) %>% round
mu3 <- (muN + b3 + rnorm(N,0,sig)) %>% round
mu4 <- (muN + b4 + rnorm(N,0,sig)) %>% round
EXE3 <- data.frame(id = 1:N,
                   period1 = mu1,
                   period2 = mu2,
                   period3 = mu3,
                   period4 = mu4)

anovakun(EXE3[,-1],"sA",4)

# 印刷用データフレーム
EXE3 %>%
  knitr::kable(.,format = "latex")
# 保存用データフレーム
write_csv(EXE3,file = "Lesson8exe3.csv")


