data{
  int L;
  array[L] real X;
  array[L] int Y;
}

parameters{
  real beta0;
  real beta1;
}

transformed parameters{
  array[L] real<lower=0> lambda;
  for(l in 1:L){
    lambda[l] = exp(beta0 + (beta1 * X[l]));
  }
}

model{
  // model
  for(l in 1:L){
    Y[l] ~ poisson(lambda[l]);
  }
  // prior
  beta0 ~ normal(0,10);
  beta1 ~ normal(0,10);
}
