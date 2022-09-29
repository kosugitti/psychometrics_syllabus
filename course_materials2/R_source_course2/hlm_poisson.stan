data{
  int L;
  int G;
  array[L] int Gindex;
  array[L] real X;
  array[L] int Y;
}

parameters{
  array[G] real beta0;
  array[G] real beta1;
  real gamma0;
  real gamma1;
  real<lower=0> tau0;
  real<lower=0> tau1;
}

transformed parameters{
  array[L] real<lower=0> lambda;
  for(l in 1:L){
    lambda[l] = exp(beta0[Gindex[l]] + (beta1[Gindex[l]] * X[l]));
  }
}

model{
  // model
  for(l in 1:L){
    Y[l] ~ poisson(lambda[l]);
  }
  
  for(g in 1:G){
    beta0[g] ~ normal(gamma0,tau0);
    beta1[g] ~ normal(gamma1,tau1);
  }
  
  //prior
  gamma0 ~ normal(0,10);
  gamma1 ~ normal(0,10);
  tau0 ~ cauchy(0,5);
  tau1 ~ cauchy(0,5);
}
