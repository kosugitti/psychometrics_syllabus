rm(list = ls())
A <- matrix(c(1, 2, 3, 4), ncol = 2)
B <- matrix(c(3, 2, 1, 4, 5, 6), ncol = 3)
C <- matrix(c(4, 2, 1, 3), ncol = 2)
x <- matrix(c(1, 2, 3), ncol = 1)
y <- matrix(c(2, 8), ncol = 2)
A
B
C
x
y
A + B
A - C
A %*% B
A %*% C
t(B) %*% A
A %*% t(y)
x %*% y
x %*% B
t(x) %*% t(B)
y %*% x
