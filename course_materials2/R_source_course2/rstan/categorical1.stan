data{
    int K;
    int X[K];
}

parameters{
    simplex[K] pi;
}

model{
    X ~ multinomial(pi);
}

generated quantities{
    int<lower=0,upper=1> FLG1;
    int<lower=0,upper=1> FLG2;
    int<lower=0,upper=1> FLG3;
    
    if(pi[1]>pi[2]){FLG1=1;}else{FLG1=0;}
    if(pi[1]>pi[3]){FLG2=1;}else{FLG2=0;}
    if(pi[1]>pi[2] && pi[1]>pi[3]){FLG3=1;}else{FLG3=0;}
}
