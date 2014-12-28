### Expenditure Divergence - Spatial Lag Model
###
### CREATED: December 23, 2014
###
### LAST MODIFIED: December 23, 2014
###
### INPUT: Data prepared for modeling in the Expenditure Divergence analysis (Chapter 5).
### OUTPUT: SL estimation results

##  Load applicable libraries ##

#Manipulation of spatial data
library(spdep)
library(raster)
library(maptools)
#Spatial econometrics
library(splm)
#Visualization
library(ggplot2)

##  Read in flat and spatial data ##

#Establish working directory
workdir<-'/home/choct155/dissertation/TEL/ipynb/'
#Read in data
data<-read.csv(paste(workdir,'h1_exp_model_in.csv',sep=''))
#Rename a few variables
names(data)[1]<-'NAME'
names(data)[2]<-'year'
names(data)[12]<-'exp_total'
#Read in CO shapefile
c<-readShapeSpatial('/home/choct155/Google Drive/Dissertation/Data/spatial/US/co_county.shp',IDvar='NAME')
#Set projection (from docs)
projection(c)<-'+proj=longlat +datum=NAD83'
##Convert to nb object
c_nb<-poly2nb(c)
#Convert to listw object
c_lw<-nb2listw(c_nb)
#Validate correspondence in dimensions of flat and shape data
print(paste('County Count Equivalent:',length(c_lw$weights)==dim(data[which(data$year==2000),])[1]))

##  Define Model Specifications ##
tot<-dist_clust ~ exp_total + pop_growth + pcintgov + pcrev + pcap + prop_ratio + intensity_stock + exp_intensity
bvf<-dist_clust_bf ~ exp_total + pop_growth + pcintgov + pcrev + pcap + prop_ratio + intensity_stock + exp_intensity
pca<-dist_clust_pca ~ exp_total + pop_growth + pcintgov + pcrev + pcap + prop_ratio + intensity_stock + exp_intensity

tot2<-dist_clust ~ pop_growth + pcintgov + pcrev + pcap_q + prop_ratio + intensity_stock
bvf2<-dist_clust_bf ~ pop_growth + pcintgov + pcrev + pcap_q + prop_ratio + intensity_stock
pca2<-dist_clust_pca ~ pop_growth + pcintgov + pcrev + pcap_q + prop_ratio + intensity_stock

tot3<-dist_clust ~ pcintgov + pcrev + pcap_q + prop_ratio + intensity_stock
bvf3<-dist_clust_bf ~ pcintgov + pcrev + pcap_q + prop_ratio + intensity_stock
pca3<-dist_clust_pca ~ pcintgov + pcrev + pcap_q + prop_ratio + intensity_stock

mlist2<-list(tot2,bvf2,pca2)
mlist3<-list(tot3,bvf3,pca3)

## Fit and Estimate SLM ##

#Define function to capture model coef and standard error by year and dependent
slm<-function(ml,yr){
  #Fit and estimate models
  fp<-lagsarlm(ml[[1]],data=data[which(data$year==yr),],c_lw)
  bf<-lagsarlm(ml[[2]],data=data[which(data$year==yr),],c_lw)
  pca<-lagsarlm(ml[[3]],data=data[which(data$year==yr),],c_lw)
  #Capture model components
  df1<-data.frame(Variable=attr(summary(fp)$coefficients,'names'),
                  Coefficient=fp$coefficients,
                  SE=fp$rest.se,
                  Model='Full Portfolio')
  df2<-data.frame(Variable=attr(summary(bf)$coefficients,'names'),
                  Coefficient=bf$coefficients,
                  SE=bf$rest.se,
                  Model='Regression Filtered')
  df3<-data.frame(Variable=attr(summary(pca)$coefficients,'names'),
                  Coefficient=pca$coefficients,
                  SE=pca$rest.se,
                  Model='Principal Components')
  #Consolidate results into single frame
  df<-data.frame(rbind(df1,df2,df3))
  #Reintegrate year
  df$Year<-yr
  #Return output df
  return(df)
}

test<-rbind(slm(2000),slm(2001))

#Evaluate SLM for all three models over the 1993-2009 range
slm_dfs<-list()
for (yr in 1993:2001){
  print(yr)
  slm_tmp<-slm(mlist2,yr)
  slm_dfs[[length(slm_dfs)+1]]<-slm_tmp
}
for (yr in 2002:2009){
  print(yr)
  slm_tmp<-slm(mlist3,yr)
  slm_dfs[[length(slm_dfs)+1]]<-slm_tmp
}

#Row bind all results dfs
res_df<-do.call('rbind',slm_dfs)

# Specify the width of your confidence intervals
interval1 <- -qnorm((1-0.9)/2)  # 90% multiplier
interval2 <- -qnorm((1-0.95)/2)  # 95% multiplier

res_plot<-ggplot(res_df,aes(colour=Model)) +
            geom_hline(yintercept=0,colour=gray(1/2),lty=2) +
            geom_linerange(aes(x=Variable,
                               ymin = Coefficient - SE*interval1,
                               ymax=Coefficient + SE*interval1),
                           lwd=1,
                           position=position_dodge(width=1/2)) +
            geom_pointrange(aes(x=Variable,y=Coefficient,
                                ymin=Coefficient - SE*interval2,
                                ymax=Coefficient + SE*interval2),
                            lwd=1/2,
                            position=position_dodge(width = 1/2),
                            shape=21,
                            fill="WHITE") +
            coord_flip() + theme_bw() + facet_wrap(~ Year)

print(res_plot)