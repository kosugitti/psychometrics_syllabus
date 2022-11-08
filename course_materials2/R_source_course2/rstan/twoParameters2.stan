data{
  int<lower=0> L;
  int<lower=0> N;
  int<lower=0> M;
  int<lower=0,upper=N> Pid[L];
  int<lower=0,upper=M> Qid[L];
  int<lower=0,upper=1> resp[L];
}

parameters{
  real<lower=0> a[M];
  real<lower=-5,upper=5> b[M];
  real theta[N];
}

transformed parameters{
  real<lower=0,upper=1> prob[N,M];
  for(n in 1:N){
    for(m in 1:M){
      prob[n,m] = inv_logit(1.7*a[m]*(theta[n]-b[m]));
    }
  }
}

model{
  for(l in 1:L){
    resp[l] ~ bernoulli(prob[Pid[l],Qid[l]]);
  }
  //prior
  a ~ normal(0,3);
  b ~ normal(0,3);
  theta ~ normal(0,1);
}
