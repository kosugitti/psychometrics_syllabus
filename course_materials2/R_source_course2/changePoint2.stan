data{
  int L;
  real W[L];
}

parameters{
  real<lower=0,upper=L> tau;
  vector[2] mu;
  real<lower=0> sigma;
}

model{
  for(l in 1:L){
    if(l > tau){
      W[l] ~ normal(mu[1],sigma);
    }else{
      W[l] ~ normal(mu[2],sigma);
    }
  }
  
  mu ~ normal(80,10);
  sigma ~ cauchy(0,5);
}
