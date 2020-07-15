rm(list=ls())
options(stringsAsFactors = FALSE)
options(scipen=999)
library(readxl)
library(tidyverse)
library(sp)
library(rgdal)
library(sf)
library(geosphere)
library(otuSummary)


# =======================================================================
# /Users/markhatcher/Downloads/1270055003_asgs_2016_vol_3_aust_gpkg
# data source:
#  https://data.gov.au/dataset/
#  ds-dga-32adc1ef-5bac-4eaa-9521-a116792f32a1/distribution/
#  dist-dga-b8d5f808-3294-4b8b-92b2-0e09e4fe1305/details?q=

# for coordinate reference system see the following source file:
# source file: POA_2016_AUST.xml
# xpath expression: /gmd:MD_Metadata/gmd:referenceSystemInfo[1]/
# gmd:MD_ReferenceSystem[1]/gmd:referenceSystemIdentifier[1]/gmd:RS_Identifier[1]/gmd:code[1]
# it was "4283"

# read the file and set projection as per metadata
setwd("/Users/markhatcher/Downloads/1270055003_asgs_2016_vol_3_aust_gpkg")
poa_gpkg_spoly_df <- readOGR("ASGS 2016 Volume 3.gpkg", "POA_2016_AUST")
proj4string(poa_gpkg_spoly_df) <- sp::CRS("+init=epsg:4283")
# =================================================================

# reproject to wgs84... distance measure needs this
poa_gpkg_spoly_df_wgs_84 <- sp::spTransform(poa_gpkg_spoly_df,
    CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")) 

# get the egs84 centroids
sp_points_df_cent_wgs_84 <- 
  sp::SpatialPointsDataFrame(
    coords = rgeos::gCentroid(poa_gpkg_spoly_df_wgs_84 , byid = TRUE),  
    data = poa_gpkg_spoly_df_wgs_84@data, 
    proj4string = poa_gpkg_spoly_df_wgs_84@proj4string)

# 2668
sp_points_df_cent_wgs_84 %>% nrow()
# expected number of rows
(2668 * (2668 -1)) / 2

# 2668 x 2668
mat_distance <- geosphere::distm(sp_points_df_cent_wgs_84, fun = distHaversine)
# convert to km
mat_distance_km <- mat_distance / 1000

# set the names
colnames(mat_distance_km) <- sp_points_df_cent_wgs_84@data$POA_CODE_2016
rownames(mat_distance_km) <- sp_points_df_cent_wgs_84@data$POA_CODE_2016

# otuSummary::matrixConvert extracts the matrix triangle and then 
# converts to a data.frame... expected rows == (n*(n-1)) /2
vct_col_names <- c("from", "to", "distance_km")
df_distance_km <- otuSummary::matrixConvert(mat_distance_km, vct_col_names)
(2668 * (2668 -1)) / 2
df_distance_km %>% nrow()

# zipped up this is 50 mb
setwd("/Users/markhatcher/Documents/new_ways_of_working/seifa_postcode_zipped/created_data")
write.csv(df_distance_km,'centroid_distance_km.csv')
