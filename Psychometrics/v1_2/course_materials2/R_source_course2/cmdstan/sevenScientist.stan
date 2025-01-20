data{
  array[7] real Y;
}

parameters{
  real mu;
  array[7] real<lower=0> sig;
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
