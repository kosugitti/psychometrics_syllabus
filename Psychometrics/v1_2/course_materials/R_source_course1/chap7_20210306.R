rm(list=ls())
library(tidyverse)
library(gridExtra)
set.seed(20210306)
N <- 1000
Y <- rnorm(N, 160, 10)
g <- Y %>%
    as_tibble() %>%
    ggplot(aes(x = value)) +
    geom_histogram(binwidth = 5, fill = "#56B4E9", colour = "#0072B2", boundary = 0, closed = "left") +
    ylim(0, 220) +
    stat_bin(binwidth = 5, boundary = 0, closed = "left", aes(label = ..count..), geom = "text", vjust = -0.5, color = "#993F00")

ggsave(g,filename = "../images/text07/Rplot07_01.png", dpi = 600, width = 12, height = 8)

g <- Y %>%
    as_tibble() %>%
    ggplot(aes(x = value)) +
    geom_histogram(binwidth =2.5, fill = "#56B4E9", colour = "#0072B2", boundary = 0, closed = "left") +
    ylim(0, 120) +
    stat_bin(binwidth = 2.5, boundary = 0, closed = "left", aes(label = ..count..), geom = "text", vjust = -0.5, color = "#993F00")
ggsave(g,filename = "../images/text07/Rplot07_02.png", dpi = 600, width = 12, height = 8)

g <- Y %>%
    as_tibble() %>%
    ggplot(aes(x = value)) +
    geom_histogram(binwidth =0.5, fill = "#56B4E9", colour = "#0072B2", boundary = 0, closed = "left") +
    ylim(0, 35) +
    stat_bin(binwidth = 0.5, boundary = 0, closed = "left", aes(label = ..count..), geom = "text", vjust = -0.5, color = "#993F00")
ggsave(g,filename = "../images/text07/Rplot07_03.png", dpi = 600, width = 12, height = 8)


g1 <- data.frame(Ns = seq(0, 5)) %>%
    dplyr::mutate(Prob = dbinom(Ns, 5, 0.2)) %>%
    ggplot(aes(x = Ns, y = Prob)) + xlab("成功回数") +
    geom_bar(stat = "identity")

g2 <- data.frame(Ns = seq(0, 10)) %>%
    dplyr::mutate(Prob = dbinom(Ns, 10, 0.5)) %>%
    ggplot(aes(x = Ns, y = Prob)) + xlab("成功回数") +
    geom_bar(stat = "identity")

g3 <- data.frame(Ns = seq(0, 30)) %>%
    dplyr::mutate(Prob = dbinom(Ns, 30, 0.8)) %>%
    ggplot(aes(x = Ns, y = Prob)) + xlab("成功回数") +
    geom_bar(stat = "identity")
g <- gridExtra::grid.arrange(g1,g2,g3)
ggsave(g,filename = "../images/text07/Rplot07_04.png", dpi = 600, width = 12, height = 8)

