data{
  int L;
  int N;
  int Lv;
  int id[L];
  int cond[L];
  int val[L];
}

parameters{
  real mu[N];
  real raw_effect[Lv-1];
  real psi;
  real<lower=0> sig;
  real<lower=0> tau;
}

transformed parameters{
  real effect[Lv];
  effect[1:(Lv-1)] = raw_effect;
  effect[Lv] = 0 - sum(raw_effect);
}

model{
  for(l in 1:L){
    val[l] ~ normal(mu[id[l]]+effect[cond[l]],sig);
  }
  mu ~ normal(psi,tau);
  
  raw_effect ~ uniform(-100,100);
  psi ~ uniform(0,100);
  tau ~ cauchy(0,5);
  sig ~ cauchy(0,5);
}
