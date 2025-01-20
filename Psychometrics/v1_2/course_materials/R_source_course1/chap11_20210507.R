rm(list = ls())
library(tidyverse)
old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))
dat <- read_csv("baseballDecade.csv", na = "NA", locale = locale(encoding = "utf8")) %>% 
    filter(Year=="2020年度")
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



dat %>% 
    dplyr::filter(position=="投手") %>% 
    dplyr::select(Win,Lose,Save,Hold,salary) %>% 
    na.omit %>% 
    cor()

# 課題 ----------------------------------------------------------------------

# Homesしらべ　向丘駅近辺のワンルーム家賃相場
library(tidyverse)
heibei = c(41.4,20.28,18.2,19.87,20.28,23.18,19.87,19.87)
chiku = c(14,16,28,16,19,20,17,20)
ekitoho = c(10,9,10,13,7,14,12,17)
yachin = c(8.6,6.1,4.2,5.7,6.3,5.4,6.25,5.8)

dat.df <- data.frame(heibei,chiku,ekitoho,yachin) 
dat.df %>% knitr::kable(format='latex',caption='家賃相場')
write_csv(dat.df, file="yachin.csv")
read_csv("yachin.csv")

psych::pairs.panels(dat.df)

mean(dat.df$heibei)
mean(dat.df$yachin)
sdx = (dat.df$heibei - mean(dat.df$heibei))^2 %>% mean %>% sqrt
sdy = (dat.df$yachin - mean(dat.df$yachin))^2 %>% mean %>% sqrt
sdXY = mean((dat.df$heibei - mean(dat.df$heibei))*(dat.df$yachin - mean(dat.df$yachin)))
Rxy = sdXY / sdx / sdy
b1 = Rxy * sdy / sdx
b0 = mean(dat.df$yachin) - b1*mean(dat.df$heibei)

summary(lm(yachin~heibei,dat=dat.df))
summary(lm(heibei~yachin,dat=dat.df))
b1 * 15 + b0


