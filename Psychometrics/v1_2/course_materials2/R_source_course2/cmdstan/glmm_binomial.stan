data{
  int L;
  int N;
  array[L] int index;
  array[L] real X;
  array[L] int Y;
  array[L] int H;
}

parameters{
  real beta0;
  real beta1;
  array[N] real mu;
}

transformed parameters{
  array[L] real<lower=0,upper=1> theta;
  for(l in 1:L){
    theta[l] = inv_logit(beta0 + (beta1 * X[l]) + mu[index[l]]);
  }
}

model{
  // model
  for(l in 1:L){
    Y[l] ~ binomial(H[l],theta[l]);
  }
  // prior
  beta0 ~ normal(0,10);
  beta1 ~ normal(0,10);
  mu ~ normal(0,10);
}
