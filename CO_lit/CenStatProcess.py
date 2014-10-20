#Processing of [CenStats Data](http://www2.census.gov/prod2/statcomp/usac/zip/)

#In CenStatAcquire, we grabbed all of the CenStats data from the Census and stored it locally.
#In CenStatStandardize, we released the data from Excel and consolidated into a single dataset,
#`censtat_raw.csv`.  In CenStatSub, we reduced the size of the set by restricting ourselves to
#only the data values from counties in Colorado (and integrated an index to facilitate data slicing).
#In this script, we need to impute missing data.  Our vehicles for this will be simple functions
#for interpolation and extrapolation.

import numpy as np
import pandas as pd
from pandas import Series, DataFrame
from scipy.interpolate import interp1d
import imputation as imp
import sys
import inspect

##Read data

#Establish working directory
workdir='/home/choct155/dissertation/MiscData/Census/CenStats/'

#Read in data
csub=pd.read_csv(workdir+'censtats_co_sub.csv')

#Reconvert lcon back to string
csub['lcon']=csub['lcon'].apply(lambda x: str(x).zfill(3))

print csub.head()

##Accounting for All Years in Study Period

#Now we need to stretch the data to cover the period in question (1993-2009).
#In practice, this means a reindex operation for each intersection of county,
#high-level concept, and low-level concept.  The rows corresponding to new years
#will contain missing values, which we will later have to impute.  To capture
#the set of intersections, we can leverage the fact that a MultiIndex can be
#thought of as a list of tuples.

#Although we do not need them yet, eventually we will want to map county and
#variable names back into the mix, so let's make some dicts upfront.

#Create mapping dicts
var_map=dict(zip(csub.apply(lambda x: x['hcon']+x['lcon']+str(x['year']),axis=1),
                 csub['var']))
cty_map=dict(zip(csub['stcou'],csub['cty']))

#Set index
csub.set_index(['stcou','year','hcon','lcon'],inplace=True)

#Sort index
csub.sortlevel(0,inplace=True)

#Drop unnecessary variables
csub.pop('Unnamed: 0')
csub.pop('cty')
csub.pop('var')

#Grab list of tuples from MultiIndex
ind_list=list(csub.index)

#Convert to set that contains only the 1st, 3rd, and 4th tuple positions
sub_ind_set=list(set([(tup[0],tup[2],tup[3]) for tup in ind_list]))

#Create container for reindexed cross-sections
xs_list=[]

#For each intersection...
for cut in sub_ind_set:
  #...capture the reindexed subset...
  try:
    ri_sub=csub.xs((cut[0],cut[1],cut[2]),\
                    level=('stcou','hcon','lcon')).\
                    reindex(range(1990,2010)).\
                    reset_index().rename(columns={'index':'year'})
  except:
    #...(apparently there are some duplicates)...
    ri_sub=csub.xs((cut[0],cut[1],cut[2]),\
                    level=('stcou','hcon','lcon')).iloc[0].\
                    reindex(range(1990,2010)).\
                    reset_index().rename(columns={'index':'year'})
  #...reintegrate cross-section variables...
  ri_sub['stcou']=cut[0]
  ri_sub['hcon']=cut[1]
  ri_sub['lcon']=cut[2]
  #...throw index variables back into the index...
  ri_sub.set_index(['stcou','hcon','lcon','year'],inplace=True)
  #...explicitly set column name to 'val'...
  ri_sub.columns=['val']
  #...and throw it in the list (while moving year to the last index position)
  xs_list.append(ri_sub.astype(float))


print xs_list[0].head()
for i,xs in enumerate(xs_list):
  if (xs.columns != xs_list[0].columns).all():
    print i
  else:
    pass
print xs_list[213514].columns
#Now that we have a list of year-expanded subsets, we need to interpolate where
#possible.  Interpolation is possible when a given missing value rests inside
#of two non-null values.  Extrapolation, on the other hand, will be a separate
#process.  We have already crafted a function that takes each intersection series and
#returns an array with linearly interpolated values included.  It resides in the
#**imputation** module.

#With this function, we can generate interpolated versions of the data for each
#subset defined as the intersection of county, high-level concept, and low-level
#concept.

#Create container to capture problem sub index positions
prob_sub_idx=[]

#For each subset...
for i,sub in enumerate(xs_list):
  #...generate an interpolated version of the data
  try:
    sub['val_i']=Series(imp.series_interp(sub['val']),index=sub.index)
  except:
    print sys.exc_info()
    prob_sub_idx.append(i)

print xs_list[4]
print xs_list[4].columns
print xs_list[4][xs_list[4]['val'].notnull()]

print prob_sub_idx[:5]
print len(np.array([1]))
help(imputation.series_interp)

print imp.series_interp(xs_list[4]['val'])
print help(imp.series_interp)
print inspect.getsourcelines(imp.series_interp)