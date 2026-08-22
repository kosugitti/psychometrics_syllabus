data {
  int<lower=0> N1;
  int<lower=0> N2;
  vector[N1] y1;
  vector[N2] y2;
}

parameters {
  real mu1;
  real mu2;
  real<lower=0> sigma;
}

model {
  y1 ~ normal(mu1, sigma);
  y2 ~ normal(mu2, sigma);
}

generated quantities{
  real delta
  delta = mu1 - mu2;
}

