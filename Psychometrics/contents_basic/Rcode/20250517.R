rm(list = ls())
pacman::p_load(tidyverse, cmdstanr)
# 年齢層と睡眠障害の有無のデータを作成
set.seed(123) # 再現性のため

# 必要なパッケージの読み込み
library(knitr)
library(xtable)
# サンプルサイズ
n <- 300

# 年齢層のデータ作成
age_group <- factor(sample(
  c("10代", "20代", "30代", "40代以上"),
  n,
  replace = TRUE,
  prob = c(0.15, 0.35, 0.30, 0.20)
), levels = c("10代", "20代", "30代", "40代以上"))

# 睡眠障害の有無のデータ作成（年齢層によって異なる確率で）
sleep_disorder <- vector("character", n)

for (i in 1:n) {
  if (age_group[i] == "10代") {
    sleep_disorder[i] <- sample(c("あり", "なし"), 1, prob = c(0.20, 0.80))
  } else if (age_group[i] == "20代") {
    sleep_disorder[i] <- sample(c("あり", "なし"), 1, prob = c(0.30, 0.70))
  } else if (age_group[i] == "30代") {
    sleep_disorder[i] <- sample(c("あり", "なし"), 1, prob = c(0.40, 0.60))
  } else { # 40代以上
    sleep_disorder[i] <- sample(c("あり", "なし"), 1, prob = c(0.50, 0.50))
  }
}
sleep_disorder <- factor(sleep_disorder, levels = c("あり", "なし"))

# データフレームの作成
sleep_data <- data.frame(年齢層 = age_group, 睡眠障害 = sleep_disorder)

# 基本のクロス集計表
sleep_table <- table(sleep_data$年齢層, sleep_data$睡眠障害)

# カイ二乗検定を実行
chi_sq_test <- chisq.test(sleep_table)

# カイ二乗値を取得
chi_sq_value <- chi_sq_test$statistic

# サンプルサイズ
N <- sum(sleep_table)

# 行数と列数
r <- nrow(sleep_table)
c <- ncol(sleep_table)

# クラメールのV係数を計算
cramers_v <- sqrt(chi_sq_value / (N * min(r - 1, c - 1)))
print(paste("クラメールのV係数:", round(cramers_v, 3)))



# 周辺度数を追加（行と列の合計）
library(stats)
sleep_table_with_margins <- addmargins(sleep_table)

# 名前を日本語に変更
dimnames(sleep_table_with_margins)[[1]][nrow(sleep_table_with_margins)] <- "合計"
dimnames(sleep_table_with_margins)[[2]][ncol(sleep_table_with_margins)] <- "合計"

# xtableでLaTeX形式に変換
xtable_result <- xtable(sleep_table_with_margins,
  caption = "年齢層と睡眠障害のクロス集計表",
  label = "tab:age_sleep"
)
xtable_result


# 列変数を基準にした相対度数（列パーセント）の計算
col_percent <- prop.table(sleep_table, margin = 2) * 100
col_percent <- round(col_percent, 1) # 小数点以下1桁に丸める

# 周辺度数も含めた列パーセント表
col_percent_with_margins <- addmargins(col_percent, margin = 1)
# 合計行は必ず100%になるようにする
col_percent_with_margins[nrow(col_percent_with_margins), ] <- 100.0

# 名前を日本語に変更
dimnames(col_percent_with_margins)[[1]][nrow(col_percent_with_margins)] <- "合計"

# LaTeX形式で出力
library(xtable)
xtable_col_percent <- xtable(col_percent_with_margins,
  caption = "年齢層と睡眠障害のクロス集計表（列パーセント）",
  label = "tab:age_sleep_col_pct"
)

# TeXコードを生成
tex_code <- print(xtable_col_percent,
  include.rownames = TRUE,
  include.colnames = TRUE,
  caption.placement = "top",
  hline.after = c(-1, 0, nrow(col_percent_with_margins) - 1, nrow(col_percent_with_margins)),
  sanitize.text.function = function(x) {
    x
  }
)

