rm(list=ls())
library(tidyverse)
# ある小学校で身体測定をしたところ， 3 人の身長はそれぞれ,155cm,143cm,132cm だったとします。
dat <- c(155,143,132)
# このデータが，\underline{平均170，標準偏差10}の正規分布から独立に得られていたとすると，その時の\textbf{尤度}はどれぐらいになるでしょう。
options(digits=20,scipen=18)
dat %>% dnorm(mean=170,sd=10) %>% prod
dat %>% dnorm(mean=170,sd=10) %>% sum
dat %>% pnorm(mean=170,sd=10) %>% sum
dat %>% pnorm() %>% sum
dat %>% pnorm(mean=170,sd=10) %>% prod

# このデータが，\underline{平均140，標準偏差10}の正規分布から独立に得られていたとすると，その時の\textbf{対数尤度}はどれぐらいになるでしょう。
dat %>% dnorm(mean=140,sd=10) %>% log %>% sum
dat %>% dnorm(mean=140,sd=10) %>% log %>% prod
dat %>% dnorm() %>% log %>% sum
dat %>% pnorm(mean=140,sd=10) %>% log %>% sum
dat %>% pnorm(mean=140,sd=10) %>% log %>% prod
dat %>% pnorm() %>% log %>% sum
# このデータが，\underline{平均140，標準偏差10}の正規分布から得られていたと考えるモデル＼と，\underline{平均140，標準偏差8}の正規分布から得られていたと考えるモデルがあったとします。データはどちらをより支持しますか。
dat %>% dnorm(mean=140,sd=10) %>% log %>% sum -> model1
dat %>% dnorm(mean=140,sd=8) %>% log %>% sum -> model2
model1 > model2
# このデータが正規分布から得られると考えて，そのときの平均値の最尤推定値を求めましょう。
mean(dat)
dat %>% sd
t.test(dat)
