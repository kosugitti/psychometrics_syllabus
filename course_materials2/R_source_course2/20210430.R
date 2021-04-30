rm(list = ls())
library(tidyverse)

A <- 1:9
B <- c(3, 4, 5)
C <- matrix(A, ncol = 3)
D <- matrix(A, ncol = 3, byrow = T)

A
B
C
D

E <- matrix(A, ncol = 3, nrow = 6)
G <- matrix(A, ncol = 3, nrow = 4)
E
G
