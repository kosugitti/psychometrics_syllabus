rm(list = ls())
library(tidyverse)
source("http://aoki2.si.gunma-u.ac.jp/R/src/dual.R", encoding = "euc-jp")
source("http://aoki2.si.gunma-u.ac.jp/R/src/summary.dual.R", encoding = "euc-jp")
source("http://aoki2.si.gunma-u.ac.jp/R/src/plot.dual.R", encoding = "euc-jp")

blood <- matrix(c(0, 5, 0, 0, 0, 2, 3, 0, 3, 2, 0, 1), ncol = 4)
blood
res <- dual(blood)
res
plot(res)

blood2 <- data.frame(
  HeadACHE = c(3, 3, 3, 4, 4, 1, 1, 1, 1, 1, 2, 2, 3, 3, 3, 4),
  Blood = c(3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1)
)
blood2 %>% cor()

blood3 <- data.frame(
  HeadACHE2 = c(3, 3, 4, 4, 4, 2, 2, 3, 4, 4, 4, 1, 1, 1, 1, 1),
  Bloos = c(3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1)
)
blood3 %>% cor()

tbl <- matrix(c( # 3行4列の分割表の例（ファイルから読んでも良い）
  2, 3, 5, 6,
  5, 1, 7, 5,
  5, 3, 4, 3
), byrow = TRUE, ncol = 4)

ans <- dual(tbl)
summary(ans)
summary(ans, weighted = TRUE)
plot(ans, 1, 2)
library(MASS) # R の MASS 中の corresp を使ってみる
corresp(tbl, nf = min(nrow(tbl), ncol(tbl)) - 1)

library(MASS)
caith
result <- corresp(caith, nf = min(nrow(caith), ncol(caith) - 1))
result
plot(result)

caith %>% knitr::kable(format = "latex")

library(ggrepel)
library(colorBlindness)
scale_fill_manual(values = colorBlindness::Blue2Orange10Steps)
result$rscore[, 1:2] %>%
  as.data.frame() %>%
  rownames_to_column() %>%
  mutate(rowname = paste0(rowname, "_eye")) %>%
  rbind(result$cscore[, 1:2] %>% as.data.frame() %>% rownames_to_column() %>% mutate(rowname = paste0(rowname, "_hair"))) %>%
  mutate(RC = if_else(str_detect(rowname, pattern = "hair"), 1, 2) %>% as.factor()) %>%
  ggplot(aes(x = V1, y = V2, label = rowname, color = RC)) +
  geom_point() +
  geom_text_repel() +
  theme(legend.position = "none") +
  xlab("dim1") +
  ylab("dim2") -> g
ggsave(g, filename = "../images/chapter14/Rplot14_01.png", dpi = 600, width = 8, height = 8)
