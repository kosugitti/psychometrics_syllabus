data{
  int N;
  array[N] vector[2] X;
}

parameters{
  vector[2] mu;
  real<lower=0> sd1;
  real<lower=0> sd2;
  real<lower=-1,upper=1> rho;
}

transformed parameters{
  cov_matrix[2] SIG;
  SIG[1,1] = sd1 * sd1;
  SIG[1,2] = sd1 * sd2 * rho;
  SIG[2,1] = sd2 * sd1 * rho;
  SIG[2,2] = sd2 * sd2;
}

model{
  X ~ multi_normal(mu,SIG);
  //prior
  mu[1] ~ uniform(0,100);
  mu[2] ~ uniform(0,100);
  rho ~ uniform(-1,1);
  sd1 ~ cauchy(0,5);
  sd2 ~ cauchy(0,5);
}
