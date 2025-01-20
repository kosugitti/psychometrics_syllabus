rm(list=ls())
qnorm(0.025,mean=45,sd=2.5)
qnorm(0.975,mean=45,sd=2.5)

1-pnorm((45-40)/2.5,0,1)

t <- (45-40)/(9/4)
(1-pt(t,df=15))*2

t <- (0.3*sqrt(49-2))/(sqrt(1-0.3^2))
1-pt(t,df=47)

