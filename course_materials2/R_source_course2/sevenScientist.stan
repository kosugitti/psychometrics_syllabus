data{
  real Y[7];
}

parameters{
  real mu;
  real<lower=0> sig[7];
}

model{
  for(i in 1:7){
    //likelihood
    Y[i] ~ normal(mu,sig[i]);
    //prior
    sig[i] ~ cauchy(0,5);
  }
  //prior
  mu ~ normal(0,100);
}
