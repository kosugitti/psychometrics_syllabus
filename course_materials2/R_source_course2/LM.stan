data{
  int N;
  real Y[N];
  real X[N];
}

parameters{
  real beta0;
  real beta1;
  real<lower=0> sig;
}

transformed parameters{
  real mu[N];
  for(i in 1:N){
    mu[i] = beta0 + beta1 * X[i];
  }
}

model{
  // model
  for(i in 1:N){
    Y[i] ~ normal(mu[i],sig);
  }
  // prior
  beta0 ~ normal(0,100);
  beta1 ~ normal(0,100);
  sig ~ cauchy(0,5);
}

generated quantities{
  real predY[N];
  for(i in 1:N){
    predY[i] = normal_rng(mu[i],sig);
  }
}
