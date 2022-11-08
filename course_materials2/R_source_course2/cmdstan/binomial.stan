data{
  int N;
  array[N] int AB;
  array[N] int Hit;
  array[N] real X;
}

parameters{
  real beta0;
  real beta1;
}

transformed parameters{
  real theta[N];
  for(n in 1:N){
    theta[n] = inv_logit(beta0 + beta1 * X[n]);
  }
}

model{
  // model
  for(n in 1:N){
    Hit[n] ~ binomial(AB[n],theta[n]);
  }
  // prior
  beta0 ~ normal(0,100);
  beta1 ~ normal(0,100);
}


