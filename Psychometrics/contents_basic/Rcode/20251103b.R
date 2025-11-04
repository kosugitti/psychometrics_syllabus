rm(list = ls())
source("https://bit.ly/3WL8VYR")
pacman::p_load(MASS, tidyverse)
set.seed(123)
n <- 10
mu <- 50
effA <- c(5, -5)
effAB <- matrix(c(2, -1, -1, -2, -2, +4), nrow = 3)
sig <- 10
rhoA <- 0.4
rhoB <- 0.8

rhoA <- matrix(c(sig^2, rhoA * sig^2, rhoA * sig^2, sig^2), nrow = 2)
rhoB <- matrix(c(
  sig^2, rhoB * sig^2, rhoB * sig^2,
  rhoB * sig^2, sig^2, rhoB * sig^2,
  rhoB * sig^2, rhoB * sig^2, sig^2
), nrow = 3)

effA <- mvrnorm(n * 3, effA, rhoA) %>%
  as.data.frame() %>%
  mutate(id = rep(1:n, 3), Time = paste0("t", rep(1:3, each = n))) %>%
  pivot_longer(-c(id, Time)) %>%
  pivot_wider(id_cols = id, names_from = c(name, Time), values_from = value) %>%
  rename(m1_t1 = V1_t1, m1_t2 = V1_t2, m1_t3 = V1_t3,
         m2_t1 = V2_t1, m2_t2 = V2_t2, m2_t3 = V2_t3) %>%
  dplyr::select(id, starts_with("m1"), starts_with("m2"))

# 要因B：3時間 × 2変数
effB_m1 <- c(0, 3, 6)
effB_m2 <- c(0, 3, 6)
rhoB_3var <- matrix(c(1, 0.3, 0.3, 0.3, 1, 0.3, 0.3, 0.3, 1), nrow = 3)

# m1の3時間分
eff_m1 <- mvrnorm(n, effB_m1, rhoB_3var) %>%
  as.data.frame() %>%
  mutate(id = 1:n) %>%
  pivot_longer(-id, names_to = "Time", values_to = "m1") %>%
  mutate(Time = str_replace(Time, "V", "t"))

# m2の3時間分
eff_m2 <- mvrnorm(n, effB_m2, rhoB_3var) %>%
  as.data.frame() %>%
  mutate(id = 1:n) %>%
  pivot_longer(-id, names_to = "Time", values_to = "m2") %>%
  mutate(Time = str_replace(Time, "V", "t"))

# 結合してピボット
effB <- eff_m1 %>%
  left_join(eff_m2, by = c("id", "Time")) %>%
  pivot_wider(id_cols = id, names_from = Time, values_from = c(m1, m2)) %>%
  dplyr::select(id, starts_with("m1"), starts_with("m2"))

# 交互作用項を追加（2要因の交互作用）
# effAB: 3x2行列（3時間 × 2学習方法）
# effBからのマッチング
idx_match <- match(effA$id, effB$id)

# 交互作用を加えたデータ
effAB_data <- effA %>%
  mutate(
    # effBからのマッチング結果を使用
    m2_t1 = effB$m2_t1[idx_match],
    m2_t2 = effB$m2_t2[idx_match],
    m2_t3 = effB$m2_t3[idx_match]
  ) %>%
  mutate(
    # 交互作用効果を加える
    m1_t1 = m1_t1 + effAB[1, 1],
    m1_t2 = m1_t2 + effAB[2, 1],
    m1_t3 = m1_t3 + effAB[3, 1],
    m2_t1 = m2_t1 + effAB[1, 2],
    m2_t2 = m2_t2 + effAB[2, 2],
    m2_t3 = m2_t3 + effAB[3, 2]
  ) %>%
  dplyr::select(id, starts_with("m1"), starts_with("m2"))


# 三つ合わせて ------------------------------------------------------------------

dat <- bind_cols(
  id = factor(LETTERS[effA$id]),
  (effA[, -1] + effB[, -1] + effAB_data[, -1] + mu) %>% round()
)

# TeXテーブルを出力
pacman::p_load(xtable)
print(xtable(dat, caption = "二要因被験者内デザインのデータ", label = "tbl:23_01"),
      include.rownames = FALSE,
      file = "../ch22_data_table.tex")

# 個人差の表を作成
Gmean <- dat %>% pivot_longer(-id) %>% pull(value) %>% mean()

subj_table <- dat %>%
  pivot_longer(-id) %>%
  group_by(id) %>%
  summarise(平均 = mean(value), .groups = "drop") %>%
  mutate(
    効果 = 平均 - Gmean,
    効果二乗 = 効果^2,
    要素数 = 6,
    SS寄与 = 効果二乗 * 要素数
  )

