sp_points_df_cent <- 
  sp::SpatialPointsDataFrame(
    coords = rgeos::gCentroid(poa_gpkg_spoly_df, byid = TRUE),  
    data = poa_gpkg_spoly_df@data, 
    proj4string = poa_gpkg_spoly_df@proj4string)

# woden 2606
# kingston 2604
# tuggers 2901
# mollymook 2539
# noosa heads 4566

# 2539, 2604, 2606, 4566
# mollymook, kingston, woden, noosa
# distGeo

# mollymook ==> mollymook  0 km
# mollymook ==> kingston 103 kilometres
# mollymook ==>  woden 109 kilometres
# mollymook ==> noosa 1031

vct_sub_set <- c("2606", "2604", "2901", "2539", "4566")
vct_geo_subset <- sp_points_df_cent@data$POA_NAME_2016 %in% vct_sub_set
vct_geo_subset %>% sum()
points_subset <- sp_points_df_cent[vct_geo_subset, ]


mat_distance <- distm(points_subset, fun = distHaversine)
colnames(mat_distance) <- points_subset@data$POA_NAME_2016
rownames(mat_distance) <- points_subset@data$POA_NAME_2016
mat_distance <- mat_distance / 1000

df_test_df <- otuSummary::matrixConvert(mat_distance, 
                                        c("from", "to", "distance_km"))
df_test_df





df_distance <- mat_distance %>% as.data.frame()
df_pc <- data.frame(poa_from = points_subset@data$POA_NAME_2016)
df_distance <- cbind(df_pc, df_distance)
df_distance
df_distance_long <- gather(df_distance, "poa_to", "distance_metres", -poa_from)
df_distance_long$distance_km <- df_distance_long$distance_metres / 1000
df_distance_long

mat_distance

data(varespec) 
# 21 x 21 matrix
mat <- vegdist(varespec, method = "bray") %>% as.matrix()
xx <- matrixConvert(mat)

df_test_df <- otuSummary::matrixConvert(mat_distance)




