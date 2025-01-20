rm(list = ls())
set.seed(20210128)
library(tidyverse)
library(gridExtra)
library(colorBlindness)
library(ggthemes)
old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))
# scale_colour_discrete <- colorBlindness::Blue2DarkOrange12Steps

sample <- read_csv("baseballDecade.csv") %>%
  dplyr::filter(Year == "2020年度")

g <- sample %>%
  select(height, weight) %>%
  na.omit() %>%
  ggplot(mapping = aes(y = weight, x = height)) +
  geom_point() +
  geom_point(mapping = aes(x = 175, y = 68, color = "2", size = 2)) +
  guides(size = "none", color = "none", fill = "none") +
  xlim(160, 210) +
  ylim(60, 135) +
  geom_segment(aes(x = 175, xend = 175, y = 68, yend = -Inf), color = 2, lty = 2) +
  geom_segment(aes(x = -Inf, xend = 175, y = 68, yend = 68), color = 2, lty = 2)
g

ggsave(g, filename = "../images/text04/Rplot04_02.png", dpi = 600, width = 12, height = 12)

sample %>%
  select(Name, height, weight) %>%
  na.omit() %>%
  tibble() %>%
  head() %>%
  xtable::xtable(caption = "データの一部", label = "tab::04_04")

sample %>%
  dplyr::select(height, weight) %>%
  na.omit() %>%
  cor()

library(MASS)
## 相関係数
mu <- c(0, 0)
sig <- matrix(nrow = 2, ncol = 2)
N <- 2000
dat <- NULL
for (rho in seq(-1, 1, 0.25)) {
  sig[1, 1] <- 1
  sig[1, 2] <- rho
  sig[2, 1] <- rho
  sig[2, 2] <- 1
  tmp <- data.frame(mvrnorm(N, mu, sig), rho)
  dat <- rbind(dat, tmp)
}

dat$rho <- factor(dat$rho)
library(ggplot2)
g <- ggplot(dat, aes(x = X1, y = X2)) +
  geom_point() +
  facet_wrap(~rho) +
  xlab("") +
  ylab("")
g
ggsave(g, filename = "../images/text04/Rplot04_03.png", dpi = 600, width = 12, height = 12)

### 逆U字
x <- rep(seq(-1.5, 4.5, 0.1), 2000)
y <- sin(x)
z <- rnorm(length(x), 0, 0.6)
dat <- data.frame(scale(cbind(x, y + z)))
v <- 1:length(x)
v2 <- sample(v, 250)
dat <- dat[v2, ]
names(dat) <- c("V1", "V2")
g <- ggplot(dat, aes(x = V1, y = V2)) +
  geom_point() +
  xlab("") +
  ylab("")
ggsave(g, filename = "../images/text04/Rplot04_04.png", dpi = 600, width = 12, height = 12)
cor(dat)

### 外れ値
N <- 50
rho <- 0.3
mu <- c(0, 0)
sd1 <- 1
sd2 <- 1
cov <- matrix(ncol = 2, nrow = 2)
cov[1, 1] <- sd1^2
cov[2, 2] <- sd2^2
cov[1, 2] <- sd1 * sd2 * rho
cov[2, 1] <- sd1 * sd2 * rho
df <- mvrnorm(N, mu, cov, empirical = TRUE)
df <- rbind(df, c(20, 20))
g <- df %>%
  transform() %>%
  ggplot(aes(x = X1, y = X2)) +
  geom_point() +
  xlab("") +
  ylab("")
cor(df)
ggsave(g, filename = "../images/text04/Rplot04_05.png", dpi = 600, width = 12, height = 12)


### 打ち切りデータ
N <- 1000
mu <- c(0, 0)
Sig <- matrix(c(1, 0.7, 0.7, 1), nrow = 2)
dat <- as.data.frame(mvrnorm(N, mu, Sig, empirical = T))
dat$V1 <- 10 * dat$V1 + 50
dat$V2 <- 10 * dat$V2 + 50
plot(dat)
dat$judge <- ifelse(dat$V1 < 60, 2, 1)
dat$judge <- factor(dat$judge, labels = c("pass", "fail"))
g <- ggplot(dat, aes(x = V1, y = V2, color = judge, shape = judge)) +
  scale_fill_brewer(palette = "Dark2")
g <- g + geom_point() + xlab("入試の得点") + ylab("入学後の成績") + geom_vline(xintercept = 60)
g
ggsave(g, filename = "../images/text04/Rplot04_06.png", dpi = 600, width = 12, height = 12)

cor(dat[, 1], dat[, 2])
subdat <- subset(dat, dat$judge == "pass")
cor(subdat[, 1], subdat[, 2])


### 複数の異なる群
N <- 100
X1 <- rnorm(N, 10, 15)
X2 <- rnorm(N, 40, 15)
X3 <- rnorm(N, 70, 15)
Y1 <- X1 * -0.3 + rnorm(N, 0, 10) + 10
Y2 <- X2 * -0.3 + rnorm(N, 0, 10) + 50
Y3 <- X3 * -0.3 + rnorm(N, 0, 10) + 80
dat <- data.frame(rbind(cbind(X1, Y1), cbind(X2, Y2), cbind(X3, Y3)))
cor(dat[, 1:2])
dat$group <- factor(rep(1:3, each = N), labels = c("Group A", "Group B", "Group C"))
g1 <- ggplot(dat, aes(x = X1, y = Y1)) +
  geom_point() +
  scale_fill_brewer(palette = "Dark2")
g1

g2 <- ggplot(dat, aes(x = X1, y = Y1, shape = group, color = group)) +
  geom_point() +
  xlab("") +
  ylab("") +
  scale_fill_brewer(palette = "Dark2")
g2

g <- gridExtra::grid.arrange(g1, g2, ncol = 2)
g
ggsave(g, filename = "../images/text04/Rplot04_07.png", dpi = 600, width = 12, height = 6)

cor(X1, Y1)
cor(X2, Y2)
cor(X3, Y3)



# 課題 ----------------------------------------------------------------------

N <- 5
X <- rnorm(N, 150, 10) %>% round()
Y <- rnorm(N, 50, 10) %>% round()
dat <- data.frame(X = X, Y = Y)
xtable::xtable(dat)
