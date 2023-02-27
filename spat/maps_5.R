# plot from DB "mailhac" with Stamen backgrounds


library(RPostgreSQL)
library(sf)
library(ggmap)
library(ggplot2)


# convert to Mercador
items <- function(sqll, con = con){
  sqll.wkt <- "SELECT site, ST_AsText(geom) as wkt FROM objets WHERE "
  sqll <- paste0 (sqll.wkt, sqll)
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv,
                   dbname="mailhac_9",
                   host="localhost",
                   port=5432,
                   user="postgres",
                   password="postgres")
  data.df <- dbGetQuery(con, sqll)
  dbDisconnect(con)
  data.sf <- st_as_sf(data.df, wkt = "wkt")
  print(nrow(data.sf))
  st_crs(data.sf) <- 4326
  data.merc <- st_transform(data.sf, 3857)[1]
  return(data.merc)
}

spat <- function(x = NA, buff = 3){
  # map extent
  roi.extent.merc <- st_union(x)
  roi.extent.wgs <- st_transform(roi.extent.merc, crs = 4326)
  roi <- as.numeric(st_bbox(roi.extent.wgs))
  bbox <- c(left = roi[1] - buff,
            bottom = roi[2] - buff,
            right = roi[3] + buff,
            top = roi[4] + buff)
  stamenbck <- get_stamenmap(bbox,
                             zoom = 6,
                             maptype = "terrain-background")
  return(stamenbck)
}


steles.bouclier <- items("famille LIKE 'stele bouclier'")
baracal <- items("site LIKE 'Baracal' LIMIT 1")
carneril <- items("site LIKE '%Carneril%' LIMIT 1")
cespedes <- items("site LIKE 'Granja de Cespedes' LIMIT 1")
foios <- items("site LIKE 'Foios' LIMIT 1")
brozas <- items("site LIKE 'Brozas' LIMIT 1")
huelva <- items("site LIKE 'Huelva' LIMIT 1")
cloonbrin <- items("site LIKE 'Cloonbrin' LIMIT 1")
bangor <- items("site LIKE 'Bangor' LIMIT 1")
delphes <- items("site LIKE 'Delphes' LIMIT 1")
froslunda <- items("site LIKE 'Froslunda' LIMIT 1")
ategua <- items("site LIKE 'Ategua' LIMIT 1")
kville <- items("site LIKE 'Kville' LIMIT 1")
capote <- items("site LIKE 'Capote' LIMIT 1")
cabeza.4 <- items("numero LIKE 'Cabeza De%4%'")
valpalmas <- items("site LIKE 'Valpalmas'")
# vilamayor <- items("site LIKE 'Vila Maior' LIMIT 1")
# - - - - - - - - - - - - - - - - - -
a.classer <- items("famille LIKE '%classe%'")
penatu <- items("site LIKE 'Pena Tu'")
tabuyo <- items("site LIKE 'Tabuyo%'")


stamenbck <- spat(a.classer)

plot(a.classer,
     cex = 1,
     pch = 16,
     col = "black",
     main = NA,
     bgMap = stamenbck,
     xlim = st_bbox(roi.extent.merc)[c(1, 3)],
     ylim = st_bbox(roi.extent.merc)[c(2, 4)],
     reset = FALSE)
#
plot(tabuyo,
     cex = 2,
     pch = 16,
     col = "blue",
     add = TRUE)
text(x = sf::st_coordinates(cabeza.4)[, 1],
     y = sf::st_coordinates(cabeza.4)[, 2],
     col = "blue",
     labels = tabuyo$site,
     pos = 3)

plot(penatu,
     cex = 2,
     pch = 16,
     col = "red",
     add = TRUE)
text(x = sf::st_coordinates(cabeza.4)[, 1],
     y = sf::st_coordinates(cabeza.4)[, 2],
     col = "red",
     labels = penatu$site,
     pos = 3)