# 合計行を追加
subj_total <- data.frame(
  id = "合計",
  平均 = NA,
  効果 = NA,
  効果二乗 = NA,
  要素数 = NA,
  SS寄与 = sum(subj_table$SS寄与)
)

subj_table_with_total <- rbind(subj_table, subj_total)

print(xtable(subj_table_with_total, caption = "個人差の計算", label = "tbl:22_02_sub"),
      include.rownames = FALSE,
      file = "../ch22_subject_table.tex")

# 効果の表を作成
Gmean <- dat %>% pivot_longer(-id) %>% pull(value) %>% mean()

# 各水準の平均を計算
m1_mean <- dat %>% select(starts_with("m1")) %>% unlist() %>% mean()
m2_mean <- dat %>% select(starts_with("m2")) %>% unlist() %>% mean()
t1_mean <- dat %>% select(ends_with("t1")) %>% unlist() %>% mean()
t2_mean <- dat %>% select(ends_with("t2")) %>% unlist() %>% mean()
t3_mean <- dat %>% select(ends_with("t3")) %>% unlist() %>% mean()
m1t1_mean <- dat$m1_t1 %>% mean()
m1t2_mean <- dat$m1_t2 %>% mean()
m1t3_mean <- dat$m1_t3 %>% mean()
m2t1_mean <- dat$m2_t1 %>% mean()
m2t2_mean <- dat$m2_t2 %>% mean()
m2t3_mean <- dat$m2_t3 %>% mean()

# 効果（偏差）を計算
effects <- c(m1_mean, m2_mean, t1_mean, t2_mean, t3_mean,
             m1t1_mean, m1t2_mean, m1t3_mean, m2t1_mean, m2t2_mean, m2t3_mean) - Gmean

# 平方を計算
effects_sq <- effects^2

# 要素数
n_elements <- c(30, 30, 20, 20, 20, 10, 10, 10, 10, 10, 10)

# 平方和への寄与
ss_contrib <- effects_sq * n_elements

# データフレーム作成
effect_table <- data.frame(
  水準 = c("m1", "m2", "t1", "t2", "t3", "m1t1", "m1t2", "m1t3", "m2t1", "m2t2", "m2t3"),
  平均 = c(m1_mean, m2_mean, t1_mean, t2_mean, t3_mean,
          m1t1_mean, m1t2_mean, m1t3_mean, m2t1_mean, m2t2_mean, m2t3_mean),
  効果 = effects,
  効果二乗 = effects_sq,
  要素数 = n_elements,
  SS寄与 = ss_contrib
) %>% t()

colnames(effect_table) <- effect_table[1, ]
effect_table <- effect_table[-1, ]

# TeX形式で出力
print(xtable(effect_table, caption = "各水準の効果と平方和への寄与", label = "tbl:22_03"),
      file = "../ch22_effect_table.tex")

# 交互作用の表を作成
# m効果とt効果を計算
m1_effect <- m1_mean - Gmean
m2_effect <- m2_mean - Gmean
t1_effect <- t1_mean - Gmean
t2_effect <- t2_mean - Gmean
t3_effect <- t3_mean - Gmean

# 交互作用表
interaction_table <- data.frame(
  セル = c("m1t1", "m1t2", "m1t3", "m2t1", "m2t2", "m2t3"),
  観測平均 = c(m1t1_mean, m1t2_mean, m1t3_mean, m2t1_mean, m2t2_mean, m2t3_mean),
  予測平均 = c(
    Gmean + m1_effect + t1_effect,
    Gmean + m1_effect + t2_effect,
    Gmean + m1_effect + t3_effect,
    Gmean + m2_effect + t1_effect,
    Gmean + m2_effect + t2_effect,
    Gmean + m2_effect + t3_effect
  )
) %>%
  mutate(
    交互作用効果 = 観測平均 - 予測平均,
    効果二乗 = 交互作用効果^2,
    要素数 = 10,
    SS寄与 = 効果二乗 * 要素数
  )

# 合計行を追加
interaction_total <- data.frame(
  セル = "合計",
  観測平均 = NA,
  予測平均 = NA,
  交互作用効果 = NA,
  効果二乗 = NA,
  要素数 = NA,
  SS寄与 = sum(interaction_table$SS寄与)
)

interaction_table_with_total <- rbind(interaction_table, interaction_total)

print(xtable(interaction_table_with_total, caption = "交互作用の計算", label = "tbl:22_04"),
      include.rownames = FALSE,
      file = "../ch22_interaction_table.tex")

