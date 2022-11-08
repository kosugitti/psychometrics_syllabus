data{
  int<lower=0> Lv;
  int<lower=0> N;
  array[Lv,N] real X;
}

parameters{
  real gm;
  array[Lv-1] real raw_delta;
  real<lower=0> sig;
}

transformed parameters{
  array[Lv] real delta;
  array[Lv] real mu;
  
  for(i in 1:(Lv-1)){
    delta[i] = raw_delta[i];
  }
  
  delta[Lv] = 0 - sum(raw_delta);

  for(i in 1:Lv){
    mu[i] = gm + delta[i];
  }
  
}

model{
  // Likelihood
  for(l in 1:Lv){
      for(i in 1:N){
          X[l,i] ~ normal(mu[l],sig);
          
      }
  }
    
  // Prior
  gm ~ uniform(0,100);
  raw_delta ~ normal(0,100);
  sig ~ cauchy(0,100000);
}
