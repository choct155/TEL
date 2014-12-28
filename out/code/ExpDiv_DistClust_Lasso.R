library(ISLR)
library(ggplot2)
library(glmnet)
library(plyr)
library(Amelia)
library(reshape)
library(reshape2)

##  Read in data ##

print('***LOADING DATA***')
#Establish working directory
workdir<-'/home/choct155/dissertation/TEL/ipynb/'
#Read in cluster distance data
cd<-read.csv(paste(workdir,'h1_exp_model_in.csv',sep=''))
#Rename a few variables
names(cd)[1]<-'cty'
names(cd)[2]<-'year'
#Establish data dir
data_dir<-'/home/choct155/Google Drive/Dissertation/Data/'
#Read in main set
data<-read.csv(paste(data_dir,'CO_CTY_REAL.csv',sep=''))


##  Join data on county and year  ##

print('***JOINING DATA***')
#Isolate non-overlapping variables (but include join keys cty and year)
left_vars<-c(names(cd)[!names(cd) %in% names(data)],'cty','year')
#Join data
cd2<-join(cd[,left_vars],data,by=c('year','cty'),type='left')

##  Impute Missing Data ##

print('***IMPUTING MISSING DATA***')
#Impute data (dropping variables that do not vary)
cd2_mi<-amelia(cd2[,names(cd2)[!names(cd2) %in% c('nonres_rate','r_REV_REAL_ESTATE_TRANSFER_TAX')]],
                   m=5,ts='year',cs='cty',polytime=2,intercs=TRUE,p2s=2,empri=0.1*nrow(cd2))


## Define a function to run lasso on each imputed set ##

print('***DEFINING LASSO FUNCTION***')
lasso_func<-function(df,vars,fmla,dep){
  #Generate X matrix
  x<-model.matrix(fmla,data=df)
  #Generate y vector
  y<-dep
  print(head(y))
  #Fit lasso model
  reg.lasso<-glmnet(x,y,alpha=1)
  #Observe coefficients v lambda value
  print(plot(reg.lasso,xvar='lambda',label=TRUE))
  #Fit train CV
  cv.lasso<-cv.glmnet(x,y,alpha=1)
  #Observe MSE as function of lambda
  print(plot(cv.lasso))
  #Find lambda corresponding to min MSE
  l_lambda<-cv.lasso$lambda.min
  print(paste('LAMBDA MINIMIZES MSE AT:',l_lambda))
  #Capture results matrix
  res_mat<-predict(cv.lasso,type='coefficients',s=l_lambda)
  #Return df version
  return(data.frame(coef=summary(res_mat)$x,
                    row.names=rownames(res_mat)[summary(res_mat)$i]))
}

## Test Three Base Cluster Distance Measures  ##

print('***EVALUATING CLUSTER DISTANCE IN FULL EXPENDITURE PORTFOLIO SPACE***')
#Identify weight variables
wvars<-names(cd2)[grepl('w_',names(cd2))]
#Identify variables that should not be evaluated against cluster distance
no_eval<-c('dist_clust','dist_clust_bf','dist_clust_pca','dc_diff','dc_diff_bf','dc_diff_pca','cty','year','stcou','defl')
#Identify non-varying variables
nonvary<-c('nonres_rate','r_REV_REAL_ESTATE_TRANSFER_TAX')
#Define feature set
lasso_vars<-names(cd2)[!names(cd2) %in% c(no_eval,wvars,nonvary)]
lasso_rhs<-paste(lasso_vars,collapse='+')

##  Run models for base measure  ##

#Establish formulae
cd_f1<-as.formula(paste('dist_clust ~ ',lasso_rhs))
cd_f2<-as.formula(paste('dist_clust_bf ~ ',lasso_rhs))
cd_f3<-as.formula(paste('dist_clust_pca ~ ',lasso_rhs))
cd_f4<-as.formula(paste('dc_diff ~ ',lasso_rhs))
cd_f5<-as.formula(paste('dc_diff_bf ~ ',lasso_rhs))
cd_f6<-as.formula(paste('dc_diff_pca ~ ',lasso_rhs))