# 要因Aの平均値表（潰した平均値のみ）
sA_mean_table <- dat %>%
  pivot_longer(-id, names_to = "condition", values_to = "value") %>%
  mutate(A_level = ifelse(str_detect(condition, "^m1"), "m1", "m2")) %>%
  group_by(id, A_level) %>%
  summarise(平均 = mean(value), .groups = "drop") %>%
  pivot_wider(id_cols = id, names_from = A_level, values_from = 平均)

print(xtable(sA_mean_table, caption = "各被験者の要因A水準別平均", label = "tbl:22_05a"),
      include.rownames = FALSE,
      file = "../ch22_sA_mean_table.tex")

# 要因A（s×A）に伴う残差の表を作成
# 各被験者のm1, m2の平均を計算
sA_table <- dat %>%
  pivot_longer(-id, names_to = "condition", values_to = "value") %>%
  mutate(A_level = ifelse(str_detect(condition, "^m1"), "m1", "m2")) %>%
  group_by(id, A_level) %>%
  summarise(観測平均 = mean(value), .groups = "drop") %>%
  left_join(
    subj_table %>% select(id, 個人差効果 = 効果),
    by = "id"
  ) %>%
  mutate(
    A効果 = ifelse(A_level == "m1", m1_effect, m2_effect),
    予測平均 = Gmean + 個人差効果 + A効果,
    残差 = 観測平均 - 予測平均,
    残差二乗 = 残差^2,
    要素数 = 3,
    SS寄与 = 残差二乗 * 要素数
  ) %>%
  arrange(id, A_level)

# 合計行を追加
sA_total <- data.frame(
  id = "合計",
  A_level = "",
  観測平均 = NA,
  個人差効果 = NA,
  A効果 = NA,
  予測平均 = NA,
  残差 = NA,
  残差二乗 = NA,
  要素数 = NA,
  SS寄与 = sum(sA_table$SS寄与)
)

sA_table_with_total <- rbind(sA_table, sA_total)

print(xtable(sA_table_with_total, caption = "要因Aに伴う残差（s×A）の計算", label = "tbl:22_05"),
      include.rownames = FALSE,
      file = "../ch22_sA_table.tex")

# 要因Bの平均値表（潰した平均値のみ）
sB_mean_table <- dat %>%
  pivot_longer(-id, names_to = "condition", values_to = "value") %>%
  mutate(B_level = case_when(
    str_detect(condition, "t1$") ~ "t1",
    str_detect(condition, "t2$") ~ "t2",
    str_detect(condition, "t3$") ~ "t3"
  )) %>%
  group_by(id, B_level) %>%
  summarise(平均 = mean(value), .groups = "drop") %>%
  pivot_wider(id_cols = id, names_from = B_level, values_from = 平均)

print(xtable(sB_mean_table, caption = "各被験者の要因B水準別平均", label = "tbl:22_06a"),
      include.rownames = FALSE,
      file = "../ch22_sB_mean_table.tex")

# 要因B（s×B）に伴う残差の表を作成
# 各被験者のt1, t2, t3の平均を計算
sB_table <- dat %>%
  pivot_longer(-id, names_to = "condition", values_to = "value") %>%
  mutate(B_level = case_when(
    str_detect(condition, "t1$") ~ "t1",
    str_detect(condition, "t2$") ~ "t2",
    str_detect(condition, "t3$") ~ "t3"
  )) %>%
  group_by(id, B_level) %>%
  summarise(観測平均 = mean(value), .groups = "drop") %>%
  left_join(
    subj_table %>% select(id, 個人差効果 = 効果),
    by = "id"
  ) %>%
  mutate(
    B効果 = case_when(
      B_level == "t1" ~ t1_effect,
      B_level == "t2" ~ t2_effect,
      B_level == "t3" ~ t3_effect
    ),
    予測平均 = Gmean + 個人差効果 + B効果,
    残差 = 観測平均 - 予測平均,
    残差二乗 = 残差^2,
    要素数 = 2,
    SS寄与 = 残差二乗 * 要素数
  ) %>%
  arrange(id, B_level)

# 合計行を追加
sB_total <- data.frame(
  id = "合計",
  B_level = "",
  観測平均 = NA,
  個人差効果 = NA,
  B効果 = NA,
  予測平均 = NA,
  残差 = NA,
  残差二乗 = NA,
  要素数 = NA,
  SS寄与 = sum(sB_table$SS寄与)
)

sB_table_with_total <- rbind(sB_table, sB_total)

