data{
  int L;
  int Y[L];
  real X[L];
}

parameters{
  real<lower=0,upper=1> theta;
  real beta0;
  real beta1;
}

transformed parameters{
  real<lower=0> lambda[L];
  for(l in 1:L){
    lambda[l] = exp(beta0 + beta1 * X[l]);
  }
}

model{
  for(l in 1:L){
    if(Y[l]==0){
      target += log_sum_exp(log(1-theta),log(theta)+poisson_lpmf(0|lambda[l]));
    }else{
      target += log(theta) + poisson_lpmf(Y[l]|lambda[l]);
    }
  }
}
