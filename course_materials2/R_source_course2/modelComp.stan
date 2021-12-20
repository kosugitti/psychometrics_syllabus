data{
  int N;
  int Y[N];
}

parameters{
  real<lower=0,upper=1> tau;
  real<lower=0,upper=1> theta1;
  real<lower=0,upper=1> theta2;
}

transformed parameters{
  real lp[N,2];
  for(n in 1:N){
    lp[n,1] = log(tau) + bernoulli_lpmf(Y[n]|theta1);
    lp[n,2] = log1m(tau)+ bernoulli_lpmf(Y[n]|theta2);
  }
}

model{
  for(n in 1:N){
    target += log_sum_exp(lp[n]);
  }
  tau ~ beta(1,1);
  target += beta_lpdf(theta1|2.8, 17.2);
  target += beta_lpdf(theta2|13.6,6.4);
}
