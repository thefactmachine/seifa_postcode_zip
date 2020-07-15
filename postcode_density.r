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
df_density <- poa_gpkg_spoly_df@data %>% head()

# zipped up this is 50 mb
setwd("/Users/markhatcher/Documents/new_ways_of_working/seifa_postcode_zipped/created_data")
write.csv(df_density,'postcode_density.csv')




