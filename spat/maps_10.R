# plot from DB "mailhac" with Stamen backgrounds


library(RPostgreSQL)
library(sf)
library(ggmap)
library(ggplot2)


# convert to Mercador
items <- function(sqll, con = con, table = "objets"){
  if(table == "objets"){
    sqll.wkt <- "SELECT site, ST_AsText(geom) as wkt FROM objets WHERE "
  }
  if(table == "geologie"){
    sqll.wkt <- "SELECT lbl, ST_AsText(geom) as wkt FROM geologie_ WHERE "
  }
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
                 bck.col = NA,
                 bck.alpha = .7,
                 family = NA,
                 inds = NA,
                 buff = 3,
                 zoom = 6,
                 maptype = "terrain-background",
                 family.cex = 1,
                 family.pch = 16,
                 family.col = NA,
                 inds.cex = 1.5,
                 inds.pch = 16,
                 inds.color = NA,
                 inds.text = T,
                 print.colors = F
){
  print("   .. starts")
  if(!is.na(inds)){
    roi.extent.merc <- append(inds, family)
    xy <- inds[[1]]
  } else {
    roi.extent.merc <- family
    xy <- family[[1]]
  }
  # xy <- family[[1]]
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
  colors.bcks <- RColorBrewer::brewer.pal(length(bck) + 1, "Set2")
  # avoid the first green because of stamen bck
  colors.bcks <- colors.bcks[2:length(colors.bcks)]
  print("   .. plot background")
  if(!is.na(bck)){
    # exist bck
    plot(bck[[1]],
         main = title,
         col = scales::alpha(colors.bcks[1], bck.alpha),
         border = "#00000070",
         bgMap = stamenbck,
         xlim = st_bbox(roi.extent.merc.comb)[c(1, 3)],
         ylim = st_bbox(roi.extent.merc.comb)[c(2, 4)],
         reset = FALSE)
    # xy.family <- family[[1]]
    if(length(bck) > 1){
      for(i in seq(2, length(bck))){
        indi <- bck[[i]]
        plot(indi,
             col = scales::alpha(colors.bcks[i], bck.alpha),
             border = "#00000070",
             add = TRUE)
      }
    }
  } else {
    if(is.na(family.col)){
      family.col <- c("#4d4d4d", "#777777", "#0a0a0a")
    }
    plot(family[[1]],
         main = title,
         col = family.col[1],
         bgMap = stamenbck,
         xlim = st_bbox(roi.extent.merc.comb)[c(1, 3)],
         ylim = st_bbox(roi.extent.merc.comb)[c(2, 4)],
         reset = FALSE)
  }
  # xy.family <- family[[1]]
  print("   .. plot family")
  if(length(family) > 0){
    for(i in seq(1, length(family))){
      indi <- family[[i]]
      plot(indi,
           cex = family.cex,
           pch = family.pch,
           col = family.col[i],
           add = TRUE)
    }
  }
  if(!is.na(inds)){
    print("   .. plot inds")
    if(is.na(inds.color)){
      colors.inds <- RColorBrewer::brewer.pal(length(inds), "Set1")
    } else {
      colors.inds <- c(rep(inds.color, 7))
    }
    for(i in seq(1, length(inds))){
      indi <- inds[[i]]
      plot(indi,
           cex = inds.cex,
           pch = inds.pch,
           col = colors.inds[i],
           add = TRUE)
      if(inds.text){
        text(x = sf::st_coordinates(indi)[, 1],
             y = sf::st_coordinates(indi)[, 2],
             col = colors.inds[i],
             labels = indi$site,
             pos = 3)
      }
    }
  }
  if(print.colors){
    print(paste0("bck colors: ", colors.bcks))
    print(paste0("inds colors: ", colors.inds))
  }
}

spat_centroid <- function(gr){
  # centroid of a vector of steles
  gr.sf <- items(paste0("site LIKE '", gr[1],"' LIMIT 1"))
  for(i in gr){
    x <- items(paste0("site LIKE '", i,"' LIMIT 1"))
    gr.sf <- rbind(gr.sf, x)
  }
  gr.centroid <- st_centroid(st_union(gr.sf))
  return(gr.centroid)
}

gr.B <- c('Arroyo Bona%', 'Baracal', '%Carneril%', 'Ribera%', 'Foios', 'Granja de Ces%', 'Ibahern%', 'Robledillo%')
gr.BO <- c('Aldea%', 'Brozas', 'Pedra da Atalaia', 'Quintana%', 'Ana de Trujillo%', 'Martin de Trevejo%', 'Torrejon Rubio', 'Tres Arroyos', 'Valencia de Alcantara')
gr.A <- c('Ategua', 'Almargen', 'Herencias%', 'Setefilla', 'Zarza de%')

gr.B.centroid <- spat_centroid(gr.B)
gr.BO.centroid <- spat_centroid(gr.BO)
gr.A.centroid <- spat_centroid(gr.A)

