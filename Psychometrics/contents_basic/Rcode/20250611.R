rm(list=ls())
library(tidyverse)
dat <- read_csv("baseballDecade.csv", na="NA", 
                locale=locale(encoding="utf8")) %>% 
  filter(Year=="2020年度")

batter <- dat %>%
  dplyr::filter(position != "投手") %>%
  dplyr::select(height, weight)
g <- ggplot(batter, aes(x = height, y = weight))
g <-  g + geom_point()
g

g <- g + geom_smooth(method = "lm", se = FALSE)
g


result <- lm(weight ~ height, data= batter)
summary(result)
plot(result)

result$residuals
result$fitted.values

batter$residuals <- result$residuals
batter$yhat <- result$fitted.values
batter
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

;obra