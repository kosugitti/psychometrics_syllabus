rm(list = ls())
library(tidyverse)
MixedDesign <- data.frame(
  id = rep(1:4, 3),
  condition = rep(1:3, each = 4),
  stimuli1 = c(6, 6, 5, 5, 7, 4, 7, 6, 4, 3, 4, 6),
  stimuli2 = c(8, 3, 2, 5, 9, 7, 1, 6, 4, 9, 2, 3)
)
# 要因型にする
MixedDesign$condition <- factor(MixedDesign$condition,
  labels = c("control", "exp1", "exp2")
)

MixedDesign

MixedDesign_long <- MixedDesign %>%
  pivot_longer(
    cols = c(stimuli1, stimuli2),
    names_to = "stimuli",
    values_to = "value"
  )
print(MixedDesign_long)


# Bet2 --------------------------------------------------------------------

Between2 <- data.frame(
  temp = rep(1:2, each = 6),
  maker = rep(rep(1:2, each = 3), 2),
  value = c(13, 11, 12, 7, 6, 8, 9, 9, 9, 13, 11, 9)
)
Between2$temp <- factor(Between2$temp,
  labels = c("Hot", "Cold")
)
Between2$maker <- factor(Between2$maker,
  labels = c("A", "B")
)

source("https://bit.ly/3WL8VYR")

anovakun(Between2, "ABs", 2, 2, eps = T, welch = T)





result.lm <- lm(value ~ temp * maker, data = Between2)
summary(result.lm)
anova(result.lm)

# ggplot2による可視化 -------------------------------------------------------

# 基本的な棒グラフ（平均値 + エラーバー）
Between2 %>%
  group_by(temp, maker) %>%
  summarise(
    mean = mean(value),
    sd = sd(value),
    n = n(),
    se = sd / sqrt(n),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = temp, y = mean, fill = maker)) +
  geom_bar(
    stat = "identity",
    position = position_dodge(0.9),
    width = 0.8
  ) +
  geom_errorbar(aes(ymin = mean - se, ymax = mean + se),
    position = position_dodge(0.9), width = 0.25
  ) +
  labs(
    title = "温度とメーカーによる評価値の比較",
    x = "温度条件",
    y = "評価値の平均",
    fill = "メーカー"
  ) +
  theme_bw() +
  theme(text = element_text(family = "HiraginoSans-W3"))


# 図を保存
ggsave("../figures/20_anovakun/anova_figures.png", plot = g1, width = 8, height = 6, dpi = 300)

# 交互作用を見やすくした折れ線グラフ
g2 <- Between2 %>%
  group_by(temp, maker) %>%
  summarise(
    mean = mean(value),
    sd = sd(value),
    n = n(),
    se = sd / sqrt(n),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = temp, y = mean, group = maker, color = maker)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean - se, ymax = mean + se), width = 0.1) +
  labs(
    title = "温度とメーカーの交互作用",
    x = "温度条件",
    y = "評価値の平均",
    color = "メーカー"
  ) +
  theme_bw() +
  theme(text = element_text(family = "HiraginoSans-W3"))
print(g2)

# 個別データ点も含めた可視化
g3 <- Between2 %>%
  ggplot(aes(x = temp, y = value, fill = maker)) +
  geom_boxplot(alpha = 0.5, outlier.shape = NA) +
  geom_jitter(aes(color = maker), position = position_jitterdodge(jitter.width = 0.2), size = 2) +
  labs(
    title = "温度とメーカーによる評価値の分布",
    x = "温度条件",
    y = "評価値",
    fill = "メーカー",
    color = "メーカー"
  ) +
  theme_bw() +
  theme(text = element_text(family = "HiraginoSans-W3"))
print(g3)


# 課題：学習方法と復習の効果 ---------------------------------------------------

# 課題1: データフレームの作成
LearningData <- data.frame(
  id = rep(1:4, 4),
  method = rep(1:2, each = 8),
  review = rep(rep(1:2, each = 4), 2),
  score = c(85, 88, 82, 90, 72, 68, 75, 70, 78, 82, 80, 76, 65, 62, 68, 60)
)

# 要因型に変換
LearningData$method <- factor(LearningData$method,
  labels = c("対面", "オンライン")
)
LearningData$review <- factor(LearningData$review,
  labels = c("復習あり", "復習なし")
)

# データの確認
print(LearningData)

# 課題2: anovakunで二要因分散分析を実行
cat("\n=== 課題2: 二要因分散分析の結果 ===\n")
anovakun(LearningData[, -1], "ABs", 2, 2, eps = T)

# 課題3-4: 結果の解釈
# 主効果と交互作用の有意性、効果量、単純効果の検定結果は
# 上記のanovakun出力から確認できます

# 課題5: ggplot2による可視化
cat("\n=== 課題5: 結果の可視化 ===\n")
g_learning <- LearningData %>%
  group_by(method, review) %>%
  summarise(
    mean = mean(score),
    sd = sd(score),
    n = n(),
    se = sd / sqrt(n),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = method, y = mean, fill = review)) +
  geom_bar(
    stat = "identity",
    position = position_dodge(0.9),
    width = 0.8
  ) +
  geom_errorbar(aes(ymin = mean - se, ymax = mean + se),
    position = position_dodge(0.9), width = 0.25
  ) +
  labs(
    title = "学習方法と復習の有無によるテスト得点の比較",
    x = "学習方法",
    y = "テスト得点の平均",
    fill = "復習の有無"
  ) +
  theme_bw() +
  theme(text = element_text(family = "HiraginoSans-W3"))

print(g_learning)


# 発展課題1: 線形モデルでの分析
cat("\n=== 発展課題1: 線形モデルでの分析 ===\n")
result_learning <- lm(score ~ method * review, data = LearningData)
cat("\n--- summary()の結果 ---\n")
print(summary(result_learning))
cat("\n--- anova()の結果 ---\n")
print(anova(result_learning))

# 記述統計の確認
cat("\n=== 各条件の記述統計 ===\n")
LearningData %>%
  group_by(method, review) %>%
  summarise(
    平均 = mean(score),
    標準偏差 = sd(score),
    サンプル数 = n(),
    .groups = "drop"
  ) %>%
  print()
