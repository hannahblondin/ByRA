## Made by Kelly DeForest, SFSU
## 04/28/2022

## This script was created to make quick plots of ByRA output tifs. It will save
## pngs of the maps to your working directory for each tif, and it will plot them in
## your RStudio, assuming you're using RStudio.

# Checks to see if all of the necessary packages and libraries are installed
if (!is.element("sf", installed.packages())) 
  install.packages("sf", dep = T)
if (!is.element("raster", installed.packages()))
  install.packages("raster", dep = T)
if (!is.element("tmap", installed.packages()))
  install.packages("tmap", dep = T)

library(sf)
library(raster)
library(tmap)

# Input pathway to ByRA output folder. Make sure to use /, not \, between folder names
# The working directory should be the 'outputs' folder that ByRA creates for 
# each run. If you want to include an AOI, uncomment lines 21, 41, 42, 58, and 59.
wd <- setwd("C:/Users/kelly/Box Sync/modleR/ByRA_kd/vignettes/Output_visualizations/Sample_data/outputs")

# Input path to area of interest shapefile
#AOI <- st_read("C:/Users/kelly/Box Sync/modleR/ByRA_kd/vignettes/Output_visualizations/Sample_data/AOI/TRAT_AOI_subregions.shp")
# Remove hashtag from above if you do want to include the AOI

# Pick classification type for total risk rasters
## examples: "jenks", "cont", "equal", "quantile"
pick_style <- "cont"

# Create lists of all reclass and total risk rasters for the map making loop 
allRR <- list.files(wd, pattern = "RECLASS")
allTR <- list.files(wd, pattern = "TOTAL")

# create maps for Reclass risk tiffs 
tmap_mode("plot")
for (r in 1:length(allRR)){
  inras <- raster(allRR[r])
  inras[inras==0] <- NA
  static_map <- tm_shape(inras) +
    tm_raster(style = "fixed", palette = "Oranges", breaks = c(1,2,3,3), labels = c("1-low", "2-medium", "3-high"), legend.show = T)+
    #uncomment the two lines below if you have an AOI
    #tm_shape(AOI)+
    #tm_borders(col= "Black")+
  tmap_save(static_map,paste0("reclassmap_",r,".png"))
  print(static_map)
}

# Create maps for total risk tiffs
tmap_mode("plot")
for (t in 1:length(allTR)){
  inras <- raster(allTR[t])
  inras[inras==0] <- NA
  static_map <- tm_shape(inras) +
    tm_raster(style = pick_style, palette = "Reds", legend.show = T)+
    # uncomment the two lines below if you have an AOI
    #tm_shape(AOI)+
    #tm_borders(col= "Black")+
  tmap_save(static_map,paste0("totalmap_",t,".png"))
  print(static_map)
}
