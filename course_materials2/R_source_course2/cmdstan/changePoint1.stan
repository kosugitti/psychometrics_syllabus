data{
  int L;
  array[L] real W;
}

parameters{
  array[L] real<lower=0,upper=1> theta;
  ordered[2] mu;
  real<lower=0> sigma;
}

model{
  for(l in 1:L){
    target += log_sum_exp(
      log(theta[l]) + normal_lpdf(W[l]|mu[1],sigma),
      log1m(theta[l]) + normal_lpdf(W[l]|mu[2],sigma)
    );
  }
  
  mu ~ normal(80,10);
  sigma ~ cauchy(0,5);
}
