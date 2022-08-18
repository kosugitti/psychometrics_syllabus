## QとRに分解
QRdecompose <- function(A){
    Q = matrix(0,ncol=ncol(A),nrow=nrow(A))
    R = matrix(0,ncol=ncol(A),nrow=nrow(A))
    for(i in 1:N){
        b <- A[,i]
        for(j in 1:i){
            if(j<i){
                R[j,i] <- t(A[,i])%*%Q[,j]
                b <- b -  R[j,i]*Q[,j]
            }
        }
        R[i,i] <- sqrt(sum(b^2))
        Q[,i] <- b/R[i,i]
    }
    return(list(Q=Q,R=R))
}

A <- matrix(c(1,0.3,0.4,0.9,0.3,1.0,0.5,0.4,0.4,0.5,1.0,0.7,0.9,0.4,0.7,1.0),ncol=4)

for(iter in 1:10){
    QRresult <- QRdecompose(A)
    Q <- QRresult$Q
    R <- QRresult$R
    print(paste("iter",iter))
    # print(knitr::kable(Q,digits=3,format = 'latex',row.names = NA))
    # print(knitr::kable(R,digits=3,format = 'latex',row.names = NA))
    A <- R %*%Q
    print(knitr::kable(A,digits=3,format = 'latex',row.names = NA))
}
diag(A)
