rm(list = ls())
library(tidyverse)
library(gridExtra)
dat <- read_csv("baseballDecade.csv", na = "NA")
dat %>% select(height, weight)
dat %>% filter(Year == "2020年度")
# 身長が180cm以上の人だけ取り出す
dat %>% filter(height > 180)
# 体重が100kg以下の人だけ取り出す
dat %>% filter(weight < 100)
# 投手だけ取り出す
dat %>% filter(position == "投手")
# 野手だけ取り出す，野手とは投手でない人のことです
dat %>% filter(position != "投手")
# どちらかの条件を満たす，という場合
dat %>% filter(position == "捕手" | position == "内野手" | position == "外野手")

dat %>%
  select(AtBats, Hit) %>%
  mutate(BattingAverage = Hit / AtBats)

dat.long <- dat %>%
  select(Year, Name, position) %>%
  rownames_to_column("ID") %>%
  print() %>%
  pivot_longer(-ID, names_to = "Variables", values_to = "Value")
dat.long

dat.long %>% 
    pivot_wider(id_cols = ID, names_from = name, values_from = value)


g1 <- ggplot(data = dat, mapping = aes(x = height, y = weight))
g1
g2 <- g1 + geom_point()
g2
g3 <- g2 + geom_smooth(method = "lm")
g3
g4 <- g3 + facet_wrap(~team)
g4
g <- gridExtra::grid.arrange(g1, g2, g3, g4)
ggsave(g, filename = "../images/04_usingR/Rplot05_01.png", dpi = 600, width = 12, height = 8)

library(tidyverse)
dat <- read_csv("BaseballDecade.csv") %>% filter(Year == "2020年度")
dat$team <- as.factor(dat$team)
dat$position <- as.factor(dat$position)
dat$bloodType <- as.factor(dat$bloodType)

g1 <- ggplot(data = dat, mapping = aes(x = height, y = weight, color = team))
g1 + geom_point()
g1 + geom_smooth()
g2 <- ggplot(data = dat, mapping = aes(x = team, y = salary, fill = team))
g2 + geom_boxplot()

g <- dat %>%
  ggplot(aes(x = HR, y = salary, color = position)) +
  geom_point() +
  facet_wrap(~team)
g
ggsave(g, filename = "../images/04_usingR/Rplot05_02.png", dpi = 600, width = 12, height = 8)
