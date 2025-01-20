data{
    int<lower=0> N1; // Number of Subjects in Group 1
    int<lower=0> N2; // Number of Subjects in Group 2
    real X1[N1]; // Data in Group 1
    real X2[N2]; // Data in Group 2
    int<lower=0> C; //constant 
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
    real Xpred1;
    real Xpred2;
    int<lower=0,upper=1> FLG1;
    int<lower=0,upper=1> FLG2;
    Xpred1 = normal_rng(mu1,sig1);
    Xpred2 = normal_rng(mu2,sig2);
    //probability of dominance
    if(Xpred1 > Xpred2){
        FLG1 = 1;
    }else{
        FLG1 = 0;
    }
    //probability beyond threshold
    if(Xpred1 - Xpred2 > C ){
        FLG2 = 1;
    }else{
        FLG2 = 0;
    }
}
