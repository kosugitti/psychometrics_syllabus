data{
    int N1;
    int N2;
    real X1[N1];
    real X2[N2];
}

parameters{
    real mu1;
    real mu2;
    real<lower=0> sig1;
    real<lower=0> sig2;
}

model{
    target += normal_lpdf(X1|mu1,sig1);
    target += normal_lpdf(X2|mu2,sig2);
    target += normal_lpdf(mu1|0,100);
    target += normal_lpdf(mu2|0,100);
    target += cauchy_lpdf(sig1|0,5)- cauchy_lpdf(0|0,5);;
    target += cauchy_lpdf(sig2|0,5)- cauchy_lpdf(0|0,5);;
}

generated quantities{
    real log_lik[N1+N2];
    real diff;
    real d;
    diff = mu1 - mu2;
    d = diff/sqrt((sig1*N1+sig2*N2)/(N1+N2));
    for(n in 1:N1){
        log_lik[n] = normal_lpdf(X1|mu1,sig1);
    }
    for(n in 1:N2){
        log_lik[N1+n] = normal_lpdf(X2|mu1,sig2);
    }
}