# データを入力
koukou <- c(2.13, 2.42, 2.26, 3.87, 3.90, 2.43, 3.44, 2.15, 2.18, 3.00, 3.42, 2.55, 3.19, 3.05, 2.52)
daigaku <- c(460, 500, 473, 620, 690, 512, 582, 550, 485, 650, 593, 528, 585, 569, 518)
# データフレーム型に組み上げる
seiseki <- data.frame(koukou, daigaku)

# データは図にする
ggplot(seiseki, aes(x = koukou, y = daigaku)) +
  geom_point() +
  geom_smooth(method = "lm", se = F)

# 線形モデルはlm関数。従属変数~説明変数の形で書く
fit <- lm(daigaku ~ koukou, data = seiseki)
# 結果をわかりやすく表示
summary(fit)

library(brms)
fit.brm <- brm(daigaku ~ koukou, data = seiseki)
fit.brm
plot(fit.brm)
ggsave(plot(fit.brm), filename = "Rplot27_01.png", dpi = 600, width = 8, height = 4)

library(tidybayes)
fit.brm$fit %>%
  rstan::extract() %>%
  as_tibble() %>%
  print()
tidyr::gather(key, val) %>%
  dplyr::group_by(key) %>%
  dplyr::summarize(EAP = mean(val), MED = median(val))

install.packages(bayestestR)
library(bayestestR)
map_estimate(fit.brm)


hdi(fit.brm, ci = 0.95)

fit.brm$fit %>%
  rstan::extract() %>%
  as.data.frame()


# 二要因 ---------------------------------------------------------------------


Example2 <- data.frame(
  id = 1:12,
  num = rep(1:3, 4),
  temp = rep(1:2, each = 6),
  maker = rep(rep(1:2, each = 3), 2),
  value = c(13, 11, 12, 7, 6, 8, 9, 9, 9, 13, 11, 9)
)
Example2$temp <- factor(Example2$temp,
  labels = c("Hot", "Cold")
)
Example2$maker <- factor(Example2$maker,
  label = c("A", "B")
)

result.brm2 <- brm(value ~ temp * maker, data = Example2)
result.brm2
plot(result.brm2)


conditional_effects(result.brm2, effects = "temp")
conditional_effects(result.brm2, effects = "maker")
conditional_effects(result.brm2, effects = "temp:maker")


lm(value ~ temp * maker, data = Example2) %>% summary()

#  within -----------------------------------------------------------------


Example3 <- data.frame(
  ID = rep(1:4,3),
  time = rep(1:3,each=4),
  value = c(10, 9, 4, 7,5, 4, 2, 3,9, 5, 3, 5)
)
Example3$time <- factor(Example3$time,labels = c("time1","time2","time3"))

result.brm3 <- brm(value ~ time + (1 | ID), data = Example3)
result.brm3
conditional_effects(result.brm3)
