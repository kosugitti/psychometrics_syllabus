data{
  int L;
  int N;
  real X[L];
  int Y[L];
  int index[L];
}

parameters{
  real beta0;
  real beta1;
  real mu[N];
}

model{
  // model
  for(l in 1:L){
    Y[l] ~ poisson_log(beta0 + (beta1 * X[l]) + mu[index[l]]);
  }
  // prior
  beta0 ~ normal(0,10);
  beta1 ~ normal(0,10);
  mu ~ normal(0,10);
}
