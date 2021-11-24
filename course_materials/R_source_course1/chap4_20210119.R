rm(list = ls())
library(tidyverse)
library(posterior)
library(bayesplot)
library(RColorBrewer) 
library(ggthemes)
library(tidyverse)

A <- c(4, 4, 5, 5, 5, 5, 6, 6)
B <- c(1, 2, 3, 5, 5, 7, 8, 9)
df <- data.frame(A, B)
df %>%
  rowid_to_column("id") %>%
  pivot_longer(-id) %>%
  group_by(name) %>%
  summarise(mean = mean(value), median = median(value))
df %>%
  rowid_to_column("id") %>%
  pivot_longer(-id) %>%
  ggplot(aes(x = value, fill = name)) +
  geom_histogram(binwidth = 0.5) + scale_fill_brewer(palette="Set1") +
  facet_wrap(~name) -> g1

g1

ggsave(g1, filename = "../images/text04/Rplot04_01.png", dpi = 600, width = 8, height = 4)
