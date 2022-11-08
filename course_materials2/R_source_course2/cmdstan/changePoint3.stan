data{
  int L; // data length
  array[L] real W;
  array[L] real X;
}

parameters{
  real<lower=100,upper=250> tau;
  array[2] real beta0;
  real<upper=0> beta1a;
  real<lower=0> beta1b;
  real<lower=0> sigma;
}


model{
  for(l in 1:L){
    if( l < tau ){
      W[l] ~ normal( beta0[1] + (beta1a * X[l]),sigma);
    }else{
      W[l] ~ normal( beta0[2] + (beta1b * X[l]),sigma);
    }
  }
  
  beta0 ~ normal(70,10);
  beta1a ~ normal(0,5);
  beta1b ~ normal(0,5);
  sigma ~ cauchy(0,5);
}
