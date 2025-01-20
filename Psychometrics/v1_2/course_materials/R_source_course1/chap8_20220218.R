library(tidyverse)
library(datasauRus)
datasauRus::box_plots %>% 
    GGally::ggpairs()
datasauRus::datasaurus_dozen %>% 
    ggplot(aes(x=x,y=y,color=dataset))+geom_point()+facet_wrap(~dataset)

datasauRus::datasaurus_dozen %>% 
    dplyr::filter(dataset == "dino"|dataset=="circle"|dataset=="star") %>% 
    group_by(dataset) %>% 
    summarise(Mean.X = mean(x),
              Mean.Y = mean(y),
              SD.x = sd(x),
              SD.y = sd(y),
              Min.x = min(x),
              Min.y = min(y),
              Max.x = max(x),
              Max.y = max(y),
              Corr = cor(x,y)) %>% 
    knitr::kable(format="latex",digits = 3)

g <- datasauRus::datasaurus_dozen %>% 
    dplyr::filter(dataset == "dino"|dataset=="circle"|dataset=="star") %>% 
    ggplot(aes(x=x,y=y,color=dataset))+geom_point()+facet_wrap(~dataset)+
    theme(legend.position = "none")
g
ggsave(g, filename = "../images/08_CorrelationCausation/Rplot08_01.png", dpi = 600, width = 12, height = 4)