# 結果を表示
print(col_percent_with_margins)
# 行変数を基準にした相対度数（行パーセント）の計算
row_percent <- prop.table(sleep_table, margin = 1) * 100
row_percent <- round(row_percent, 1) # 小数点以下1桁に丸める

# 周辺度数も含めた行パーセント表
row_percent_with_margins <- addmargins(row_percent, margin = 2)
# 合計列は必ず100%になるようにする
row_percent_with_margins[, ncol(row_percent_with_margins)] <- 100.0

# 名前を日本語に変更
dimnames(row_percent_with_margins)[[2]][ncol(row_percent_with_margins)] <- "合計"

# LaTeX形式で出力
library(xtable)
xtable_row_percent <- xtable(row_percent_with_margins,
  caption = "年齢層と睡眠障害のクロス集計表（行パーセント）",
  label = "tab:age_sleep_row_pct"
)

# TeXコードを生成
tex_code <- print(xtable_row_percent,
  include.rownames = TRUE,
  include.colnames = TRUE,
  caption.placement = "top",
  hline.after = c(-1, 0, nrow(row_percent_with_margins)),
  sanitize.text.function = function(x) {
    x
  }
)

# 結果を表示
print(row_percent_with_margins)



# 相関 --------------------------------------------------------------

dat <- read_csv("BaseballDecade.csv") %>%
  filter(Year == "2020年度") %>%
  distinct() %>%
  rowid_to_column("ID") %>%
  select(ID, Name, height, weight) %>%
  na.omit()
dat %>% NROW()
dat %>%
  head() %>%
  xtable()

# 矢印の向きを反転し、値をシンプルに表示するバージョン
g <- dat %>%
  ggplot(aes(x = height, y = weight)) +
  # 基本の散布図
  geom_point() +
  # 1行目のデータだけ赤色のポイントで表示
  geom_point(data = dat[1, ], color = "red", size = 3) +
  xlim(150, 210) +
  ylim(50, 130) +
  # x軸への矢印（上から下へ）
  geom_segment(
    data = dat[1, ],
    aes(x = height, y = weight, xend = height, yend = 50),
    arrow = arrow(length = unit(0.3, "cm"), type = "closed"), linetype = "dashed",
    color = "red"
  ) +
  # y軸への矢印（右から左へ）
  geom_segment(
    data = dat[1, ],
    aes(x = height, y = weight, xend = 150, yend = weight),
    arrow = arrow(length = unit(0.3, "cm"), type = "closed"), linetype = "dashed",
    color = "red"
  ) +
  # x軸上の値をテキストで表示
  geom_text(
    data = dat[1, ],
    aes(x = height, y = 52), # x軸の少し上
    label = as.character(round(dat$height[1], 1)),
    color = "red",
    vjust = 5,
    size = 3.5
  ) +
  # y軸上の値をテキストで表示
  geom_text(
    data = dat[1, ],
    aes(x = 152, y = weight), # y軸の少し右
    label = as.character(round(dat$weight[1], 1)),
    color = "red",
    hjust = 5,
    size = 3.5
  ) +
  # テーマ調整
  theme_classic()

plot(g)
ggsave(filename = "../figures/06_Corr/scatter_plot.png")

cor(dat$height, dat$weight)

# 順序相関 ------------------------------------------------------------

# 小さなデータセットでの例
x_small <- c(5, 8, 3, 10, 6)
y_small <- c(7, 9, 2, 8, 5)

# 手順1: 順位に変換
rank_x_small <- rank(x_small)
rank_y_small <- rank(y_small)

# 手順2: 順位の差を計算
d_small <- rank_x_small - rank_y_small

# 手順3: 差の二乗を計算
d_squared_small <- d_small^2

# 結果をデータフレームにまとめる
result_table <- data.frame(
  x値 = x_small,
  x順位 = rank_x_small,
  y値 = y_small,
  y順位 = rank_y_small,
  順位の差d = d_small,
  差の二乗d2 = d_squared_small
)

print(result_table)

