library(sf) # pour le spatial
library(ggplot2) # pour les graphiques
library(ggrepel) # pour écarter les labels
library(dplyr) # méthode

# data: n-columns
depots <- read.table('https://raw.github.com/zoometh/Rdev/master/data/data.csv',
                     header = T,
                     sep = ";",
                     row.names = 1)
symbols.col <- c("shape", "color", "x", "y")
depots.symbols <- depots[ , (names(depots) %in% symbols.col)]
depots.ca <- depots[ , !(names(depots) %in% symbols.col)]
symb_dd <- merge (depots.ca, depots.symbols, by = "row.names") # regroupe sur row.names
# créer le dendrogramme
dend1 <- depots.ca %>%
  dist %>% hclust(method = "complete")
# coupe en 3 groupes
groups <- as.data.frame(cutree(dend1, k = 3))
colnames(groups)[1] <- "group"
depots.group <- merge(depots, groups, by = "row.names")
# download FRA.zip (le shapefile)
temp <- tempfile()
download.file("https://raw.github.com/zoometh/Rdev/master/data/FRA.zip",
              destfile = temp, quiet = TRUE)
td <- tempdir()
lfiles <- unzip(temp, exdir = td) # tous les fichiers (.shp, .dbf, etc.)
FRA <- st_read(dsn = td, layer = "FRA_adm0")
# recoupe FRA sur l'emprise des depots +/- buffer
buff <-  0.5
xmax <- max(depots.group$x) + buff
xmin <- min(depots.group$x) - buff
ymax <- max(depots.group$y) + buff
ymin <- min(depots.group$y) - buff
m <- rbind(c(xmin,ymin), c(xmax,ymin), c(xmax,ymax), c(xmin,ymax), c(xmin,ymin))
roi <- st_polygon(list(m))
roi <- st_sfc(roi)
st_crs(roi) <- "+init=epsg:4326"
FRA.roi <- st_intersection(FRA, roi)
# titre
tit <- paste("CAH sur", nrow(depots.ca), "individus et", ncol(depots.ca), "variables")
# graphique
gcah.sp <- ggplot() +
  ggtitle(tit) +
  geom_sf(data = FRA.roi, fill = 'gray90') +
  geom_point(data = depots.group, aes(x = x, y = y, color = as.factor(group))) +
  geom_text_repel(data = depots.group,
                  aes(x = x, y = y, label = Row.names, color = as.factor(group)),
                  cex = 2,
                  segment.size = 0.1,
                  segment.alpha = 0.5) +
  theme(plot.title = element_text(size = 8, face = "bold")) +
  theme_bw() +
  theme(legend.position="bottom") +
gcah.sp

# sauver
png("out/cah_sp_depots.png", width = 12, height = 10, units = "cm", res = 300)
gcah.sp
dev.off()
shell.exec(paste0(getwd(), "/out/cah_sp_depots.png"))
