data{
  int<lower=0> Lv;
  int<lower=0> N;
  real X[Lv,N];
}

parameters{
  real gm;
  real raw_delta[Lv-1];
  real<lower=0> sig;
}

transformed parameters{
  real delta[Lv];
  real mu[Lv];
  
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
