data{
  int<lower=0> M;
  int<lower=0> N;
  array[N,M] int<lower=0,upper=1> resp;
}

parameters{
  array[M] real<lower=0> a;
  array[M] real<lower=-5,upper=5> b;
  array[M] real<lower=0,upper=1> c;
  array[N] real theta;
}

transformed parameters{
  array[N,M] real<lower=0,upper=1> prob;
  for(n in 1:N){
    for(m in 1:M){
      prob[n,m] = c[m] + (1-c[m])*inv_logit(1.7*a[m]*(theta[n]-b[m]));
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
  a ~ normal(0,3);
  b ~ normal(0,3);
  c ~ normal(0,3);
  theta ~ normal(0,1);
}
