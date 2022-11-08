data{
 int L;
 real W[L];
 int<lower=0> Nmiss;
}

parameters{
  real muZero;
  real mu[L];
  real<lower=0> Miss_W[Nmiss];
  real<lower=0> sig;
  real<lower=0> tau;
}

model{
  mu[1] ~ normal(muZero, tau);
  mu[2] ~ normal(mu[1] , tau);
  
  {
    int j = 0;
    for(l in 1:L){
      if( W[l] != 999){
          // こっちは尤度
          W[l] ~ normal(mu[l],sig);
      }else{
        j = j + 1;
        // こっちはパラメータ
        Miss_W[j] ~ normal(2*mu[l-1]-mu[l-2], sig);
      }
    }
  }
  
  for(i in 3:L){
    //2階差分
    mu[i] ~ normal(2*mu[i-1]-mu[i-2],tau);
  }
  
  muZero ~ normal(80,10); 
  sig ~ cauchy(0,5);
  tau ~ cauchy(0,5);
}
