rm(list = ls())
dat <- read.csv("BaseballDecade.csv", na.strings = "NA")

str(dat)
head(dat)
summary(dat)
quantile(dat$salary)
quantile(dat$salary, probs = c(0.3, 0.75))
hist(dat$salary)
hist(dat$height)

hist(dat$weight)
# 2×1のレイアウトを設定（2行1列）
par(mfrow = c(1, 2)) # 1行2列に変更すると横に並びます

# 1つ目のヒストグラム
hist(dat$salary, main = "給与のヒストグラム", xlab = "給与")

# 2つ目のヒストグラム
hist(dat$height, main = "身長のヒストグラム", xlab = "身長(cm)")

par(mfrow = c(1, 1))
boxplot(dat$weight)


library(tidyverse)
dat <- read_csv("BaseballDecade.csv", na = "NA")
dat.long <- dat %>%
  select(Year, Name, position) %>%
  rownames_to_column("ID") %>%
  pivot_longer(-ID) %>%
  print()

dat %>%
  select(Year, Name, position) %>%
  rownames_to_column("ID") %>%
  pivot_longer(-ID, names_to = "Variables", values_to = "Value")
