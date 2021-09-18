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

d2 <- rep(10:1,10)
d1 <- rep(1:10,each=10)
dat <- transform(list(x=d1,y=d2,val=as.vector(X)))
g <- ggplot(dat,aes(x=d1,y=d2,label=val))+geom_text(size=10)+xlab("")+ylab("")+
  theme(
    panel.background = element_blank(),
    panel.grid = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank()
  )+scale_y_continuous(breaks=NULL)+scale_x_continuous(breaks=NULL)
ggsave(file = paste0("start",".png"), plot = g, dpi = 100, width = 10,height = 5)


# 何行何列目かを見つける関数
finds <- function(x,v){
  result <- c()
  for(i in 1:length(v)){
    pos <- which(x==v[i])
    if(length(pos)>1){pos=sample(pos,1)}
    result <- c(result,pos)
  }
  return(result)
}
 

# 可視化 ---------------------------------------------------------------------
n <- 5
samp.df2 <- data.frame(id=numeric(),val=numeric())
for(i in 1:10){
  dat$col <- 1
  s <- samp.df %>% filter(V1==i)
  print(s)
  gr <- finds(dat$val,s$s)
  dat[gr,]$col <- 2
  dat$col <- as.factor(dat$col)
  g <- ggplot(dat,aes(x=d1,y=d2,label=val,color=col))+geom_text(size=10)+xlab("")+ylab("")+
    theme(
      panel.background = element_blank(),
      panel.grid = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      legend.position = 'none'
    )+scale_y_continuous(breaks=NULL)+scale_x_continuous(breaks=NULL)+
    scale_color_manual(values = c("black","red"))
  ggsave(file = paste0("sample",i,".png"), plot = g, dpi = 100, width = 10,height = 5)
  samp.df2 <- rbind(samp.df2,cbind(rep(i,n),s))
}
samp.df2$V1 <- as.factor(samp.df2$V1)
tapply(samp.df2$s,samp.df2$V1,mean)
mean(samp.df2$s)

mean((tapply(samp.df2$s,samp.df2$V1,mean)-mean(x))^2)


# サンプル数を増やす ---------------------------------------------------------------
n <- 10
mm <- c()
for(X in 1:100){
  samp.df <- data.frame(id=numeric(),val=numeric())
  for(i in 1:X){
    dat$col <- 1
    s <- sample(x,n,replace = F)
    gr <- finds(x,s)
    dat[gr,]$col <- 2
    dat$col <- as.factor(dat$col)
    # g <- ggplot(dat,aes(x=d1,y=d2,label=val,color=col))+geom_text(size=10)+xlab("")+ylab("")+
    #   theme(
    #     panel.background = element_blank(),
    #     panel.grid = element_blank(),
    #     axis.title.x = element_blank(),
    #     axis.title.y = element_blank(),
    #     legend.position = 'none'
    #   )+scale_y_continuous(breaks=NULL)+scale_x_continuous(breaks=NULL)+
    #   scale_color_manual(values = c("black","red"))
    #ggsave(file = paste0("sample",i,".png"), plot = g, dpi = 100, width = 10,height = 5)
    samp.df <- rbind(samp.df,cbind(rep(i,n),s))
  }
  mm <- c(mm,mean(samp.df$s))
}
mm %>% transform() %>% mutate(id=row_number(),val=X_data) %>% ggplot(aes(x=id,y=val))+
  geom_point()+geom_line()+geom_hline(yintercept=mean(x),color="red")+ylab('mean')+xlab('numbeer of samples')

# サンプルサイズを変える ---------------------------------------------------------------
n <- 5
mm2 <- c()
for(X in 1:100){
  samp.df <- data.frame(id=numeric(),val=numeric())
  for(i in 1:X){
    dat$col <- 1
    s <- sample(x,n,replace = F)
    gr <- finds(x,s)
    dat[gr,]$col <- 2
    dat$col <- as.factor(dat$col)
    samp.df <- rbind(samp.df,cbind(rep(i,n),s))
  }
  mm2 <- c(mm2,mean(samp.df$s))
}
c(mm,mm2) %>% transform()%>% mutate(id=rep(1:100,2),val=X_data,n=rep(1:2,each=100)) %>%
  mutate(n=factor(n,labels=c("n=10","n=5"))) %>% ggplot(aes(x=id,y=val,color=n))+geom_point()+
  geom_hline(yintercept = mean(x))+geom_line()+ylab('mean')+xlab('numbeer of samples')

n <- 3
mm3 <- c()
for(X in 1:100){
  samp.df <- data.frame(id=numeric(),val=numeric())
  for(i in 1:X){
    dat$col <- 1
    s <- sample(x,n,replace = F)
    gr <- finds(x,s)
    dat[gr,]$col <- 2
    dat$col <- as.factor(dat$col)
    samp.df <- rbind(samp.df,cbind(rep(i,n),s))
  }
  mm3 <- c(mm3,mean(samp.df$s))
}

n <- 20
mm4 <- c()
for(X in 1:100){
  samp.df <- data.frame(id=numeric(),val=numeric())
  for(i in 1:X){
    dat$col <- 1
    s <- sample(x,n,replace = F)
    gr <- finds(x,s)
    dat[gr,]$col <- 2
    dat$col <- as.factor(dat$col)
    samp.df <- rbind(samp.df,cbind(rep(i,n),s))
  }
  mm4 <- c(mm4,mean(samp.df$s))
}

c(mm3,mm2,mm,mm4) %>% transform()%>% mutate(id=rep(1:100,4),val=X_data,n=rep(1:4,each=100)) %>%
  mutate(n=factor(n,labels=c("n=3","n=5","n=10","n=20"))) %>% ggplot(aes(x=id,y=val,color=n))+geom_point()+
  geom_hline(yintercept = mean(x))+geom_line()+ylab('mean')+xlab('numbeer of samples')+facet_wrap(~n,nrow=2,ncol=2)


# 分散の場合 -------------------------------------------------------------------

n <- 10
for(X in 1:200){
  samp.df <- data.frame(id=numeric(),val=numeric())
  for(i in 1:X){
    s <- sample(x,n,replace = F)
    samp.df <- rbind(samp.df,cbind(rep(i,n),s))
  }
}
samp.df$V1 <- as.factor(samp.df$V1)
mvec <- tapply(samp.df$s,samp.df$V1,mean)

vm <- c()
for(i in 1:length(mvec)){
  tmp <- mean((mvec[1:i] - mean(mvec[1:i]))^2)
  vm <- c(vm,tmp)
}

vm %>% transform() %>% mutate(id=1:nrow(mvec),val=X_data) %>% ggplot(aes(x=id,y=val))+geom_point()+geom_line(color='red')+
  geom_hline(yintercept=mean((x-mean(x))^2)/n)
  