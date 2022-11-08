data {
  int N; // number of data points
  int P; // number of items
  int Y[N,P]; // observations
}
parameters {
  real theta[N];
  vector<lower=0, upper=5>[P] a;
  vector<lower=-4, upper=4>[P] b;
}
model {
  //prior
  theta ~ normal(0,1);
  a ~ cauchy(0,5);
  b ~ normal(0,5);
  
  //model
  for (n in 1:N){
    for(p in 1:P){
      Y[n,p] ~ bernoulli_logit(a[p]*(theta[n]-b[p]));
    }
  }
}
