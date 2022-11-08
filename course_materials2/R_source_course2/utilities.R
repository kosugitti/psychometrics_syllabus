rm(list = ls())
library(pacman)
pacman::p_load(
  tidyverse,
  posterior,
  bayesplot,
  RColorBrewer,
  ggthemes,
  patchwork,
  cmdstanr,
  bayestestR
)
color_scheme_set("brightblue")
old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))
theme_set(theme(text = element_text(family = "HiraKakuProN-W3")))
update_geom_defaults("text", list(family = "HiraKakuProN-W3"))
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# map推定値 ------------------------------------------------------------------

map_estimation <- function(z) {
  density(z)$x[which.max(density(z)$y)]
}


# MCMCの出力を一通り計算する ---------------------------------------------------------

MCMC_result <- function(x) {
  Rhats <- summary(x)$summary[, "Rhat"] %>%
    as.data.frame() %>%
    rownames_to_column() %>%
    rename(Varname = 1, Rhat = 2)
  RhatCheck <- all(Rhats$Rhat < 1.10, na.rm = T)
  if (!RhatCheck) {
    stop("Rhatが1.10を超えているものがあります。")
  } else {
    print("all Rhats are <1.1, Fine!")
  }
  ret <- x %>%
    as.data.frame() %>%
    as_tibble() %>%
    rowid_to_column("iter") %>%
    pivot_longer(-iter, names_to = "Varname") %>%
    group_by(Varname) %>%
    summarise(
      EAP = mean(value),
      MED = median(value),
      MAP = map_estimation(value),
      SD = sd(value),
      L95 = quantile(value, probs = 0.025),
      L50 = quantile(value, probs = 0.25),
      U50 = quantile(value, probs = 0.75),
      U95 = quantile(value, probs = 0.975)
    ) %>%
    right_join(Rhats, by = "Varname")
  return(ret)
}
