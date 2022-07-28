# Crime-spatial-statistics-in-London-

## Spatial Autocorrelation Analysis: 
Spatial autocorrelation is used to describe the presence of systematic spatial variation of a variable (Haining, 2001) and can be investigated using both global and local measures. 

### Global Autocorrelation:
Global measures provide a single statistic that summarise the level of spatial autocorrelation across the whole dataset. Their simplicity allows for a rapid interpretation however they do not account for how autocorrelation may be heterogeneous across space. 

1. Global Moran’s I: Developed by Patrick Moran, the Global Moran’s I (GMI) tool measures spatial autocorrelation by reviewing feature locations and feature values simultaneously (ESRI, 2018). With a default null hypothesis of Complete Spatial Randomness (CSR), the analysis provides a test statistic that ranges from -1 (indicating perfect dispersion) to 1 (perfect clustering) along with a z-score and p value (GIS Geography, 2021). 

2. Getis Ord General G: Similar to the GMI, the Getis Ord General G has a null hypothesis of CSR and returns a single value of spatial autocorrelation for the entire dataset. The General G adds to the results of the Moran I by returning not only the presence of clustering but also its direction. For example, assuming the p value is significant, the z-scores of the General G will indicate if the cluster is a hot spot or cold spot. Positive z scores indicate the presence of hot spots (high value clusters) and negative z scores indicate cold spots (low value clusters). The presence of strong cold and hot spots in the area will cancel each other out, leading to a misleading overall statistic. If this is the case, a local spatial autocorrelation method should be used instead.

### Local Autocorrelation:
Global autocorrelation tests generate a single-value summary of autocorrelation across the spatial extent. In doing so, they fail to account for the presence of spatial heterogeneity and create the illusion of homogeneity. Such non-uniformity is endemic in spatial processes according to Tobler’s Law. In recognition of this, we must assume that spatial heterogeneity, relating to distribution and variation, exists within the project datasets. Local measures of autocorrelation interrogate the granular relationship between each spatial object and its neighbouring spatial object. 

1. Moran Scatterplot: It is a tool to identify the clusters of high and low values in spatial data. Its horizontal axis is based on the values of the observations and is also known as the response axis. The vertical Y axis is based on the weighted average or spatial lag of the corresponding observation on the horizontal X axis. The plot is divided into four quadrants. 

2. Getis and Ord’s Gi (and Gi*): The family of Moran indices, does not discriminate between hot spots and cold spots. The Gi* index is therefore more suitable because it can locate unsafe regions on a global scale and discern cluster structures of high- or low-value concentration among local observations. 

3. Bonferroni Test: The Bonferroni test ensures that the p value for each test must be equal to its alpha divided by the count of the total tests undertaken (Armstrong, 2014). It minimizes the likelihood of misidentification of spatial dependency.

4. Local Moran's I: Local Moran's I endeavours to find local clusters and outliers from heterogeneous spatial objects to offer insight into how spatial processes proliferate at local levels. The test results distinguish clusters by decomposing the Global Moran’s I statistics into the contributions localised statistics that reflect the contribution of each spatial object in the sample (Haworth, 2018).

