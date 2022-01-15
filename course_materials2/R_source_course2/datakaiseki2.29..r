rm(list = ls())
library(cmdstanr)
library(posterior)
library(bayesplot)
color_scheme_set("brightblue")
library(dplyr)
library(tidyverse)
library(caret)
library(bayesplot)
library(rstan)

dat <- read_csv("weight.csv")

#体脂肪率30％以上を除外
dat <- read_csv("weight.csv") %>%
  mutate(bodyFat = ifelse(bodyFat > 30, NA, bodyFat))

#体脂肪率を小数に戻す
dat1 <- dat %>% mutate(bodyFat = bodyFat / 100)

#筋肉量（muscle）の算出と列の追加
a <-matrix(c(dat1$weight))
b <-matrix(c(dat1$bodyFat))
kinnniku <-a*b
muscle<- data.frame(kinnniku)
names(muscle) <- c("muscle")

dat2 <- cbind(dat1,muscle)

dat3<-dat2 %>%
  mutate(lag = lag(date)) %>%
  mutate(date = as.Date(date), lag = as.Date(lag)) %>%
  mutate(FLG = date - lag)

#欠損値の追加
dat4 <- data.frame(date= as.Date("2012/06/08"):as.Date("2021/12/06")) %>%
  mutate(date = as.Date(date, origin = "1970-01-01")) %>%
  left_join(dat3, by="date")%>%
  tidyr::replace_na(list(weight = 999, bodyFat = 999,muscle = 999))

#推定
model<- cmdstanr::cmdstan_model("datakaiseki2.29.stan")
dataSet <- list(L = NROW(dat4), W = dat4$muscle, Nmiss = sum(dat4$muscle == 999))
fit <- model$sample(
  data = dataSet,
  chains = 4, parallel_chains = 4,
  iter_sampling = 5000
)
fit

fit$summary(c("muZero", "sig", "tau"))


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
  

fit2<- fit$output_files() %>%
  rstan::read_stan_csv()%>%
  MCMC_result()


Est4 <- fit2 %>%
  dplyr::filter(str_detect(Varname, "mu")) %>%
  dplyr::filter(!str_detect(Varname, "muZero")) %>%
  dplyr::mutate(ID = str_extract(Varname, pattern = "\\d+") %>% as.numeric()) %>%
  arrange(ID) %>%
  select(ID, MAP, U95, L95)

