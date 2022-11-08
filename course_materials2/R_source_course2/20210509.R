rm(list = ls())
library(tidyverse)
library(psych)
help(bfi)
dat <- psych::bfi %>% dplyr::select(-gender, -education, -age)
dat

corMat <- cor(dat, use = "pairwise")
corMat
eig <- eigen(corMat)
cumsum(eig$values / sum(eig$values))

png("../images/chapter10/Rplot10_01.png", width = 800, height = 800) # 描画デバイスを開く
fa.parallel(dat, fa = "fa")
dev.off()
ret <- fa.parallel(dat, fa = "fa")
ret$fa.values
ret$fa.sim

result <- fa(dat, nfactors = 5, fm = "ml", rotate = "geominQ", scores = T)
print(result, sort = T, cut = 0.3)
result$scores

dat %>%
  dplyr::mutate(
    A = (A1 + A2 + A3 + A4 + A5) / 5,
    C = (C1 + C2 + C3 + C4 + C5) / 5,
    E = (E1 + E2 + E3 + E4 + E5) / 5,
    N = (N1 + N2 + N3 + N4 + N5) / 5,
    O = (O1 + O2 + O3 + O4 + O5) / 5
  ) %>%
  dplyr::bind_cols(., result$scores %>% as.data.frame()) %>%
  dplyr::select(ML1, ML2, ML3, ML4, ML5, A, C, E, N, O) %>%
  cor(use = "pairwise")
