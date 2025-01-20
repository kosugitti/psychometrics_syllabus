data{
    int<lower=0> N1; // Number of Subjects in Group 1
    int<lower=0> N2; // Number of Subjects in Group 2
    real X1[N1]; // Data in Group 1
    real X2[N2]; // Data in Group 2
}

parameters{
    real mu1;
    real mu2;
    real<lower=0> sig1;
    real<lower=0> sig2;
}

model{
    // likelihood
    X1 ~ normal(mu1,sig1);
    X2 ~ normal(mu2,sig2);
    // prior
    mu1 ~ uniform(0,100);
    mu2 ~ uniform(0,100);
    sig1 ~ cauchy(0,5);
    sig2 ~ cauchy(0,5);
}

generated quantities{
    real Xpred1[N1];
    real Xpred2[N2];
    for(i in 1:N1){
        Xpred1[i] = normal_rng(mu1,sig1);
    }
    for(i in 1:N2){
        Xpred2[i] = normal_rng(mu2,sig2);
    }
}
