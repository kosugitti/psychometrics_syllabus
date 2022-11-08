data{
  int N;
  int<lower=0,upper=1> Y[N];
  real X[N];
}

parameters{
  real beta0;
  real beta1;
}

transformed parameters{
  real theta[N];
  for(i in 1:N){
    theta[i] = inv_logit(beta0 + beta1 * X[i]);
  }
}

model{
  // model
  for(i in 1:N){
    Y[i] ~ bernoulli(theta[i]);
  }
  // prior
  beta0 ~ normal(0,100);
  beta1 ~ normal(0,100);
}


