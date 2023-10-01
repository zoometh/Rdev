# remotes::install_github("zoometh/outlineR")
# remotes::install_github("benmarwick/outliner")
library(ggplot2)
library(ggrepel)
library(sf)
library(rgdal)
library(raster)
# Create a raster
library(magick)
library(Momocs)
library(outlineR)

sampling <- T

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

inpath <- "./img/input_data"
jpgs <- "./img/out"
shp <- "./measurements/measurments.shp"
rasters <- "./img/out_cropped"


gmm_prepare <- F
if(gmm_prepare){
  separate_single_artefacts(inpath = inpath,
                            outpath = jpgs)
  # separate_single_artefacts_v1(inpath = inpath,
  #                              outpath = jpgs)
}

imgs <- list.files(rasters,
                   full.names = TRUE, pattern = "jpg")

measurements <- sf::st_read(shp)
rs <- raster::raster(imgs[1])

# crs(rs) <- CRS('+init=EPSG:27700')
# TODO: loop
meas.s <- measurements[measurements$num == "001" & measurements$anat == "s", ]
meas.p <- measurements[measurements$num == "001" & measurements$anat == "p", ]

# shoulder
geomdf.s <- st_coordinates(meas.s)
geomdf.s[ ,"Y"] <- extent(rs)@ymax + max(geomdf.s[ ,"Y"])
df.s <- st_as_sfc(st_as_text(st_linestring(geomdf.s)))

# pelvis
geomdf.p <- st_coordinates(meas.p)
geomdf.p[ ,"Y"] <- extent(rs)@ymax + max(geomdf.p[ ,"Y"])
df.p <- st_as_sfc(st_as_text(st_linestring(geomdf.p)))

# # sf method.. not used
# shape <- readOGR(dsn = "./measurements", layer = "measurments")
# shape <- shape[shape$num == "001", ]

rs.contour <- rasterToContour(rs)

# # method plot.. not used
# plot(rs.contour)
# plot(df.s, col = "red", add = TRUE)
# plot(df.p, col = "blue", add = TRUE)

rs.sf <- st_as_sf(rs.contour)
s.sf <- st_as_sf(df.s)
p.sf <- st_as_sf(df.p)

ggplot() +
  geom_sf(data = rs.sf) +
  geom_sf(data = s.sf, color = "blue") +
  geom_sf(data = p.sf, color = "red") +
  theme_bw()


# rs[] <- runif(ncell(rs))
# rs[rs > 0] <- 1
# rc <- rasterToContour(rs, levels = c(1))

quantile(rs)
plot(rs)

ct <- raster::rasterToPolygons(rast,
                               fun=inOne ,
                               dissolve=TRUE)
plot(rs)


# stats
measurements <- as.data.frame(measurements)
measurements$geometry <- NULL
# reshape
measurements <- reshape2::dcast(measurements, num ~ anat)

# scatter plot
ggplot(measurements, aes(p, s)) +
  stat_smooth(method = lm) +
  geom_point() +
  geom_text_repel(aes(p, s, label = num))

gmm <- 0
if(gmm){

  lf <- list.files(jpgs, full.names=TRUE) # store to list
  if(sampling){
    lf.samp <- sample(1:length(lf), 3)
    lf <- lf[lf.samp]
  }

  coo <- import_jpg(lf) # convert JPG to Coo
  sickles <- Out(coo)

  # panel.out <- paste0(path.data, "/out/1_panel.jpg")
  # jpeg(panel.out, height = fig.full.h, width = fig.full.w, units = "cm", res = 600)
  panel(sickles,
        names=TRUE,
        # names.col = sickles$fac$cols,
        # cols = sickles$fac$cols,
        # borders = sickles$fac$cols,
        cex.names = 0.5,
        # main = sickle.legend,
        cex.main = 0.8
  )
  # dev.off()
}