print(xtable(sB_table_with_total, caption = "要因Bに伴う残差（s×B）の計算", label = "tbl:22_06"),
      include.rownames = FALSE,
      file = "../ch22_sB_table.tex")

# 交互作用に伴う残差（s×A×B）の表を作成
# まず、各セルの観測平均と予測平均を計算

# 交互作用効果を再計算
interaction_effects <- data.frame(
  セル = c("m1_t1", "m1_t2", "m1_t3", "m2_t1", "m2_t2", "m2_t3"),
  AB効果 = c(
    m1t1_mean - Gmean - m1_effect - t1_effect,
    m1t2_mean - Gmean - m1_effect - t2_effect,
    m1t3_mean - Gmean - m1_effect - t3_effect,
    m2t1_mean - Gmean - m2_effect - t1_effect,
    m2t2_mean - Gmean - m2_effect - t2_effect,
    m2t3_mean - Gmean - m2_effect - t3_effect
  )
)

# s×A効果を計算（既に計算済みのsA_tableから）
sA_effects <- sA_table %>%
  select(id, A_level, sA効果 = 残差) %>%
  mutate(A_level = paste0(A_level, "_"))

# s×B効果を計算（既に計算済みのsB_tableから）
sB_effects <- sB_table %>%
  select(id, B_level, sB効果 = 残差) %>%
  mutate(B_level = paste0("_", B_level))

# 各被験者の各セルの観測値と予測値
sAB_table <- dat %>%
  pivot_longer(-id, names_to = "セル", values_to = "観測値") %>%
  left_join(
    subj_table %>% select(id, 個人差効果 = 効果),
    by = "id"
  ) %>%
  mutate(
    A_level = ifelse(str_detect(セル, "^m1"), "m1_", "m2_"),
    B_level = case_when(
      str_detect(セル, "t1$") ~ "_t1",
      str_detect(セル, "t2$") ~ "_t2",
      str_detect(セル, "t3$") ~ "_t3"
    ),
    A効果 = ifelse(str_detect(セル, "^m1"), m1_effect, m2_effect),
    B効果 = case_when(
      str_detect(セル, "t1$") ~ t1_effect,
      str_detect(セル, "t2$") ~ t2_effect,
      str_detect(セル, "t3$") ~ t3_effect
    )
  ) %>%
  left_join(
    interaction_effects %>% rename(セル名 = セル),
    by = c("セル" = "セル名")
  ) %>%
  left_join(
    sA_effects,
    by = c("id", "A_level")
  ) %>%
  left_join(
    sB_effects,
    by = c("id", "B_level")
  ) %>%
  mutate(
    予測平均 = Gmean + 個人差効果 + A効果 + B効果 + AB効果 + sA効果 + sB効果
  ) %>%
  select(id, セル, 観測値, 個人差効果, A効果, B効果, AB効果, sA効果, sB効果, 予測平均)

# 予測平均の表（観測値と予測平均のみ）
sAB_pred_table <- sAB_table %>%
  select(id, セル, 観測値, 予測平均) %>%
  arrange(id, セル)

print(xtable(sAB_pred_table, caption = "各セルの観測値と予測平均", label = "tbl:22_07a"),
      include.rownames = FALSE,
      file = "../ch22_sAB_pred_table.tex")

# 残差の計算表
sAB_resid_table <- sAB_table %>%
  mutate(
    残差 = 観測値 - 予測平均,
    残差二乗 = 残差^2,
    要素数 = 1,
    SS寄与 = 残差二乗 * 要素数
  ) %>%
  arrange(id, セル)

# 合計行を追加
sAB_resid_total <- data.frame(
  id = "合計",
  セル = "",
  観測値 = NA,
  個人差効果 = NA,
  A効果 = NA,
  B効果 = NA,
  AB効果 = NA,
  sA効果 = NA,
  sB効果 = NA,
  予測平均 = NA,
  残差 = NA,
  残差二乗 = NA,
  要素数 = NA,
  SS寄与 = sum(sAB_resid_table$SS寄与)
)

sAB_resid_table_with_total <- rbind(sAB_resid_table, sAB_resid_total)

print(xtable(sAB_resid_table_with_total, caption = "交互作用に伴う残差（s×A×B）の計算", label = "tbl:22_07"),
      include.rownames = FALSE,
      file = "../ch22_sAB_table.tex")

anovakun(dat[, -1], "sAB", 2, 3, eps = T)




# 平方和に分解 ------------------------------------------------------------------

# グランド平均を計算
Gmean <- dat %>%
  pivot_longer(-id) %>%
  pull(value) %>%
  mean()

