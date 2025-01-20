data {
  int<lower=0> N;
  int<lower=0,upper=1> Y[N];
}
transformed data{
  vector<lower=0,upper=1>[2] omega;
  real<lower=0> kappa;

  omega[1] = .10;
  omega[2] = .70;
  kappa = 20;
}
parameters {
  vector<lower=0,upper=1>[2] theta;
  real<lower=0,upper=1> m_prob;
}
transformed parameters{
  vector<lower=0>[2] alpha;
  vector<lower=0>[2] beta;
  alpha = omega * (kappa - 2) + 1;
  beta  = (1 - omega) * (kappa - 2) + 1;
}
model {
  // Uncomment and change parameters to set prior to something other than 
  // uniform.  
  m_prob ~ beta(1,1);  

  theta ~ beta(alpha,beta);
  for (i in 1:N) {
    target +=  log_mix(m_prob, bernoulli_lpmf(Y[i] | theta[1]), 
                               bernoulli_lpmf(Y[i] | theta[2]));
  }
}
