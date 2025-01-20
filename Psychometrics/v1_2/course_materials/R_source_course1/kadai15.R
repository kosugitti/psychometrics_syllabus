rm(list=ls())
library(tidyverse)

# お題 ----------------------------------------------------------------------
# 平均値を同じに設定した正規乱数をN個発生させ，無作為に2群に分割して，5%水準でt検定にかけた。
# このとき，正しいことを言っている文章をすべて選びなさい。
# 選択肢
# 必ず帰無仮説が採択される。
# 95%の確率で帰無仮説が棄却される。
# 必ず対立仮説が採択される。
# 5％の確率で対立仮説が採択される。
# 5%の確率で帰無仮説が棄却される。
# 乱数の標準偏差をより大きく設定すると，対立仮説が採択されやすくなる。
# 乱数の標準偏差をより小さく設定すると，対立仮説が採択されやすくなる。
# Nをより大きくすると，帰無仮説が採択されやすくなる。
# Nをより大きくすると，対立仮説が採択されやすくなる。
# 
set.seed(12345)
MaX <- 1000

result <- matrix(NA,ncol=4,nrow=MaX*5*3) %>% data.frame
colnames(result) <- c("iter", "N","sig", "p")
tmp <- 0
for(i in 1:MaX){
    mu <- 0
    for(n in c(10,30,50,100,1000)){
        for(sig in c(1,3,5)){
            tmp <- tmp +1
            X <- rnorm(n, mu, sig) %>% transform() %>% 
                mutate(G = rep(1:2,n/2))
            res <- t.test(X_data~G, data = X)
            result[tmp,]$iteri= i
            result[tmp,]$N= n
            result[tmp,]$sig = sig
            result[tmp,]$p = res$p.value
        }
    }
}


# 必ず帰無仮説が採択される。
# 95%の確率で帰無仮説が棄却される。
# 必ず対立仮説が採択される。
# 5％の確率で対立仮説が採択される。
# 5%の確率で帰無仮説が棄却される。
result %>% dplyr::mutate(FLG = if_else(p<0.05,1,0)) %>% summary()

# 乱数の標準偏差をより大きく設定すると，対立仮説が採択されやすくなる。
# 乱数の標準偏差をより小さく設定すると，対立仮説が採択されやすくなる。
# Nをより大きくすると，帰無仮説が採択されやすくなる。
# Nをより大きくすると，対立仮説が採択されやすくなる。
result %>% 
    dplyr::mutate(FLG = if_else(p<0.05,1,0)) %>% 
    group_by(sig) %>% 
    summarise(MEAN = mean(FLG))
result %>% 
    dplyr::mutate(FLG = if_else(p<0.05,1,0)) %>% 
    group_by(N) %>% 
    summarise(MEAN = mean(FLG))
