rm(list = ls())
library(cmdstanr)
library(posterior)
library(bayesplot)
color_scheme_set("brightblue")

model <- cmdstanr::cmdstan_model("categorical1.stan")
fit <- model$sample(
  data = list(K = 3, X = c(51, 45, 27)),
  chains = 4,
  parallel_chains = 4,
  refresh = 500
)

fit

bayesplot::mcmc_areas(fit$draws(c("theta[1]", "theta[2]", "theta[3]"))) %>% 
  ggsave(filename = "../images/chapter23/Rplot23_01.png", dpi = 600, width = 8, height = 4)
fit

# Kappa係数
model2 <- cmdstanr::cmdstan_model("kappa.stan")
dataSet <- list(Y=c(55,16,14,35))
fit2 <- model2$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4
)
fit2
