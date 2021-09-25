# library(FactoMineR) # pour les analyses factorielles
library(ggdendro) # pour les dendrogrammes
library(dendextend) # pour les dendrogrammes
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
depots.symbols$ord <- 1:nrow(depots.symbols) # utile pour réordonner
depots.ca <- depots[ , !(names(depots) %in% symbols.col)]
symb_dd <- merge (depots.ca, depots.symbols, by = "row.names") # regroupe sur row.names
# créer le dendrogramme
dend1 <- depots.ca %>%
  dist %>% hclust(method = "complete")
# coupe en 3 groupes
groups <- cutree(dend1, k = 3)
