rm(list = ls())
library(pacman)
pacman::p_load(tidyverse, 
               posterior, 
               bayesplot, 
               RColorBrewer, 
               ggthemes, 
               patchwork,
               cmdstanr,
               bayestestR)
color_scheme_set("brightblue")
old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))
theme_set(theme(text = element_text(family = "HiraKakuProN-W3")))
update_geom_defaults("text", list(family = "HiraKakuProN-W3"))

# map推定値 ------------------------------------------------------------------

map_estimation <- function(z) {
    density(z)$x[which.max(density(z)$y)]
}

N <- 100
X <- rnorm(N,0,1)
model <- cmdstan_model("mcmcSample.stan")
dataSet <- list(N=N,X=X)
fit <- model$sample(data=dataSet,chains=4,parallel_chains=4)
fit.df <- fit$output_files() %>% rstan::read_stan_csv() %>% 
    as.data.frame %>% as_tibble 
g1 <- fit.df %>% ggplot(aes(x=mu,y=sigma))+geom_point()
g2 <- fit.df %>% ggplot(aes(x=mu))+geom_density()+xlab("")
g3 <- fit.df %>% ggplot(aes(x=sigma))+geom_density()+coord_flip()+xlab("")

g <- g2 + plot_spacer() + g1 + g3 +plot_layout(ncol = 2, heights = c(.2, .8), widths = c(.8, .2))
ggsave(g, filename = "../images/text28/Rplot28_01.png", dpi = 600, width = 9, height = 9)
g

