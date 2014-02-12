##Analysis To Date

At the current time, I have done much of the work required to demonstrate the impact of TELs on both the clustering of economic and fiscal behavior and the divergence between the expenditure profiles desired by jurisdictions and the actual expenditure composition they use.  The final models need to be adjusted for both, but this will be revisited when all the pieces are completed to understand the best means of fitting them together.

##Value Added

There is a wealth of rich research in the area of tax and expenditure limitations, but my research has three components that are not currently (or barely are) in play:

1. Most research attacks TELs from the perspective of evaluating the average effect across jurisdictions.  [Mullins' work](http://onlinelibrary.wiley.com/doi/10.1111/j.0275-1100.2004.00350.x/abstract;jsessionid=6EF2FF4ACCC437DBE4BAACA6016F3945.f02t03?deniedAccessCustomisedMessage=&userIsAuthenticated=false) is a notable exception in this regard, and it seems only fitting that I extend the body of work in this area.

2. Variability in the application of TELs has been difficult to capture.  The simple reason is, in a nutshell, that authorizing statutes and/or constitutional provisions do not change all that rapidly.  The most common approach for introducing variation has been the construction of indices from TEL provisions.  This has led to even more focus on state comparisons than might otherwise be the case (because variation in TEL structure is typically across states).  Furthermore, researchers have had difficulty studying the effect of overlapping policies, which typically disrupt the impact that indices are trying to pick up.  My approach has been to abstract away from specific provisions, towards the impact of said provisions on individual jurisdictions.  The measure (intensity stock) seeks to capture the cumulative constraint placed upon revenue sources for each jurisdiction.  It varies as a function of economic base growth.  To the best of my knowledge, this is a unique approach.

3. When averaging the effect of TELs across all local governments in a state, one is less concerned with the externalities across said jurisdictions.  However, when evaluating the responses of individual local governments (as I seek to do here), spatial considerations are non-trivial.  A growing amount of research across the public policy/economic spectrum is explicitly incorporating spatial dependency into estimation strategies, and my research is a part of this trend.  The difference is that TEL research is a new application on this front.

##Distillation

Dr. Mullins and I had a meeting today (1/9/2014) in which we discussed (among other things) the need to focus on one or two hypotheses per emprical section.  To my mind, the consensus view after this meeting reflected three things:

1. The components of the above value-added discussion;
2. Leveraging the analysis I have done to date; and,
3. Continuity of inquiry.

The long run model is understanding the impact of TELs on economic growth.  To get there we will first whether or not there is a TEL related impact on fiscal capacity.  The idea is demonstrate that downward revenue pressure exists.  The next step is to ask whether or not TELs cause divergences between actual and desired expenditure profiles.  If TELs depress revenue generation, then local governments will be forced to alter their expenditure profiles, presumably by cutting non-essential services, and then services that feature the smallest marginal products.  The implication is that the jurisdiction will have a more difficult time attracting residents and employers when expenditure choices are artificially constrained.  Finally, we ask if there is an impact on economic dynamics, which we may link back to the results of the existence of systemic fiscal constraints.

All of the county finance data used to explor fiscal behavior have been provided by the [Division of Local Government](http://www.colorado.gov/cs/Satellite/DOLA-Main/CBON/1251590375285) within the [Colorado Department of Local Affairs](http://www.colorado.gov/cs/Satellite/DOLA-Main/CBON/1251589672852).  These data represent nominal county government revenues and expenditures over the 1975 to 2009 time period.  All data housed in the [County and Municipal Financial Compendium](http://www.colorado.gov/cs/Satellite/DOLA-Main/CBON/1251595228967) are standardized to a set of revenue and expenditure functions to permit comparisons across jurisdictions and over time.

The hypotheses for this approach are as follows:

###*Fiscal Capacity*

At first glance, given that TELs are initiated with the explicit purpose of slowing the growth in revenue (or expenditures), one would expect revenue generation to decrease by construction.  In truth, however, revenue limits often do not cover the full revenue base.  For example, according to [Article 10 Section 20](http://ballotpedia.org/Article_X,_Colorado_Constitution#Section_20) of the Colorado State Constitution, TABOR revenue limits are applied only to the local income and property tax bases.  Total spending is limited as well, a restrictive coupling that increases the need for a safety valve: intergovernmental transfers.  Furthermore, the amendment specifically excludes from the TABOR base the following revenues:

+ Gifts
+ Federal Funds
+ Collections from Another Government
+ Pension Contributions from Employees
+ Pension Fund Earnings
+ Reserve Tranfers or Expenditures
+ Damage Awards
+ Property Sales

Thus, limited methods to circumvent TABOR restrictions do exist, making the impact on revenue an empirical question.  This section will also be used to explore the possibility of a direct relationship between TEL stringency in Colorado and fiscal (a.k.a. economic) capacity.  This secondary objective is more of an exploratory exercise insofar as the relationship to economic productivity is likely to be more complicated than the relationship to revenue generation.

**H1:  TELs increase differentials in revenue generation and fiscal capacity across jurisdictions**

If TELs restrict revenue growth, we would expect a disparity between counties that are constrained and those that are not.  The first method to evaluate the existence of this disparity is a simple Bayesian t-test revealing the difference in real per capita revenue (revenue generation) and real per capita annual payroll (fiscal capacity) across counties that have and have not De-Bruced.  

We further expect that the disparity will grow with the strength of the constraint imposed by the TEL structure in Colorado.  This hypothesis will be evaluated by regressing real per capita revenue and real per capita annual payroll on our continous TEL intensity stock variable, which captures the cumulative constraint imposed by TABOR and the Statewide Limit on Property Tax Revenue (SLPTR) over time.  The model will also control for the Gallagher Amendment via a variable capturing the ratio of residential to non-residential assessment value within each county, as well as a vector of relevant economic variables capturing demand for housing and macroeconomic behavior.  This model will be evaluated with pooled OLS, repeated cross-sectional spatial lag models, and fixed effect panel analysis.

**H2:  TELs increase spatial clustering of revenue outcomes**

Fiscal behavior is strongly dependent on socioeconomic characteristics, both within the county and in neighboring counties.  This section evaluates whether or not the clustering of similar behavior grows are decreases as a consequence of TELs.  Evaluation of this hypothesis will involve regressing Local Indicators of Spatial Autocorrelation (LISAs) on TEL intensity stock and the Gallagher ratio (and aforementioned covariates).  The LISAs used are Local Moran's I and Getis & Ord's G\*.  The former returns high values when similar values are clustered, and low values when disimilar values are clustered.  The latter returns high values when high values are clustered, and low values when low values are clustered.  The value base for this hypothesis is real per capita revenue.

**H3:  TELs increase spatial clustering of fiscal capacity**

This hypothesis mirrors the first, except that the base for the LISAs is per capita annual payroll.


###*Expenditure Choices*

The general theory here is that if TELs constrain revenue sources, they will force expenditure behavior to change.  Indeed, for many proponents, this is an explicit policy goal.

**H4:  TELs create wedges between preferred and actual expenditure portfolios**

The challenge in demonstrating a difference between preferred and actual expenditure portfolios is capturing a plausible counterfactual.  A general approach to this is to identify a reasonable attribute match with a different jurisdiction or construct.  This can be a county in a different state that does not operate under the same TEL conditions.  This approach has the benefit of tangibility, and if a composite of like counties is generated, it affords an opportunity to abstract away from state specific institutional contexts.  A downside of this approach is the difficulty in incorporating state specific unobservables that are particular to Colorado.  

An alternative approach, the one pursued initially in this inquiry, attempts to capture the preferences of a given county by grouping like counties together based upon expenditure composition.  The idea here is that expenditure composition is a reasonable proxy for opportunity cost preference ordering, and as such, counties with similar compositions during the learning phase (the period of time over which preferences are measured) desire similar things from the public sector.  Deviations from the group preference are conceived as being exogenously driven.  Operationally, these deviations are measured as the distance between two **n**-dimensional points (**n** corresponds to the number of expenditure functions in the portfolio).  The first point is a given county-year's expenditure composition.  The second point is the expenditure composition represented by the centroid of the original cluster (which was generated over the learning period).  The clusters in 1975 (determined via [K-Means clustering](http://en.wikipedia.org/wiki/K-means_clustering)), for example, appear in the figure below:

![Fiscal Clusters](https://github.com/choct155/TEL/blob/master/ipynb/FiscClusters1975.png "Fiscal Clusters")

If those represent our training clusters, the centroids then remain fixed and we measure the distance of a county in a given year from its associated centroid.  This distance to the cluster becomes our dependent variable, a measure of disimilarity between the county in a given year and it's preference foundation.  Then we can regress this distance on TEL intensity stock, the Gallagher ratio, and our covariates to measure how much the TEL structure causes a county to stray from its preferred expenditure composition.  In this way, we have built a composite construct to represent our counterfactual and we are able to avoid issues associated with state-specific unobservables.  The downside of this approach is that the state has been fundamentally altered by the TEL regime, so we do not capture the full extent of the effect.  It is thus a complementary technique to the cross-state approach rather than a substitute.

**H5:  TELs decrease variation in expenditure portfolios across local governments that are similarly constrained by said TELs**

The challenge in evaluating convergence as a function the TEL structure is establishing the point of convergence.  If we are to understand variation across the similarly constrained, one approach is to bin the constraint measure and measure variation within each of the bins.  The problem with this approach is an a priori definition of the size of these bins when we have no reason to suspect that our size choices are appropriate before the fact.  A better approach would allow the data to define the groupings that occur as a matter of course.

In a broad sense we want to capture expenditure composition as a function of TEL intensity.  We can again use a spatial frame to explore this relationship.  The first step is understanding how to represent similarly constrained counties.  We can do this by clustering counties in the (intensity stock, Gallagher ratio) plane.  Once we have these clusters of similarly constrained counties, we can evaluate the expenditure attributes of each cluster.  That is, we find the centroid of the **n**-dimensional space (again, **n** is the number of expenditure functions) and measure the distance of each county in the cluster from that point.  What we are after is the variation in this distance to the cluster centroid.  Once we have these distances, we can compare the distances in cluster '**A**' with the distances in cluster '**B**' with a Bayesian t-test (and so on until all clusters are compared with all others).  The expected relationship is that those county-years with the highest values of intensity stock and Gallgher ratio will exhibit the least amount of variation.  

A benefit of this approach is that, since we are evaluating distances in **n**-dimensional space, we can capture individual dimensions if need be.  Furthermore, the clustering space can be extended to include other dimensions (e.g. a scaling factor like total expenditures).

**H6:  TELs increase variation between more affluent and less affluent jurisdictions**

**H7:  TELs will reduce the propensity for capital investment**



###*Economic Impact*

**H8:  TELs decrease the attractiveness of a jurisdiction for residents**

**H9:  TELs decrease the attractiveness of a jurisdiction for employers**

