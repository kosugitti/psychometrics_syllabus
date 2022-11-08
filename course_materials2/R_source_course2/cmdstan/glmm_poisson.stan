data{
  int L;
  array[L] real X;
  array[L] int Y;
}

parameters{
  real beta0;
  real beta1;
  array[L] real mu;
}

model{
  // model
  for(l in 1:L){
    Y[l] ~ poisson_log(beta0 + (beta1 * X[l]) + mu[l]);
  }
  // prior
  beta0 ~ normal(0,10);
  beta1 ~ normal(0,10);
  mu ~ normal(0,10);
}
