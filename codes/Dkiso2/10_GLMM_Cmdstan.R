rm(list = ls())
library(cmdstanr)
library(posterior)
library(bayesplot)
color_scheme_set("brightblue")


# データの読み込み ----------------------------------------------------------------

baseball <- read_csv("baseballDecade.csv")

dat <- baseball %>%
    filter(position == "投手") %>%
    filter(salary > 5000) %>%
    group_by(Name) %>% print %>% 
    nest() %>% print %>% 
    mutate(
        n = purrr::map_dbl(data, ~ NROW(.)),
        FLG = purrr::map_lgl(data, ~ anyNA(.$Win))
    ) %>% print %>% 
    filter(n == 10) %>% print %>% 
    filter(!FLG) %>% print %>% 
    unnest(data) %>%
    select(Year, Name, salary, Win)

# GLMM --------------------------------------------------------------------
### ポアソン分布で個体差を入れて
model_pois <- cmdstanr::cmdstan_model("glm_poisson.stan")
### データの加工
dat.tmp <- dat %>%
    dplyr::filter(Year == "2020年度") %>%
    mutate(salary = salary / 1000) %>%
    mutate(ID = as.factor(Name)) %>%
    mutate(ID = as.numeric(ID))

dataSet <- list(
    L = NROW(dat.tmp),
    X = dat.tmp$salary,
    Y = dat.tmp$Win,
    idIndex = dat.tmp$ID
)
### コンパイルと推定
model_pois <- cmdstanr::cmdstan_model("glm_poisson.stan")
fit <- model_pois$sample(
    data = dataSet,
    chains = 4,
    parallel_chains = 4,
    iter_warmup = 1000,
    iter_sampling = 3000
)

### 結果の出力
fit.stanfit <- fit$output_files() %>% rstan::read_stan_csv()
fit.MCMC <- fit.stanfit %>%
    as.data.frame() %>%
    as_tibble() %>%
    dplyr::select(beta0, beta1, "mu[1]", "mu[2]", "mu[3]", "mu[4]", "mu[5]") %>%
    rowid_to_column("iter") %>%
    pivot_longer(-iter) %>%
    group_by(name) %>%
    summarise(
        EAP = mean(value),
        MED = median(value),
        MAP = map_estimation(value),
        sd = sd(value)
    )


# 課題1，打率のデータ整形 ------------------------------------------------------------

dat <- baseball %>%
    dplyr::filter(position != "投手") %>%
    dplyr::filter(Year == "2020年度") %>%
    filter(salary > 5000) %>%
    select(Year, Name, salary, AtBats, Hit, Games, HR)

model_binom <- cmdstanr::cmdstan_model("glm_binomial.stan")
dat.tmp <- dat %>%
    mutate(salary = salary / 1000) %>%
    mutate(ID = as.factor(Name)) %>%
    mutate(ID = as.numeric(ID))

dataSet <- list(
    L = NROW(dat.tmp), X = dat.tmp$salary,
    Y = dat.tmp$HR, N = dat.tmp$Hit
)

fit <- model_binom$sample(
    data = dataSet,
    chains = 4,
    parallel_chains = 4,
)

# 課題2，階層線形モデル -------------------------------------------------------------
dat.tmp <- pitcher%>%
    mutate(
        NameID = as.factor(Name),
        teamID = as.factor(team)
    ) %>%
    mutate(
        NameID = as.numeric(NameID),
        teamID = as.numeric(teamID)
    )
dataSet <- list(
    L = NROW(dat.tmp),
    G = max(dat.tmp$teamID),
    Gindex = dat.tmp$teamID,
    X = dat.tmp$salary,
    Y = dat.tmp$Win
)

modelH <- cmdstan_model("glmm_poisson.stan")
fit_glmm <- modelH$sample(
    data = dataSet,
    chains = 4,
    parallel_chains = 4,
    iter_sampling = 5000,
    iter_warmup = 1000
)

fit_glmm
