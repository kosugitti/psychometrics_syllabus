rm(list=ls())
library(tidyverse)
library(colorBlindness)
old = theme_set(theme_gray(base_family="HiraKakuProN-W3"))
scale_fill_manual(values=colorBlindness::Blue2Orange10Steps)
p <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) + 
    stat_function(fun = dnorm)+
    stat_function(fun = dnorm, args = list(mean=1,sd=1),color=palette()[2])+
    stat_function(fun = dnorm, args = list(mean=1,sd=3),color=palette()[4])+
    stat_function(fun = dnorm, args = list(mean=-2,sd=0.5),color=palette()[3])
    
p    
ggsave(p, filename = "../images/text08/Rplot08_01.png", dpi = 600, width = 12, height = 8)
