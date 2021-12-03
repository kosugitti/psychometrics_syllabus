data{
  int<lower=0> L; // data length
  int<lower=0> N; // number of persons
  int<lower=0> M; // number of questions
  int<lower=0> Pid[L];  // personal ID
  int<lower=0> Qid[L];  // question ID
  int<lower=0> resp[L]; // response
}

parameters{
  real<lower=0> a[M];
  real<lower=-5,upper=5> b[M];
  real theta[N];
}

model{
  //likelihood
  for(l in 1:L){
    resp[l] ~ bernoulli_logit(1.7*a[Qid[l]]*(theta[Pid[l]]-b[Qid[l]]));
  }
  
  //prior
  a ~ lognormal(0,sqrt(0.5));
  b ~ normal(0,3);
  theta ~ normal(0,1);
}
