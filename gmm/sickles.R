library(Momocs)
library(stringr)
# library(RColorBrewer)

jpgs <- "C:/Users/Thomas Huet/Desktop/SICKLES_SHAPES/img" # read folder
lf <- list.files(jpgs, full.names=TRUE) # store to list
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
stack(sickles, borders = sickles$fac$cols)


# PCA
bot.f <- efourier(sickles, norm = F, nb.h = 1)
bot.p <- PCA(bot.f)
plot(bot.p,
     col = bot.p$fac$cols,
     cex = 1.5)
# cluster
CLUST(bot.f, palette =col_summer)
