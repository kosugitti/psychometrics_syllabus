library(tidyverse)
library(gridExtra)
dat <- read_csv("sample.csv",na = "NA")
dat
old <- theme_set(theme_gray(base_family = "HiraKakuProN-W3"))

g1 <- ggplot(data = dat,
            mapping = aes(x = 身長, y = 体重))
g1

g2 <- g1 + geom_point()

g3 <- g2 + geom_smooth(method="lm")

g4 <- g3 + facet_wrap(~地域)

g <- gridExtra::grid.arrange(g1,g2,g3,g4)
ggsave(g,filename = "../images/text05/Rplot05_01.png", dpi = 600, width = 12, height = 8)

dat <- read_csv("baseball2020.csv")
dat$team <- as.factor(dat$team)
dat$position <- as.factor(dat$position)
dat$bloodType <- as.factor(dat$bloodType)
g <- dat %>% ggplot(aes(x=HR,y=salary,color=position))+geom_point()+facet_wrap(~team) 
g
ggsave(g,filename = "../images/text05/Rplot05_02.png", dpi = 600, width = 12, height = 8)

