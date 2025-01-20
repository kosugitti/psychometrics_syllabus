data{
  int<lower=0> L; // data length
  int<lower=0> N; // number of persons
  int<lower=0> M; // number of questions
  array[L] int<lower=0> Pid;  // personal ID
  array[L] int<lower=0> Qid;  // question ID
  array[L] int<lower=0> resp; // response
}

parameters{
  array[M] real<lower=0> a;
  array[M] real<lower=-5,upper=5> b;
  array[N] real theta;
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
