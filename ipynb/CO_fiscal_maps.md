Mapping Colorado Fiscal Activity by County (1987-2009)
========================================================

This script is a support script of sorts for the primary IPython Notebook *CO_county_fin*.  I am doing the actual mapping separately because, for some unknown reason, I am no longer able to call th **[rgdal](http://crantastic.org/packages/rgdal)** library in the Notebook, even though I can still call it here (in RStudio).

In any event, the problem that I was working on was how to associate several years of data with the same spatial information.  To state the problem more explicitly, even though we aren't plotting all of it, the full set contains 35 years of information.  Thus, the dataset is now 35 times the size of the data that was removed from the shapefile in the first place.  Since I want to use **[ggplot2](http://ggplot2.org/)** to make cool looking maps, I will not be using the spatio-temporal capability of the **[spacetime](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=2&ved=0CDcQFjAB&url=http%3A%2F%2Fcran.r-project.org%2Fweb%2Fpackages%2Fspacetime%2Fvignettes%2Fjss816.pdf&ei=vrZBUunhAbb_4APjwoCwCg&usg=AFQjCNEtZPUEGwHgQYpqRYOYYGvlZUAdFw&sig2=4H81oEVeshYJykwFmM4CeA&bvm=bv.52434380,d.dmg)** package nor its associated plotting functions.  Rather, I will be using the methods described in a great [Stack Overflow response](http://stackoverflow.com/questions/9186529/grid-with-choropleth-maps-in-ggplot2) to a question about choropleth map grids.

First, we need to read in the merged data and the shapefile.

```r
library(maptools)
```

```
## Loading required package: foreign
```

```
## Loading required package: sp
```

```
## Loading required package: grid
```

```
## Loading required package: lattice
```

```
## Checking rgeos availability: TRUE
```

```r
library(gpclib)
```

```
## General Polygon Clipper Library for R (version 1.5-5) Type 'class ?
## gpc.poly' for help
```

```r
library(sp)
library(ggmap)
```

```
## Loading required package: ggplot2
```

```r
library(rgdal)
```

```
## rgdal: version: 0.8-11, (SVN revision 479M) Geospatial Data Abstraction
## Library extensions to R successfully loaded Loaded GDAL runtime: GDAL
## 1.10.0, released 2013/04/24 Path to GDAL shared files:
## /usr/share/gdal/1.10 Loaded PROJ.4 runtime: Rel. 4.8.0, 6 March 2012,
## [PJ_VERSION: 480] Path to PROJ.4 shared files: (autodetected)
```

```r
library(raster)
library(ggplot2)
library(plyr)

# Read in fiscal data
cgg <- read.csv("/home/choct155/Google Drive/Dissertation/Data/CO_county_ggfin.csv")

# Read in county shapefile
us <- readShapeSpatial("/home/choct155/Google Drive/Dissertation/Data/spatial/US/tl_2012_us_county.shp")
projection(us) <- "+proj=longlat +datum=NAD83"

# Subset to Colorado
co <- us[us$STATEFP == "08", ]

# Inspect both sets
print(summary(cgg))
```

```
##        X                     NAME_x       AUDIT_YEAR     LGTYPE_ID    
##  Min.   :   0   Adams County    :  35   Min.   :1975   Min.   : 1.00  
##  1st Qu.: 560   Alamosa County  :  35   1st Qu.:1983   1st Qu.: 1.00  
##  Median :1120   Arapahoe County :  35   Median :1992   Median : 1.00  
##  Mean   :1120   Archuleta County:  35   Mean   :1992   Mean   : 3.02  
##  3rd Qu.:1679   Baca County     :  35   3rd Qu.:2001   3rd Qu.: 1.00  
##  Max.   :2239   Bent County     :  35   Max.   :2009   Max.   :70.00  
##                 (Other)         :2030                                 
##      LG_ID          REV_TOTAL        REV_TOTAL_TAX      REV_PROPERTY_TAX  
##  Min.   :   997   Min.   :9.38e+05   Min.   :3.18e+05   Min.   :0.00e+00  
##  1st Qu.: 25964   1st Qu.:6.58e+06   1st Qu.:2.01e+06   1st Qu.:1.59e+06  
##  Median : 50893   Median :1.21e+07   Median :4.52e+06   Median :3.20e+06  
##  Mean   : 59316   Mean   :5.16e+07   Mean   :2.70e+07   Mean   :1.46e+07  
##  3rd Qu.: 79254   3rd Qu.:2.39e+07   3rd Qu.:1.18e+07   3rd Qu.:7.94e+06  
##  Max.   :255287   Max.   :1.48e+09   Max.   :8.99e+08   Max.   :2.69e+08  
##                                                                           
##    REV_SO_TAX       REV_SALES_USE_TAX  REV_OCCUPATION_TAX
##  Min.   :       0   Min.   :0.00e+00   Min.   :       0  
##  1st Qu.:  171430   1st Qu.:0.00e+00   1st Qu.:       0  
##  Median :  344152   Median :2.78e+05   Median :       0  
##  Mean   : 1383822   Mean   :9.28e+06   Mean   :  665490  
##  3rd Qu.:  766507   3rd Qu.:2.08e+06   3rd Qu.:       0  
##  Max.   :19441491   Max.   :5.50e+08   Max.   :55721565  
##                                                          
##  REV_FRANCHISE_TAX  REV_OTHER_TAX      REV_LODGING_TAX   
##  Min.   :   -4626   Min.   : -281416   Min.   :       0  
##  1st Qu.:       0   1st Qu.:    4409   1st Qu.:       0  
##  Median :       0   Median :   19447   Median :       0  
##  Mean   :  450188   Mean   :  655165   Mean   :  252087  
##  3rd Qu.:       0   3rd Qu.:   73184   3rd Qu.:       0  
##  Max.   :37042845   Max.   :82994068   Max.   :53573193  
##                                                          
##  REV_REAL_ESTATE_TRANSFER_TAX REV_UNCLASS_TAX  REV_LICENSES     
##  Min.   :0                    Min.   :    0   Min.   :       0  
##  1st Qu.:0                    1st Qu.:    0   1st Qu.:    5843  
##  Median :0                    Median :    0   Median :   59760  
##  Mean   :0                    Mean   :   37   Mean   :  789369  
##  3rd Qu.:0                    3rd Qu.:    0   3rd Qu.:  443435  
##  Max.   :0                    Max.   :82276   Max.   :30403538  
##                                                                 
##   REV_CHARGES         REV_FINES        REV_TRANSFER_IN   
##  Min.   :0.00e+00   Min.   :    -622   Min.   :       0  
##  1st Qu.:3.28e+05   1st Qu.:       0   1st Qu.:       0  
##  Median :7.48e+05   Median :       0   Median :       0  
##  Mean   :4.63e+06   Mean   :  489204   Mean   :   48751  
##  3rd Qu.:2.56e+06   3rd Qu.:   18969   3rd Qu.:       0  
##  Max.   :1.81e+08   Max.   :44863000   Max.   :11618191  
##                                                          
##   REV_INTGOVT          REV_HUT         REV_CIGARETTE_TAX 
##  Min.   :5.04e+05   Min.   :       0   Min.   :       0  
##  1st Qu.:2.86e+06   1st Qu.: 1066872   1st Qu.:    2277  
##  Median :5.29e+06   Median : 1826310   Median :    8343  
##  Mean   :1.56e+07   Mean   : 2574602   Mean   :  139751  
##  3rd Qu.:9.24e+06   3rd Qu.: 2685575   3rd Qu.:   40223  
##  Max.   :4.11e+08   Max.   :29875498   Max.   :17075875  
##                                                          
##  REV_MOTOR_VEH_FEE    REV_CTF        REV_SOCIAL_SERVICE ALL_OTHER_INTGOVT 
##  Min.   :      0   Min.   :      0   Min.   :0.00e+00   Min.   :1.08e+04  
##  1st Qu.:  19901   1st Qu.:      0   1st Qu.:5.09e+05   1st Qu.:6.99e+05  
##  Median :  47081   Median :  28518   Median :1.29e+06   Median :1.46e+06  
##  Mean   : 157562   Mean   : 166400   Mean   :7.14e+06   Mean   :5.42e+06  
##  3rd Qu.: 116767   3rd Qu.:  83784   3rd Qu.:3.71e+06   3rd Qu.:3.26e+06  
##  Max.   :6389205   Max.   :6587150   Max.   :1.70e+08   Max.   :2.36e+08  
##                                                                           
##     REV_MISC          REV_INTEREST        EXP_TOTAL       
##  Min.   :  -290237   Min.   : -362074   Min.   :9.66e+05  
##  1st Qu.:   300279   1st Qu.:  133137   1st Qu.:6.36e+06  
##  Median :   644743   Median :  297773   Median :1.21e+07  
##  Mean   :  3040774   Mean   : 1637245   Mean   :5.30e+07  
##  3rd Qu.:  1638337   3rd Qu.:  893140   3rd Qu.:2.39e+07  
##  Max.   :122314826   Max.   :59665131   Max.   :1.86e+09  
##                                                           
##  EXP_TOTAL_OPERATING  EXP_GEN_GOVT       EXP_JUDICIAL     
##  Min.   :8.74e+05    Min.   :3.34e+05   Min.   :       0  
##  1st Qu.:5.34e+06    1st Qu.:1.13e+06   1st Qu.:   54997  
##  Median :9.37e+06    Median :2.19e+06   Median :  163647  
##  Mean   :4.13e+07    Mean   :8.38e+06   Mean   : 1394563  
##  3rd Qu.:1.86e+07    3rd Qu.:4.69e+06   3rd Qu.:  487680  
##  Max.   :1.22e+09    Max.   :2.65e+08   Max.   :38502690  
##                                                           
##  EXP_TOTAL_PUBLIC_SAFETY   EXP_POLICE          EXP_FIRE       
##  Min.   :3.43e+04        Min.   :0.00e+00   Min.   :0.00e+00  
##  1st Qu.:4.66e+05        1st Qu.:3.95e+05   1st Qu.:0.00e+00  
##  Median :1.28e+06        Median :1.04e+06   Median :0.00e+00  
##  Mean   :1.01e+07        Mean   :7.86e+06   Mean   :1.30e+06  
##  3rd Qu.:4.09e+06        3rd Qu.:3.41e+06   3rd Qu.:2.36e+03  
##  Max.   :4.95e+08        Max.   :2.80e+08   Max.   :1.02e+08  
##                                                               
##  EXP_OTHER_PUBLIC_SAFETY EXP_TOTAL_PUBLIC_WORKS   EXP_STREET      
##  Min.   :0.00e+00        Min.   :2.26e+05       Min.   :       0  
##  1st Qu.:2.67e+04        1st Qu.:1.41e+06       1st Qu.: 1341848  
##  Median :1.50e+05        Median :2.40e+06       Median : 2254473  
##  Mean   :9.50e+05        Mean   :5.58e+06       Mean   : 4642441  
##  3rd Qu.:6.18e+05        3rd Qu.:4.57e+06       3rd Qu.: 3990537  
##  Max.   :1.22e+08        Max.   :1.00e+08       Max.   :60278448  
##                                                                   
##    EXP_TRASH        EXP_OTHER_PUBLIC_WORKS   EXP_HEALTH      
##  Min.   :       0   Min.   :       0       Min.   :       0  
##  1st Qu.:       0   1st Qu.:       0       1st Qu.:  197217  
##  Median :   70623   Median :       0       Median :  433401  
##  Mean   :  655851   Mean   :  278038       Mean   : 1981126  
##  3rd Qu.:  267753   3rd Qu.:       0       3rd Qu.: 1228658  
##  Max.   :38360813   Max.   :94779328       Max.   :81731677  
##                                                              
##  EXP_RECREATION     EXP_SOCIAL_SERVICE    EXP_MISC       
##  Min.   :0.00e+00   Min.   :0.00e+00   Min.   :0.00e+00  
##  1st Qu.:1.04e+05   1st Qu.:6.36e+05   1st Qu.:4.47e+04  
##  Median :2.19e+05   Median :1.54e+06   Median :1.25e+05  
##  Mean   :2.70e+06   Mean   :9.47e+06   Mean   :1.67e+06  
##  3rd Qu.:6.86e+05   3rd Qu.:4.43e+06   3rd Qu.:3.37e+05  
##  Max.   :1.50e+08   Max.   :2.10e+08   Max.   :2.62e+08  
##                                                          
##  EXP_TRANSFER_OUT   EXP_CAPITAL_OUTLAY EXP_DEBT_SERVICE_GEN
##  Min.   :0.00e+00   Min.   :0.00e+00   Min.   :0.00e+00    
##  1st Qu.:3.49e+04   1st Qu.:6.04e+05   1st Qu.:0.00e+00    
##  Median :2.19e+05   Median :1.36e+06   Median :7.21e+04    
##  Mean   :2.39e+06   Mean   :7.12e+06   Mean   :2.20e+06    
##  3rd Qu.:1.06e+06   3rd Qu.:3.79e+06   3rd Qu.:6.55e+05    
##  Max.   :1.12e+08   Max.   :5.97e+08   Max.   :1.55e+08    
##                                                            
##  EXP_PRINCIPAL_GEN  EXP_INTEREST_GEN    GO_DEBT_GEN      
##  Min.   :       0   Min.   :       0   Min.   :0.00e+00  
##  1st Qu.:       0   1st Qu.:       0   1st Qu.:0.00e+00  
##  Median :   50234   Median :    8078   Median :0.00e+00  
##  Mean   : 1214648   Mean   :  985832   Mean   :5.57e+06  
##  3rd Qu.:  401279   3rd Qu.:  187404   3rd Qu.:0.00e+00  
##  Max.   :97620815   Max.   :82485362   Max.   :6.16e+08  
##                                                          
##  REVENUE_DEBT_GEN   OTHER_DEBT_GEN         ASSETS        
##  Min.   :0.00e+00   Min.   :0.00e+00   Min.   :0.00e+00  
##  1st Qu.:0.00e+00   1st Qu.:0.00e+00   1st Qu.:0.00e+00  
##  Median :0.00e+00   Median :1.54e+05   Median :5.12e+06  
##  Mean   :7.30e+06   Mean   :7.51e+06   Mean   :4.69e+07  
##  3rd Qu.:0.00e+00   3rd Qu.:1.55e+06   3rd Qu.:1.51e+07  
##  Max.   :4.45e+08   Max.   :5.52e+08   Max.   :4.37e+09  
##                                                          
##   LIABILITIES         POPULATION       RETAIL_SALES     
##  Min.   :0.00e+00   Min.   :    580   Min.   :6.67e+03  
##  1st Qu.:0.00e+00   1st Qu.:   7776   1st Qu.:1.50e+05  
##  Median :6.59e+05   Median :  19014   Median :1.44e+06  
##  Mean   :1.18e+07   Mean   :  97659   Mean   :5.79e+08  
##  3rd Qu.:2.75e+06   3rd Qu.:  49405   3rd Qu.:1.38e+08  
##  Max.   :1.18e+09   Max.   :1990987   Max.   :2.66e+10  
##                                                         
##  ST_SALES_TAX_PAID  SALES_TAX_RATE       DFL          FNAME     
##  Min.   :1.88e+04   Min.   : 0.00   Min.   :1   Adams    :  35  
##  1st Qu.:7.60e+05   1st Qu.: 0.00   1st Qu.:1   Alamosa  :  35  
##  Median :3.52e+06   Median : 1.14   Median :1   Arapahoe :  35  
##  Mean   :2.32e+07   Mean   : 1.54   Mean   :1   Archuleta:  35  
##  3rd Qu.:1.11e+07   3rd Qu.: 2.49   3rd Qu.:1   Baca     :  35  
##  Max.   :3.79e+08   Max.   :11.96   Max.   :1   Bent     :  35  
##                                                 (Other)  :2030  
##      ALAND              AWATER             CBSAFP      CLASSFP  
##  Min.   :8.54e+07   Min.   :  301808   Min.   :14500   H1:2170  
##  1st Qu.:2.06e+09   1st Qu.: 4396657   1st Qu.:19740   H6:  70  
##  Median :3.71e+09   Median :12481115   Median :19740            
##  Mean   :4.19e+09   Mean   :18289476   Mean   :23244            
##  3rd Qu.:5.71e+09   3rd Qu.:23456646   3rd Qu.:22820            
##  Max.   :1.24e+10   Max.   :98113981   Max.   :44540            
##                                        NA's   :1365             
##     COUNTYFP        COUNTYNS           CSAFP      FUNCSTAT     GEOID     
##  Min.   :  1.0   Min.   : 198116   Min.   :216    A:2170   Min.   :8001  
##  1st Qu.: 30.5   1st Qu.: 198132   1st Qu.:216    C:  70   1st Qu.:8030  
##  Median : 62.0   Median : 198148   Median :216             Median :8062  
##  Mean   : 62.2   Mean   : 225455   Mean   :216             Mean   :8062  
##  3rd Qu.: 93.5   3rd Qu.: 198163   3rd Qu.:216             3rd Qu.:8094  
##  Max.   :125.0   Max.   :1945881   Max.   :216             Max.   :8125  
##                                    NA's   :1820                          
##     INTPTLAT       INTPTLON         LSAD   METDIVFP         MTFCC     
##  Min.   :37.2   Min.   :-109   Min.   :6   Mode:logical   G4020:2240  
##  1st Qu.:38.0   1st Qu.:-107   1st Qu.:6   NA's:2240                  
##  Median :38.9   Median :-105   Median :6                              
##  Mean   :38.9   Mean   :-105   Mean   :6                              
##  3rd Qu.:39.9   3rd Qu.:-104   3rd Qu.:6                              
##  Max.   :40.9   Max.   :-102   Max.   :6                              
##                                                                       
##        NAME_y                 NAMELSAD       STATEFP    sorting_id  
##  Adams    :  35   Adams County    :  35   Min.   :8   Min.   :2169  
##  Alamosa  :  35   Alamosa County  :  35   1st Qu.:8   1st Qu.:2218  
##  Arapahoe :  35   Arapahoe County :  35   Median :8   Median :2238  
##  Archuleta:  35   Archuleta County:  35   Mean   :8   Mean   :2267  
##  Baca     :  35   Baca County     :  35   3rd Qu.:8   3rd Qu.:2254  
##  Bent     :  35   Bent County     :  35   Max.   :8   Max.   :3137  
##  (Other)  :2030   (Other)         :2030
```

```r
print(summary(co))
```

```
## Object of class SpatialPolygonsDataFrame
## Coordinates:
##       min  max
## x -109.06 -102
## y   36.99   41
## Is projected: FALSE 
## proj4string :
## [+proj=longlat +datum=NAD83 +ellps=GRS80 +towgs84=0,0,0]
## Data attributes:
##     STATEFP      COUNTYFP      COUNTYNS      GEOID           NAME   
##  08     :64   001    : 1   00198116: 1   08001  : 1   Adams    : 1  
##  01     : 0   003    : 1   00198117: 1   08003  : 1   Alamosa  : 1  
##  02     : 0   005    : 1   00198118: 1   08005  : 1   Arapahoe : 1  
##  04     : 0   007    : 1   00198119: 1   08007  : 1   Archuleta: 1  
##  05     : 0   009    : 1   00198120: 1   08009  : 1   Baca     : 1  
##  06     : 0   011    : 1   00198121: 1   08011  : 1   Bent     : 1  
##  (Other): 0   (Other):58   (Other) :58   (Other):58   (Other)  :58  
##              NAMELSAD       LSAD    CLASSFP   MTFCC        CSAFP   
##  Adams County    : 1   06     :64   C7: 0   G4020:64   216    :12  
##  Alamosa County  : 1   00     : 0   H1:62              102    : 0  
##  Arapahoe County : 1   03     : 0   H4: 0              104    : 0  
##  Archuleta County: 1   04     : 0   H5: 0              112    : 0  
##  Baca County     : 1   05     : 0   H6: 2              118    : 0  
##  Bent County     : 1   07     : 0                      (Other): 0  
##  (Other)         :58   (Other): 0                      NA's   :52  
##      CBSAFP      METDIVFP  FUNCSTAT     ALAND              AWATER        
##  19740  :10   13644  : 0   A:62     Min.   :8.54e+07   Min.   :  301808  
##  17820  : 2   14484  : 0   B: 0     1st Qu.:2.06e+09   1st Qu.: 4396657  
##  20780  : 2   15764  : 0   C: 2     Median :3.71e+09   Median :12481115  
##  14500  : 1   15804  : 0   F: 0     Mean   :4.19e+09   Mean   :18289476  
##  15860  : 1   16974  : 0   G: 0     3rd Qu.:5.71e+09   3rd Qu.:23456646  
##  (Other): 9   (Other): 0   N: 0     Max.   :1.24e+10   Max.   :98113981  
##  NA's   :39   NA's   :64   S: 0                                          
##         INTPTLAT          INTPTLON 
##  +37.2023952: 1   -102.3451047: 1  
##  +37.2134065: 1   -102.3553579: 1  
##  +37.2775474: 1   -102.3921613: 1  
##  +37.2873673: 1   -102.4226489: 1  
##  +37.3066778: 1   -102.5377653: 1  
##  +37.3188308: 1   -102.6030226: 1  
##  (Other)    :58   (Other)     :58
```


You can also embed plots, for example:


```r
plot(cars)
```

![plot of chunk unnamed-chunk-1](figure/unnamed-chunk-1.png) 


