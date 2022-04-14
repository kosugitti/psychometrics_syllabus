rm(list = ls())
library(tidyverse)
library(ggrepel)
library(metR) # geom_text_contour

# Metric MDS --------------------------------------------------------------

# MDSの関数
result.MDS1 <- cmdscale(eurodist, k = 3)
# y軸反転
g <- result.MDS1 %>%
  as.data.frame() %>%
  dplyr::mutate(label = rownames(.)) %>%
  ggplot(aes(x = V1, y = V2, label = label)) +
  geom_point() +
  geom_text_repel(size=7) +
  xlim(-2500, 2500) +
  ylim(2500, -2500) +
  xlab("dim 1") +
  ylab("dim2")

ggsave(g, filename = "../images/15_MDS/Rplot15_01.png", dpi = 600, width = 16, height = 16)

# Non-Metric MDS ----------------------------------------------------------
dat <- read_csv("M1score2021.csv")

dat.mat <- dat %>%
  dplyr::filter(年代 == 21) %>%
  arrange(ネタ順) %>%
  dplyr::select(-年代, -ネタ順) %>%
  pivot_longer(-演者) %>%
  na.omit() %>%
  pivot_wider(id_cols = 演者, names_from = name, values_from = value)

dat.mat %>% knitr::kable(format = "latex")
dat.mat <- dat.mat %>% as.matrix()

## 距離の計算例
tmp.dat <- dat %>%
  dplyr::filter(年代 == 21) %>%
  arrange(ネタ順) %>%
  dplyr::select(-年代, -ネタ順) %>%
  pivot_longer(-演者) %>%
  na.omit() %>%
  pivot_wider(id_cols = name, names_from = 演者, values_from = value) %>%
  dplyr::select(name, モグライダー, ランジャタイ) %>%
  dplyr::mutate_at(2:3, as.numeric) %>%
  dplyr::mutate(diff = モグライダー - ランジャタイ) %>%
  dplyr::mutate(sq = diff^2) %>%
  t()
Name.tmp <- tmp.dat[1, ]
tmp.dat <- tmp.dat[-1, ] %>%
  apply(1, as.numeric) %>%
  addmargins(1) %>%
  t()
colnames(tmp.dat) <- c(Name.tmp, "総和")
tmp.dat %>% knitr::kable(format = "latex")



rownames(dat.mat) <- dat.mat[, 1]
dat.mat <- dat.mat[, -1] %>%
  dist()

dat.mat %>%
  as.matrix() %>%
  knitr::kable(format = "latex", digit = 3)


library(MASS)
## stress check
N <- 7
stress.df <- data.frame(dim = 1:N, stress.pct = matrix(nrow = N))
for (i in 1:N) {
  tmp <- isoMDS(dat.mat, k = i)
  stress.df[i, ]$stress.pct <- tmp$stress
}

g <- stress.df %>%
  na.omit() %>%
  mutate(stress = stress.pct / 100) %>%
  print() %>%
  ggplot(aes(x = dim, y = stress)) +
  geom_point() +
  geom_line() +
  scale_x_continuous(breaks = 1:N) +
  xlab("次元数") +
  ylab("Stress値")

ggsave(g, filename = "../images/15_MDS/Rplot15_02.png", dpi = 600, width = 8, height = 6)

result.isoMDS <- dat.mat %>% isoMDS(k = 2)
g <- result.isoMDS$points %>%
  as.data.frame() %>%
  rownames_to_column("player") %>%
  ggplot(aes(x = V1, y = V2, label = player)) +
  geom_point() +
  geom_text_repel() +
  xlab("Dim 1") +
  ylab("Dim 2")
ggsave(g, filename = "../images/15_MDS/Rplot15_03.png", dpi = 600, width = 8, height = 8)



# prefmap -----------------------------------------------------------------

Kosugi <- c(90,60,85,92,83,89,85,83,82,88)
## データフレームにして操作
result.isoMDS$points %>% data.frame %>% 
  # 変数名を作成
  mutate(Player=rownames(.)) %>% 
  # 個人の選好を追加
  mutate(Pref=Kosugi) %>% 
  # 第一項のために二乗和を計算
  mutate(XX = X1^2+X2^2) %>% print -> PrefData
## 回帰分析で係数を算出
result.lm <- lm(Pref~XX+X1+X2,data=PrefData)
summary(result.lm)
## 理想点
coef <- result.lm$coefficients
Ideal <- data.frame(X1=-0.5*coef[3]/coef[2],X2=-0.5*coef[4]/coef[2],Player="著者の理想点")
## 描画
g1 <- PrefData %>% 
  dplyr::select(X1,X2,Player) %>% 
  bind_rows(Ideal) %>% 
  bind_cols(data.frame(Col = as.factor(c(rep(1,10),2)))) %>% 
  ggplot(aes(x=X1,y=X2,label=Player)) + geom_point(aes(pch = Col)) + 
  geom_text_repel()+theme(legend.position = "none")
ggsave(g1, filename = "../images/15_MDS/Rplot15_04.png", dpi = 600, width = 8, height = 8)

# Abelson -----------------------------------------------------------------

# 自作関数Abelson.map
Abelson.map <- function(dat,locations){
  z <- double()
  X <- dat[,1]
  Y <- dat[,2]
  P <- dat[,3]
  un <- matrix(1,nrow(locations),1,)
  Xs <- un %*% X
  Ys <- un %*% Y
  dm <- ((locations[,1]-Xs)^2+(locations[,2]-Ys)^2+1)
  V <- t(P %*% (1/t(dm)))
  xx <- sort(unique(locations[,1]))
  nx <- length(xx)
  yy <- sort(unique(locations[,2]))
  ny <- length(yy)
  values <- matrix(V,ncol=ny)
  ret <- structure(list(x=xx,y=yy,valence=values))
  return(ret)
}
##　空間全体の座標を作成
loc <- expand.grid(seq(-10,10,0.1),seq(-10,10,0.1))
## x,y,Vの座標をデータとする
result.isoMDS$points %>% data.frame %>% 
  # 個人の選好を追加
  mutate(Pref=Kosugi-mean(Kosugi)) -> abDat
ab <- Abelson.map(abDat,loc)
abDat <- abDat %>% rownames_to_column("player")
### 再構成
abX <- ab$x
abY <- ab$y
rownames(ab$valence) <- abY
colnames(ab$valence) <- abX
tbl <- ab$valence %>% as.data.frame %>% 
  rownames_to_column("X") %>%
  pivot_longer(-X,names_to="Y") %>% 
  mutate_all(as.numeric) %>% 
  as_tibble

g <- ggplot()
g <- g +  geom_contour(data=tbl, aes(x=X,y=Y,z=value),binwidth = 3)
#g <- g + geom_text_contour(data=tbl, aes(x=X,y=Y,z=value),binwidth = 3)
g <- g +  geom_point(data=abDat,aes(x=X1,y=X2))
g <- g + geom_text_repel(data = abDat,aes(x=X1,y=X2,label=player))
g

ggsave(g, filename = "../images/15_MDS/Rplot15_05.png", dpi = 600, width = 8, height = 8)