#Run LASSO on all five imputed sets
print('***LASSO EVAL - IMPUTATION 1***')
imp1<-lasso_func(cd2_mi$imputations$imp1,lasso_vars,cd_f1,cd2_mi$imputations$imp1$dist_clust)
print('***LASSO EVAL - IMPUTATION 2***')
imp2<-lasso_func(cd2_mi$imputations$imp2,lasso_vars,cd_f1,cd2_mi$imputations$imp2$dist_clust)
print('***LASSO EVAL - IMPUTATION 3***')
imp3<-lasso_func(cd2_mi$imputations$imp3,lasso_vars,cd_f1,cd2_mi$imputations$imp3$dist_clust)
print('***LASSO EVAL - IMPUTATION 4***')
imp4<-lasso_func(cd2_mi$imputations$imp4,lasso_vars,cd_f1,cd2_mi$imputations$imp4$dist_clust)
print('***LASSO EVAL - IMPUTATION 5***')
imp5<-lasso_func(cd2_mi$imputations$imp5,lasso_vars,cd_f1,cd2_mi$imputations$imp5$dist_clust)

#Write imputed sets to disk
write.csv(cd2_mi$imputations$imp1,file='/home/choct155/dissertation/TEL/ExpDiv/dist_clust_lasso_imp1.csv')
write.csv(cd2_mi$imputations$imp2,file='/home/choct155/dissertation/TEL/ExpDiv/dist_clust_lasso_imp2.csv')
write.csv(cd2_mi$imputations$imp3,file='/home/choct155/dissertation/TEL/ExpDiv/dist_clust_lasso_imp3.csv')
write.csv(cd2_mi$imputations$imp4,file='/home/choct155/dissertation/TEL/ExpDiv/dist_clust_lasso_imp4.csv')
write.csv(cd2_mi$imputations$imp5,file='/home/choct155/dissertation/TEL/ExpDiv/dist_clust_lasso_imp5.csv')



##  Collapse results into single DF ##
#Adjust column names for each imputed df
names(imp1)<-'imp1'
names(imp2)<-'imp2'
names(imp3)<-'imp3'
names(imp4)<-'imp4'
names(imp5)<-'imp5'
#Define a function to merge all of the DFs together by variable name
mi_lasso<-Reduce(function(a,b){
  temp<-merge(a,b,by='row.names',all=T)
  row.names(temp)<-temp[,'Row.names']
  temp[,!names(temp) %in% 'Row.names']
},list(imp1,imp2,imp3,imp4,imp5))
#Generate column wise means
mi_lasso$avg<-rowMeans(mi_lasso,na.rm=TRUE)
mi_lasso$avg_na<-rowMeans(mi_lasso)
#Create variable column
mi_lasso$var<-row.names(mi_lasso)
#Remove intercept
mi_lasso2<-mi_lasso[!rownames(mi_lasso) %in% '(Intercept)',]

##  Plot the average estimates across LASSO models  ##
lasso_avg<-ggplot(mi_lasso2,aes(x=reorder(var,avg),y=avg)) + 
                  geom_bar(stat='identity',fill='#FF0000') +
                  coord_flip() +
                  theme_bw() +
                  theme(text = element_text(size=6),legend.position="none") +
                  ylab('Coefficient') +
                  xlab('Variable')

ggsave('ExpDiv_Lasso_avg.svg')

## Define new function to run lasso on each imputed set and return predictive scores  ##

print('***DEFINING LASSO FUNCTION***')
lasso_func_pred<-function(df,vars,fmla,dep){
  #Generate X matrix
  x<-model.matrix(fmla,data=df)
  #Generate y vector
  y<-dep
  print(head(y))
  #Fit lasso model
  reg.lasso<-glmnet(x,y,alpha=1)
  #Observe coefficients v lambda value
  print(plot(reg.lasso,xvar='lambda',label=TRUE))
  #Fit train CV
  cv.lasso<-cv.glmnet(x,y,alpha=1)
  #Find lambda corresponding to min MSE
  l_lambda<-cv.lasso$lambda.min
  #Capture predicted values
  pred_y<-predict(cv.lasso,x,s=l_lambda)
  #Calculate R^2 as (1-SSE/SST)
  SSE<-sum((y-pred_y)**2)
  print(SSE)
  SST<-sum((y-mean(y))**2)
  print(SST)
  R2<-1-(SSE/SST)
  #Capture errors
  e=y-as.vector(pred_y)
  #Capture results matrix
  res_mat<-predict(cv.lasso,type='coefficients',s=l_lambda)
  #Return df version
  coefs=data.frame(coef=summary(res_mat)$x,
                    row.names=rownames(res_mat)[summary(res_mat)$i])
  #Return list of output
  output<-list('score'=R2,'oresp'=y,'presp'=as.vector(pred_y),'e'=e,'coef'=coefs)
  return(output)
}

