# tbl::21_02のデータをデータフレームで読み込む
# ch21_WithinDesign.tex より

# データフレームの作成
data <- data.frame(
  ID = c(1, 2, 3, 4),
  Time1 = c(10, 9, 4, 7),
  Time2 = c(5, 4, 2, 3),
  Time3 = c(9, 5, 3, 5)
)

# データフレームの確認
print(data)

# 行平均（個人ごとの平均）を計算
data$平均 <- rowMeans(data[, c("Time1", "Time2", "Time3")])

# 列平均（時期ごとの平均）を計算
col_means <- colMeans(data[, c("Time1", "Time2", "Time3")])
print("時期ごとの平均:")
print(col_means)

# 全体平均を計算
grand_mean <- mean(as.matrix(data[, c("Time1", "Time2", "Time3")]))
print(paste("全体平均:", grand_mean))

# 個人差の計算（個人の平均 - 全体平均）
data$個人差 <- data$平均 - grand_mean
print("個人差:")
print(data[, c("ID", "個人差")])

# 時期の効果（時期の平均 - 全体平均）
time_effects <- col_means - grand_mean
print("時期の効果:")
print(time_effects)

# 拡張データフレーム（ロング形式）の作成
long_data <- data.frame(
  ID = rep(1:4, each = 3),
  時期 = rep(c("Time1", "Time2", "Time3"), times = 4),
  スコア = c(10, 5, 9, 9, 4, 5, 4, 2, 3, 7, 3, 5),
  全体平均 = grand_mean,
  個人差 = rep(data$個人差, each = 3),
  効果 = rep(time_effects, times = 4)
)

# 誤差の計算（スコア - 全体平均 - 個人差 - 効果）
long_data$誤差 <- long_data$スコア - long_data$全体平均 - long_data$個人差 - long_data$効果

print("詳細データ（tbl::21_03に対応）:")
print(long_data)

# 平方和の計算
SS_person <- sum(data$個人差^2) * 3  # 個人差の平方和（×3は時期の数）
SS_effect <- sum(time_effects^2) * 4  # 効果の平方和（×4は人数）
SS_error <- sum(long_data$誤差^2)     # 誤差の平方和

print("平方和:")
print(paste("個人差の平方和:", SS_person))
print(paste("効果の平方和:", SS_effect))
print(paste("誤差の平方和:", SS_error))
print(paste("合計:", SS_person + SS_effect + SS_error))

# F分布の図を作成（ggplot2版）
library(ggplot2)

# IDカラーパレットの定義（全図で統一）
id_colors <- c("1" = "#E41A1C", "2" = "#377EB8", "3" = "#4DAF4A", "4" = "#984EA3")

# 自由度: df1 = 2 (効果), df2 = 6 (誤差)
# 誤差の自由度 = (水準数-1) × (被験者数-1) = (3-1) × (4-1) = 2 × 3 = 6
df1 <- 2
df2 <- 6
F_value <- 16.0  # 実現値

# 5%臨界値を計算
critical_value <- qf(0.95, df1, df2)
print(paste("5%臨界値:", round(critical_value, 3)))

# F分布のデータを作成
x <- seq(0, 20, length.out = 500)
f_dist_data <- data.frame(
  x = x,
  y = df(x, df1, df2)
)

# 棄却域のデータ
x_reject <- seq(critical_value, 20, length.out = 100)
reject_data <- data.frame(
  x = x_reject,
  y = df(x_reject, df1, df2)
)

