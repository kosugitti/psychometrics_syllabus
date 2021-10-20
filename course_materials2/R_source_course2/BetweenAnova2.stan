data{
  int<lower=0> Lv;                             // 水準数
  int<lower=0> L;                              // データ数
  int<lower=0,upper=Lv> idx[L];                // データのID
  real X[L];                                   // 変数の値
}

parameters{
  real gm;                                     // 全体平均
  real raw_delta[Lv-1];                        // 全体からの差。水準数マイナス1個
  real<lower=0> sig;                           // 誤差の分散
}

transformed parameters{
  real delta[Lv];                            // 差の大きさを作り直す
  real mu[Lv];                                // 再構成される群ごとの平均
  
  for(i in 1:(Lv-1))                          // ほとんどコピー
    delta[i] = raw_delta[i];

  delta[Lv] = 0 - sum(raw_delta);           // 総和が0になるように最後だけ書き換える
  for(i in 1:Lv)
    mu[i] = gm + delta[i];                   // 群ごとに再構成
  
}

model{
  // Likelihood
  for(l in 1:L)
    X[l] ~ normal(mu[idx[l]],sig);
    
  // Prior
  gm ~ uniform(0,100);
  raw_delta ~ normal(0,100);
  sig ~ cauchy(0,5);
}
