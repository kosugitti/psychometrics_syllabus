data{
  int<lower=0> M;
  int<lower=0> N;
  array[N,M] int<lower=0,upper=1> resp;
}

parameters{
  array[M] real<lower=-5,upper=5> b;
  array[N] real theta;
}

transformed parameters{
  array[N,M] real<lower=0,upper=1> prob;
  for(n in 1:N){
    for(m in 1:M){
      prob[n,m] = inv_logit(1.7*(theta[n]-b[m]));
    }
  }
}

model{
  for(n in 1:N){
    for(m in 1:M){
      resp[n,m] ~ bernoulli(prob[n,m]);
    }
  }
  //prior
  b ~ normal(0,3);
  theta ~ normal(0,1);
}