# 手順4: 差の二乗の合計を計算
d_squared_sum_small <- sum(d_squared_small)
print(paste("Σd² =", d_squared_sum_small))

# 手順5: スピアマンの相関係数を計算
n_small <- length(x_small)
rs_small <- 1 - (6 * d_squared_sum_small) / (n_small * (n_small^2 - 1))
print(paste("ρ =", round(rs_small, 3)))

# 検証
print(paste("cor()関数による結果:", round(cor(x_small, y_small, method = "spearman"), 3)))


cor(x, y, method = "spearman")
cor(rank(x), rank(y), method = "pearson")




# 授業のコードと課題 ------------------------------------------------------

dat <- read_csv("BaseballDecade.csv") %>%
  filter(Year == "2020年度")
dat %>% summary()

# 必要なパッケージの読み込み
library(tidyverse)

# データの読み込みと2020年度に絞り込み
dat <- read_csv("BaseballDecade.csv") %>%
  filter(Year == "2020年度")

# 1. 身長と体重変数の散布図を書く（baseの plot() 関数を使用）
plot(dat$height, dat$weight,
  xlab = "身長(cm)", ylab = "体重(kg)",
  main = "身長と体重の散布図"
)


ggplot(dat, aes(x = height, y = weight)) +
  geom_point() +
  labs(
    x = "身長(cm)", y = "体重(kg)",
    title = "身長と体重の散布図（ggplot2）"
  ) +
  theme_bw()

# 2. 身長と体重変数の相関係数を算出する
# ピアソンの相関係数
cor_pearson <- cor(dat$height, dat$weight, method = "pearson", use = "complete.obs")
cat("ピアソンの相関係数：", round(cor_pearson, 3), "\n")

# 3. 身長と体重とホームラン変数だけ抜きだし、上位20人分のデータに限定したうえで、
# スピアマンの順位相関係数を計算する
top20_players <- dat %>%
  filter(Year == "2020年度") %>% # 2020年度のデータ
  filter(position != "投手") %>% # 投手以外（野手）を選択
  arrange(desc(salary)) %>% # 年俸の降順でソート
  head(20) %>% # 上位20人を取得
  select(Name, team, salary, HR) # 必要な列だけを選択

hist(top20_players$salary)
hist(top20_players$HR)
plot(top20_players$salary, top20_players$HR)

# スピアマンの順位相関係数の計算（身長とHR）
cor(top20_players$salary, top20_players$HR, method = "spearman")

# スピアマンの順位相関係数の計算（体重とHR）
cor_spearman_weight_hr <- cor(top_hr$weight, top_hr$HR, method = "spearman", use = "complete.obs")
cat("体重とHRのスピアマンの順位相関係数：", round(cor_spearman_weight_hr, 3), "\n")

# 4. Tigers, Giants, Carpの3チームと血液型変数を抜き出し、それぞれをFactor型にした上で、
# クロス集計表をだす
team_blood <- dat %>%
  filter(team %in% c("Tigers", "Giants", "Carp")) %>%
  select(team, bloodType)
# Factor型に変換
team_blood$team <- factor(team_blood$team)
team_blood$bloodType <- factor(team_blood$bloodType)

# クロス集計表の作成
cross_table <- table(team_blood$team, team_blood$bloodType)
print(cross_table)

# 5. クロス集計表からカイ二乗値を計算する
chi_sq_test <- chisq.test(cross_table)
print(chi_sq_test)

# 6. クラメールのVをパッケージに頼らず自分で計算する
# クラメールのV = sqrt(χ²/(n * (min(r,c) - 1)))
# χ² = カイ二乗値
# n = サンプルサイズ
# r = 行数
# c = 列数

chi_sq_value <- chi_sq_test$statistic
n <- sum(cross_table) # サンプルサイズ
r <- nrow(cross_table) # 行数
c <- ncol(cross_table) # 列数
min_rc <- min(r, c) # r と c の小さい方

# クラメールのVの計算
cramers_v <- sqrt(chi_sq_value / (n * (min_rc - 1)))
cat("クラメールのV：", round(cramers_v, 3), "\n")
cramers_v
