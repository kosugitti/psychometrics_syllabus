rm(list = ls())
library(tidyverse)
library(lavaan)
HolzingerSwineford1939 %>%
  as_tibble() %>%
  print() %>%
  mutate_if(is.double, .funs = function(x) round(x, 2)) %>%
  head() %>%
  knitr::kable(
    format = "latex", label = "tbl::13_01",
    caption = "Holzinger and Swineford(1939)のデータ"
  )

example(cfa)
## 観測変数だけのモデル
model1 <- "
x4 ~ x5 + x6
"
result1 <- sem(model1, data = HolzingerSwineford1939)
summary(result1, fit.measures = T)
# 比較
result1.1 <- lm(x4 ~ x5 + x6, data = HolzingerSwineford1939)
summary(result1.1)

fitmeasures(result1)
summary(result1, fit.measures = T)

result1.2 <- lm(x1 ~ x2 + x3, data = HolzingerSwineford1939)
summary(result1.2)

## Path Analysis
model2 <- "
x4 ~ x5
x5 ~ x6
x6 ~ grade
"
result2 <- sem(model2, data = HolzingerSwineford1939)
summary(result2, fit.measures = T, standardized = T)

library(semPlot)
semPaths(result2, what = "est")
library(tidySEM)
png("../images/chapter13/Rplot13_01.png", width = 1000, height = 200)
graph_sem(model = result2)
dev.off()

### FA
model3 <- "
 visual =~ x1 + x2 + x3
textual =~ x4 + x5 + x6
  speed =~ x7 + x8 + x9
"
result3 <- sem(model3, data = HolzingerSwineford1939)
summary(result3, fit.measures = T, standardized = T)
semPaths(result3, what = "est")

## CFAなら
source("utilty_sem.R")
write(lav2tikz(result3, size = "scriptsize"), file = "chapter13fig02.tex")
my_lavaan_plot(result3)

### SEM
model4 <- "
 visual =~ x1 + x2 + x3
textual =~ x4 + x5 + x6
  speed =~ x7 + x8 + x9
 textual ~ visual + speed
  speed ~ grade
"
result4 <- sem(model4, data = HolzingerSwineford1939)
summary(result4, fit.measures = T, standardized = T)
modificationindices(result4) %>%
  as_tibble() %>%
  arrange(-mi)

# 実際の図はlav2tikz関数を元に，自力で加筆
# write(lav2tikz(result4, size = "scriptsize"), file = "chapter13fig03.tex")
my_lavaan_plot(result4)

### SEM
model4.2 <- "
 visual =~ x1 + x2 + x3 + x9
textual =~ x4 + x5 + x6
  speed =~ x7 + x8 + x9
 textual ~ visual + speed
  speed ~ grade
"
result4.2 <- sem(model4.2, data = HolzingerSwineford1939)
fit2 <- fitmeasures(result4.2) %>% transform
fitmeasures(result4) %>% transform %>% 
    bind_cols(fit2) %>% 
    rename(before=1,after=2) %>% 
    mutate_all(.fun=function(x) round(x,3)) %>% 
    rownames_to_column("index") %>% 
    filter(index %in% c("cfi","tli","gfi","agfi","aic","bic","rmsea","srma")) %>% 
    mutate(index = stringr::str_to_upper(index)) %>% 
    knitr::kable(format='latex',caption="修正前後での指標の変化",label="tbl::13_02")

