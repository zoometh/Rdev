# plot from DB "mailhac" with Stamen backgrounds


library(RPostgreSQL)
library(sf)
library(ggmap)
library(ggplot2)


# get the precise SQL command from the df
sqll.me <- function(data = NA, df = NA, data.col = "data", sqll.col = "sqll"){
  sqll <- df[df[ , data.col] == data, sqll.col]
  return(sqll)
}

# convert to Mercador
to.mercator <- function(data, con = con){
  drv <- dbDriver("PostgreSQL")
  con <- dbConnect(drv,
                   dbname="mailhac_9",
                   host="localhost",
                   port=5432,
                   user="postgres",
                   password="postgres")
  data.df <- dbGetQuery(con, data)
  dbDisconnect(con)
  data.sf <- st_as_sf(data.df, wkt = "wkt")
  st_crs(data.sf) <- 4326
  data.merc <- st_transform(data.sf, 3857)[1]
  return(data.merc)
}



# dataframe of sql commands
sqll.wkt <- "SELECT site, ST_AsText(geom) as wkt FROM objets WHERE "
df <- data.frame(data = c("steles.bouclier",
                          "huelva"),
                 sqll = c(paste0 (sqll.wkt, "famille LIKE 'stele bouclier'"),
                          paste0 (sqll.wkt, "site LIKE 'Huelva' LIMIT 1")
                 )
                )
#
#
#
#
# sqll.me(data = "steles.bouclier", df)
# sqll.me(data = "huelva", df)
#
# df[df[ , "data"] == "steles.bouclier", "sqll"]

# steles.bouclier <- sqll.me(data = "steles.bouclier", df)
steles.bouclier <- to.mercator(sqll.me(data = "steles.bouclier", df))
huelva <- to.mercator(sqll.me(data = "huelva", df))

# # steles
# steles.bouclier.sqll <- "SELECT site, ST_AsText(geom) as wkt FROM objets WHERE famille LIKE 'stele bouclier'"
# steles.bouclier.df <- dbGetQuery(con, steles.bouclier.sqll)
# steles.bouclier <- st_as_sf(steles.bouclier.df, wkt = "wkt")
# st_crs(steles.bouclier) <- 4326
# steles.bouclier <- st_transform(steles.bouclier, 3857)[1]
# # steles.bouclier <- st_transform(steles.bouclier, 3857)
# # steles.bouclier.xy <- st_coordinates(steles.bouclier)
#
# ## other sites
# # huelva
# huelva.sqll <- "SELECT site, ST_AsText(geom) as wkt FROM objets WHERE site LIKE 'Huelva' LIMIT 1"
# huelva.df <- dbGetQuery(con, huelva.sqll)
# huelva <- st_as_sf(huelva.df, wkt = "wkt")
# st_crs(huelva) <- 4326
# huelva <- st_transform(huelva, 3857)[1]
# #

# spatial
buff <- .5
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


