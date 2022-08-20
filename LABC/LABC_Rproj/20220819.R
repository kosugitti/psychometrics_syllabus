
X <- matrix(c(150,160,145,165,175,
              50,55,40,65,85,
              42,38,22,50,48),ncol=3)
One <- rep(1,5)
m <- (t(X)%*%One)/5
V <- X - One %*% t(m)
S <- (t(V) %*% V)/5
S
Q <- diag(diag(1/sqrt(S)))
Q
Z <- V %*% Q
(t(Z) %*% Z )/5
