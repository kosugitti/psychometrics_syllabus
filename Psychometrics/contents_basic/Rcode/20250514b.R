rm(list = ls())
library(tidyverse)
dat <- read.csv("BaseballDecade.csv", na.strings = "NA")
dat2011 <- dat %>% filter(Year == "2011年度")

str(dat2011)
head(dat2011)

summary(dat2011)
quantile(dat2011$salary)
quantile(dat2011$salary, probs = c(0.3, 0.75))

# 基本的なヒストグラム
hist(dat2011$salary)
hist(dat2011$height)
hist(dat2011$weight)

# 箱ひげ図
boxplot(dat2011$salary)

# 3つのヒストグラムを横並びで表示し、ファイルに保存
png("../figures/05_descriptives/hist_func.png", width = 1200, height = 400)

# 日本語フォントの設定（Mac用）
par(family = "HiraginoSans-W3") # macOSのヒラギノフォント

par(mfrow = c(1, 3)) # 1行3列のレイアウト

# 給与のヒストグラム
hist(dat2011$salary,
     main = "給与のヒストグラム",
     xlab = "給与(万円)",
     ylab = "度数",
     col = "white",
     border = "black",
     density = 10,
     angle = 45)

# 身長のヒストグラム
hist(dat2011$height,
     main = "身長のヒストグラム",
     xlab = "身長(cm)",
     ylab = "度数",
     col = "white",
     border = "black",
     density = 15,
     angle = 90)

# 体重のヒストグラム
hist(dat2011$weight,
     main = "体重のヒストグラム",
     xlab = "体重(kg)",
     ylab = "度数",
     col = "white",
     border = "black",
     density = 20,
     angle = 135)

par(mfrow = c(1, 1)) # レイアウトをリセット
dev.off()

# factor型への変換
dat2011$position <- as.factor(dat2011$position)
table(dat2011$position)
