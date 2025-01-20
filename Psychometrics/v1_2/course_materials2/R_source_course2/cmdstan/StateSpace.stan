data{
 int L;
 array[L] real W;
}

parameters{
  real muZero;
  array[L] real mu;
  real<lower=0> sig;
  real<lower=0> tau;
}

model{
  mu[1] ~ normal(muZero, tau);
  
  for(l in 1:L){
    W[l] ~ normal(mu[l],sig);
  }
  
  for(i in 2:L){
    mu[i] ~ normal(mu[i-1],tau);
  }
  
  muZero ~ normal(80,10); 
  sig ~ cauchy(0,5);
  tau ~ cauchy(0,5);
}