mp.ambre <- items("mp = 'ambre'")

steles.bouclier <- items("famille LIKE 'stele bouclier'")
steles.bouclier.gr1 <- items("site LIKE IN ")

baracal <- items("site LIKE 'Baracal' LIMIT 1")
vilarmaior <- items("site LIKE '%Maior%' LIMIT 1")
foios <- items("site LIKE 'Foios' LIMIT 1")
appleby <- items("site LIKE 'Appleby' LIMIT 1")
roesnoen <- items("site LIKE 'Roesnoen' LIMIT 1")

bernieres <- items("site LIKE 'Bernieres' LIMIT 1")
zarzamontsanchez <- items("site LIKE 'Zarza de Montanchez' LIMIT 1")
santanatrujillo <- items("site LIKE 'Ana de %' LIMIT 1")

substantio <- items("site LIKE 'Substantio' LIMIT 1")
valpalmas <- items("site LIKE 'Valpalmas'")
belalcazar <-items("site LIKE 'Belalcazar'")
telhado <-items("site LIKE 'Telhado'")

# carneril <- items("site LIKE '%Carneril%' LIMIT 1")
# cespedes <- items("site LIKE 'Granja de Cespedes' LIMIT 1")


brozas <- items("site LIKE 'Brozas' LIMIT 1")
huelva <- items("site LIKE 'Huelva' LIMIT 1")
cloonbrin <- items("site LIKE 'Cloonbrin' LIMIT 1")
delphes <- items("site LIKE 'Delphes' LIMIT 1")
froslunda <- items("site LIKE 'Froslunda' LIMIT 1")
saidda <- items("site LIKE 'Sa Idda' LIMIT 1")
bangor <- items("site LIKE 'Bangor' LIMIT 1")


ategua <- items("site LIKE 'Ategua' LIMIT 1")
aldeanueva <- items("site LIKE 'Aldea%Barto%' LIMIT 1")
frannarp <- items("site LIKE 'Frann%' LIMIT 1")
fuentescantos <- items("site LIKE 'Fuente%Canto%' LIMIT 1")

canchoroano <- items("site LIKE 'Cancho Roano' LIMIT 1")
setefilla <- items("site LIKE 'Setefilla' LIMIT 1")
salen <- items("site LIKE 'Salen' LIMIT 1")
cortijoreina <- items("site LIKE 'Cortijo%Reina' LIMIT 1")

uluburun <- items("site LIKE 'Uluburun' LIMIT 1")
cerromuriano <- items("site LIKE 'Cerro Muriano' LIMIT 1")


kville <- items("site LIKE 'Kville' LIMIT 1")
capote <- items("site LIKE 'Capote' LIMIT 1")
cabeza.4 <- items("numero LIKE 'Cabeza De%4%'")
# - - - - - - - - - - - - - - - - - -
aclasser <- items("famille LIKE '%classe%'")
diademe <- items("famille LIKE '%diademe%'")
alentejo <- items("famille LIKE '%alentejo%'")
pedreirinha <- items("site LIKE 'Pedreirinha'")
corse <- items("famille LIKE '%corse%'")
istantari <- items("site LIKE '%Stantar%' LIMIT 1")
penatu <- items("site LIKE 'Pena Tu' LIMIT 1")
tabuyo <- items("site LIKE 'Tabuyo%' LIMIT 1")
colado <- items("site LIKE 'Collado de S%' LIMIT 1")
mamoiada <- items("site LIKE 'Mamoi%' LIMIT 1")

# Geol
ipb <- items("lbl LIKE '%IPB%' LIMIT 1", table = "geologie")
omz <- items("lbl LIKE '%OMZ%' LIMIT 1", table = "geologie")

# epees

epee.huelva <- items("type like 'epee' and chr_1 like 'Huelva'")


# inds <- list(tabuyo, penatu)
spat(title = "",
     # bck = list(omz),
     family = list(steles.bouclier),
     family.col = c("#4d4d4d", "#000000"),
     family.cex = .8,
     # inds = NA,
     # inds = list(cerromuriano),
     inds = list(foios, appleby, roesnoen),
     # inds = list(gr.B.centroid, gr.BO.centroid, gr.A.centroid),
     #inds.color = c("#000000", "#ff0000", "#0000ff"),
     inds.text = F,
     zoom = 5,
     buff = 3,
     print.colors = T)

# geologie
JPN <- st_read("D:/Projet Art Rupestre_1/Sources/2_PAYS/Espagne-Portugal/GEOL/IPB_afr_modified.shp")
st_crs(JPN) <- 4326
JPN.merc <- st_transform(JPN, 3857)[1]
plot(JPN.merc,
     col = "grey",
     border  = "NA",
     add = TRUE)

centroid <- st_centroid(steles.bouclier)

coordinates(steles.bouclier)
