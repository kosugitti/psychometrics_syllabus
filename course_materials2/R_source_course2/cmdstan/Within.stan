data{
  int L;
  int N;
  int Lv;
  array[L] int id;
  array[L] int cond;
  array[L] int val;
}

parameters{
  array[N] real mu;
  array[Lv-1] real raw_effect;
  real psi;
  real<lower=0> sig;
  real<lower=0> tau;
}

transformed parameters{
  array[Lv] real effect;
  effect[1:(Lv-1)] = raw_effect;
  effect[Lv] = 0 - sum(raw_effect);
}

model{
  for(l in 1:L){
    val[l] ~ normal(mu[id[l]]+effect[cond[l]],sig);
  }
  mu ~ normal(psi,tau);
  
  effect ~ uniform(-100,100);
  psi ~ uniform(0,100);
  tau ~ cauchy(0,5);
  sig ~ cauchy(0,5);
}
