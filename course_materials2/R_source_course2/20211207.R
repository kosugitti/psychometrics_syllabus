rm(list = ls())
source("utilities.R")
dat <- read_csv("weight.csv")
g <- dat %>%
  filter(date > "2020/01/01") %>%
  ggplot(aes(x = date, y = weight)) +
  geom_point()
ggsave(g, filename = "../images/chapter29/Rplot29_01.png", dpi = 600, width = 8, height = 4)


# 状態空間モデル -----------------------------------------------------------------

dat1 <- dat %>%
  filter(date > "2020/01/01") %>%
  mutate(date = as.Date(date))

model <- cmdstan_model("StateSpace.stan")
dataSet <- list(L = NROW(dat1), W = dat1$weight)
fit1 <- model$sample(
  data = dataSet,
  chains = 4,
  parallel_chains = 4
)

fit1.df <- fit1$output_files() %>%
  rstan::read_stan_csv() %>%
  MCMC_result()

Est1 <- fit1.df %>%
  dplyr::filter(str_detect(Varname, "mu")) %>%
  dplyr::mutate(ID = str_extract(Varname, pattern = "\\d+") %>% as.numeric()) %>%
  arrange(ID)

g <- dat1 %>%
  rowid_to_column("ID") %>%
  left_join(Est1, by = "ID") %>%
  ggplot(aes(x = ID, y = weight, ymin = U95, ymax = L95)) +
  geom_point() +
  geom_point(aes(x = ID, y = MAP), color = palette()[2]) +
  geom_ribbon(fill = palette()[3], alpha = 0.2)
ggsave(g, filename = "../images/chapter29/Rplot29_02.png", dpi = 600, width = 8, height = 4)

# 日付は連続か？ -----------------------------------------------------------------

dat1 %>%
  mutate(lag = lag(date)) %>%
  mutate(date = as.Date(date), lag = as.Date(lag)) %>%
  mutate(FLG = date - lag) %>%
  dplyr::filter(FLG > 1)

fullDays <- data.frame(date = as.Date("2020/01/01"):as.Date("2021/12/01")) %>%
  mutate(date = as.Date(date, origin = "1970-01-01")) %>%
  left_join(dat1, by = "date") %>%
  tidyr::replace_na(list(weight = 999))

model2 <- cmdstan_model("StateSpace2.stan")
dataSet <- list(L = NROW(fullDays), W = fullDays$weight, Nmiss = sum(fullDays$weight == 999))
fit2 <- model2$sample(
  data = dataSet,
  chains = 4, parallel_chains = 4
)

fit2.df <- fit2$output_files() %>%
  rstan::read_stan_csv() %>%
  MCMC_result()
Est2 <- fit2.df %>%
  dplyr::filter(str_detect(Varname, "mu")) %>%
  dplyr::filter(!str_detect(Varname, "muZero")) %>%
  dplyr::mutate(ID = str_extract(Varname, pattern = "\\d+") %>% as.numeric()) %>%
  arrange(ID) %>%
  select(ID, MAP, U95, L95)
Est2miss <- fit2.df %>%
  dplyr::filter(str_detect(Varname, "Miss_W")) %>%
  dplyr::mutate(ID = str_extract(Varname, pattern = "\\d+") %>% as.numeric()) %>%
  arrange(ID) %>%
  select(ID, MAP, U95, L95)

### plot用の関数を準備
plotFunction <- function(fullDays,Est,MissEst){
  tmp <- fullDays %>% rowid_to_column("ID") %>% 
    left_join(Est2,by="ID") %>% 
    rowwise() %>% 
    mutate(FLG = if(weight!=999){1}else{2})
  misJ <- 1
  tmp$weight2 <- NA
  tmp$weight2U <- NA
  tmp$weight2L <- NA
  for(i in 1:NROW(tmp)){
    if(tmp$FLG[i]==2){
      tmp$weight2[i] <- MissEst$MAP[misJ]
      tmp$weight2U[i] <- MissEst$U95[misJ]
      tmp$weight2L[i] <- MissEst$L95[misJ]
      misJ <- misJ +1}else{
        tmp$weight2[i] <- tmp$weight[i]
        tmp$weight2U[i] <- tmp$weight[i]
        tmp$weight2L[i] <- tmp$weight[i]
      }
  }
  return(tmp)
}

plot.tmp <- plotFunction(fullDays,Est2,Est2miss)

