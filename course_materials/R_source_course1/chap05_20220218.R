library(tidyverse)
library(ggplot2)
library(gridExtra)
library(colorBlindness)
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
set.seed(12345)
limitRange <- function(fun, min, max) {
    function(x) {
        y <- fun(x)
        y[x <= min | x >= max] <- NA
        return(y)
    }
}

dL <- 2
dS <- 0.2
sL <- 2
sS <- 0.2

g1 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
    stat_function(fun = dnorm,args=list(mean=dL,sd=sS),color=cbPalette[3]) +
    stat_function(fun = dnorm,args=list(mean=-dL,sd=sS),color=cbPalette[2]) +
    xlab("")+ylab("")+theme(axis.text.y=element_blank())
g2 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
    stat_function(fun = dnorm,args=list(mean=dS,sd=sS),color=cbPalette[3]) +
    stat_function(fun = dnorm,args=list(mean=-dS,sd=sS),color=cbPalette[2]) +
    xlab("")+ylab("")+theme(axis.text.y=element_blank())
g3 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
    stat_function(fun = dnorm,args=list(mean=dL,sd=sL),color=cbPalette[3]) +
    stat_function(fun = dnorm,args=list(mean=-dL,sd=sL),color=cbPalette[2]) +
    xlab("")+ylab("")+theme(axis.text.y=element_blank())
g4 <- ggplot(data.frame(x = c(-4, 4)), aes(x = x)) +
    stat_function(fun = dnorm,args=list(mean=dS,sd=sL),color=cbPalette[3]) +
    stat_function(fun = dnorm,args=list(mean=-dS,sd=sL),color=cbPalette[2]) +
    xlab("")+ylab("")+theme(axis.text.y=element_blank())
g <- grid.arrange(g1,g2,g3,g4)

ggsave(g, filename = "../images/05_descriptives/m05_01.png", dpi = 800, width = 8, height = 4)
