rm(list=ls())
options(stringsAsFactors = FALSE)
options(scipen=999)
library(readxl)
library(tidyverse)

# data source
# https://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/2033.0.55.0012016?OpenDocument
# Postal Area, Indexes, SEIFA 2016 


# spreadsheet structure
# name        pos.  description

# contents    1     description of spreadsheet
# table 1     2     4 measures - index value & decile
# table 2     3     socio-economic disadvantage -- detail
# table 3     4     socio-economic advantage & disadvantage -- detail
# table 4     5     economic resources -- detail
# table 5     6     education and occupation - detail
# table 6     7     exluded areas

# short names 

# socio-economic disadvantage                 sed
# socio-economic advantage & disadvantage     sead
# economic resources                          er
# education and occupation                    eo

# type
# index             indx
# decile            dec
# post area code    poa

setwd("/Users/markhatcher/Documents/new_ways_of_working/seifa_postcode")

vct_names <- c("poa", "sed_indx", "sed_dec", "sead_indx", 
  "sead_dec", "er_indx", "er_dec", "eo_indx", "eo_dec", "population")

str_file_path <- "source_data/2033055001_poa_indexes.xls"

# read summary - converted 6 values to NA
df_seifa_summary <- readxl::read_excel(str_file_path, 
      sheet = 2, range = "A7:J2636", col_names = FALSE)

names(df_seifa_summary) <- vct_names

# add in exclusion indicator column
df_seifa_summary$excluded <- FALSE

# =======================================================================
# excluded areas 

# read excluded areas
df_exluded_areas <- readxl::read_excel(str_file_path, 
      sheet = 7, range = "A7:B47", col_names = FALSE)

# 1 column here [41 x 1]
names(df_exluded_areas) <- c("poa", "population")

# create a blank data.frame 
df_ex_area_blank <- data.frame(matrix(ncol = length(vct_names[2:9]), 
      nrow = nrow(df_exluded_areas )))

names(df_ex_area_blank) <- vct_names[2:9]

df_ex_area_all_cols <- cbind(df_exluded_areas, df_ex_area_blank) %>%
  select(poa, sed_indx:eo_dec, population)

df_ex_area_all_cols$excluded <- TRUE

# =======================================================================
# stack the two data.frames

# believe it or not there is an intersection between those
# exluded and those in the summmary table....

vct_over_lap <- df_seifa_summary$poa[df_seifa_summary$poa %in% 
            df_ex_area_all_cols$poa]

df_seifa_summary_filt <- df_seifa_summary %>% filter(!poa %in% vct_over_lap)

df_seifa_data <- bind_rows(df_seifa_summary_filt, df_ex_area_all_cols)

# ASSERT nothing got lost (sum of two data.frames less overlap)
nrow(df_seifa_data) == (2630 + 41 - 1)

# check that postcode is unique
(df_seifa_data$poa %>% unique() %>% length()) == nrow(df_seifa_data)

# print number of postal area codes [2670]
df_seifa_data$poa %>% unique() %>% length()

write.csv(df_seifa_data,'created_data/seifa.csv')