g <- ggplot(data = plot.tmp) +
  geom_point(aes(x = date, y = weight2)) +
  geom_errorbar(aes(x = date, y = weight2, ymin = weight2L, ymax = weight2U, color = palette()[2]))+
  geom_point(aes(x = date, y = MAP,color=palette()[3])) +
  geom_errorbar(aes(x = date, y = MAP, ymin = L95, ymax = U95,color=palette()[4])) +
  scale_x_date(date_breaks = "1 month", limits = as.Date(c("2020-01-01", "2020-05-01"))) + 
  theme(legend.position = "none")
ggsave(g, filename = "../images/chapter29/Rplot29_03.png", dpi = 600, width = 8, height = 4)

# 未来も欠損じゃない？ --------------------------------------------------------------

dat1 %>%
  mutate(lag = lag(date)) %>%
  mutate(date = as.Date(date), lag = as.Date(lag)) %>%
  mutate(FLG = date - lag) %>%
  dplyr::filter(FLG > 1)

fullDays <- data.frame(date = as.Date("2020/01/01"):as.Date("2021/12/31")) %>%
  mutate(date = as.Date(date, origin = "1970-01-01")) %>%
  left_join(dat1, by = "date") %>%
  tidyr::replace_na(list(weight = 999))

dataSet <- list(L = NROW(fullDays), W = fullDays$weight, Nmiss = sum(fullDays$weight == 999))
fit3 <- model2$sample(
  data = dataSet,
  chains = 4, parallel_chains = 4
)


fit3.df <- fit3$output_files() %>%
  rstan::read_stan_csv() %>%
  MCMC_result()
Est3 <- fit3.df %>%
  dplyr::filter(str_detect(Varname, "mu")) %>%
  dplyr::filter(!str_detect(Varname, "muZero")) %>%
  dplyr::mutate(ID = str_extract(Varname, pattern = "\\d+") %>% as.numeric()) %>%
  arrange(ID) %>%
  select(ID, MAP, U95, L95)
Est3miss <- fit3.df %>%
  dplyr::filter(str_detect(Varname, "Miss_W")) %>%
  dplyr::mutate(ID = str_extract(Varname, pattern = "\\d+") %>% as.numeric()) %>%
  arrange(ID) %>%
  select(ID, MAP, U95, L95)


plot.tmp <- plotFunction(fullDays,Est3,Est3miss)

g <- ggplot(data = plot.tmp) +
  geom_point(aes(x = date, y = weight2)) +
  geom_errorbar(aes(x = date, y = weight2, ymin = weight2L, ymax = weight2U, color = palette()[2]))+
  geom_point(aes(x = date, y = MAP,color=palette()[3])) +
  geom_errorbar(aes(x = date, y = MAP, ymin = L95, ymax = U95,color=palette()[4])) +
  scale_x_date(date_breaks = "1 month", limits = as.Date(c("2021-05-01", "2021-12-31"))) + 
  theme(legend.position = "none")

ggsave(g, filename = "../images/chapter29/Rplot29_04.png", dpi = 600, width = 8, height = 4)

# 二階差分 --------------------------------------------------------------------


model3 <- cmdstan_model("StateSpace3.stan")
fit4 <- model3$sample(
  data = dataSet,
  chains = 4, parallel_chains = 4,
  iter_sampling = 5000
)


fit4.df <- fit4$output_files() %>%
  rstan::read_stan_csv() %>%
  MCMC_result()

Est4 <- fit4.df %>%
  dplyr::filter(str_detect(Varname, "mu")) %>%
  dplyr::filter(!str_detect(Varname, "muZero")) %>%
  dplyr::mutate(ID = str_extract(Varname, pattern = "\\d+") %>% as.numeric()) %>%
  arrange(ID) %>%
  select(ID, MAP, U95, L95)
Est4miss <- fit4.df %>%
  dplyr::filter(str_detect(Varname, "Miss_W")) %>%
  dplyr::mutate(ID = str_extract(Varname, pattern = "\\d+") %>% as.numeric()) %>%
  arrange(ID) %>%
  select(ID, MAP, U95, L95)


plot.tmp <- plotFunction(fullDays,Est4,Est4miss)

g <- ggplot(data = plot.tmp) +
  geom_point(aes(x = date, y = weight2)) +
  geom_errorbar(aes(x = date, y = weight2, ymin = weight2L, ymax = weight2U, color = palette()[2]))+
  geom_point(aes(x = date, y = MAP,color=palette()[3])) +
  geom_errorbar(aes(x = date, y = MAP, ymin = L95, ymax = U95,color=palette()[4])) +
  scale_x_date(date_breaks = "1 month", limits = as.Date(c("2021-05-01", "2021-12-31"))) + 
  theme(legend.position = "none")

ggsave(g, filename = "../images/chapter29/Rplot29_05.png", dpi = 600, width = 8, height = 4)