# ggplotで図を作成
p <- ggplot(f_dist_data, aes(x = x, y = y)) +
  # F分布の曲線
  geom_line(linewidth = 1.2, color = "black") +
  # 棄却域を塗りつぶし
  geom_ribbon(data = reject_data,
              aes(x = x, ymin = 0, ymax = y),
              fill = "red", alpha = 0.3) +
  # 臨界値の線
  geom_vline(xintercept = critical_value,
             color = "red", linewidth = 1, linetype = "dashed") +
  # 実現値の線
  geom_vline(xintercept = F_value,
             color = "blue", linewidth = 1, linetype = "solid") +
  # ラベル
  annotate("text", x = critical_value + 0.5, y = max(f_dist_data$y) * 0.9,
           label = paste0("臨界値 = ", round(critical_value, 3)),
           color = "red", hjust = 0, size = 4) +
  annotate("text", x = F_value + 0.5, y = max(f_dist_data$y) * 0.7,
           label = paste0("実現値 = ", F_value),
           color = "blue", hjust = 0, size = 4) +
  # 軸ラベルとタイトル
  labs(x = "F値",
       y = "確率密度",
       title = paste0("F分布 (自由度: df1=", df1, ", df2=", df2, ")")) +
  # テーマ
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    panel.grid.minor = element_blank()
  )

# 図を表示
print(p)

# 図を保存
# Rcodeフォルダからの相対パス、またはプロジェクトルートから実行する場合に対応
output_path <- if (dir.exists("../figures/21_Within")) {
  "../figures/21_Within/F_distribution_df2_6.png"
} else if (dir.exists("Psychometrics/contents_basic/figures/21_Within")) {
  "Psychometrics/contents_basic/figures/21_Within/F_distribution_df2_6.png"
} else {
  stop("figures/21_Within ディレクトリが見つかりません")
}

ggsave(output_path,
       plot = p,
       width = 10,
       height = 6,
       dpi = 300)

print(paste("図を保存しました:", output_path))

# ========================================
# fig:21_01 Within_pattern.png の作成
# tbl::21_01のデータを使って4人の変化を折れ線グラフにする
# ========================================

library(dplyr)
library(tidyr)

# ロング形式に変換
data_long_plot <- data[, c("ID", "Time1", "Time2", "Time3")] %>%
  pivot_longer(cols = starts_with("Time"),
               names_to = "Time",
               values_to = "Score") %>%
  mutate(Time = factor(Time, levels = c("Time1", "Time2", "Time3")),
         ID = factor(ID))

# ggplotで折れ線グラフを作成
p_pattern <- ggplot(data_long_plot, aes(x = Time, y = Score, group = ID, color = ID)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  labs(x = "時期",
       y = "抑うつスコア",
       color = "クライアントID") +
  scale_x_discrete(labels = c("Time1" = "第1期", "Time2" = "第2期", "Time3" = "第3期")) +
  scale_color_manual(values = id_colors) +
  ylim(0, 11) +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "right"
  )

# 図を表示
print(p_pattern)

# 図を保存
output_path_pattern <- if (dir.exists("../figures/21_Within")) {
  "../figures/21_Within/Within_pattern.png"
} else if (dir.exists("Psychometrics/contents_basic/figures/21_Within")) {
  "Psychometrics/contents_basic/figures/21_Within/Within_pattern.png"
} else {
  stop("figures/21_Within ディレクトリが見つかりません")
}

ggsave(output_path_pattern,
       plot = p_pattern,
       width = 8,
       height = 6,
       dpi = 300)

print(paste("図を保存しました:", output_path_pattern))

# ========================================
# fig:21_02 Within_mean.png の作成
# 3つの時期の平均値を棒グラフで、全体平均を水平線で表現
# ========================================

# 時期ごとの平均値のデータフレームを作成
mean_data <- data.frame(
  Time = factor(c("Time1", "Time2", "Time3"),
                levels = c("Time1", "Time2", "Time3")),
  Mean = col_means
)

