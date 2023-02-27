library(RPostgreSQL)
library(sf)
library(ggmap)
library(ggplot2)

buff <- .5

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,
                 dbname="mailhac_9",
                 host="localhost",
                 port=5432,
                 user="postgres",
                 password="postgres")

# steles
steles.bouclier.sqll <- "SELECT site, ST_AsText(geom) as wkt FROM objets WHERE famille LIKE 'stele bouclier'"
steles.bouclier.df <- dbGetQuery(con, steles.bouclier.sqll)
steles.bouclier <- st_as_sf(steles.bouclier.df, wkt = "wkt")
st_crs(steles.bouclier) <- 4326
steles.bouclier <- st_transform(steles.bouclier, 3857)[1]
# steles.bouclier <- st_transform(steles.bouclier, 3857)
# steles.bouclier.xy <- st_coordinates(steles.bouclier)

# other sites
huelva.sqll <- "SELECT site, ST_AsText(geom) as wkt FROM objets WHERE site LIKE 'Huelva' LIMIT 1"
huelva.df <- dbGetQuery(con, huelva.sqll)
huelva <- st_as_sf(huelva.df, wkt = "wkt")
st_crs(huelva) <- 4326
huelva <- st_transform(huelva, 3857)[1]

# map extent
roi <- as.numeric(st_bbox(steles.bouclier))
bbox <- c(left = roi[1] - buff,
          bottom = roi[2] - buff,
          right = roi[3] + buff,
          top = roi[4] + buff)
stamenbck <- get_stamenmap(bbox,
                           zoom = 7,
                           maptype = "terrain-background")

plot(steles.bouclier,
     cex = 1,
     pch = 16,
     col = "black",
     main = NA,
     bgMap = stamenbck,
     reset = FALSE)
plot(huelva,
     cex = 2,
     pch = 16,
     col = "red",
     add = TRUE)


# # NotWorkingWell
#
#
# bck <- ggmap::ggmap(stamenbck) +
#   coord_map()
#
# library(dplyr)
#
# bck +
#   geom_sf(data = steles.bouclier, fill = "black") +
#   coord_sf(crs = 3857)
#
#
#
#
#
# zz <- st_coordinates(head(steles.bouclier))

dbDisconnect(con)
