data{
  int<lower=0> L;
  int<lower=0> N;
  int<lower=0> M;
  array[L] int<lower=0,upper=N> Pid;
  array[L] int<lower=0,upper=M> Qid;
  array[L] int<lower=0,upper=1> resp;
}

parameters{
  array[M] real<lower=0> a;
  array[M] real<lower=-5,upper=5> b;
  array[N] real theta;
}

transformed parameters{
  array[N,M] real<lower=0,upper=1> prob;
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
