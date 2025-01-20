data{
  int Y[4];
}

parameters{
  real<lower=0,upper=1> alpha;
  real<lower=0,upper=1> beta;
  real<lower=0,upper=1> gamma;
}

transformed parameters{
  simplex[4] Pi;
  Pi[1] = alpha * beta;
  Pi[2] = (1-alpha) * gamma;
  Pi[3] = alpha * (1-beta);
  Pi[4] = (1-alpha) * (1-gamma);
}

model{
  Y ~ multinomial(Pi);
  alpha ~ uniform(0,1);
  beta ~ uniform(0,1);
  gamma ~ uniform(0,1);
}

generated quantities{
  real po;
  real pe;
  real kappa;
  po = Pi[1] + Pi[4];
  pe = (Pi[1]+Pi[2])*(Pi[1]+Pi[3]) + (Pi[2]+Pi[4])*(Pi[3]+Pi[4]);
  kappa = (po-pe)/(1-pe);
}
