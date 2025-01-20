data{
  int<lower=0> N1;
  int<lower=0> N2;
  int<lower=0> N3;
  real X1[N1];
  real X2[N2];
  real X3[N3];
}

parameters{
  real mu1;
  real mu2;
  real mu3;
  real<lower=0> sig;
}

model{
  // likelihood
  X1 ~ normal(mu1,sig);
  X2 ~ normal(mu2,sig);
  X3 ~ normal(mu3,sig);
  // prior
  mu1 ~ uniform(0,100);
  mu2 ~ uniform(0,100);
  mu3 ~ uniform(0,100);
  sig ~ cauchy(0,5);
}

generated quantities{
  real diff12;
  real diff13;
  real diff23;
  
  diff12 = mu1 - mu2;
  diff13 = mu1 - mu3;
  diff23 = mu2 - mu3;
}
