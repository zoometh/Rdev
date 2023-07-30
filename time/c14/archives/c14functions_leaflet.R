library(dplyr)
library(c14bazAAR)
library(grDevices)
library(sp)
library(leaflet)

# load a database
# with lon, lat (coord): radon, context, emedyd, eubar, medafricarbon, katsianis...
# without lon, lat (coord): 14sea,...
dbC14 <- get_c14data("katsianis")
colnames(dbC14)

long.lat <- cbind(dbC14$lon, dbC14$lat) # matrix
# clean up
long.lat.clean <- long.lat[complete.cases(long.lat), ] # rm NA values
long.lat.clean <- long.lat.clean[(long.lat.clean[,1] >= -90) & (long.lat.clean[,1] <= 90),]
long.lat.clean <- long.lat.clean[(coords.clean[,2] >= -90) & (long.lat.clean[,2] <= 90),]
ch <- chull(long.lat.clean)
coords <- long.lat.clean[c(ch, ch[1]), ]
sp.ch <- SpatialPolygons(list(Polygons(list(Polygon(coords)),ID=1)))
sp.ch.df <- SpatialPolygonsDataFrame(sp.ch, data=data.frame(ID=1))
leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  # convexhull
  addPolygons(data = sp.ch.df,
              # popup= ~secteur,
              stroke = TRUE,
              color = "#000000",
              weight = 2,
              fillOpacity = 0,
              smoothFactor = 0.5) %>%
  # all rocks
  addCircleMarkers(lng=sp.ch.df$x,
                   lat=sp.ch.df$y,
                   popup=roches.all$lbl,
                   radius = 0.5,
                   opacity = 0.3)