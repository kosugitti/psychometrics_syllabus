data{
  int N;
  int Y[N];
}

parameters{
  real<lower=0,upper=1> theta;
}

model{
 Y ~ bernoulli(theta); 
}
