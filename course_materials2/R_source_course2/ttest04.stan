data{
    int<lower=0> N1; // Number of Subjects in Group 1
    int<lower=0> N2; // Number of Subjects in Group 2
    array[N1] real X1; // Data in Group 1
    array[N2] real X2; // Data in Group 2
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
    real diff;
    int<lower=0, upper=1> FLG;
    real cohen_d1;
    real cohen_d2;
    diff = mu1 - mu2;
    cohen_d1 = diff / sig1;
    cohen_d2 = diff / sig2;
    if(diff > 5){
        FLG = 1;
    }else{
        FLG = 0;
    }
}
