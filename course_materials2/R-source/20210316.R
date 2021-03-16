rm(list=ls())
library(tidyverse)
library(rstatix)
library(broom)
library(ltm)
load("IRTsample.Rdata")
test <- df %>%dplyr::select(-GID,-ID) 
result.irt <- ltm(test~z1)

set.seed(20210316)

twoParameters <- function(x,a,b){
    1/(1+exp(-1.7*a*(x-b)))
}

ITEMS <- c("M0104","M0605","D0014","I0018","B0003")

irtSample <- result.irt$coefficients %>% as.data.frame %>% rownames_to_column("Qid") %>% 
    dplyr::rename(b='(Intercept)',a=z1) %>% as_tibble %>% 
    filter(a > 0.8 & a < 2) %>% 
    filter(b > -2 & b < 2) %>% 
    # arrange(b) %>% tail() %>% 
    filter(Qid %in% ITEMS)

p <- ggplot(data.frame(X=c(-4, 4)), aes(x=X)) + xlab("theta")+ ylab("pass ratio")+
    mapply(
        function(a,b,co) stat_function(fun=twoParameters, args=list(a=a, b=b), aes_q(color=co)),
        irtSample$a,irtSample$b,irtSample$Qid
    ) + labs(color="items")

ggsave(p, filename = "../images/chapter04/Rplot04_05.png", dpi = 600, width = 12, height = 6)

irtSample %>% xtable::xtable()

twoParameters(0,irtSample[1,]$a,irtSample[1,]$b)*100
twoParameters(2,irtSample[1,]$a,irtSample[1,]$b)*100
twoParameters(0,irtSample[3,]$a,irtSample[3,]$b)*100
twoParameters(2,irtSample[3,]$a,irtSample[3,]$b)*100
