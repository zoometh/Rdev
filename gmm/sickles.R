library(Momocs)
library(stringr)
# library(RColorBrewer)

sampling <- T

jpgs <- "C:/Rprojects/_coll/SICKLES_SHAPES/img" # read folder
lf <- list.files(jpgs, full.names=TRUE) # store to list
if(sampling){
  lf.samp <- sample(1:length(lf), 10)
  lf <- lf[lf.samp]
}
coo <- import_jpg(lf) # convert JPG to Coo
sickles <- Out(coo) # convert Coo to Outlines
sites <- substr(names(sickles), 1, 3) # extract 3 first letters (site name)
df.obj <- data.frame(object=names(sickles), # store object name and site name
                     site=substr(names(sickles), 1, 3))
sites.uni <- unique(df.obj$site) # get unique site names
# get one color by site name
n <- length(sites.uni)
color.uni <- rainbow(n, s = 1, v = 1,
                     start = 0, end = max(1, n - 1)/n,
                     alpha = 1)
# gather site name with colors
df.colors <- data.frame(site=sites.uni,
                        cols=color.uni)
# gather objects shapes, objects names, site names, colors in a single df
df.obj.col <- merge(df.obj, df.colors, all.x = TRUE, by = "site" )
# store this df as a classifier
sickles$fac <- df.obj.col
# panel
panel(sickles,
      names=TRUE,
      # names.col = sickles$fac$cols,
      cols = sickles$fac$cols,
      borders = sickles$fac$cols)
# stack
stack(sickles,
      borders = sickles$fac$cols,
      meanshape = T)
# standardized
sickles %>%
  coo_center %>% coo_scale %>%
  coo_alignxax() %>% coo_slidedirection("up") %T>%
  print() %>% stack()
# PCA
bot.f <- efourier(sickles, norm = F, nb.h = 20)
bot.p <- PCA(bot.f)
plot(bot.p,
     col = bot.p$fac$cols,
     cex = 1.5)
# cluster
CLUST(bot.f)
# KMEANS
nb.centers <- 5
KMEANS(bot.p, centers = nb.centers)
