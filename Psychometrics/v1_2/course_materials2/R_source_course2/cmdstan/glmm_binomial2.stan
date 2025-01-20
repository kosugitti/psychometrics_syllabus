data{
  int L;
  array[L] real X;
  array[L] int Y;
  array[L] int N;
}

parameters{
  real beta0;
  real beta1;
  array[L] real mu;
}

model{
  // model
  for(l in 1:L){
    Y[l] ~ binomial_logit(N[l],beta0 + (beta1 * X[l]) + mu[l]);
  }
  // prior
  beta0 ~ normal(0,10);
  beta1 ~ normal(0,10);
  mu ~ normal(0,10);
}
