rm(list = ls())
library(tidyverse)
library(cmdstanr)
library(bayestestR)
library(posterior)x
set.seed(12345)
d <- 5
N1 <- N2 <- 30
mu1 <- 50
mu2 <- mu1 + d
X1 <- rnorm(N1, mu1, 10)
X2 <- rnorm(N2, mu2, 10)
model <- cmdstanr::cmdstan_model("ttest20220107.stan")
dataSet <- list(N1 = N1, N2 = N2, X1 = X1, X2 = X2)
fit <- model$sample(
  data = dataSet,
  iter_sampling = 10000
)
fit$summary()
result.df <- fit$draws(c("diff", "d", "mu1", "mu2", "sig1", "sig2")) %>%
  posterior::as_draws_df() %>%
  distinct() %>%
  as_tibble()
result.df %>%
  describe_posterior(centrality = c("median", "mean"), dispersion = T, rope_range = c(-5, 5), test = "rope")

result.df %>%
  select(diff) %>%
  ggplot(aes(x = diff)) +
  geom_density() +
    geom_vline(xintercept = -5,lty=2)+
    geom_vline(xintercept = 5,lty=2)+
    geom_segment(
        data = result.df, aes(x = -13.20, xend = -1.59, y = 0.01, yend = 0.01),
        arrow = arrow(ends = "both", angle = 90, length = unit(.2, "cm")), color = palette()[1],lwd=2
    )+
    xlab("差の事後分布")+ylab("密度")

data.frame(value = c(X1,X2),group=c(rep(1,N1),rep(2,N2))) %>% write_csv("ttest20220107.csv")
           