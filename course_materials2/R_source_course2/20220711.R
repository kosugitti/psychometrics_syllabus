rm(list = ls())
library(lavaan)
library(tidyverse)
HolzingerSwineford1939

model1 <- "
x4 ~ x5 + x6
"
result <- sem(model1, data = HolzingerSwineford1939)
summary(result, fit.measures = TRUE)
lm(x4 ~ x5 + x6, data = HolzingerSwineford1939)

model2 <- "
x4 ~ x5
x5 ~ x6
x6 ~ grade
"
result2 <- sem(model2, data = HolzingerSwineford1939)
summary(result2, fit.measures = TRUE)
library(semPlot)
semPaths(result2, what = "est")
library(tidySEM)
graph_sem(model = result2)


# 測定方程式を入れたモデル ------------------------------------------------------------

model3 <- "
visal =~ x1 + x2 + x3
texual =~ x4 + x5 + x6
speed =~ x7 + x8 + x9
"
result3 <- sem(model3, data = HolzingerSwineford1939)
summary(result3, fit.measures = T, standardized = T)
semPaths(result3, what = "est")

# SEM ---------------------------------------------------------------------

model4 <- "
visual =~ x1 + x2 + x3 + x4 + x9
textual =~ x4 + x5 + x6
speed =~ x7 + x8 + x9
textual ~ visual
speed ~ grade
"

result4 <- sem(model4, data = HolzingerSwineford1939)
summary(result4, fit.measures = T, standardized = T)

modificationindices(result4)
