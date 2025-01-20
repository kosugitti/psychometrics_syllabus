parameters{
  real a;
  real b;
}
model{
  a ~ normal(0,10000);
  b ~ normal(0,10000);

  0.0 ~ normal(a + b,1.0);
}
