rm(list = ls())
library(tidyverse)
dat <- read_csv("baseballDecade.csv",
  na = "NA",
  locale = locale(encoding = "utf8")
) %>%
  filter(Year == "2020年度")

batter <- dat %>%
  dplyr::filter(position != "投手") %>%
  dplyr::select(height, weight)
g <- ggplot(batter, aes(x = height, y = weight))
g <- g + geom_point()
g

g <- g + geom_smooth(method = "lm", se = FALSE)
g

# ggsave(filename = "../figures/09_Regression_onR/scatter_batter1.png")

result <- lm(weight ~ height, data = batter)
summary(result)
plot(result)

result$residuals
result$fitted.values

batter$residuals <- result$residuals
batter$yhat <- result$fitted.values
batter
summary(batter)
plot(batter)
cor(batter)

batter2 <- dat %>%
  dplyr::filter(position != "投手") %>%
  dplyr::select(HR, Hit, salary) %>%
  na.omit()
plot(batter2)
cor(batter2)

library(patchwork)
g1 + g2

result2 <- lm(salary ~ HR + Hit, data = batter2)
summary(result2)

batter2z <- scale(batter2) %>% as.data.frame()
summary(batter2z)
result2z <- lm(salary ~ HR + Hit, data = batter2z)
summary(result2z)

# 課題 --------------------------------------------------------------
rm(list = ls())
library(tidyverse)
dat <- read_csv("baseballDecade.csv",
  na = "NA",
  locale = locale(encoding = "utf8")
) %>%
  filter(Year == "2020年度")

# 身長と体重のデータを抜き出す
batter <- dat %>%
  dplyr::filter(position != "投手") %>%
  dplyr::select(height, weight)

# 散布図の作成
g <- ggplot(batter, aes(x = weight, y = height))
g <- g + geom_point()
g

# 単回帰分析の実行
result1 <- lm(height ~ weight, data = batter)
summary(result1)

# 年俸，本塁打，安打のデータを準備
batter2 <- dat %>%
  dplyr::filter(position != "投手") %>%
  dplyr::select(weight, HR, Hit) %>%
  na.omit()

# 散布図行列の作成
plot(batter2)

result2 <- lm(weight ~ HR + Hit, data = batter2)
summary(result2)

# データを標準化
batter2_std <- scale(batter2) %>% as.data.frame()

# 標準化されたデータで重回帰分析
result2z <- lm(weight ~ HR + Hit, data = batter2_std)
summary(result2z)
