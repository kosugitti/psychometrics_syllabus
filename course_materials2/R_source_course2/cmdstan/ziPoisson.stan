data{
  int L;
  array[L] int Y;
}

parameters{
  real<lower=0,upper=1> theta;
  real<lower=0> lambda;
}

model{
  for(l in 1:L){
    if(Y[l]==0){
      target += log_sum_exp(log(1-theta),log(theta)+poisson_lpmf(0|lambda));
    }else{
      target += log(theta) + poisson_lpmf(Y[l]|lambda);
    }
  }
}
