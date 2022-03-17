library(Momocs)
library(stringr)
library(openxlsx)
library(ggplot2)
library(sf)
# library(RColorBrewer)

sampling <- T

path.data <- "C:/Rprojects/_coll/SICKLES_SHAPES/" # root folder
df.coords <- read.xlsx(paste0(path.data, "COORD.xlsx"))
jpgs <- paste0(path.data, "img")  # img folder
lf <- list.files(jpgs, full.names=TRUE) # store to list
if(sampling){
  lf.samp <- sample(1:length(lf), 20)
  lf <- lf[lf.samp]
}
coo <- import_jpg(lf) # convert JPG to Coo
sickles <- Out(coo) # convert Coo to Outlines
# color by sites
sites <- substr(names(sickles), 1, 3) # extract 3 first letters (site name)
df.obj <- data.frame(num = names(sickles), # store object name and site name
                     code = substr(names(sickles), 1, 3))
sites.uni <- unique(df.obj$code) # get unique site names
# get one color by site name
n <- length(sites.uni)
color.uni <- rainbow(n, s = 1, v = 1,
                     start = 0, end = max(1, n - 1)/n,
                     alpha = 1)
# gather site name with colors
df.colors <- data.frame(code = sites.uni,
                        cols = color.uni)
# names
sickles.names <- names(sickles)
# short names
names(sickles) <- 1:length(sickles)
df.names <- data.frame(names = names(sickles),
                       num = sickles.names)
# gather objects shapes, objects names, site names, colors in a single df
df.obj.col <- merge(df.obj, df.colors, all.x = TRUE, by = "code" )
# store this df as a classifier
sickles$fac <- df.obj.col
n.sites <- length(sites.uni)
n.sickles <- length(sickles)
# panel
panel.out <- paste0(path.data, "1_panel.jpg")
jpeg(panel.out, height = 15, width = 17,units = "cm", res = 600)
panel(sickles,
      names=TRUE,
      # names.col = sickles$fac$cols,
      cols = sickles$fac$cols,
      borders = sickles$fac$cols,
      cex.names = 0.5,
      main = paste0("shapes panel of ", n.sickles, " sickle inserts of ", n.sites, " sites"),
      cex.main = 0.8
)
dev.off()

# # stack
# stack(sickles,
#       borders = sickles$fac$cols,
#       meanshape = T)
# standardized
stack.out <- paste0(path.data, "2_stack.jpg")
jpeg(stack.out, height = 15, width = 17,units = "cm", res = 600)
stacked <- sickles %>%
  coo_center %>% coo_scale %>%
  coo_alignxax() %>% coo_slidedirection("up")
stack(stacked,
      borders = sickles$fac$cols,
      main = paste0("shapes stack of ", n.sckins, " sickle inserts of ", n.sites, " sites"),)
dev.off()

# PCA
sickles.f <- efourier(sickles, norm = F, nb.h = 20)
sickles.p <- PCA(sickles.f)
pca.out <- paste0(path.data, "3_pca.jpg")
jpeg(pca.out, height = 15, width = 17, units = "cm", res = 600)
plot(sickles.p,
     col = sickles.p$fac$cols,
     labelspoints = T,
     cex = 1)
dev.off()

# cluster
# TODO: colors
clus.out <- paste0(path.data, "4_clust.jpg")
jpeg(clus.out, height = 15, width = 17, units = "cm", res = 600)
CLUST(sickles.f,
      palette = pal_div_BrBG(5))
dev.off()

# KMEANS
# TODO: colors
nb.centers <- 5
kmeans.out <- paste0(path.data, "5_kmeans.jpg")
jpeg(kmeans.out, height = 15, width = 17, units = "cm", res = 600)
kmean <- KMEANS(sickles.p,
                centers = nb.centers)
kmean
dev.off()

## spatial
df.member <- data.frame(names = names(kmean$cluster),
                        membership = as.integer(kmean$cluster))
# head(df.obj.col)
# head(df.nm.col.mbr)
# head(df.coords)
df.nm.col <- merge(df.names, df.obj.col, by = "num")
df.nm.col.mbr <- merge(df.member, df.nm.col, by = "names")
df.nm.col.mbr.spat <- merge(df.nm.col.mbr, df.coords, by = "code")



# bbox
buff <- .5
xmin <- min(df.nm.col.mbr.spat$long) + buff
ymin <- min(df.nm.col.mbr.spat$lat) - buff
xmax <- max(df.nm.col.mbr.spat$long) + buff
ymax <- max(df.nm.col.mbr.spat$lat) - buff
m <- rbind(c(xmin,ymin), c(xmax,ymin), c(xmax,ymax), c(xmin,ymax), c(xmin,ymin))
roi <- st_polygon(list(m))
roi <- st_sfc(roi)
st_crs(roi) <- "+init=epsg:4326"
bck_admin.shp <- st_read(dsn = path.data, layer = "admin_background")
# TODO: intersects
# bck_admin.roi <- st_intersects(bck_admin.shp, roi)
spat.out <- paste0(path.data, "6_map.jpg")
gg.out <- ggplot(df.nm.col.mbr.spat) +
  facet_grid(membership ~ .) +
  geom_sf(data = bck_admin.shp) +
  geom_point(data = df.nm.col.mbr.spat, aes (x = long, y = lat), size = 2) +
  xlim(xmin - .5, xmax + .5) +
  ylim(ymin - .5, ymax + .5) +
  # geom_sf(data = ws_roi.shp, fill = 'red') +
  theme_bw()
ggsave(spat.out, gg.out, width = 8, height = 21)


