Y <- c(2,3,4,5)
X <- matrix(c(1,1,0,0,0,0,1,1),ncol=2)
PA <- X %*%solve((t(X)%*%X))%*%t(X)
PE <- diag(1,4) - PA
G <- c(1,1,1,1)
PG <- G %*%solve((t(G)%*%G))%*%t(G)
PF <- PA - PG

Y%*%PA
Y%*%PE
Y%*%PG
Y%*%PF
I <- PG+PF+PE

t(Y) %*% I %*% Y
t(Y) %*% PG %*% Y
t(Y) %*% PF %*% Y
t(Y) %*% PE %*% Y

sum(diag(PE))
sum(diag(PF))
sum(diag(PG))
