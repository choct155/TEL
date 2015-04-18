library(aod)
library(ggplot2)
library(corrgram)
library(stargazer)

#exmpt<-read.csv('/home/choct155/dissertation/TEL/CO_lit/exempt_logit_input.csv')
exmpt<-read.csv('/home/choct155/projects/TEL/CO_lit/exempt_logit_input.csv')

#Extract id variables and the dependent
log_vars<-names(exmpt)[!names(exmpt) %in% c('pass','results','ss_development','X','ss_no.waiver')]
exm<-exmpt[c('pass',log_vars)]
exm_ols<-exmpt[c('results',log_vars)]

head(exm)


corrgram(exm, order=NULL, lower.panel=panel.shade,
         upper.panel=NULL, text.panel=panel.txt,
         main="Ballot Data")


#Generate formula for the model
r_formula<-as.formula(paste('pass ~',paste(log_vars,collapse='+')))
r_formula_ols<-as.formula(paste('results ~',paste(log_vars,collapse='+')))

logit<-glm(r_formula,data=exm,family='binomial')
probit<-glm(r_formula,data=exm,family=binomial(link='probit'))
ols<-lm(r_formula_ols,data=exm_ols)

summary(logit)
summary(probit)

plot(logit$y,logit$fitted.values)

hist(logit$residuals,breaks=50)

pred_act<-data.frame(cbind(exm$pass,round(predict(logit,exm[log_vars],type='response'))))
pred_act_probit<-data.frame(cbind(exm$pass,round(predict(probit,exm[log_vars],type='response'))))

logit_acc<-mean(pred_act$X1==pred_act$X2)
probit_acc<-mean(pred_act_probit$X1==pred_act_probit$X2)

print(paste('Average Predictive Accuracy - Logit',logit_acc))
print(paste('Average Predictive Accuracy - Probit',probit_acc))

summary(logit)$coefficients
#write.csv(summary(logit)$coefficients,file='/home/choct155/dissertation/TEL/CO_lit/rlogit_summ.csv')
#write.csv(summary(probit)$coefficients,file='/home/choct155/dissertation/TEL/CO_lit/rprobit_summ.csv')
write.csv(summary(logit)$coefficients,file='/home/choct155/projects/TEL/CO_lit/rlogit_summ.csv')
write.csv(summary(probit)$coefficients,file='/home/choct155/projects/TEL/CO_lit/rprobit_summ.csv')
write.csv(summary(ols)$coefficients,file='/home/choct155/projects/TEL/CO_lit/ols_summ.csv')

stargazer(logit,probit,ols,no.space=TRUE,single.row=TRUE)
