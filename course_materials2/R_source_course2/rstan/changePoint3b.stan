data{
  int L; // data length
  real W[L];
  real X[L];
}

parameters{
  real<lower=100,upper=250> tau;
  real beta0a;
  real<upper=0> beta1a;
  real<lower=0> beta1b;
  real<lower=0> sigma;
}

transformed parameters{
  real beta0b;
  beta0b = beta0a + ((beta1a-beta1b) * tau);
}

model{
  for(l in 1:L){
    if( l < tau ){
      W[l] ~ normal( beta0a + (beta1a * X[l]),sigma);
    }else{
      W[l] ~ normal( beta0b + (beta1b * (X[l])),sigma);
    }
  }
  
  beta1a ~ normal(0,5);
  beta1b ~ normal(0,5);
  sigma ~ cauchy(0,5);
}
