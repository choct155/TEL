### Expenditure Divergence - Panel Models
###
### CREATED: December 23, 2014
###
### LAST MODIFIED: December 23, 2014
###
### INPUT: Data prepared for modeling in the Expenditure Divergence analysis (Chapter 5).
### OUTPUT: Panels estimation results

##  Load applicable libraries ##

#Spatial econometrics
library(plm)
#Visualization
library(ggplot2)
#Reporting
library(stargazer)

##  Read in data ##

#Establish working directory
workdir<-'/home/choct155/dissertation/TEL/ipynb/'
#Read in data
data<-read.csv(paste(workdir,'h1_exp_model_in.csv',sep=''))
#Rename a few variables
names(data)[1]<-'cty'
names(data)[2]<-'year'
names(data)[12]<-'exp_total'

##  Convert to pdata.frame ##
pdata<-pdata.frame(data,index=c('cty','year'),drop.index=TRUE,row.names=TRUE)

pdata$ldist_clust<-lag(pdata$dist_clust)


##  Define Model Specifications ##
tot<-dist_clust ~ pop_growth + pcintgov + pcrev + pcap_q + prop_ratio + lag(intensity_stock)
tot<-dist_clust ~ exp_total + pop_growth + pcintgov + pcrev + pcap + prop_ratio + intensity_stock + exp_intensity
bvf<-dist_clust_bf ~ exp_total + pop_growth + pcintgov + pcrev + pcap + prop_ratio + intensity_stock + exp_intensity
pca<-dist_clust_pca ~ exp_total + pop_growth + pcintgov + pcrev + pcap + prop_ratio + intensity_stock + exp_intensity

totd<-dist_clust ~ pop_growth + pcintgov + pcrev + pcap_q + prop_ratio + lag(intensity_stock) + lag(dist_clust)
bvfd<-dist_clust_bf ~ exp_total + pop_growth + pcintgov + pcrev + pcap + prop_ratio + intensity_stock + exp_intensity
pcad<-dist_clust_pca ~ exp_total + pop_growth + pcintgov + pcrev + pcap + prop_ratio + intensity_stock + exp_intensity

##  Set up test models ##
test_fe<-plm(tot,data=pdata,model='within')
test_fe2<-plm(tot,data=pdata,model='within',effect='twoways')
test_pool<-plm(tot,data=pdata,model='pooling')
test_fd<-plm(tot,data=pdata,model='fd')
test_between<-plm(tot,data=pdata,model='between')
test_re<-plm(tot,data=pdata,model='random')

bvf_fe<-plm(bvf,data=pdata,model='within')
bvf_fe2<-plm(bvf,data=pdata,model='within',effect='twoways')
bvf_pool<-plm(bvf,data=pdata,model='pooling')
bvf_fd<-plm(bvf,data=pdata,model='fd')
bvf_between<-plm(bvf,data=pdata,model='between')
bvf_re<-plm(bvf,data=pdata,model='random')

pca_fe<-plm(pca,data=pdata,model='within')
pca_fe2<-plm(pca,data=pdata,model='within',effect='twoways')
pca_pool<-plm(pca,data=pdata,model='pooling')
pca_fd<-plm(pca,data=pdata,model='fd')
pca_between<-plm(pca,data=pdata,model='between')
pca_re<-plm(pca,data=pdata,model='random')

test_fe<-plm(tot,data=pdata,model='within')
test_fe2<-plm(tot,data=pdata,model='within',effect='twoways')
test_pool<-plm(tot,data=pdata,model='pooling')
test_fd<-plm(tot,data=pdata,model='fd')
test_between<-plm(tot,data=pdata,model='between')
test_re<-plm(tot,data=pdata,model='random')

testd_fe<-plm(totd,data=pdata,model='within')

##  Capture residuals from test models  ##
res_fe<-data.frame(attr(test_fe$model,"index"),test_fe$resid)
res_pool<-data.frame(attr(test_pool$model,"index"),test_pool$resid)

