rm(list = ls())
library(tidyverse)
old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))
dat <- read_csv("baseball2020.csv", na = "NA", locale = locale(encoding = "utf8"))
summary(dat)

batter <- dat %>%
  dplyr::filter(position != "投手") %>%
  dplyr::select(height, weight)
g <- ggplot(batter, aes(x = height, y = weight)) +
  geom_point()
ggsave(g, filename = "../images/text11/Rplot11_01.png", dpi = 600, width = 6, height = 6)
g
g <- g + geom_smooth(method = "lm", se = FALSE)
g

result <- lm(weight ~ height, data = batter)
summary(result)

str(result)

batter <- batter %>%
  dplyr::mutate(
    residuals = result$residuals,
    yhat = result$fitted.values
  ) %>%
  print()
summary(batter)
plot(batter)
cor(batter)

batter2 <- dat %>%
  dplyr::filter(position != "投手") %>%
  dplyr::select(HR, Hit, salary) %>%
  na.omit()
g1 <- ggplot(batter2, aes(x = HR, y = salary)) +
  geom_point()
g1
g2 <- ggplot(batter2, aes(x = Hit, y = salary)) +
  geom_point()
g2
cor(batter2)

g <- gridExtra::grid.arrange(g1, g2)
ggsave(g, filename = "../images/text11/Rplot11_02.png", dpi = 600, width = 8, height = 6)

result2 <- lm(salary ~ HR + Hit, data = batter2)
summary(result2)

batter2z <- scale(batter2) %>% as.data.frame()
summary(batter2z)
result2z <- lm(salary ~ HR + Hit, data = batter2z)
summary(result2z)




