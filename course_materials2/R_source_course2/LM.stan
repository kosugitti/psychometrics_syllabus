data{
  int N;
  array[N] real Y;
  array[N] real X;
}

parameters{
  real beta0;
  real beta1;
  real<lower=0> sig;
}

transformed parameters{
  array[N] real mu;
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
  array[N] real predY;
  for(i in 1:N){
    predY[i] = normal_rng(mu[i],sig);
  }
}
