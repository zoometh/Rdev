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

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

inpath <- "./img/input_data"
jpgs <- "./img/out"
shp <- "./measurements/measurments.shp"
rasters <- "./img/out_cropped"
margined <- "./img/out_cropped_margins"

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

measurements.df <- as.data.frame(measurements)


# rm uncomplete
rm.incomplete <- F
if(rm.incomplete){
  incomplete <- c("img1-042", "img1-044", "img1-045")
  measurements.done <- setdiff(measurements.done, incomplete)
  measurements.df <- measurements.df[!(measurements.df$lbl %in% incomplete), ]
}

measurements.df$geometry <- NULL
# reshape
measurements.df <- reshape2::dcast(measurements.df, lbl ~ anat, value.var = "length")
measurements.df$ratio <- measurements.df$p / measurements.df$s
# plot ordering on ratio
measurements.df <- measurements.df[with(measurements.df, order(-ratio)), ]
ordered.ratio <- measurements.df$lbl
min(measurements.df$ratio)
max(measurements.df$ratio)

myplots <- list()
ct <- 0
# sort by ...
sort.alphabetically <- sort(measurements.df$lbl)
sort.by.ratio <- rev(ordered.ratio)
for(i in sort.by.ratio){
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

# plot one
myplots[[which(sort.by.ratio == "img2-032")]]

# stats
stats <- T
if(stats){


  # TODO: scaling for scatterplot
  # measurements.img1 <- measurements[measurements$lbl]
  # # scatter plot
  # tit <- paste0("Scatterplot of pelvis lengths and shoulder lengths (p/s) of ",
  #               nrow(measurements.df),
  #               " complete bladelets")
  # gscat <- ggplot(measurements.df, aes(p, s)) +
  #   ggtitle(tit) +
  #   stat_smooth(method = lm) +
  #   geom_point() +
  #   geom_text_repel(aes(p, s, label = lbl)) +
  #   theme_bw()
  # ggsave(file = "./img/scatter.jpg",
  #        gscat,
  #        width = 10, height = 6)

  # (multi)modality
  data <- measurements.df$ratio
  LaplacesDemon::is.unimodal(data)
  LaplacesDemon::is.multimodal(data)
  LaplacesDemon::is.bimodal(data)
  mousetrap::bimodality_coefficient(data)
  diptest::dip.test(data)
  max(data)
  measurements.df[measurements.df$ratio == max(data), ]
  min(data)
  moments::skewness(data)
  # density
  tit <- paste0("Ratio pelvis / shoulder lengths (p/s) of ", nrow(measurements.df), " bladelets")
  gdens <- ggplot(measurements.df, aes(ratio)) +
    ggtitle(tit) +
    geom_density(fill = "lightgrey") +
    theme_bw()
  ggsave(file = "./img/density.jpg",
         gdens,
         width = 10, height = 6)
}





gmm <- 0
if(gmm){

  lf <- list.files(margined, full.names=TRUE) # store to list
  lf <- lf[!grepl("xml", lf)]
  if(FALSE){
    lf.samp <- sample(1:length(lf), 3)
    lf <- lf[lf.samp]
  }
  ## Add margins
  # library(magick)
  # margins <- 3  # Adjust the margin size as needed
  # for(i in lf){
  #   input_image <- image_read(i)
  #   output_image <- image_border(input_image, margins, color = "white")
  #   image_write(output_image, path = gsub("out_cropped", "out_cropped_margins", i))
  # }

  coo <- import_jpg(lf) # convert JPG to Coo
  sickles <- Out(coo)

  # panel.out <- paste0(path.data, "/out/1_panel.jpg")
  # jpeg(panel.out, height = fig.full.h, width = fig.full.w, units = "cm", res = 600)
  panel(sickles,
        names=TRUE,
        # names.col = sickles$fac$cols,
        # cols = sickles$fac$cols,
        borders = "black",
        cex.names = 0.5,
        # main = sickle.legend,
        cex.main = 0.8
  )
  # dev.off()

  tit <- paste0("Stack of ", length(sickles), " bladelets")
  pca.out <- paste0("./img/0_stack.jpg")
  jpeg(pca.out, height = 16, width = 8, units = "cm", res = 300)
  stacked <- sickles %>%
    coo_center %>%
    coo_scale %>%
    # coo_alignxax() %>%
    coo_slidedirection("up")
  stack(stacked,
        title = tit)
  dev.off()
        # borders = sickles$fac$cols,
        # title = sickle.legend
        # TODO: size title
  # )

  # PCA
  tit <- paste0("PCA of ", length(sickles), " bladelets")
  sickles.f <- efourier(sickles, norm = T, nb.h = 20)
  sickles.p <- PCA(sickles.f)
  pca.out <- paste0("./img/3_pca.jpg")
  jpeg(pca.out, height = 16, width = 16, units = "cm", res = 300)
  plot_PCA(sickles.p,
           title = tit)
  dev.off()

  # clustering
  nb.centers <- 2
  my.colors <- c("#0000ff", "#ff0000", "#00FF00", "#FFC0CB", "#FFA500", "#800080")
  my.colors.select <- my.colors[1:nb.centers]
  my.color.ramp <- colorRampPalette(my.colors.select)
  clus.out <- paste0("./img/4_clust.jpg")
  jpeg(clus.out, height = 20, width = 12, units = "cm", res = 300)
  CLUST(sickles.f,
        hclust_method = "ward.D2",
        k = 2,
        cex = 1/3,
        palette = my.color.ramp)
  dev.off()

  # Kmeans
  kmeans.out <- paste0("./img/5_kmeans.jpg")
  jpeg(kmeans.out, height = 16, width = 16, units = "cm", res = 300)
  KMEANS(sickles.p,
         centers = nb.centers,
         color = my.color.ramp)
  kmean <- KMEANS(sickles.p,
                  centers = nb.centers)
  kmeans.centers <- as.data.frame(kmean$centers)
  for(i in 1:nrow(kmeans.centers)){
    text(kmeans.centers[i, 1], kmeans.centers[i, 2], i)
  }
  dev.off()



}
