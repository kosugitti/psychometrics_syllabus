rm(list = ls())
library(tidyverse)
library(rstatix)
library(broom)
library(ltm)
load("IRTsample.Rdata")
test <- df %>% dplyr::select(-GID, -ID)
result.irt <- ltm(test ~ z1, IRT.param = TRUE)

set.seed(20210316)

twoParameters <- function(x, a, b) {
  1 / (1 + exp(-1.7 * a * (x - b)))
}


ITEMS <- c("I0022", "M0605", "I0017", "I0013", "I0041")

irtSample <- summary(result.irt)$coefficients %>%
  as.data.frame() %>%
  rownames_to_column("var") %>%
  mutate(
    type = str_split(var, pattern = "\\.", simplify = T)[, 1],
    Qid = str_split(var, pattern = "\\.", simplify = T)[, 2]
  ) %>%
  dplyr::select(Qid, type, value) %>%
  pivot_wider(id_cols = Qid, names_from = type, values_from = value) %>%
  filter(Qid %in% ITEMS)

p <- ggplot(data.frame(X = c(-4, 4)), aes(x = X)) +
  xlab("theta") +
  ylab("pass ratio") +
  mapply(
    function(a, b, co) stat_function(fun = twoParameters, args = list(a = a, b = b), aes_q(color = co)),
    irtSample$Dscrmn, irtSample$Dffclt, irtSample$Qid
  ) +
  labs(color = "items")
p
ggsave(p, filename = "../images/chapter04/Rplot04_05.png", dpi = 600, width = 12, height = 6)

irtSample %>% xtable::xtable()

twoParameters(0, irtSample[1, ]$Dscrmn, irtSample[1, ]$Dffclt) * 100
twoParameters(2, irtSample[1, ]$Dscrmn, irtSample[1, ]$Dffclt) * 100
twoParameters(-2, irtSample[1, ]$Dscrmn, irtSample[1, ]$Dffclt) * 100
twoParameters(0, irtSample[2, ]$Dscrmn, irtSample[2, ]$Dffclt) * 100
twoParameters(2, irtSample[2, ]$Dscrmn, irtSample[2, ]$Dffclt) * 100
twoParameters(-2, irtSample[2, ]$Dscrmn, irtSample[2, ]$Dffclt) * 100
twoParameters(0, irtSample[3, ]$Dscrmn, irtSample[3, ]$Dffclt) * 100
twoParameters(2, irtSample[3, ]$Dscrmn, irtSample[3, ]$Dffclt) * 100
twoParameters(-2, irtSample[3, ]$Dscrmn, irtSample[3, ]$Dffclt) * 100

### 被験者母数を決める

p <- ggplot(data.frame(X = c(-4, 4)), aes(x = X)) +
  xlab("theta") +
  ylab("pass ratio") +
  stat_function(fun = twoParameters, args = list(a = irtSample[1, ]$Dscrmn, b = irtSample[1, ]$Dffclt))
p
p <- p + geom_ribbon(data = data.frame(X = x <- seq(-4, 4, len = 101), Y = twoParameters(x, a = irtSample[1, ]$Dscrmn, b = irtSample[1, ]$Dffclt)), aes(ymin = 0, ymax = Y), alpha = 0.2)
p
ggsave(p, filename = "../images/chapter04/Rplot04_06.png", dpi = 600, width = 12, height = 6)


p <- p + stat_function(fun = twoParameters, args = list(a = irtSample[2, ]$Dscrmn, b = irtSample[2, ]$Dffclt)) +
  geom_ribbon(
    data = data.frame(
      X = x <- seq(-4, 4, len = 101),
      Y = twoParameters(x, a = irtSample[1, ]$Dscrmn, b = irtSample[1, ]$Dffclt),
      Y2 = twoParameters(x, a = irtSample[2, ]$Dscrmn, b = irtSample[2, ]$Dffclt)
    ),
    aes(ymin = Y2, ymax = Y),
    alpha = 0.2
  )
p1 <- p + geom_segment(
  x = 0, xend = 0,
  y = twoParameters(0, a = irtSample[1, ]$Dscrmn, b = irtSample[1, ]$Dffclt),
  yend = twoParameters(0, a = irtSample[2, ]$Dscrmn, b = irtSample[2, ]$Dffclt), arrow = arrow(ends = "both"), color = "white"
)
p1
ggsave(p1, filename = "../images/chapter04/Rplot04_07.png", dpi = 600, width = 12, height = 6)

p <- p + stat_function(fun = twoParameters, args = list(a = irtSample[5, ]$Dscrmn, b = irtSample[5, ]$Dffclt)) +
  geom_ribbon(
    data = data.frame(
      X = x <- seq(-4, 4, len = 101),
      Y = twoParameters(x, a = irtSample[5, ]$Dscrmn, b = irtSample[5, ]$Dffclt),
      Y2 = twoParameters(x, a = irtSample[2, ]$Dscrmn, b = irtSample[2, ]$Dffclt)
    ),
    aes(ymin = Y2, ymax = Y),
    alpha = 0.2
  )
p2 <- p + geom_segment(
  x = 0, xend = 0,
  y = twoParameters(0, a = irtSample[5, ]$Dscrmn, b = irtSample[5, ]$Dffclt),
  yend = twoParameters(0, a = irtSample[2, ]$Dscrmn, b = irtSample[2, ]$Dffclt), arrow = arrow(ends = "both"), color = "white"
)
p2
ggsave(p2, filename = "../images/chapter04/Rplot04_08.png", dpi = 600, width = 12, height = 6)
