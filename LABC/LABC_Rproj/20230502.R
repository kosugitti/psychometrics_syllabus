Y <- c(2,3,4,5)
X <- matrix(c(1,1,0,0,0,0,1,1),ncol=2)
PA <- X %*%solve((t(X)%*%X))%*%t(X)
PE <- diag(1,4) - PA
G <- c(1,1,1,1)
PG <- G %*%solve((t(G)%*%G))%*%t(G)
PF <- PA - PG

PA%*%Y
PE%*%Y
PG%*%Y
PF%*%Y
I <- PG+PF+PE

y <- Y - mean(Y)

t(y) %*% I %*% y
t(y) %*% PG %*% y
t(y) %*% PF %*% y
t(y) %*% PE %*% y

sum(diag(PE))
sum(diag(PF))
sum(diag(PG))

# 切片を含む -------------------------------------------------------------------

## ランク落ち
X <- matrix(c(1,1,1,1,1,1,0,0,0,0,1,1),ncol=3)
PA <- X %*%solve((t(X)%*%X))%*%t(X)

## ランク対応
X <- matrix(c(1,1,1,1,1,1,-1,-1),ncol=2)
PA <- X %*%solve((t(X)%*%X))%*%t(X)
Y%*%PA
