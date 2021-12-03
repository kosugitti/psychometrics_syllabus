library(tidyverse)
library(broom)
dat_lm <- iris %>%
  group_by(Species) %>%
  nest() %>%
  mutate(model_lm = map(data, ~ lm(Petal.Length ~ Sepal.Width, data = .))) %>%
  mutate(coeff = map(model_lm, broom::tidy)) %>%
  unnest(coeff) %>%
  select(Species, data, term, estimate) %>%
  pivot_wider(id_cols = c(Species, data), names_from = term, values_from = estimate) %>%
  rename(b0 = 3, b1 = 4)
dat_lm

myModel <- function(x, b0, b1) {
  b0 + b1 * x * x
}

plot.list <- list()
for (g in 1:NROW(dat_lm)) {
  plot.list[[g]] <- dat_lm[g, ] %>%
    unnest(data) %>%
    ggplot(aes(x = Sepal.Width, y = Petal.Length)) +
    geom_point(color = g) +
    stat_function(fun = myModel, args = list(b0 = dat_lm[g, ]$b0, b1 = dat_lm[g, ]$b1), color = g) +
    ggtitle(dat_lm[g, ]$Species)
}

g <- do.call(gridExtra::grid.arrange, plot.list)
plot(g)

ggplot(iris, aes(x = Sepal.Width, y = Petal.Length, group = Species)) +
  geom_point() +
  facet_wrap(~Species) +
  geom_smooth(method = "lm", se = F)


df <- fit.stanfit %>%
  rstan::extract() %>%
  as.data.frame() %>%
  as_tibble()

df %>%
  rowid_to_column("iter") %>%
  pivot_longer(-iter) %>%
  group_by(name) %>%
  summarise(EAP = mean(value))


sample <- data.frame(
  name = c("theta.1.1", "gamma.1.2", "theta.2.1", "lambda.2.2"),
  value = c(0.120, 0.0796, 0.584, 0.264)
)


sample %>%
  mutate(
    variables = str_split_fixed(name, pattern = "\\.", n = 3)[, 1],
    val1 = str_split_fixed(name, pattern = "\\.", n = 3)[, 2],
    val2 = str_split_fixed(name, pattern = "\\.", n = 3)[, 3]
  )


sample %>%
  mutate(variables = str_split(name, pattern = "\\.", n = 3,simplify = T)) -> sample2

sample2 %>% names

set.seed(1235)
theta <- 0.6
lambda <- 3.5
N <- 10
sample <- data.frame(FLG= rbinom(N,size=1, prob = theta) )
sample %>% 
  rowwise() %>% 
  mutate(value = if_else(FLG==0,rpois(1,0),rpois(1,lambda)))


dat <- list(
  A = c(150,120,130),
  B = c(130),
  C = rnorm(10,0,1)
)

dat %>% as.data.frame()


dat %>% as.matrix() %>% t()