# 棒グラフと全体平均の水平線を作成
p_mean <- ggplot(mean_data, aes(x = Time, y = Mean, fill = Time)) +
  geom_col(width = 0.6) +
  geom_hline(yintercept = grand_mean,
             color = "red",
             linewidth = 1,
             linetype = "dashed") +
  annotate("text", x = 2.5, y = grand_mean + 0.5,
           label = paste0("全体平均 = ", grand_mean),
           color = "red", hjust = 0.5, size = 4) +
  labs(x = "時期",
       y = "抑うつスコア") +
  scale_x_discrete(labels = c("Time1" = "第1期", "Time2" = "第2期", "Time3" = "第3期")) +
  scale_fill_manual(values = c("Time1" = "#4292C6", "Time2" = "#2171B5", "Time3" = "#08519C"),
                    labels = c("Time1" = "第1期", "Time2" = "第2期", "Time3" = "第3期"),
                    name = "時期") +
  ylim(0, 11) +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "none"
  )

# 図を表示
print(p_mean)

# 図を保存
output_path_mean <- if (dir.exists("../figures/21_Within")) {
  "../figures/21_Within/Within_mean.png"
} else if (dir.exists("Psychometrics/contents_basic/figures/21_Within")) {
  "Psychometrics/contents_basic/figures/21_Within/Within_mean.png"
} else {
  stop("figures/21_Within ディレクトリが見つかりません")
}

ggsave(output_path_mean,
       plot = p_mean,
       width = 8,
       height = 6,
       dpi = 300)

print(paste("図を保存しました:", output_path_mean))

# ========================================
# 個人差を表す図の作成
# 4本の個人平均と全体平均を水平線で表示
# ========================================

# 個人平均のデータフレームを作成
individual_means <- data.frame(
  ID = factor(rep(1:4, each = 3)),
  Time = factor(rep(c("Time1", "Time2", "Time3"), times = 4),
                levels = c("Time1", "Time2", "Time3")),
  Mean = rep(data$平均, each = 3)
)

# 全体平均のデータフレーム
grand_mean_line <- data.frame(
  Time = factor(c("Time1", "Time2", "Time3"),
                levels = c("Time1", "Time2", "Time3")),
  Mean = grand_mean
)

# 個人平均と全体平均の水平線を描画
p_individual <- ggplot() +
  # 個人平均の水平線
  geom_line(data = individual_means,
            aes(x = Time, y = Mean, group = ID, color = ID),
            linewidth = 1) +
  geom_point(data = individual_means,
             aes(x = Time, y = Mean, color = ID),
             size = 2) +
  # 全体平均の水平線
  geom_line(data = grand_mean_line,
            aes(x = Time, y = Mean, group = 1),
            color = "red",
            linewidth = 1.5,
            linetype = "dashed") +
  labs(x = "時期",
       y = "抑うつスコア",
       color = "クライアントID") +
  scale_x_discrete(labels = c("Time1" = "第1期", "Time2" = "第2期", "Time3" = "第3期")) +
  scale_color_manual(values = id_colors) +
  ylim(0, 11) +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "right"
  )

# 図を表示
print(p_individual)

# 図を保存
output_path_individual <- if (dir.exists("../figures/21_Within")) {
  "../figures/21_Within/Within_individual.png"
} else if (dir.exists("Psychometrics/contents_basic/figures/21_Within")) {
  "Psychometrics/contents_basic/figures/21_Within/Within_individual.png"
} else {
  stop("figures/21_Within ディレクトリが見つかりません")
}

ggsave(output_path_individual,
       plot = p_individual,
       width = 8,
       height = 6,
       dpi = 300)

print(paste("図を保存しました:", output_path_individual))


# ========================================
# ID=1のみの詳細な図
# 全体平均、個人平均、理論値、実測値を明確に表示
# ========================================

# ID=1のデータのみを抽出
id1_actual <- data_long_plot %>% filter(ID == 1)
id1_theory <- theory_data %>% filter(ID == 1)
id1_individual <- individual_means %>% filter(ID == 1)

# ID=1の個人平均
id1_mean <- data$平均[1]

