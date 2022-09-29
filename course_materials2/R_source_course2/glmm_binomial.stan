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

transformed parameters{
  real<lower=0,upper=1> theta[L];
  for(l in 1:L){
    theta[l] = inv_logit(beta0 + (beta1 * X[l]) + mu[l]);
  }
}

model{
  // model
  for(l in 1:L){
    Y[l] ~ binomial(N[l],theta[l]);
  }
  // prior
  beta0 ~ normal(0,10);
  beta1 ~ normal(0,10);
  mu ~ normal(0,10);
}