## Capture scores and error information from LASSO models ##

#Create list of formulae and dependents
fmls<-c(cd_f1,cd_f2,cd_f3,cd_f4,cd_f5,cd_f6)
deps<-list(cd2_mi$imputations$imp1$dist_clust,
           cd2_mi$imputations$imp1$dist_clust_bf,
           cd2_mi$imputations$imp1$dist_clust_pca,
           cd2_mi$imputations$imp1$dc_diff,
           cd2_mi$imputations$imp1$dc_diff_bf,
           cd2_mi$imputations$imp1$dc_diff_pca)
deps_nm<-c('dist_clust','dist_clust_bf','dist_clust_pca','dc_diff','dc_diff_bf','dc_diff_pca')

#Create list to hold model results
pimp<-list()

#For each of six distance measures...
for (i in 1:6){
  print(paste('****',deps_nm[i],'****'))
  #...run LASSO on all five imputed sets
  print('***LASSO PREDICT - IMPUTATION 1***')
  pimp1<-lasso_func_pred(cd2_mi$imputations$imp1,lasso_vars,fmls[i][[1]],unlist(deps[i]))
  print('***LASSO PREDICT - IMPUTATION 2***')
  pimp2<-lasso_func_pred(cd2_mi$imputations$imp2,lasso_vars,fmls[i][[1]],unlist(deps[i]))
  print('***LASSO PREDICT - IMPUTATION 3***')
  pimp3<-lasso_func_pred(cd2_mi$imputations$imp3,lasso_vars,fmls[i][[1]],unlist(deps[i]))
  print('***LASSO PREDICT - IMPUTATION 4***')
  pimp4<-lasso_func_pred(cd2_mi$imputations$imp4,lasso_vars,fmls[i][[1]],unlist(deps[i]))
  print('***LASSO PREDICT - IMPUTATION 5***')
  pimp5<-lasso_func_pred(cd2_mi$imputations$imp5,lasso_vars,fmls[i][[1]],unlist(deps[i]))
  #...capture the results...
  res<-list(imp1=pimp1,imp2=pimp2,imp3=pimp3,imp4=pimp4,imp5=pimp5)
  pimp[[length(pimp)+1]]<-c(res)
  #...and rename the list element
  names(pimp)[length(pimp)]<-deps_nm[i]
}

#Plot error density for first imputation
lerror<-data.frame(pimp$dist_clust$imp1$e)
names(lerror)[1]<-'error'
lasso_error_density<-ggplot(lerror,aes(x=error))+geom_density(fill='red') +
                      theme(panel.background = element_rect(fill='white')) +
                      geom_vline(aes(xintercept=0),size=1) +
                      xlab('Residuals') + ylab('Density') + ggtitle('Distribution of LASSO Residuals - Full Portfolio (First Imputation)')
print(lasso_error_density)

#Capture scores across imputations for full portfolio distance space
#Initiate counter and series list
i=1
vs<-c()
#For each variable...
for (var in pimp){
  #...capture the scores in a DF...
  df_tmp<-data.frame(sapply(var,function(imp) imp$score))
  #...rename data series...
  names(df_tmp)<-deps_nm[i]
  #...and throw it in the list...
  vs<-c(vs,df_tmp)
  #iterate
  i=i+1
}

#Collapse into a single DF
var_scores<-data.frame(do.call('rbind',vs))
names(var_scores)<-c('imp1','imp2','imp3','imp4','imp5')

##  Plot scores by variable and imputation  ##

#Capture row names as a variable
var_scores$lab<-rownames(var_scores)
#Melt data
var_scoresm<-melt(var_scores)
names(var_scoresm)[2]<-'Imputation'
#Plot data
vs_plot<-ggplot(var_scoresm,aes(lab,value)) + geom_point(aes(colour=Imputation),size=5,alpha=.6) +
          theme(panel.background = element_rect(fill='white'),panel.grid.major = element_line(colour = "grey",linetype='dotted')) +
          xlab('Distance Measures') + ylab('Explained Variation') + ggtitle('LASSO Scores by Distance Measure and Imputation Set') +
          scale_x_discrete(labels=c("Full Portfolio\nLeading", "Regression Filtered\nLead", "PCA\nLead", "Full Portfolio", "Regression Filtered", "PCA"))
print(vs_plot)
ggsave('ExpDiv_Lasso_Scores_by_imp.svg')

