rm(list = ls())
library(tidyverse)
set.seed(178)


# もしも世界が100人の村だったら --------------------------------------------------------

N <- 100
X <- rnorm(N, 50, 10) %>%
  round() %>%
  matrix(ncol = 10)
X
## テキスト用出力
print(xtable::xtable(X, label = "tbl::16_01", digits = 0), include.rownames = F, include.colnames = F)

# 母平均
mean(X)
# データは図にする
X %>%
  as.vector() %>%
  as.data.frame() %>%
  ggplot(aes(x = .)) +
  geom_histogram(binwidth = 2) +
  xlab("") -> g1
ggsave(g1, filename = "Rplot16_01.png", dpi = 600, width = 8, height = 4)
# サンプルサイズ
n <- 5
# サンプリングを10回繰り返す
samp.df <- data.frame(id = numeric(), val = numeric())
for (i in 1:10) {
  s <- sample(X, n, replace = F)
  print(s)
  samp.df <- rbind(samp.df, cbind(rep(i, n), s))
}

## テキスト用出力
samp.df %>%
  group_by(V1) %>%
  summarise(M = mean(s)) %>%
  distinct() %>%
  dplyr::rename(サンプル番号 = V1, 標本平均 = M) -> tbl1
print(xtable::xtable(tbl1, digits = 2, label = "tbl::16_02"), include.rownames = F)

## 標本平均の平均
mean(samp.df$s)
## 母平均とのズレ
mean(samp.df$s) - mean(X)
## 標本平均のSD
samp.df %>%
  group_by(V1) %>%
  summarise(M = mean(s)) %>%
  summarise(V = sd(M) * 9 / 10)

# サンプルサイズをあげる
n <- 10
samp.df <- data.frame(id = numeric(), val = numeric())
for (i in 1:10) {
  s <- sample(X, n, replace = F)
  print(s)
  samp.df <- rbind(samp.df, cbind(rep(i, n), s))
}

samp.df %>% ggplot(aes(x = s)) +
  geom_histogram(binwidth = 3) +
  facet_wrap(~V1, ncol = 5) -> g2
ggsave(g2, filename = "Rplot16_02.png", dpi = 600, width = 8, height = 4)

samp.df %>%
  group_by(V1) %>%
  summarise(M = mean(s)) %>%
  distinct() %>%
  dplyr::rename(サンプル番号 = V1, 標本平均 = M) -> tbl2

print(xtable::xtable(tbl2, digits = 2, label = "tbl::16_03"), include.rownames = F)

mean(samp.df$s) - mean(X)
## 標本平均の分散
samp.df %>%
  group_by(V1) %>%
  summarise(M = mean(s)) %>%
  summarise(V = sd(M) * 9 / 10)


# サンプルサイズを変えるシミュレーション ---------------------------------------------------------------
set.seed(5971)
### 仮想母集団を大きめに
N <- 100000
X <- rnorm(N, 50, 10)
## サンプル数
iter <- 100
## 空のデータフレームを作る
samp.df <- data.frame(id = numeric(), val = numeric())
## サンプルサイズ
n <- 3
for (i in 1:iter) {
  s <- sample(X, n, replace = F)
  samp.df <- rbind(samp.df, cbind(rep(i, n), s))
}
samp.df %>%
  group_by(V1) %>%
  summarise(T1 = mean(s)) -> T1

n <- 5
for (i in 1:iter) {
  s <- sample(X, n, replace = F)
  samp.df <- rbind(samp.df, cbind(rep(i, n), s))
}
samp.df %>%
  group_by(V1) %>%
  summarise(T2 = mean(s)) -> T2

n <- 10
for (i in 1:iter) {
  s <- sample(X, n, replace = F)
  samp.df <- rbind(samp.df, cbind(rep(i, n), s))
}
samp.df %>%
  group_by(V1) %>%
  summarise(T3 = mean(s)) -> T3

n <- 50
for (i in 1:iter) {
  s <- sample(X, n, replace = F)
  samp.df <- rbind(samp.df, cbind(rep(i, n), s))
}
samp.df %>%
  group_by(V1) %>%
  summarise(T4 = mean(s)) -> T4

T1 %>%
  right_join(T2, by = "V1") %>%
  right_join(T3, by = "V1") %>%
  right_join(T4, by = "V1") -> MeanSet
MeanSet$M1 <- NA
MeanSet$M2 <- NA
MeanSet$M3 <- NA
MeanSet$M4 <- NA

for (i in 1:NROW(MeanSet)) {
  MeanSet$M1[i] <- mean(MeanSet$T1[1:i])
  MeanSet$M2[i] <- mean(MeanSet$T2[1:i])
  MeanSet$M3[i] <- mean(MeanSet$T3[1:i])
  MeanSet$M4[i] <- mean(MeanSet$T4[1:i])
}


MeanSet %>%
  dplyr::select(V1, M1, M2, M3, M4) %>%
  pivot_longer(-V1) %>%
  mutate(name = factor(name, labels = c("n=3", "n=5", "n=10", "n=50"))) %>%
  ggplot(aes(x = V1, y = value, color = name)) +
  # geom_point() +
  geom_hline(yintercept = mean(X), color = "blue", lty = 2) +
  geom_line() +
  ylab("mean(Expectation)") +
  xlab("number of samples") +
  facet_wrap(~name, nrow = 2, ncol = 2) +
  scale_fill_manual(values = c("#CC6666", "#9999CC", "#66CC99"))



ggsave(filename = "Rplot16_03.png", dpi = 600, width = 8, height = 4)

# 分散の場合 -------------------------------------------------------------------

n <- 10
samp.df <- data.frame(id = numeric(), val = numeric())
for (iter in 1:200) {
  s <- sample(X, n, replace = F)
  samp.df <- rbind(samp.df, cbind(rep(iter, n), s))
}

samp.df %>%
  group_by(V1) %>%
  summarise(unV = var(s), bV = unV * (n - 1) / n) %>%
  distinct() -> VM

VM$unV_m <- NA
VM$V_m <- NA

for (i in 1:NROW(VM)) {
  VM$unV_m[i] <- mean(VM$unV[1:i])
  VM$V_m[i] <- mean(VM$bV[1:i])
}

# 分散の式はずれてしまう
VM %>%
  dplyr::select(V1, V_m) %>%
  ggplot(aes(x = V1, y = V_m)) +
  geom_point() +
  geom_line() +
  geom_hline(yintercept = mean((X - mean(X))^2), color = "blue", lty = 2) +
  theme_gray(base_family = "HiraKakuPro-W3") +
  xlab("number of samples") +
  ylab("mean(Expectation)")
ggsave(filename = "Rplot16_04.png", dpi = 600, width = 8, height = 4)

# 不偏分散を使おう
VM %>%
  dplyr::select(V1, unV_m, V_m) %>%
  pivot_longer(-V1) %>%
  ggplot(aes(x = V1, y = value, group = name, color = name)) +
  geom_line() +
  geom_hline(yintercept = mean((X - mean(X))^2), color = "blue", lty = 2) +
  scale_color_hue(name = "分散の種類", labels = c(unV_m = "不偏分散", V_m = "標本分散")) +
  theme_gray(base_family = "HiraKakuPro-W3") +
  xlab("number of samples") +
  ylab("mean(Expectation)") +
  scale_fill_manual(values = c("#CC6666", "#9999CC", "#66CC99"))

ggsave(filename = "Rplot16_05.png", dpi = 600, width = 8, height = 4)
