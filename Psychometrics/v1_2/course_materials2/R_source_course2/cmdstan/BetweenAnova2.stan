data{
  int<lower=0> Lv;                             // 水準数
  int<lower=0> L;                              // データ数
  array[L] int<lower=0,upper=Lv> idx;                // データのID
  array[L] real X;                                   // 変数の値
}

parameters{
  real gm;                                     // 全体平均
  array[Lv-1] real raw_delta;                        // 全体からの差。水準数マイナス1個
  real<lower=0> sig;                           // 誤差の分散
}

transformed parameters{
  array[Lv] real delta;                            // 差の大きさを作り直す
  array[Lv] real mu;                                // 再構成される群ごとの平均
  
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
