data{
  int N;
  int Y[N];
  real omega1;
  real omega2;
  real kappa1;
  real kappa2;
}

transformed data{
  real a1;
  real a2;
  real b1;
  real b2;
  a1 = omega1 * (kappa1-2)+1;
  b1 = (1-omega1)*(kappa1-2) +1;
  a2 = omega2 * (kappa2-2)+1;
  b2 = (1-omega2)*(kappa2*2)+1;
}

parameters{
  real<lower=0,upper=1> tau;
  real<lower=0,upper=1> theta;
}

transformed parameters{
  real lp[N,2];
  for(n in 1:N){
    lp[n,1] = log(tau) + beta_lpdf(theta|a1,b1) + bernoulli_lpmf(Y[n]|theta);
    lp[n,2] = log1m(tau)+ beta_lpdf(theta|a2,b2) + bernoulli_lpmf(Y[n]|theta);
  }
}

model{
  for(n in 1:N){
    target += log_sum_exp(lp[n]);
  }
}