# 被験者の平均を計算
subj_mean <- dat %>%
  pivot_longer(-id) %>%
  group_by(id) %>%
  summarise(subj_avg = mean(value), .groups = "drop")

# 要因Aの水準別平均を計算
A_mean <- dat %>%
  pivot_longer(-id) %>%
  mutate(name1 = str_sub(name, 1, 2)) %>%
  group_by(name1) %>%
  summarise(A_avg = mean(value), .groups = "drop")

# 要因Bの水準別平均を計算
B_mean <- dat %>%
  pivot_longer(-id) %>%
  mutate(name2 = str_sub(name, 4, 5)) %>%
  group_by(name2) %>%
  summarise(B_avg = mean(value), .groups = "drop")

# A×Bの交互作用平均を計算
AB_mean <- dat %>%
  pivot_longer(-id) %>%
  mutate(
    name1 = str_sub(name, 1, 2),
    name2 = str_sub(name, 4, 5)
  ) %>%
  group_by(name1, name2) %>%
  summarise(AB_avg = mean(value), .groups = "drop")

# SS_A: 要因A の平方和 (n_B × n_s)倍
n <- nrow(dat)
n_A <- 2
n_B <- 3
SS_A <- n_B * n * sum((A_mean$A_avg - Gmean)^2)

# SS_B: 要因B の平方和 (n_A × n_s)倍
SS_B <- n_A * n * sum((B_mean$B_avg - Gmean)^2)

# SS_A×B: 交互作用の平方和
AB_mean_calc <- AB_mean %>%
  left_join(A_mean %>% rename(name1 = name1), by = "name1") %>%
  left_join(B_mean %>% rename(name2 = name2), by = "name2") %>%
  mutate(
    AB_effect = AB_avg - A_avg - B_avg + Gmean
  )
SS_AB <- n * sum(AB_mean_calc$AB_effect^2)

# SS(s×A): 被験者×要因A の交互作用（Aの誤差項）
sA_cell <- dat %>%
  pivot_longer(-id) %>%
  mutate(name1 = str_sub(name, 1, 2)) %>%
  group_by(id, name1) %>%
  summarise(cell_mean = mean(value), .groups = "drop") %>%
  left_join(
    subj_mean %>% rename(id = id),
    by = "id"
  ) %>%
  left_join(
    A_mean %>% rename(name1 = name1),
    by = "name1"
  ) %>%
  mutate(
    dev = cell_mean - subj_avg - A_avg + Gmean
  )
SS_sA <- n_B * sum(sA_cell$dev^2)

# SS(s×B): 被験者×要因B の交互作用（Bの誤差項）
sB_cell <- dat %>%
  pivot_longer(-id) %>%
  mutate(name2 = str_sub(name, 4, 5)) %>%
  group_by(id, name2) %>%
  summarise(cell_mean = mean(value), .groups = "drop") %>%
  left_join(
    subj_mean %>% rename(id = id),
    by = "id"
  ) %>%
  left_join(
    B_mean %>% rename(name2 = name2),
    by = "name2"
  ) %>%
  mutate(
    dev = cell_mean - subj_avg - B_avg + Gmean
  )
SS_sB <- n_A * sum(sB_cell$dev^2)

# SS(s×A×B): 被験者×要因A×要因B の交互作用（残差）
# SS_Total - SS_s - SS_A - SS(s×A) - SS_B - SS(s×B) - SS(A×B) = SS(s×A×B)
# または、各観測から加算的な予測値を引く
SS_s <- n_A * n_B * sum((subj_mean$subj_avg - Gmean)^2)
SS_Total <- dat %>%
  pivot_longer(-id) %>%
  pull(value) %>%
  {sum((. - Gmean)^2)}

SS_sAB <- SS_Total - SS_s - SS_A - SS_sA - SS_B - SS_sB - SS_AB

# 結果を表示
cat("\n=== 平方和の分解 ===\n\n")
cat("SS_s =", SS_s, "\n")
cat("SS_A =", SS_A, "\n")
cat("SS(s×A) =", SS_sA, "\n")
cat("SS_B =", SS_B, "\n")
cat("SS(s×B) =", SS_sB, "\n")
cat("SS(A×B) =", SS_AB, "\n")
cat("SS(s×A×B) =", SS_sAB, "\n")
cat("SS_Total =", SS_Total, "\n")
cat("\n合計確認: SS_s + SS_A + SS(s×A) + SS_B + SS(s×B) + SS(A×B) + SS(s×A×B) =",
    SS_s + SS_A + SS_sA + SS_B + SS_sB + SS_AB + SS_sAB, "\n")
