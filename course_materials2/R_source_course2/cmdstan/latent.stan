data {
  int<lower=1> K;
  int<lower=1> L;
  array[L] real Y;
}

parameters {
  array[L] simplex[K] theta;
  ordered[K] mu;
  array[K] real<lower=0> sigma;
}

transformed parameters{
  array[L] vector[K] lp;
  for (l in 1:L) {
    for (k in 1:K) {
      lp[l,k] = log(theta[l,k])+ normal_lpdf(Y[l]|mu[k],sigma[k]);
    }
  }
}

model{
  for(l in 1:L){
    target+=log_sum_exp(lp[l]);
  }
  sigma ~ cauchy(0,5);
  mu ~ normal(0,10);
}

generated quantities{
  array[L] vector[K] prob_class;
  array[L] int<lower=1,upper=K> pred_class;
  for(l in 1:L){
    prob_class[l] = softmax(lp[l]);
    pred_class[l] = categorical_rng(prob_class[l]);
  }
}
