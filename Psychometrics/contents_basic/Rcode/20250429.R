rm(list = ls())
dat <- read.csv("BaseballDecade.csv", na.strings = "NA")
str(dat)


dat$bloodType <- factor(dat$bloodType)
str(dat$bloodType)
levels(dat$bloodType)

dat$Year <- factor(dat$Year, ordered = TRUE)
str(dat$Year)
levels(dat$Year)

# 仮想データ -------------------------------------------------------------------


set.seed(123) # 再現性のために乱数シードを固定
# 仮想データを作成
participants <- data.frame(
  id = 1:20, # 参加者ID（名義尺度）
  age = sample(18:65, 20, replace = TRUE), # 年齢（比率尺度）
  gender = sample(c("男性", "女性", "その他"), 20, replace = TRUE), # 性別（名義尺度）
  education = sample(c("高校", "学部", "修士", "博士"), 20, replace = TRUE), # 学歴（順序尺度）
  stress_level = sample(1:5, 20, replace = TRUE), # ストレスレベル1-5（順序尺度）
  response_time = runif(20, 0.5, 2.5), # 反応時間（秒）（比率尺度）
  completed = sample(c(TRUE, FALSE), 20, replace = TRUE, prob = c(0.8, 0.2)) # 実験完了フラグ（論理値）
)

print(participants)
str(participants)
summary(participants)


participants$gender <- factor(participants$gender)
participants$education <- factor(participants$education,
  levels = c("高校", "学部", "修士", "博士"),
  ordered = TRUE
)
participants$stress_level <- factor(participants$stress_level,
  levels = 1:5,
  labels = c("とても低い", "低い", "普通", "高い", "とても高い"),
  ordered = TRUE
)
print(participants)
str(participants)
summary(participants)
