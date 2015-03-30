###############################################################
### TELs AND REVENUE IN COLORADO
###
### This script captures the analysis housed in the revenue
### chapter of my dissertation.  This analysis was previously
### captured in various forms in the following Notebooks:
###
###		1. CO_TEL_convergence.ipynb
### 	2. TEL_converge_recession.ipynb
###
### The commentary that accompanies the decisions made can
### be found in said Notebooks.
###
### This will be a modularized implementation to facilitate
### modification and portability.  The data used were captured
### in CO_CTY_DATA.ipynb.
###############################################################

#Import relevant libraries
import numpy as np
import pandas as pd
from pandas import Series, DataFrame
from IPython.display import HTML
import pandas.io.data as web
import pysal
import seaborn as sb
from statsmodels.graphics.gofplots import *

################
###DATA INPUT###
################

#Establish working directory
workdir='/home/choct155/projects/gdrive_data/Google Drive/Dissertation/Data/spatial/US/'

#Read in data set that contains fiscal and spatial attributes
co_sf=pd.read_csv(workdir+'CO_sf.csv')

#Read in demographic data collected by CO Dept of Local Affairs
co_dem=pd.read_csv(workdir+'CO_cty_profile.csv',delimiter='\t')

#Rename columns
co_dem.columns=['AUDIT_YEAR','FNAME','var','value']
