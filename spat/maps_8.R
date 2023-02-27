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

spat <- function(title = "",
                 bck = NA,
                 inds = NA,
                 buff = 3,
                 zoom = 6,
                 maptype = "terrain-background",
                 bck.cex = 1,
                 bck.pch = 16,
                 bck.col = c("#4d4d4d", "#777777", "#0a0a0a"),
                 inds.cex = 1.5,
                 inds.pch = 16,
                 inds.color = NA,
                 inds.text = T
){
  print("   .. starts")
  if(!is.na(inds)){
    roi.extent.merc <- append(inds, bck)
    xy <- inds[[1]]
  } else {
    roi.extent.merc <- bck
    xy <- bck[[1]]
  }
  # xy <- bck[[1]]
  for(i in seq(1, length(roi.extent.merc))){
    indi <- roi.extent.merc[[i]]
    xy <- st_union(xy, indi, by_feature = FALSE)
  }
  roi.extent.merc.comb <- st_combine(xy)
  roi.extent.wgs <- st_transform(roi.extent.merc.comb, crs = 4326)
  roi <- as.numeric(st_bbox(roi.extent.wgs))
  bbox <- c(left = roi[1] - buff,
            bottom = roi[2] - buff,
            right = roi[3] + buff,
            top = roi[4] + buff)
  print("   .. stamen")
  stamenbck <- get_stamenmap(bbox,
                             zoom = zoom,
                             maptype = maptype,
                             alpha = .5)
  bbox.roi <- st_bbox(c(xmin = roi[1] - buff, xmax = roi[3] + buff,
                        ymin = roi[2] - buff, ymax = roi[4] + buff),
                      crs = st_crs(3857))
  # bbox.roi.merc <- st_transform(bbox.roi, crs = 3857)[1]
  xy.bck <- bck[[1]]
  print("   .. plot bck")
  plot(xy.bck,
       main = title,
       cex = bck.cex,
       pch = bck.pch,
       col = bck.col[1],
       bgMap = stamenbck,
       # xlim = c(roi[1] - buff, roi[3] + buff),
       # ylim = c(roi[1] - buff, roi[3] + buff),
       xlim = st_bbox(roi.extent.merc.comb)[c(1, 3)],
       ylim = st_bbox(roi.extent.merc.comb)[c(2, 4)],
       # xlim = st_bbox(roi.extent.merc.comb)[c(1, 3)],
       # ylim = st_bbox(roi.extent.merc.comb)[c(2, 4)],
       reset = FALSE)
  if(length(bck) > 1){
    print("   .. plot inds")
    for(i in seq(2, length(bck))){
      indi <- bck[[i]]
      plot(indi,
           cex = bck.cex,
           pch = bck.pch,
           col = bck.col[i],
           add = TRUE)
    }
  }
  if(!is.na(inds)){
    for(i in seq(1, length(inds))){
      if(is.na(inds.color)){
        colors <- RColorBrewer::brewer.pal(length(inds), "Set1")
      } else {
        colors <- c(rep(inds.color, 7))
      }
      indi <- inds[[i]]
      plot(indi,
           cex = inds.cex,
           pch = inds.pch,
           col = colors[i],
           add = TRUE)
      if(inds.text){
        text(x = sf::st_coordinates(indi)[, 1],
             y = sf::st_coordinates(indi)[, 2],
             col = colors[i],
             labels = indi$site,
             pos = 3)
      }
    }
  }
}



steles.bouclier <- items("famille LIKE 'stele bouclier'")
baracal <- items("site LIKE 'Baracal' LIMIT 1")
salen <- items("site LIKE 'Salen' LIMIT 1")
substantio <- items("site LIKE 'Substantio' LIMIT 1")
valpalmas <- items("site LIKE 'Valpalmas'")

# carneril <- items("site LIKE '%Carneril%' LIMIT 1")
# cespedes <- items("site LIKE 'Granja de Cespedes' LIMIT 1")
# foios <- items("site LIKE 'Foios' LIMIT 1")
# brozas <- items("site LIKE 'Brozas' LIMIT 1")
# huelva <- items("site LIKE 'Huelva' LIMIT 1")
# cloonbrin <- items("site LIKE 'Cloonbrin' LIMIT 1")
# bangor <- items("site LIKE 'Bangor' LIMIT 1")
# delphes <- items("site LIKE 'Delphes' LIMIT 1")
# froslunda <- items("site LIKE 'Froslunda' LIMIT 1")
# ategua <- items("site LIKE 'Ategua' LIMIT 1")
# kville <- items("site LIKE 'Kville' LIMIT 1")
# capote <- items("site LIKE 'Capote' LIMIT 1")
# cabeza.4 <- items("numero LIKE 'Cabeza De%4%'")
# # vilamayor <- items("site LIKE 'Vila Maior' LIMIT 1")
# - - - - - - - - - - - - - - - - - -
a.classer <- items("famille LIKE '%classe%'")
diademe <- items("famille LIKE '%diademe%'")
alentejo <- items("famille LIKE '%alentejo%'")
corse <- items("famille LIKE '%corse%'")
penatu <- items("site LIKE 'Pena Tu' LIMIT 1")
tabuyo <- items("site LIKE 'Tabuyo%' LIMIT 1")
colado <- items("site LIKE 'Collado de S%' LIMIT 1")
mamoiada <- items("site LIKE 'Mamoi%' LIMIT 1")

# inds <- list(tabuyo, penatu)
spat(title = "",
     bck = list(steles.bouclier),
     # inds = NA,
     inds = list(baracal, salen, substantio, valpalmas),
     inds.text = F,
     buff = 10)

