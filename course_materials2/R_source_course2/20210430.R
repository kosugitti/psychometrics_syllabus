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


# 四則演算 --------------------------------------------------------------------

x <- 1:3
y <- 8:10
x + y
x - y
2 * x
y / 3
A <- matrix(c(1, 2, 3, 4), ncol = 2)
B <- matrix(c(5, 6, 7, 8), ncol = 2)
A + B
A * 3 + B * 2


a <- c(1, 2, 1)
b <- c(3, 4, 2)
a * b
a %*% b
a %*% t(b)
A <- matrix(1:9, ncol = 3)
A * a
A %*% a
a %*% A
B <- matrix(1:6, nrow = 3, byrow = T)
C <- matrix(c(1, 0, 0, 1, 1, 1), ncol = 3)
B %*% C
B %*% t(C)

A <- matrix(c(2, 1, 5, 3), ncol = 2)
solve(A)
A %*% solve(A)


A <- matrix(c(1, 5, 3, -2, 4, 1, -5, 3, -3), ncol = 3)
b <- c(3, 1, 6)
solve(A) %*% b


# データの行列計算 ----------------------------------------------------------------

dataset <- read_csv("baseballDecade.csv") %>%
  dplyr::filter(Year=="2020年度") %>% 
  dplyr::filter(position == "投手") %>%
  dplyr::select(Name, team, height, weight, salary, Win, Save) %>%
  na.omit() %>%
  arrange(-Win) %>% print %>% 
  select(height, weight, salary) %>%
  as.matrix() 

# write_csv(dat, "pitcher2020.csv")
# 
# datafile <- read_csv("pitcher2020.csv")

n <- nrow(dataset)
one <- rep(1, n)
m <- t(dataset) %*% one / n
V <- dataset - one %*% t(m)
S <- t(V) %*% V / n
SD <- diag(S) %>% sqrt()
Q <- diag(SD)
Z <- V %*% solve(Q)
R <- t(Z) %*% Z / n
cor(dataset)

eig <- eigen(R)
eig$values
sum(eig$values)
sum(diag(R))
eig$vector
eig$vector[,1]^2 %>% sum
