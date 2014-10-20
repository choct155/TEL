###Imputation

#This script will just serve as a simple collection of methods that are useful for imputation.
#Perhaps it will grow over time, but we will start with some very simple routines for
#interpolation (because I don't like the default pandas interpolation behavior outside
#of the interpolation support boundary) and extrapolation.  The initial applications will because
#quite specific, so future generalization is a likely outcome.

import numpy as np
import pandas as pd
from pandas import Series, DataFrame
from scipy.interpolate import interp1d

##interpolation

#The motivation for this routine is the filling in of CenStats data, which is only periodically
#observed.  We want some means of filling in values with zero additional priors (beyond sparse
#observation).  I have interpreted this uninformative prior to mean equally weighted annual increments
#between two given observed sentinel values (as opposed to assuming variable impact of given years
#on the aggregate interval trend).  Note that these data are not missing at random, and patterns of
#missingness are quite prevalent.  This hinders more complicated estimation of missing values based
#upon other observed variables in the same time period.  When we use the linear interpolation method,
#the implicit assumption is that these complications cannot be overcome given the patterns of
#missingness.

#The following function uses the 1-D interpolation routine from SciPy (which generates an interpolation
#object based upon available observations and associated support values).

def series_interp(ser):
  '''Returns an interpolated array without that pesky forward fill that seems
  to be the default behavior in pandas'''
  #Capture non-null components of series
  ser_nnull=ser[ser.notnull()]
  #Capture available values
  y=ser_nnull.values
  #Capture corresponding support values
  x=ser_nnull.index.get_level_values(level='year').values
  #Capture full range boundaries
  xfr_min=ser.index.get_level_values(level='year').values.min()
  xfr_max=ser.index.get_level_values(level='year').values.max()
  print xfr_min,xfr_max
  #Generate an output array
  #TEST
  out_arr=np.array([np.NaN]*(xfr_max-xfr_min+1))
  #If there are 2 or more values in the input Series...
  if len(y)>1:
    print x,y
    #Instantiate interpolation object
    xy_i=interp1d(x,y)
    #For each year in the study period...
    for i,val in enumerate(np.linspace(xfr_min,xfr_max,xfr_max-xfr_min+1)):
      #...if the support year is in the non-null support interval...
      if (val>=x.min()) & (val<=x.max()):
        #...assign an interpolated value...
        out_arr[i]=xy_i(val)
      else:
        #...otherwise, leave that position as a missing value
        out_arr[i]=np.NaN
    return out_arr
  elif len(y)==1:
    #...if there is only one value, distribute it across all years
    return np.array([y]*(xfr_max-xfr_min+1))
  else:
    return None



##Extrapolation

#The motivation for an extrapolation routine comes from the fact that we left values outside of
#the interpolation support alone in the *series_interp()* method.  This extrapolation routine seeks
#to interpret the estimation prior as being the typical behavior of the Series in question.
#Using the average over the interpolation support range would get us closer, but it would be vulnerable
#to outliers.  This would suggest using the median annual over the growth period to extrapolate
#(on both the front and back ends).  The danger here, of course, is the possibility of a dynamic
#process.  Kinks in the interpolation range provide standing for such concerns, but they may also
#represent volatility in a longer trend.  In using the median, we are assuming that we can chalk
#these up to volatility.

def series_extrap(ser):
  '''Function returns an array that extrapolates median growth through the missing values on
  the front and back ends of the input Series'''
  #Calculate median growth over the interpolation support period
  delta=ser.pct_change().median()
  #Identify min and max interpolation support years
  min_yr=ser[ser.notnull()].index.get_level_values(level='year').values.min()
  max_yr=ser[ser.notnull()].index.get_level_values(level='year').values.max()
  #Identify min and max years in the full range for the study period
  min_fr_yr=ser.index.get_level_values(level='year').values.min()
  max_fr_yr=ser.index.get_level_values(level='year').values.max()
  #Generate an output array
  out_arr=np.array([np.NaN]*(max_fr_yr-min_fr_yr+1))
  #For each year in the study period...
  for i,yr in enumerate(np.linspace(min_fr_yr,max_fr_yr,max_fr_yr-min_fr_yr+1)):
    #...if the year is before the minimum support year...
    if yr<min_yr:
      #...extrapolate backwards from the min support year...
      out_arr[i]=DataFrame(ser).xs(min_yr,level='year').values[0][0]*(1+((yr-min_yr)*delta))
    #...if the year is in the interpolation support period...
    elif yr<max_yr:
      #...don't mess with the value...
      out_arr[i]=DataFrame(ser).xs(yr,level='year').values[0][0]
    #...otherwise we are over the max year...
    else:
      #...so extrapolate forward from the max support year...
      out_arr[i]=DataFrame(ser).xs(max_yr,level='year').values[0][0]*(1+((yr-max_yr)*delta))
  return out_arr
