data{
    int N;
    real X[N];
}

parameters{
    real mu;
    real<lower=0> sigma;
}

model{
    X ~ normal(mu,sigma);
}