# ID=1の詳細図
p_id1 <- ggplot() +
  # 全体平均の水平線
  geom_hline(yintercept = grand_mean,
             color = "red",
             linewidth = 1.5,
             linetype = "dashed") +
  # ID=1の個人平均の水平線
  geom_hline(yintercept = id1_mean,
             color = id_colors["1"],
             linewidth = 1.2,
             linetype = "dotted") +
  # 理論値を折れ線で表示
  geom_line(data = id1_theory,
            aes(x = Time, y = Theory, group = 1),
            color = "darkgreen",
            linewidth = 1.5) +
  geom_point(data = id1_theory,
             aes(x = Time, y = Theory),
             size = 5,
             shape = 1,
             color = "darkgreen",
             stroke = 2) +
  # 実測値を丸で表示
  geom_point(data = id1_actual,
             aes(x = Time, y = Score),
             size = 4,
             shape = 16,
             color = id_colors["1"]) +
  # ラベル追加
  annotate("text", x = 0.7, y = grand_mean - 0.5,
           label = paste0("全体平均 = ", grand_mean),
           color = "red", hjust = 0, size = 4) +
  annotate("text", x = 0.7, y = id1_mean + 0.5,
           label = paste0("個人平均 = ", id1_mean),
           color = id_colors["1"], hjust = 0, size = 4) +
  labs(x = "時期",
       y = "抑うつスコア") +
  scale_x_discrete(labels = c("Time1" = "第1期", "Time2" = "第2期", "Time3" = "第3期")) +
  ylim(0, 11) +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid.minor = element_blank()
  )

# 図を表示
print(p_id1)

# 図を保存
output_path_id1 <- if (dir.exists("../figures/21_Within")) {
  "../figures/21_Within/Within_model_id1.png"
} else if (dir.exists("Psychometrics/contents_basic/figures/21_Within")) {
  "Psychometrics/contents_basic/figures/21_Within/Within_model_id1.png"
} else {
  stop("figures/21_Within ディレクトリが見つかりません")
}

ggsave(output_path_id1,
       plot = p_id1,
       width = 8,
       height = 6,
       dpi = 300)

print(paste("図を保存しました:", output_path_id1))

# ========================================
# 4人分すべてのデータを含む詳細図
# 全体平均、個人平均、理論値、実測値を表示
# ========================================

# 4人分の詳細図
p_all <- ggplot() +
  # 全体平均の水平線
  geom_hline(yintercept = grand_mean,
             color = "black",
             linewidth = 1.5,
             linetype = "dashed") +
  # 4人分の個人平均の水平線
  geom_line(data = individual_means,
            aes(x = Time, y = Mean, group = ID, color = ID),
            linewidth = 0.8,
            linetype = "dotted") +
  # 4人分の理論値を折れ線で表示
  geom_line(data = theory_data,
            aes(x = Time, y = Theory, group = ID, color = ID),
            linewidth = 1.2,
            linetype = "solid") +
  # 4人分の実測値を丸で表示
  geom_point(data = data_long_plot,
             aes(x = Time, y = Score, color = ID),
             size = 3,
             shape = 16) +
  # ラベル追加
  annotate("text", x = 3.3, y = grand_mean + 0.5,
           label = paste0("全体平均 = ", grand_mean),
           color = "black", hjust = 0.5, size = 4) +
  labs(x = "時期",
       y = "抑うつスコア",
       color = "クライアントID") +
  scale_x_discrete(labels = c("Time1" = "第1期", "Time2" = "第2期", "Time3" = "第3期")) +
  scale_color_manual(values = id_colors) +
  ylim(0, 11) +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "right"
  )

# 図を表示
print(p_all)

# 図を保存
output_path_all <- if (dir.exists("../figures/21_Within")) {
  "../figures/21_Within/Within_model_all.png"
} else if (dir.exists("Psychometrics/contents_basic/figures/21_Within")) {
  "Psychometrics/contents_basic/figures/21_Within/Within_model_all.png"
} else {
  stop("figures/21_Within ディレクトリが見つかりません")
}

ggsave(output_path_all,
       plot = p_all,
       width = 10,
       height = 6,
       dpi = 300)

print(paste("図を保存しました:", output_path_all))
