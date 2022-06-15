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
pPa