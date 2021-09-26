# PPA: point pattern analysis
library(spatstat) # pour les statistiques spatiales
library(sp)
library(sf)
library(dplyr) # méthode

# data: n-columns
SRID <- CRS("+proj=longlat +datum=WGS84")
depots <- read.table('https://raw.github.com/zoometh/Rdev/master/data/data.csv',
                     header = T,
                     sep = ";",
                     row.names = 1)

# aire d'étude
buff <-  0.5
xmin <- min(depots$x) - buff
xmax <- max(depots$x) + buff
ymin <- min(depots$y) - buff
ymax <- max(depots$y) + buff
m <- rbind(c(xmin,ymin), c(xmax,ymin), c(xmax,ymax), c(xmin,ymax), c(xmin,ymin))
roi <- st_polygon(list(m))
roi <- st_sfc(roi)
st_crs(roi) <- "+init=epsg:4326"
temp <- tempfile()
download.file("https://raw.github.com/zoometh/Rdev/master/data/FRA.zip",
              destfile = temp, quiet = TRUE)
td <- tempdir()
lfiles <- unzip(temp, exdir = td) # tous les fichiers (.shp, .dbf, etc.)
FRA <- st_read(dsn = td, layer = "FRA_adm0")
FRA.roi <- st_intersection(FRA, roi)
# depots
depots.xy <- as.matrix(depots[ , c("x", "y")])
depots.pts <- st_multipoint(depots.xy)
depots.sf <- st_sfc(depots.pts)
st_crs(depots.sf) <- "+init=epsg:4326"
# -> ppp
depots.pts.fra <- st_transform(depots.sf, 2154) # projette en France
FRA.roi.fra <- st_transform(FRA.roi, 2154)
w  <- as.owin(FRA.roi.fra)
depots.ppp <- ppp(st_coordinates(depots.pts.fra)[ , "X"],
                  st_coordinates(depots.pts.fra)[ , "Y"],
                  window = w)
# pour une revue des méthodes de PPA (Point Pattern Analysis):
# v. https://mgimond.github.io/Spatial/point-pattern-analysis-in-r.html#density-based-analysis-1
L <- Lest(depots.ppp, correction = "Ripley")
Q <- quadratcount(depots.ppp, nx = 3, ny = 3)
Q.d <- intensity(Q)
K1 <- density(depots.ppp)
ANN <- apply(nndist(depots.ppp, k=1:depots.ppp$n), 2, FUN=mean)
ann.p <- mean(nndist(depots.ppp, k=1))
n     <- 599L               # Number of simulations
ann.r <- vector(length = n) # Create an empty object to be used to store simulated ANN values
for (i in 1:n){
  rand.p   <- rpoint(n=depots.ppp$n, win=w)  # Generate random point locations
  ann.r[i] <- mean(nndist(rand.p, k=1))  # Tally the ANN values
}

png("out/ppa_depots_spat.png", width = 20, height = 20, units = "cm", res = 300)
par(mfrow = c(3, 3))
par(mar = c(1, 1, 1, 1))
# 1
plot(depots.ppp, cols=rgb(0,0,0,.2), pch=20, main = "Observed")
# 2
plot(depots.ppp, pch=20, cols = "grey70", main = "Count")  # Plot points
plot(Q, add=TRUE)  # Add quadrat grid
# 3
plot(K1, main = "Density", las=1)
contour(K1, add=TRUE)
# 4
plot(ANN ~ eval(1:depots.ppp$n), type="b", main="ANN distribution" , las=1)
# 6
plot(L, xlab="d (m)", ylab="K(d)", main = "L-Besag")
# 7
plot(rand.p, pch=16, cols=rgb(0,0,0,0.5), main = "Random")
# 8
hist(ann.r, main="Observed vs Random", las=1, breaks = 40,
     col="bisque", xlim = range(ann.p, ann.r))
abline(v=ann.p, col="blue")
# sauver
dev.off()
shell.exec(paste0(getwd(), "/out/ppa_depots_spat.png"))


