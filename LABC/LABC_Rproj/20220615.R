rm(list=ls())
## 行基本変形関数
pic <- function(size,target,constant){
    vec = rep(1,size)
    vec[target] = constant
    return(diag(vec))
}

pijc <- function(size,from,to,constant){
    vec = rep(1,size)
    mat = diag(vec)
    mat[from,to] = constant
    return(mat)
}

pij <- function(size,from,to){
    vec = rep(1,size)
    vec[from] = 0
    vec[to] = 0
    mat = diag(vec)
    mat[from,to] = 1
    return(mat)
}

### Example
A <- matrix(c(1,5,3,-2,4,1,-5,3,-3,3,1,6),ncol=4)
size <- 3
I <- diag(rep(1,size))

### そうさ
P1 <- pijc(size,2,1,-5)
P2 <- pijc(size,3,1,-3)
P3 <- pic(size,2,1/14)
P4 <- pijc(size,1,2,2)
P5 <- pijc(size,3,2,-7)
P6 <- pic(size,3,-1/2)
P7 <- pijc(size,1,3,1)
P8 <- pijc(size,2,3,-2)
P1 %*% A
P2 %*% P1 %*% A
P3 %*% P2 %*% P1 %*% A
P4 %*% P3 %*% P2 %*% P1 %*% A
P5 %*% P4 %*% P3 %*% P2 %*% P1 %*% A
P6 %*% P5 %*% P4 %*% P3 %*% P2 %*% P1 %*% A
P7 %*% P6 %*% P5 %*% P4 %*% P3 %*% P2 %*% P1 %*% A
P8 %*% P7 %*% P6 %*% P5 %*% P4 %*% P3 %*% P2 %*% P1 %*% A
P8 %*% P7 %*% P6 %*% P5 %*% P4 %*% P3 %*% P2 %*% P1 %*% I
P <- solve(matrix(c(1,5,3,-2,4,1,-5,3,-3),ncol=3))


# Example2 ----------------------------------------------------------------

A <- matrix(c(1,1,-1,2,1,3,2,1,-1,5,3,2,4,2,0,2),ncol=4)
P1 <- pijc(4,2,1,-1)
P2 <- pijc(4,3,1,1)
P3 <- pijc(4,4,1,-2)
P1 %*% A
P2 %*% P1 %*% A
P3 %*% P2 %*% P1 %*% A -> A2
P4 <- pic(4,2,0.5)
P4b <- pijc(4,1,2,-1)
P5 <- pijc(4,3,2,-3)
P6 <- pijc(4,4,2,1)
P4 %*% A2
P5 %*% P4 %*% A2
P6 %*% P5 %*% P4b %*% P4 %*% A2 -> A3
P7 <- pic(4,3,-1/7)
P8 <- pijc(4,1,3,4)
P9 <- pijc(4,2,3,-3)
P10 <- pijc(4,4,3,-7)
P10 %*% P9 %*% P8 %*% P7 %*% A3


# Example 3 ---------------------------------------------------------------

A <- matrix(c(1,2,3,-1,10,
              1,1,-2,1,-2,
              2,2,-1,-1,-1),ncol=5,byrow = T)
A
P1 <- pijc(3,2,1,-1)
P2 <- pijc(3,3,1,-2)
P2 %*% P1 %*% A -> A2
A2
P3 <- pic(3,2,-1)
P3 %*% A2
P4 <- pijc(3,1,2,-2)
P5 <- pijc(3,3,2,2)
P5 %*% P4 %*% P3 %*% A2 -> A3
A3
P6 <- pic(3,3,1/3)
P6 %*% A3
P7 <- pijc(3,1,3,7)
P8 <- pijc(3,2,3,-5)
P8 %*% P7 %*% P6 %*% A3

# 例題；掃き出し法で逆行列 ----------------------------------------------------------------------

A <- matrix(c(1,2,0,0,1,1,1,5,1),ncol=3)
I <- diag(rep(1,3))
P1 <- pijc(3,2,1,-2)
P1 %*% A
P1 %*% I
P2 <- pijc(3,3,2,-1)
P2 %*% P1 %*% A
P2 %*% P1 %*% I
P3 <- pic(3,3,-0.5)
P3 %*% P2 %*% P1 %*% A
P4 <- pijc(3,1,3,-1)
P5 <- pijc(3,2,3,-3)
P5 %*% P4 %*% P3 %*% P2 %*% P1 %*% A
P3 %*% P2 %*% P1 %*% I
P5 %*% P4 %*% P3 %*% P2 %*% P1 %*% I
