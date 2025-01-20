rm(list = ls())
library(tidyverse)
library(ggrepel)
miniEurodist <- eurodist %>% as.matrix()
miniEurodist[, 1:6] %>%
  head() %>%
  knitr::kable(format = "latex")

eurodist %>%
  cmdscale(k = 3) %>%
  as.data.frame() %>%
  rename(dim1 = V1, dim2 = V2) %>%
  rownames_to_column("city") %>%
  ggplot(aes(x = dim1, y = -dim2, label = city)) +
  geom_point() +
  geom_text_repel() -> g
g
ggsave(g, filename = "../images/chapter15/Rplot15_01.png", dpi = 600, width = 8, height = 8)
