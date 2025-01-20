data{
  int N;
  int Y[N];
  real omega[2];
  real kappa[2];
}

parameters{
  real<lower=0,upper=1> theta1;
  real<lower=0,upper=1> theta2;
}

model{
  real lp[2];
  lp[1] = log(0.5);
  lp[2] = log1m(0.5);
  for(n in 1:N){
    lp[1] += bernoulli_lpmf(Y[n]|theta1);
    lp[2] += bernoulli_lpmf(Y[n]|theta2);
  }
  target += log_sum_exp(lp);
  target += beta_lpdf(theta1|omega[1]*(kappa[1]-2)+1, (1-omega[1])*(kappa[1]-2)+1);
  target += beta_lpdf(theta2|omega[2]*(kappa[2]-2)+1, (1-omega[2])*(kappa[2]-2)+1);
}

generated quantities{
  int m;
  real lp[2,N];
  for(n in 1:N){
   lp[1,n] = bernoulli_lpmf(Y[n]|theta1)+beta_lpdf(theta1|omega[1]*(kappa[1]-2)+1, (1-omega[1])*(kappa[1]-2)+1);
   lp[2,n] = bernoulli_lpmf(Y[n]|theta2)+beta_lpdf(theta2|omega[2]*(kappa[2]-2)+1, (1-omega[2])*(kappa[2]-2)+1);
  }
  if(sum(lp[1,]) >= sum(lp[2,])){ m = 1; }else{ m = 2;}
}

