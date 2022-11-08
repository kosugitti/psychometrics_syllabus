data{
  int N;
  int K;
  array[N] vector[K] X;
}

parameters{
  vector[K] mu;
  vector<lower=0>[K] sds;
  corr_matrix[K] rho;
}

transformed parameters{
  cov_matrix[K] SIG;
  SIG = quad_form_diag(rho,sds);
}

model{
  X ~ multi_normal(mu,SIG);
  //prior
  mu[1] ~ uniform(0,100);
  mu[2] ~ uniform(0,100);
  rho ~ lkj_corr(1);
  sds ~ cauchy(0,5);
}

