A <- matrix(c(5,3,4,9),ncol=2)
eigen(A) -> res
C1 <- res$vectors[,1]%*%t(res$vectors[,1])*res$values[1]
C2 <- res$vectors[,2]%*%t(res$vectors[,2])*res$values[2]
C1
C2
A
C1 + C2
P <- matrix(c(res$vectors[,1],res$vectors[,2]),ncol=2) 
solve(P) %*% A %*% P
