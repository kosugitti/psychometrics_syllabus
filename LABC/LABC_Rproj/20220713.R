library(tidyverse)
# 基底の取り替え
## 新しい基底
NewE1 <- c(3,-1)
NewE2 <- c(1,4)
normE1 <- sqrt(sum(NewE1^2))
normE2 <- sqrt(sum(NewE2^2))
## 変換行列
A <- matrix(c(3,1,-1,4),ncol=2,byrow=T)
#新しい空間の座標点
NewCoord <- expand.grid(-2:5,-2:5) %>% mutate(N1=NA,N2=NA)
for(i in 1:NROW(NewCoord)){
    New1 <- A %*% c(NewCoord$Var1[i],NewCoord$Var2[i])
    NewCoord$N1[i] <- New1[1]
    NewCoord$N2[i] <- New1[2]
}

for(i in -1:3){
    ## 横軸
    tmp1s <- c(-2,i)
    tmp1e <- c(5,i)
    ## 縦軸
    tmp2s <- c(i,-2)
    tmp2e <- c(i,5)
    ###新しい横軸
    new1s <- A %*% tmp1s
    new1e <- A %*% tmp1e
    ### 新しい縦軸
    new2s <- A %*% tmp2s
    new2e <- A %*% tmp2e
    #### 出力
    print(paste0("\\draw[cyan!30] (",new1s[1],",",new1s[2],")--(",new1e[1],",",new1e[2],");"))
    print(paste0("\\draw[cyan!30] (",new2s[1],",",new2s[2],")--(",new2e[1],",",new2e[2],");"))
}
