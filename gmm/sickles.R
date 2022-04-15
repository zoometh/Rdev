library(Momocs)
library(stringr)
library(openxlsx)
library(ggplot2)
library(sf)
library(dplyr)
library(reshape2)
library(NbClust)
# library(RColorBrewer)

sampling <- F

path.data <- "C:/Rprojects/_coll/SICKLES_SHAPES" # root folder
df.coords <- read.xlsx(paste0(path.data, "/COORD.xlsx"))
jpgs <- paste0(path.data, "/img")  # img folder
lf <- list.files(jpgs, full.names=TRUE) # store to list
if(sampling){
  lf.samp <- sample(1:length(lf), 50)
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
sickle.legend <- paste0("shapes panel of ", n.sickles, " sickle inserts from ", n.sites, " sites")
# sizes for the outputs
fig.full.h <- 15 ; fig.full.w <- 17
fig.half.h <- 07 ; fig.half.w <- 09
k.max <- 15 # iterations

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# item analysis
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# panel
panel.out <- paste0(path.data, "/1_panel.jpg")
jpeg(panel.out, height = fig.full.h, width = fig.full.w, units = "cm", res = 600)
panel(sickles,
      names=TRUE,
      # names.col = sickles$fac$cols,
      cols = sickles$fac$cols,
      borders = sickles$fac$cols,
      cex.names = 0.5,
      main = sickle.legend,
      cex.main = 0.8
)
dev.off()

# standardized stack
stack.out <- paste0(path.data, "/2_stack.jpg")
jpeg(stack.out, height = fig.half.h, width = fig.half.w, units = "cm", res = 600)
stacked <- sickles %>%
  coo_center %>% # coo_scale %>%
  coo_alignxax() %>% coo_slidedirection("up")
stack(stacked,
      borders = sickles$fac$cols,
      title = sickle.legend
)
dev.off()

# PCA
sickles.f <- efourier(sickles, norm = F, nb.h = 20)
sickles.p <- PCA(sickles.f)
pca.out <- paste0(path.data, "/3_pca.jpg")
jpeg(pca.out, height = fig.full.h, width = fig.full.w, units = "cm", res = 600)
plot(sickles.p,
     # col = sickles.p$fac$cols,
     labelspoints = T,
     cex = 1,
     title = sickle.legend
)
dev.off()

# clustering
# TODO: colors
clus.out <- paste0(path.data, "/4_clust.jpg")
jpeg(clus.out, height = fig.full.h, width = fig.full.w, units = "cm", res = 600)
CLUST(sickles.f,
      hclust_method = "ward.D2")
dev.off()

# optimal number of clusters - items
nb.clust <- NbClust(data = sickles.p$x,
                    distance = "euclidean",
                    method = "ward.D2",
                    index = c("gap", "silhouette"))
nb.clust.opt <- nb.clust$Best.nc[1] # best nb of cluster
wss <- sapply(1:k.max,
              function(k){kmeans(sickles.p$x, k, nstart = 50, iter.max = 15)$tot.withinss})
clus.best.out <- paste0(path.data, "/4_1_clust.jpg")
jpeg(clus.best.out, height = fig.full.h, width = fig.full.w, units = "cm", res = 600)
plot(1:k.max, wss,
     type="b", pch = 19, frame = FALSE,
     xlab="Number of clusters K (red line: best number)",
     ylab="Total within-clusters sum of squares")
abline(v = nb.clust.opt, col = "red", lwd = 2)
dev.off()

# KMEANS
# TODO: colors
nb.centers <- nb.clust.opt
kmeans.out <- paste0(path.data, "/5_kmeans.jpg")
jpeg(kmeans.out, height = fig.full.h, width = fig.full.w, units = "cm", res = 600)
KMEANS(sickles.p,
       centers = nb.centers)
kmean <- KMEANS(sickles.p,
                centers = nb.centers)
kmeans.centers <- as.data.frame(kmean$centers)
for(i in 1:nrow(kmeans.centers)){
  text(kmeans.centers[i, 1], kmeans.centers[i, 2], i)
}
dev.off()

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# site analysis
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## spatial
df.member <- data.frame(names = names(kmean$cluster),
                        membership = as.integer(kmean$cluster))
df.nm.col <- merge(df.names, df.obj.col, by = "num")
df.nm.col.mbr <- merge(df.member, df.nm.col, by = "names")
df.nm.col.mbr.spat <- merge(df.nm.col.mbr, df.coords, by = "code")
# summing sickles by sites and cluster
df.spat.grp <- df.nm.col.mbr.spat[ , c("code", "membership", "long", "lat")]
df.spat.grp <- df.spat.grp %>%
  count(code, membership, lat, long)
# bbox
buff <- .5
xmin <- min(df.spat.grp$long) + buff
ymin <- min(df.spat.grp$lat) - buff
xmax <- max(df.spat.grp$long) + buff
ymax <- max(df.spat.grp$lat) - buff
m <- rbind(c(xmin,ymin), c(xmax,ymin), c(xmax,ymax), c(xmin,ymax), c(xmin,ymin))
roi <- st_polygon(list(m))
roi <- st_sfc(roi)
st_crs(roi) <- "+init=epsg:4326"
bck_admin.shp <- st_read(dsn = path.data, layer = "admin_background")
bck_admin.roi <- st_intersection(bck_admin.shp, roi)
spat.out <- paste0(path.data, "/6_map.jpg")
gg.out <- ggplot(df.spat.grp) +
  facet_grid(membership ~ .) +
  geom_sf(data = bck_admin.roi) +
  geom_point(data = df.spat.grp, aes (x = long, y = lat, size = n)) +
  theme_bw()
ggsave(spat.out, gg.out, width = 8, height = 21)

# CA on sites
df.melt <- df.nm.col.mbr.spat[ , c("code", "membership")]
df.unmelt <- dcast(df.melt, code ~ membership)
rownames(df.unmelt) <- df.unmelt$code
df.unmelt$code <- NULL
site.ca.out <- paste0(path.data, "/7_sites_ca.jpg")
jpeg(site.ca.out, height = fig.full.h, width = fig.full.w, units = "cm", res = 600)
res.sites.ca <- FactoMineR::CA(df.unmelt, graph = F)
plot(res.sites.ca)
dev.off()

# HCLUST on sites
site.hclust.out <- paste0(path.data, "/8_sites_hclust.jpg")
jpeg(site.hclust.out, height = fig.full.h, width = fig.full.w, units = "cm", res = 600)
df.unmelt %>%  scale %>%
  dist %>% hclust %>% plot
dev.off()




