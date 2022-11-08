rm(list = ls())
library(tidyverse)
dat <- read_csv("M1score2021.csv", na = c(".", " "))
dat %>%
  dplyr::filter(年代 > 17) %>%
  dplyr::select(
    年代, 演者, ネタ順,
    オール巨人,
    富澤たけし,
    塙宣之,
    立川志らく,
    中川礼二,
    松本人志,
    上沼恵美子
  ) %>%
  print() %>%
  dplyr::mutate(Score = オール巨人 + 富澤たけし + 塙宣之 + 立川志らく + 中川礼二 + 松本人志 + 上沼恵美子) %>%
  ggplot(aes(x = ネタ順, y = Score, group = 年代, color = as.factor(年代))) +
  geom_point() +
  geom_line()

dat %>%
  dplyr::filter(年代 > 17) %>%
  dplyr::select(
    オール巨人,
    富澤たけし,
    塙宣之,
    立川志らく,
    中川礼二,
    松本人志,
    上沼恵美子
  ) %>%
  cor()


# 審査員の類似度
dat %>%
  dplyr::filter(年代 > 17) %>%
  dplyr::select(
    年代,
    オール巨人,
    富澤たけし,
    塙宣之,
    立川志らく,
    中川礼二,
    松本人志,
    上沼恵美子
  ) %>%
  group_by(年代) %>%
  nest() %>%
  mutate(dist = purrr::map(data, ~ dist(t(.)))) %>%
  ungroup() %>%
  select(dist) -> kos
M18 <- kos[1, ]$dist[[1]]
M19 <- kos[2, ]$dist[[1]]
M20 <- kos[3, ]$dist[[1]]
M21 <- kos[4, ]$dist[[1]]

result <- smacof::smacofIndDiff(list(M18, M19, M20, M21),
  ndim = 3, type = "ordinal",
  constraint = "idioscal"
)
result$cweights
result$gspace
result$cweights
result$stress
plot(result, plot.type = "bubbleplot")
plot(result, plot.type = "stressplot")
plot(result, plot.type = "confplot")
plot(result, plot.type = "Shepard")
config <- result$gspace %*% result$cweights[[4]] %>%
  as.data.frame() %>%
  rownames_to_column("judges")
g1 <- config %>% ggplot(aes(x = D1, y = D2, label = judges)) +
  geom_point() +
  geom_label()
g2 <- config %>% ggplot(aes(x = D1, y = D3, label = judges)) +
  geom_point() +
  geom_label()
g3 <- config %>% ggplot(aes(x = D2, y = D3, label = judges)) +
  geom_point() +
  geom_label()
library(patchwork)
g1 + g2 + g3

library(plotly)
plot_ly(x = config$D1, y = config$D2, z = config$D3, type = "scatter3d", mode = "markers", symbol = config$judges)
