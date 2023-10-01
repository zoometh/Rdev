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
# library(outlineR)

sampling <- T

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

inpath <- "./img/input_data"
jpgs <- "./img/out"
shp <- "./measurements/measurments.shp"
rasters <- "./img/out_cropped"


gmm_prepare <- T
if(gmm_prepare){
  separate_single_artefacts(inpath = inpath,
                            outpath = jpgs)
  # separate_single_artefacts_v1(inpath = inpath,
  #                              outpath = jpgs)
}

imgs <- list.files(rasters,
                   full.names = TRUE, pattern = "jpg")

measurements <- sf::st_read(shp)
measurements$lbl <- paste0(measurements$img, "-", measurements$num)
measurements.done <- unique(measurements$lbl)

# checks #######################
table(measurements$lbl)
length(unique(measurements$lbl))
sum(measurements$anat == 's')
sum(measurements$anat == 'p')
max(measurements$length)
min(measurements$length)
###############################

# img.done <- gsub("^0.", "", measurements.done)
# rs <- raster::raster(imgs[1])

# crs(rs) <- CRS('+init=EPSG:27700')

# rm uncomplete
rm.incomplete <- T
if(rm.incomplete){
  incomplete <- c("img1-042", "img1-044", "img1-045")
  measurements.done <- setdiff(measurements.done, incomplete)
}



myplots <- list()
ct <- 0
for(i in sort(measurements.done)){
  # i <- "img1-001"
  print(i)
  ct <- ct + 1
  raster.num <- paste0(rasters, "/", i, ".jpg")
  rs <- raster::raster(raster.num)
  # shoulder
  meas.s <- measurements[measurements$lbl == i & measurements$anat == "s", ]
  geomdf.s <- st_coordinates(meas.s)
  geomdf.s[ ,"Y"] <- extent(rs)@ymax + geomdf.s[ ,"Y"]
  df.s <- st_as_sfc(st_as_text(st_linestring(geomdf.s)))
  # pelvis
  meas.p <- measurements[measurements$lbl == i & measurements$anat == "p", ]
  geomdf.p <- st_coordinates(meas.p)
  geomdf.p[ ,"Y"] <- extent(rs)@ymax + geomdf.p[ ,"Y"]
  df.p <- st_as_sfc(st_as_text(st_linestring(geomdf.p)))
  # get contour
  rs.contour <- rasterToContour(rs)
  # convert to sf
  rs.sf <- st_as_sf(rs.contour)
  s.sf <- st_as_sf(df.s)
  p.sf <- st_as_sf(df.p)
  # plot
  gg <- ggplot() +
    ggtitle(i) +
    geom_sf(data = rs.sf) +
    geom_sf(data = s.sf, color = "blue") +
    geom_sf(data = p.sf, color = "red") +
    theme_bw()
  myplots[[ct]] <- gg  # add each plot into plot list
}

margin = theme(plot.margin = unit(c(0, 0, 0, 0), "cm"))
ggsave(file = "./img/measurements.jpg",
       gridExtra::arrangeGrob(grobs = lapply(myplots, "+", margin), ncol = 12),
       width = 28, height = 18)

# stats
stats <- T
if(stats){
  measurements <- as.data.frame(measurements)
  measurements <- measurements[!(measurements$lbl %in% incomplete), ]
  measurements$geometry <- NULL
  # reshape
  measurements <- reshape2::dcast(measurements, lbl ~ anat, value.var = "length")
  measurements$ratio <- measurements$p / measurements$s
  # plot ordering on ratio
  measurements <- measurements[with(measurements, order(-ratio)), ]

  # TODO: scaling
  # measurements.img1 <- measurements[measurements$lbl]

  # scatter plot
  tit <- paste0("Scatterplot of pelvis lengths and shoulder lengths (p/s) of ",
                nrow(measurements),
                " complete bladelets")
  gscat <- ggplot(measurements, aes(p, s)) +
    ggtitle(tit) +
    stat_smooth(method = lm) +
    geom_point() +
    geom_text_repel(aes(p, s, label = lbl)) +
    theme_bw()
  ggsave(file = "./img/scatter.jpg",
         gscat,
         width = 10, height = 6)
  # density
  tit <- paste0("Ratio pelvis / shoulder lengths (p/s) of ", nrow(measurements), " complete bladelets")
  gdens <- ggplot(measurements, aes(ratio)) +
    ggtitle(tit) +
    geom_density() +
    theme_bw()
  ggsave(file = "./img/density.jpg",
         gdens,
         width = 10, height = 6)
}





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