## Define general implementation of coefficient consolidation by distance measure ##

coef_con<-function(var){
  #Adjust column names for each imputed df
  names(var$imp1$coef)<-'imp1'
  names(var$imp2$coef)<-'imp2'
  names(var$imp3$coef)<-'imp3'
  names(var$imp4$coef)<-'imp4'
  names(var$imp5$coef)<-'imp5'
  #Create new variable names
  var$imp1$coef$var<-row.names(var$imp1$coef)
  var$imp2$coef$var<-row.names(var$imp2$coef)
  var$imp3$coef$var<-row.names(var$imp3$coef)
  var$imp4$coef$var<-row.names(var$imp4$coef)
  var$imp5$coef$var<-row.names(var$imp5$coef)
  #Create list of coefficient DFs
  coef_dfs<-list(var$imp1$coef,
                 var$imp2$coef,
                 var$imp3$coef,
                 var$imp4$coef,
                 var$imp5$coef)
  #Define a function to merge all of the DFs together by variable name
  mi_lasso = Reduce(function(...) merge(..., by='var',all=T), coef_dfs)
  #Move variable names to row names
  rownames(mi_lasso)<-mi_lasso$var
  mi_lasso$var<-NULL
  #Generate column wise means
  mi_lasso$avg<-rowMeans(mi_lasso,na.rm=TRUE)
  mi_lasso$avg_na<-rowMeans(mi_lasso)
  #Create variable column
  mi_lasso$var<-row.names(mi_lasso)
  #Remove intercept
  mi_lasso2<-mi_lasso[!rownames(mi_lasso) %in% '(Intercept)',]
  #Return
  return(mi_lasso2)
}

coef_con(pimp$dist_clust)[,c('avg_na','var')]


#Capture average coefficient estimates for each distance measure
coef_by_var<-list()
i=1
#For each variable...
for (var in pimp){
  print(deps_nm[i]) 
  #...capture the average coefficient estimate (across imputed sets) and variable name....
  coef_tmp<-coef_con(var)[,c('avg_na','var')]
  #print(coef_tmp)
  #...change the name to match the variable...
  names(coef_tmp)[1]<-deps_nm[i]
  #...and throw it in the list....
  coef_by_var[[length(coef_by_var)+1]]<-coef_tmp
  i=i+1
}

#Capture all average coefficient estimates in one DF
coef_est_tmp<-Reduce(function(...) merge(..., by='var',all=T), coef_by_var)

#Keep only those coefficients that mattered in at least one model
coef_est_tmp2<-coef_est_tmp[rowSums(is.na(coef_est_tmp))<6,]

#Sort by dist_clust
#coef_est<-coef_est_tmp2[order(dist_clust,dist_clust_bf,dist_clust_pca),]
coef_est<-coef_est_tmp2[order(coef_est_tmp2$dist_clust,coef_est_tmp2$dist_clust_bf,coef_est_tmp2$dist_clust_pca),]

#Create an order variable
coef_est$order<-as.factor(seq(1,nrow(coef_est)))

#Push var to row names
#row.names(coef_est)<-coef_est$var
#coef_est$var<-NULL

#Capture score sizes
score_size<-data.frame(apply(var_scores[,c(1,2,3,4)],1,mean)*500+1)

#Melt data and assign size values
coef_estm<-melt(coef_est)
coef_estm$size<-NA

#Assign size values
for (var in deps_nm){
  coef_estm[coef_estm$variable==var,]$size<-score_size[var,]  
}

#Plot data
coef_plot<-ggplot(coef_estm,aes(order,value)) + geom_point(aes(colour=variable),size=5,alpha=.5) + coord_flip() +
            theme(panel.background = element_rect(fill='white'),
                  panel.grid.major = element_line(colour = "grey",linetype='dotted'),
                  axis.text.x = element_text(angle = 90, hjust = 1,face='bold'),
                  text = element_text(size=6)) +
            xlab('Variables') + ylab('Coefficient Estimate') + #ggtitle('LASSO Coefficients by Variable and Distance Measure') +
            scale_x_discrete(labels=coef_est$var) + 
            scale_colour_brewer(palette='Set1') +
            geom_vline(aes(xintercept=c(1,2,3,4,5,6)),colour='black',linetype='dotted') +
            geom_vline(aes(xintercept=c(49,50,51,52,53,54)),colour='black',linetype='dotted')
            
print(coef_plot)
ggsave('ExpDiv_lasso_coef_by_dist.svg')