##  Plot residuals  ##
res_fe_plot_yr<-ggplot(res_fe,aes(factor(year),test_fe.resid))+geom_boxplot(aes(fill=year)) +
                  theme(legend.position="none") +
                  theme(panel.background = element_rect(fill='white')) +
                  geom_hline(aes(yintercept=0),size=1) +
                  xlab('Year') + ylab('Residuals') + ggtitle('Fixed Effect Residuals by Year')
res_fe_plot_cty<-ggplot(res_fe,aes(factor(cty),test_fe.resid))+geom_boxplot(aes(fill=cty)) + 
                  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
                  theme(legend.position="none") +
                  theme(panel.background = element_rect(fill='white')) +
                  geom_hline(aes(yintercept=0),size=1) +
                  xlab('County') + ylab('Residuals') + ggtitle('Fixed Effect Residuals by County')
res_fe_density<-ggplot(res_fe,aes(x=test_fe.resid))+geom_density(fill='red') +
                  theme(panel.background = element_rect(fill='white')) +
                  geom_vline(aes(xintercept=0),size=1) +
                  xlab('Residuals') + ylab('Density') + ggtitle('Distribution of Fixed Effect Residuals')

res_pool_plot_yr<-ggplot(res_pool,aes(factor(year),test_pool.resid))+geom_boxplot(aes(fill=year)) +
  theme(legend.position="none") +
  theme(panel.background = element_rect(fill='white')) +
  geom_hline(aes(yintercept=0),size=1) +
  xlab('Year') + ylab('Residuals')# + ggtitle('Pooled Residuals by Year')
res_pool_plot_cty<-ggplot(res_pool,aes(factor(cty),test_pool.resid))+geom_boxplot(aes(fill=cty)) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  theme(legend.position="none") +
  theme(panel.background = element_rect(fill='white')) +
  geom_hline(aes(yintercept=0),size=1) +
  xlab('County') + ylab('Residuals') #+ ggtitle('Pooled Residuals by County')
res_pool_density<-ggplot(res_pool,aes(x=test_pool.resid))+geom_density(fill='red') +
  theme(panel.background = element_rect(fill='white')) +
  geom_vline(aes(xintercept=0),size=1) +
  xlab('Residuals') + ylab('Density') + ggtitle('Distribution of Pooled Residuals')

print(res_fe_density)
ggsave('ExpDiv_res_fe_density.svg')

print(res_pool_density)
ggsave('ExpDiv_res_pool_density.svg')

print(res_pool_plot_yr)
ggsave('ExpDiv_res_pool_plot_yr.svg')

print(res_pool_plot_cty)
ggsave('ExpDiv_res_pool_plot_cty.svg')

attr(test_fe$model,"index")

##  Test poolability (h0: coefficients are the same for all entities)  ##
print('H0: Coefficients are identical across counties...')
print(pooltest(plm(tot,data=pdata),pvcm(tot,data=pdata,model='within')))

##  Test for the existence of county and year effects  ##
print(plmtest(tot,data=pdata,effect='twoways'))

##  Test for presence of fixed or random effects ##
#print(phtest(test_fe,test_re))
#Fails > computationally singular

##  Test for serial correlation ##
print(pbgtest(test_fe,order=10))

#Capture distributions of distance measures (requires new DF with stacked values)
dist_list<-list(data.frame(Measure=pdata$dist_clust,Space='Full'),
                data.frame(Measure=pdata$dist_clust_bf,Space='RegFilt'),
                data.frame(Measure=pdata$dist_clust_pca,Space='PCA'))
dist_stack<-do.call('rbind',dist_list)

dist_distr<-ggplot(dist_stack,aes(x=Measure)) + 
              geom_density(aes(fill=Space),alpha=.5) +
              theme(panel.background = element_rect(fill='white'))
print(dist_distr)
ggsave('ExpDiv_Dist_Distributions.svg')

#Create LaTeX output tables
stargazer(test_pool,bvf_pool,pca_pool,no.space=TRUE)
stargazer(test_fe,bvf_fe,pca_fe,no.space=TRUE)
stargazer(test_fe2,bvf_fe2,pca_fe2,no.space=TRUE)
